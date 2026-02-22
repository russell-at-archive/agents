---
name: using-claude-agent-sdk
description: Provides expert guidance for building AI agents with the Claude
  Agent SDK (Python `claude_agent_sdk` or TypeScript `@anthropic-ai/claude-agent-sdk`).
  Use when code imports `claude_agent_sdk` or `@anthropic-ai/claude-agent-sdk`,
  or when asked to build, design, debug, or extend an agent using the Claude
  Agent SDK, custom tools, hooks, subagents, MCP servers, or session management.
---

# Using Claude Agent SDK

## Overview

The Claude Agent SDK wraps the same tool loop, context management, and
built-in tools that power Claude Code, exposing them as a Python or TypeScript
library. Use this skill when building, reviewing, or debugging agents that
call `query()` or `ClaudeSDKClient`. Full procedure and API reference:
[references/overview.md](references/overview.md).

## When to Use

- Code imports `claude_agent_sdk` or `@anthropic-ai/claude-agent-sdk`
- User asks to build or extend an agent using the Claude Agent SDK
- User asks about hooks, custom tools, subagents, sessions, or MCP in SDK context
- User migrating from the old Claude Code SDK (`ClaudeCodeOptions` → `ClaudeAgentOptions`)

## When Not to Use

- Direct Anthropic API calls via the Client SDK (`anthropic` / `@anthropic-ai/sdk`)
  with a manual tool loop — use the client SDK skill or claude-api skill instead
- Interactive CLI use — use the `using-claude-cli` skill
- One-off `claude -p` commands in CI — use the `using-claude-cli` skill

## Prerequisites

- Python 3.10+ or Node.js 18+
- `ANTHROPIC_API_KEY` set (or Bedrock/Vertex/Azure credentials configured)
- Package installed:

  ```bash
  pip install claude-agent-sdk     # Python
  npm install @anthropic-ai/claude-agent-sdk  # TypeScript
  ```

## Workflow

1. Load [references/overview.md](references/overview.md) for the full API
   surface: `query()`, `ClaudeSDKClient`, options, message types, and patterns.
2. Load [references/examples.md](references/examples.md) when mapping a task
   to concrete code (tools, hooks, subagents, sessions, MCP, custom tools).
3. Load [references/troubleshooting.md](references/troubleshooting.md) when
   blocked, hitting errors, or reviewing for anti-patterns.
4. Choose `query()` for one-shot tasks; `ClaudeSDKClient` for multi-turn or
   when hooks and custom tools are required.
5. Set `allowed_tools` explicitly — omitting it grants broad default access.
6. Validate outputs before treating agent results as ground truth.

## Hard Rules

- Never omit `allowed_tools` in production; always use the minimum tool set.
- Never treat agent output as verified without checking results.
- Never use `permission_mode="bypassPermissions"` without explicit user approval.
- Never call `ClaudeSDKClient` methods outside `async with` context.
- Use `fork_session=True` to branch history, not to replace `resume`.
- Hooks that raise unhandled exceptions can interrupt the agent — always catch.

## Failure Handling

- `CLINotFoundError`: Claude Code CLI not bundled; reinstall the package.
- `CLIConnectionError`: Check `ANTHROPIC_API_KEY`; verify network and auth.
- `ProcessError`: Inspect `e.exit_code` and stderr; narrow tool permissions.
- `CLIJSONDecodeError`: Response parse failure; report to SDK issue tracker.
- Hook not firing: verify event name casing (`PreToolUse` not `preToolUse`);
  check matcher regex against actual tool name.
- Session resume returns empty history: `cwd` mismatch — sessions are stored
  under `~/.claude/projects/<encoded-cwd>/`; ensure directories match.

## Red Flags

- `allowed_tools` omitted or set to `["*"]` in production
- Hook callback raises without `try/except`, risking agent interruption
- `resume` used without capturing the session ID from `ResultMessage`
- `fork_session` and `resume` omitted when multi-turn context is required
- Subagents spawned without `"Task"` in parent's `allowed_tools`
- Custom tools added without `ClaudeSDKClient` (they require the client)
- `continue_conversation=True` used when a specific session ID is needed
