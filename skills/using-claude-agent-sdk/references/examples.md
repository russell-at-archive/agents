# Claude Agent SDK: Examples

## Contents

- [One-shot task with built-in tools](#one-shot-task-with-built-in-tools)
- [Multi-turn conversation with ClaudeSDKClient](#multi-turn-conversation-with-claudesdkclient)
- [Read-only analysis agent](#read-only-analysis-agent)
- [File-editing agent with acceptEdits](#file-editing-agent-with-acceptedits)
- [Custom tool (in-process MCP)](#custom-tool-in-process-mcp)
- [PreToolUse hook: block dangerous commands](#pretooluse-hook-block-dangerous-commands)
- [PostToolUse hook: audit log](#posttooluse-hook-audit-log)
- [PreToolUse hook: modify tool input](#pretooluse-hook-modify-tool-input)
- [Notification hook: forward to Slack](#notification-hook-forward-to-slack)
- [Subagents for parallel work](#subagents-for-parallel-work)
- [Session capture and resume](#session-capture-and-resume)
- [Session forking](#session-forking)
- [MCP server (external subprocess)](#mcp-server-external-subprocess)
- [Error handling](#error-handling)

---

## One-shot task with built-in tools

```python
import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions, AssistantMessage, TextBlock, ResultMessage

async def main():
    async for message in query(
        prompt="Find all TODO comments and list them",
        options=ClaudeAgentOptions(allowed_tools=["Read", "Glob", "Grep"]),
    ):
        if isinstance(message, AssistantMessage):
            for block in message.content:
                if isinstance(block, TextBlock):
                    print(block.text)
        elif isinstance(message, ResultMessage):
            print(f"Cost: ${message.total_cost_usd:.4f}")

asyncio.run(main())
```

```typescript
import { query } from "@anthropic-ai/claude-agent-sdk";

for await (const message of query({
  prompt: "Find all TODO comments and list them",
  options: { allowedTools: ["Read", "Glob", "Grep"] }
})) {
  if (message.type === "assistant") {
    for (const block of message.content) {
      if (block.type === "text") console.log(block.text);
    }
  }
  if (message.type === "result") console.log(`Cost: $${message.total_cost_usd?.toFixed(4)}`);
}
```

---

## Multi-turn conversation with ClaudeSDKClient

```python
import asyncio
from claude_agent_sdk import ClaudeSDKClient, ClaudeAgentOptions, AssistantMessage, TextBlock

async def main():
    options = ClaudeAgentOptions(allowed_tools=["Read", "Edit", "Glob", "Grep"])

    async with ClaudeSDKClient(options=options) as client:
        await client.query("Analyze the authentication module")
        async for msg in client.receive_response():
            if isinstance(msg, AssistantMessage):
                for block in msg.content:
                    if isinstance(block, TextBlock):
                        print(block.text)

        # Full context from first turn is preserved automatically
        await client.query("Now refactor it to use JWT tokens")
        async for msg in client.receive_response():
            if isinstance(msg, AssistantMessage):
                for block in msg.content:
                    if isinstance(block, TextBlock):
                        print(block.text)

asyncio.run(main())
```

---

## Read-only analysis agent

```python
import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions

async def main():
    async for message in query(
        prompt="Review this codebase for security issues",
        options=ClaudeAgentOptions(
            allowed_tools=["Read", "Glob", "Grep"],
            # No Write, Edit, or Bash — truly read-only
        ),
    ):
        print(message)

asyncio.run(main())
```

---

## File-editing agent with acceptEdits

```python
import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions

async def main():
    async for message in query(
        prompt="Fix all type errors in the src/ directory",
        options=ClaudeAgentOptions(
            allowed_tools=["Read", "Edit", "Glob", "Grep", "Bash"],
            permission_mode="acceptEdits",  # auto-approve file edits
        ),
    ):
        print(message)

asyncio.run(main())
```

---

## Custom tool (in-process MCP)

```python
import asyncio
from claude_agent_sdk import tool, create_sdk_mcp_server, ClaudeSDKClient, ClaudeAgentOptions

@tool("get_ticket", "Fetch a Jira ticket by ID", {"ticket_id": str})
async def get_ticket(args):
    # Simulate a DB/API call
    return {
        "content": [{"type": "text", "text": f"Ticket {args['ticket_id']}: Fix login bug (P1)"}]
    }

server = create_sdk_mcp_server(name="jira", version="1.0.0", tools=[get_ticket])

options = ClaudeAgentOptions(
    mcp_servers={"jira": server},
    allowed_tools=["Read", "mcp__jira__get_ticket"],
)

async def main():
    async with ClaudeSDKClient(options=options) as client:
        await client.query("Fetch ticket PROJ-42 and summarize what needs fixing")
        async for msg in client.receive_response():
            print(msg)

asyncio.run(main())
```

---

## PreToolUse hook: block dangerous commands

```python
import asyncio
from claude_agent_sdk import ClaudeSDKClient, ClaudeAgentOptions, HookMatcher

BLOCKED_PATTERNS = ["rm -rf", "DROP TABLE", "> /dev/null"]

async def block_dangerous_bash(input_data, tool_use_id, context):
    command = input_data.get("tool_input", {}).get("command", "")
    for pattern in BLOCKED_PATTERNS:
        if pattern in command:
            return {
                "hookSpecificOutput": {
                    "hookEventName": "PreToolUse",
                    "permissionDecision": "deny",
                    "permissionDecisionReason": f"Blocked: command contains '{pattern}'",
                }
            }
    return {}

options = ClaudeAgentOptions(
    allowed_tools=["Bash"],
    hooks={"PreToolUse": [HookMatcher(matcher="Bash", hooks=[block_dangerous_bash])]},
)

async def main():
    async with ClaudeSDKClient(options=options) as client:
        await client.query("Clean up temporary files")
        async for msg in client.receive_response():
            print(msg)

asyncio.run(main())
```

---

## PostToolUse hook: audit log

```python
import asyncio
from datetime import datetime
from claude_agent_sdk import query, ClaudeAgentOptions, HookMatcher

async def audit_file_changes(input_data, tool_use_id, context):
    file_path = input_data.get("tool_input", {}).get("file_path", "unknown")
    with open("audit.log", "a") as f:
        f.write(f"{datetime.now().isoformat()} | {input_data['tool_name']} | {file_path}\n")
    return {}

async def main():
    options = ClaudeAgentOptions(
        allowed_tools=["Read", "Edit", "Write"],
        permission_mode="acceptEdits",
        hooks={
            "PostToolUse": [HookMatcher(matcher="Edit|Write", hooks=[audit_file_changes])]
        },
    )
    async for message in query(prompt="Refactor utils.py", options=options):
        print(message)

asyncio.run(main())
```

---

## PreToolUse hook: modify tool input

Redirect all file writes to a sandbox directory:

```python
async def sandbox_writes(input_data, tool_use_id, context):
    if input_data["tool_name"] == "Write":
        original = input_data["tool_input"].get("file_path", "")
        return {
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "allow",
                "updatedInput": {
                    **input_data["tool_input"],
                    "file_path": f"/sandbox{original}",
                },
            }
        }
    return {}
```

---

## Notification hook: forward to Slack

```python
import asyncio
import json
import urllib.request
from claude_agent_sdk import ClaudeSDKClient, ClaudeAgentOptions, HookMatcher

SLACK_WEBHOOK = "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"

def _post_slack(message):
    data = json.dumps({"text": f"Agent: {message}"}).encode()
    req = urllib.request.Request(
        SLACK_WEBHOOK, data=data, headers={"Content-Type": "application/json"}, method="POST"
    )
    urllib.request.urlopen(req)

async def notify_slack(input_data, tool_use_id, context):
    try:
        await asyncio.to_thread(_post_slack, input_data.get("message", ""))
    except Exception as e:
        print(f"Slack notification failed: {e}")
    return {}

options = ClaudeAgentOptions(
    hooks={"Notification": [HookMatcher(hooks=[notify_slack])]}
)
```

---

## Subagents for parallel work

```python
import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions, AgentDefinition

options = ClaudeAgentOptions(
    allowed_tools=["Read", "Glob", "Grep", "Task"],
    agents={
        "security-auditor": AgentDefinition(
            description="Audits code for security vulnerabilities.",
            prompt="Find SQL injection, XSS, auth bypass, and hardcoded secrets.",
            tools=["Read", "Glob", "Grep"],
        ),
        "performance-auditor": AgentDefinition(
            description="Identifies performance bottlenecks.",
            prompt="Find N+1 queries, missing indexes, and slow algorithms.",
            tools=["Read", "Glob", "Grep"],
        ),
    },
)

async def main():
    async for message in query(
        prompt="Run security-auditor and performance-auditor on the src/ directory",
        options=options,
    ):
        print(message)

asyncio.run(main())
```

---

## Session capture and resume

```python
import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions, ResultMessage

async def first_run():
    session_id = None
    async for message in query(
        prompt="Analyze the database schema and identify normalization issues",
        options=ClaudeAgentOptions(allowed_tools=["Read", "Glob"]),
    ):
        if isinstance(message, ResultMessage):
            session_id = message.session_id
            print(message.result)
    return session_id

async def follow_up(session_id):
    async for message in query(
        prompt="Now write migration scripts to fix the issues you found",
        options=ClaudeAgentOptions(
            resume=session_id,
            allowed_tools=["Read", "Write", "Bash"],
        ),
    ):
        print(message)

async def main():
    session_id = await first_run()
    await follow_up(session_id)

asyncio.run(main())
```

---

## Session forking

```python
import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions, ResultMessage

async def explore_alternatives(session_id):
    # Fork A: try approach 1
    fork_a_id = None
    async for message in query(
        prompt="Implement the refactoring using the Strategy pattern",
        options=ClaudeAgentOptions(resume=session_id, fork_session=True),
    ):
        if isinstance(message, ResultMessage):
            fork_a_id = message.session_id

    # Fork B: try approach 2 (original session_id unchanged)
    fork_b_id = None
    async for message in query(
        prompt="Implement the refactoring using dependency injection instead",
        options=ClaudeAgentOptions(resume=session_id, fork_session=True),
    ):
        if isinstance(message, ResultMessage):
            fork_b_id = message.session_id

    return fork_a_id, fork_b_id
```

---

## MCP server (external subprocess)

```python
import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions

options = ClaudeAgentOptions(
    mcp_servers={
        "playwright": {"command": "npx", "args": ["@playwright/mcp@latest"]}
    },
    # MCP tool names follow pattern: mcp__<server>__<action>
    allowed_tools=["mcp__playwright__browser_navigate", "mcp__playwright__browser_screenshot"],
)

async def main():
    async for message in query(
        prompt="Navigate to example.com and take a screenshot",
        options=options,
    ):
        print(message)

asyncio.run(main())
```

---

## Error handling

```python
import asyncio
from claude_agent_sdk import (
    query, ClaudeAgentOptions,
    CLINotFoundError, CLIConnectionError, ProcessError, CLIJSONDecodeError,
)

async def main():
    try:
        async for message in query(
            prompt="Fix the bug",
            options=ClaudeAgentOptions(allowed_tools=["Read", "Edit"]),
        ):
            print(message)
    except CLINotFoundError:
        print("Claude Code CLI not found. Run: pip install --upgrade claude-agent-sdk")
    except CLIConnectionError as e:
        print(f"Connection error. Check ANTHROPIC_API_KEY. Details: {e}")
    except ProcessError as e:
        print(f"Agent process failed (exit code {e.exit_code})")
    except CLIJSONDecodeError as e:
        print(f"Response parse failure: {e}")

asyncio.run(main())
```
