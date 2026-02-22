# Claude Agent SDK: Full Reference

## Contents

- [SDK vs Client SDK vs CLI](#sdk-vs-client-sdk-vs-cli)
- [Installation and authentication](#installation-and-authentication)
- [Core API: `query()`](#core-api-query)
- [Core API: `ClaudeSDKClient`](#core-api-claudesdkclient)
- [ClaudeAgentOptions reference](#claudeagentoptions-reference)
- [Message types](#message-types)
- [Built-in tools](#built-in-tools)
- [Permission modes](#permission-modes)
- [Custom tools (in-process MCP)](#custom-tools-in-process-mcp)
- [Hooks](#hooks)
- [Subagents](#subagents)
- [Sessions](#sessions)
- [MCP servers](#mcp-servers)
- [Error types](#error-types)
- [When to use query() vs ClaudeSDKClient](#when-to-use-query-vs-claudesdkclient)

---

## SDK vs Client SDK vs CLI

| | Claude Agent SDK | Anthropic Client SDK | Claude CLI |
|---|---|---|---|
| Tool execution | Built-in, autonomous | Manual loop required | Built-in |
| Interface | Python/TypeScript library | Python/TypeScript library | Shell command |
| Use case | Production agents, CI/CD | Custom tool loops, fine control | Interactive dev, one-off tasks |
| Import | `claude_agent_sdk` / `@anthropic-ai/claude-agent-sdk` | `anthropic` / `@anthropic-ai/sdk` | `claude` binary |

---

## Installation and Authentication

```bash
# Python (requires 3.10+)
pip install claude-agent-sdk

# TypeScript (requires Node 18+)
npm install @anthropic-ai/claude-agent-sdk
```

Authentication (pick one):

```bash
# Direct API key
export ANTHROPIC_API_KEY=your-api-key

# Amazon Bedrock
export CLAUDE_CODE_USE_BEDROCK=1
# + AWS credentials configured

# Google Vertex AI
export CLAUDE_CODE_USE_VERTEX=1
# + GCP credentials configured

# Microsoft Azure AI Foundry
export CLAUDE_CODE_USE_FOUNDRY=1
# + Azure credentials configured
```

---

## Core API: `query()`

Returns an `AsyncIterator` of messages. Use for single-shot tasks.

```python
import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions

async def main():
    async for message in query(
        prompt="Find and fix the bug in auth.py",
        options=ClaudeAgentOptions(allowed_tools=["Read", "Edit", "Bash"]),
    ):
        print(message)

asyncio.run(main())
```

```typescript
import { query } from "@anthropic-ai/claude-agent-sdk";

for await (const message of query({
  prompt: "Find and fix the bug in auth.py",
  options: { allowedTools: ["Read", "Edit", "Bash"] }
})) {
  console.log(message);
}
```

---

## Core API: `ClaudeSDKClient`

Multi-turn client with session management, custom tools, and hooks. Must be
used as an async context manager.

```python
from claude_agent_sdk import ClaudeSDKClient, ClaudeAgentOptions

async with ClaudeSDKClient(options=ClaudeAgentOptions(...)) as client:
    await client.query("First prompt")
    async for msg in client.receive_response():
        print(msg)

    await client.query("Follow-up with same context")
    async for msg in client.receive_response():
        print(msg)
```

```typescript
// TypeScript: use continue: true on subsequent query() calls
for await (const msg of query({ prompt: "First prompt", options: { ... } })) { ... }
for await (const msg of query({ prompt: "Follow-up", options: { ..., continue: true } })) { ... }
```

---

## ClaudeAgentOptions Reference

| Option (Python) | Option (TypeScript) | Type | Description |
|---|---|---|---|
| `allowed_tools` | `allowedTools` | `list[str]` | Tool whitelist; pre-approves listed tools |
| `permission_mode` | `permissionMode` | `str` | `"default"`, `"acceptEdits"`, `"bypassPermissions"` |
| `system_prompt` | `systemPrompt` | `str` | Custom system prompt |
| `max_turns` | `maxTurns` | `int` | Max agent turns before stopping |
| `cwd` | `cwd` | `str \| Path` | Working directory for the agent |
| `hooks` | `hooks` | `dict` | Hook callbacks by event name |
| `agents` | `agents` | `dict` | Named subagent definitions |
| `mcp_servers` | `mcpServers` | `dict` | External or in-process MCP servers |
| `resume` | `resume` | `str` | Session ID to resume |
| `fork_session` | `forkSession` | `bool` | Fork the resumed session |
| `continue_conversation` | `continue` | `bool` | Resume most recent session in cwd |
| `setting_sources` | `settingSources` | `list[str]` | Load `["project"]` for `.claude/` config |
| `cli_path` | `cliPath` | `str` | Custom path to Claude Code CLI binary |

---

## Message Types

| Type | Python class | TypeScript `type` | Key fields |
|---|---|---|---|
| Assistant response | `AssistantMessage` | `"assistant"` | `.content` list of blocks |
| User turn | `UserMessage` | `"user"` | `.content` |
| System (init) | `SystemMessage` | `"system"` | `.subtype == "init"`, `.session_id`, `.data` |
| Final result | `ResultMessage` | `"result"` | `.subtype`, `.result`, `.session_id`, `.total_cost_usd` |

Content blocks inside `AssistantMessage.content`:

- `TextBlock` — `.text` (plain text output)
- `ToolUseBlock` — `.name`, `.input` (tool call)
- `ToolResultBlock` — `.tool_use_id`, `.content` (tool result)

Extract text output:

```python
from claude_agent_sdk import AssistantMessage, TextBlock, ResultMessage

async for message in query(prompt="Summarize the codebase"):
    if isinstance(message, AssistantMessage):
        for block in message.content:
            if isinstance(block, TextBlock):
                print(block.text)
    elif isinstance(message, ResultMessage):
        print(f"Cost: ${message.total_cost_usd:.4f}")
        session_id = message.session_id
```

---

## Built-in Tools

| Tool | Description |
|---|---|
| `Read` | Read any file in the working directory |
| `Write` | Create new files |
| `Edit` | Make precise edits to existing files |
| `Bash` | Run terminal commands, scripts, git operations |
| `Glob` | Find files by pattern |
| `Grep` | Search file contents with regex |
| `WebSearch` | Search the web for current information |
| `WebFetch` | Fetch and parse web page content |
| `AskUserQuestion` | Ask the user a clarifying question |
| `Task` | Spawn a subagent (required in parent `allowed_tools`) |

---

## Permission Modes

| Mode | Behavior |
|---|---|
| `"default"` | Prompts user for sensitive tool calls |
| `"acceptEdits"` | Auto-approves file edits; prompts for Bash |
| `"bypassPermissions"` | Auto-approves all tools — use with caution |

Use `allowed_tools` to pre-approve specific tools without changing the
global permission mode. `"bypassPermissions"` requires explicit user approval
before use in production.

---

## Custom Tools (In-Process MCP)

Define Python functions as tools using `@tool`. Requires `ClaudeSDKClient`.

```python
from claude_agent_sdk import tool, create_sdk_mcp_server, ClaudeSDKClient, ClaudeAgentOptions

@tool("lookup_user", "Look up user by ID", {"user_id": str})
async def lookup_user(args):
    # args["user_id"] is available
    return {
        "content": [{"type": "text", "text": f"User {args['user_id']}: Alice"}]
    }

server = create_sdk_mcp_server(
    name="my-tools",
    version="1.0.0",
    tools=[lookup_user]
)

options = ClaudeAgentOptions(
    mcp_servers={"my-tools": server},
    allowed_tools=["mcp__my-tools__lookup_user"]
)

async with ClaudeSDKClient(options=options) as client:
    await client.query("Look up user abc-123")
    async for msg in client.receive_response():
        print(msg)
```

MCP tool naming: `mcp__<server-name>__<tool-name>`.

Advantages over external subprocess MCP servers:
- No subprocess management or IPC overhead
- All code in one process — easier to debug
- Direct Python type safety

---

## Hooks

Hooks are callback functions invoked by the SDK at lifecycle events. They
can allow, deny, or modify tool calls, inject conversation context, or
perform side effects.

### Available Hook Events

| Event | Python | TypeScript | Trigger |
|---|---|---|---|
| `PreToolUse` | Yes | Yes | Before a tool call — can block or modify |
| `PostToolUse` | Yes | Yes | After a tool call succeeds |
| `PostToolUseFailure` | Yes | Yes | After a tool call fails |
| `UserPromptSubmit` | Yes | Yes | User prompt submission |
| `Stop` | Yes | Yes | Agent stops executing |
| `SubagentStart` | Yes | Yes | Subagent initializes |
| `SubagentStop` | Yes | Yes | Subagent completes |
| `PreCompact` | Yes | Yes | Before conversation compaction |
| `PermissionRequest` | Yes | Yes | Permission dialog would display |
| `Notification` | Yes | Yes | Agent status messages |
| `SessionStart` | No | Yes | Session initialization |
| `SessionEnd` | No | Yes | Session termination |

### Hook Configuration

```python
from claude_agent_sdk import HookMatcher, ClaudeAgentOptions

options = ClaudeAgentOptions(
    hooks={
        "PreToolUse": [
            HookMatcher(matcher="Bash", hooks=[my_callback]),
            HookMatcher(matcher="Write|Edit", hooks=[file_guard]),
            HookMatcher(hooks=[global_logger]),  # no matcher = all tools
        ]
    }
)
```

### Callback Signature

```python
async def my_callback(input_data: dict, tool_use_id: str | None, context) -> dict:
    ...
    return {}  # Allow with no changes
```

`input_data` keys: `hook_event_name`, `tool_name`, `tool_input`, `session_id`, `cwd`.

### Hook Return Values

```python
# Allow with no changes
return {}

# Deny the tool call
return {
    "hookSpecificOutput": {
        "hookEventName": input_data["hook_event_name"],
        "permissionDecision": "deny",
        "permissionDecisionReason": "Reason shown to the model",
    }
}

# Allow and modify the input
return {
    "hookSpecificOutput": {
        "hookEventName": input_data["hook_event_name"],
        "permissionDecision": "allow",
        "updatedInput": {**input_data["tool_input"], "file_path": "/sandbox/file.txt"},
    }
}

# Inject context into the conversation
return {
    "systemMessage": "Context injected into Claude's conversation",
    "hookSpecificOutput": {...},
}

# Async side-effect (don't wait for completion)
return {"async_": True, "asyncTimeout": 30000}
```

Priority when multiple hooks apply: `deny` > `ask` > `allow`.

---

## Subagents

Spawn specialized agents for subtasks. Parent must include `"Task"` in
`allowed_tools`.

```python
from claude_agent_sdk import AgentDefinition, ClaudeAgentOptions, query

options = ClaudeAgentOptions(
    allowed_tools=["Read", "Glob", "Grep", "Task"],
    agents={
        "security-auditor": AgentDefinition(
            description="Audits code for security vulnerabilities.",
            prompt="Find security issues: injection, auth bypass, secrets.",
            tools=["Read", "Glob", "Grep"],
        )
    },
)

async for message in query(
    prompt="Use the security-auditor agent to review this codebase",
    options=options,
):
    print(message)
```

Subagent messages include `parent_tool_use_id` for correlation.
Subagents do not inherit parent permissions — configure separately.

---

## Sessions

Sessions persist conversation history to disk at
`~/.claude/projects/<encoded-cwd>/<session-id>.jsonl`.

### Capture session ID

```python
from claude_agent_sdk import ResultMessage

session_id = None
async for message in query(prompt="Analyze auth.py", options=options):
    if isinstance(message, ResultMessage):
        session_id = message.session_id
```

### Resume a specific session

```python
options = ClaudeAgentOptions(resume=session_id, allowed_tools=["Read", "Edit"])
async for message in query(prompt="Now implement the fix", options=options):
    ...
```

### Continue most-recent session (no ID tracking)

```python
options = ClaudeAgentOptions(continue_conversation=True)
# TypeScript: options: { continue: true }
```

### Fork a session

```python
options = ClaudeAgentOptions(resume=session_id, fork_session=True)
# Creates a new session with copied history; original unchanged
```

### Sessions across hosts

Session files are local. To resume across hosts: copy
`~/.claude/projects/<encoded-cwd>/<session-id>.jsonl` to the same path
on the target host with matching `cwd`.

---

## MCP Servers

### External subprocess MCP

```python
options = ClaudeAgentOptions(
    mcp_servers={
        "playwright": {"command": "npx", "args": ["@playwright/mcp@latest"]}
    }
)
```

### Mixed (in-process + external)

```python
options = ClaudeAgentOptions(
    mcp_servers={
        "internal": sdk_server,      # in-process
        "external": {"command": "..."}  # subprocess
    }
)
```

---

## Error Types

| Exception | Meaning | Fix |
|---|---|---|
| `CLINotFoundError` | Claude Code CLI binary missing | Reinstall `claude-agent-sdk` |
| `CLIConnectionError` | Can't reach Claude API | Check `ANTHROPIC_API_KEY` |
| `ProcessError` | Agent process exited non-zero | Check `.exit_code`, narrow tools |
| `CLIJSONDecodeError` | Response parse failure | Report to SDK GitHub issues |

Import: `from claude_agent_sdk import CLINotFoundError, CLIConnectionError, ProcessError, CLIJSONDecodeError`

---

## When to Use `query()` vs `ClaudeSDKClient`

| Need | Use |
|---|---|
| Single one-shot task | `query()` |
| Multi-turn conversation in one process | `ClaudeSDKClient` |
| Custom tools (`@tool` / `create_sdk_mcp_server`) | `ClaudeSDKClient` |
| SDK hooks | `ClaudeSDKClient` (Python) or `query()` with hook option (TypeScript) |
| Stateless, no session persistence (TypeScript) | `query()` with `persistSession: false` |
| Session tracking across multiple turns | `ClaudeSDKClient` (Python) / `continue: true` (TypeScript) |
