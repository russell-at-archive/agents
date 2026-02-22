# Claude Code Hooks

Official docs: <https://docs.anthropic.com/en/docs/claude-code/hooks>

Hooks let you run shell commands, HTTP requests, or LLM evaluations at
specific points in the Claude Code lifecycle. They can observe, modify,
or block Claude's actions.

## Table of Contents

- [Configuration](#configuration)
- [Hook Events](#hook-events)
- [Hook Types](#hook-types)
- [Input Format](#input-format)
- [Output and Control](#output-and-control)
- [Exit Codes](#exit-codes)
- [Matchers](#matchers)
- [Execution Model](#execution-model)
- [Environment Variables](#environment-variables)
- [Security](#security)
- [Examples](#examples)
- [Troubleshooting](#troubleshooting)

---

## Configuration

Hooks are defined in the `hooks` key of a settings file.

### Settings File Locations

| File                              | Scope                 | Shareable |
| --------------------------------- | --------------------- | --------- |
| `~/.claude/settings.json`         | User (all projects)   | No        |
| `.claude/settings.json`           | Project (shared)      | Yes       |
| `.claude/settings.local.json`     | Project (personal)    | No        |
| Managed policy settings           | Organization-wide     | Admin     |
| Plugin `hooks/hooks.json`         | Plugin lifetime       | Yes       |
| Skill/agent YAML frontmatter      | Component lifetime    | Yes       |

### Schema

```json
{
  "hooks": {
    "EventName": [
      {
        "matcher": "regex_pattern",
        "hooks": [
          {
            "type": "command",
            "command": "path/to/script.sh",
            "timeout": 60
          }
        ]
      }
    ]
  }
}
```

The `matcher` field is optional. Omit it to match all invocations of the
event. Each event key maps to an array of matcher groups; each group has
its own `hooks` array that runs when the matcher fires.

---

## Hook Events

| Event                | Fires When                         | Can Block |
| -------------------- | ---------------------------------- | --------- |
| `SessionStart`       | Session begins or resumes          | No        |
| `UserPromptSubmit`   | User submits a prompt              | Yes       |
| `PreToolUse`         | Before a tool executes             | Yes       |
| `PermissionRequest`  | Permission dialog would appear     | Yes       |
| `PostToolUse`        | After a tool succeeds              | Partial   |
| `PostToolUseFail`    | After a tool fails                 | No        |
| `Stop`               | Claude finishes responding         | Yes       |
| `SubagentStart`      | A subagent is spawned              | No        |
| `SubagentStop`       | A subagent finishes                | Yes       |
| `TaskCompleted`      | A task is marked complete          | Yes       |
| `TeammateIdle`       | A teammate agent goes idle         | Yes       |
| `ConfigChange`       | A config file changes externally   | Yes       |
| `WorktreeCreate`     | A git worktree is created          | Yes       |
| `WorktreeRemove`     | A git worktree is removed          | No        |
| `PreCompact`         | Before context compaction          | No        |
| `Notification`       | Claude needs attention             | No        |
| `InstructionsLoaded` | CLAUDE.md or rules load            | No        |
| `SessionEnd`         | Session terminates                 | No        |

---

## Hook Types

### Command (`type: "command"`)

Runs a shell command. JSON event data is written to stdin. Stdout and
exit code control behavior.

```json
{
  "type": "command",
  "command": ".claude/hooks/guard.sh",
  "timeout": 60,
  "async": false,
  "statusMessage": "Checking..."
}
```

- `timeout`: seconds before cancellation (default: 600)
- `async`: run in background without blocking (default: `false`)
- `statusMessage`: custom spinner text shown while running

### HTTP (`type: "http"`)

POSTs event JSON to a URL. Response body uses the same format as command
stdout.

```json
{
  "type": "http",
  "url": "http://localhost:8080/hooks/tool-use",
  "headers": {
    "Authorization": "Bearer $MY_TOKEN"
  },
  "allowedEnvVars": ["MY_TOKEN"],
  "timeout": 30
}
```

- Non-2xx responses are non-blocking errors (execution continues).
- Only variables listed in `allowedEnvVars` are interpolated; others
  become empty strings.

### Prompt (`type: "prompt"`)

Single-turn LLM evaluation. Returns `{"ok": true}` or
`{"ok": false, "reason": "..."}`.

```json
{
  "type": "prompt",
  "prompt": "Is this a safe bash command? Reply with JSON only.",
  "model": "claude-haiku-4-5-20251001",
  "timeout": 30
}
```

Use for judgment-based decisions that don't require tool access.

### Agent (`type: "agent"`)

Multi-turn subagent with Read, Grep, and Glob tools. Up to 50 tool-use
turns. Returns `{"ok": true}` or `{"ok": false, "reason": "..."}`.

```json
{
  "type": "agent",
  "prompt": "Verify that all unit tests pass. Run them and report results.",
  "timeout": 120
}
```

Use for complex verification that requires inspecting the codebase.

---

## Input Format

All hook types receive a JSON object with common fields plus
event-specific fields.

### Common Fields

```json
{
  "session_id": "abc123",
  "transcript_path": "/path/to/transcript.jsonl",
  "cwd": "/current/directory",
  "permission_mode": "default",
  "hook_event_name": "PreToolUse",
  "agent_id": "subagent_id",
  "agent_type": "Explore"
}
```

`permission_mode` values: `default`, `plan`, `acceptEdits`, `dontAsk`,
`bypassPermissions`.

### Event-Specific Fields

#### `SessionStart`

```json
{
  "source": "startup",
  "model": "claude-sonnet-4-6"
}
```

`source` values: `startup`, `resume`, `clear`, `compact`.

#### `PreToolUse` and `PostToolUse` — Bash

```json
{
  "tool_name": "Bash",
  "tool_use_id": "unique_id",
  "tool_input": {
    "command": "npm test",
    "description": "Run test suite",
    "timeout": 120000,
    "run_in_background": false
  }
}
```

#### `PreToolUse` and `PostToolUse` — Edit / Write

```json
{
  "tool_name": "Write",
  "tool_use_id": "unique_id",
  "tool_input": {
    "file_path": "/path/to/file.txt",
    "content": "file content here"
  }
}
```

#### `Stop`

```json
{
  "stop_hook_active": false
}
```

Check `stop_hook_active` to avoid infinite loops when a `Stop` hook
itself triggers another stop.

---

## Output and Control

Hooks control Claude by writing JSON to stdout (exit code 0) or using
exit code 2 to block.

### Top-Level Decision Fields

Used by: `UserPromptSubmit`, `PostToolUse`, `Stop`, `ConfigChange`.

```json
{
  "continue": true,
  "decision": "block",
  "reason": "Reason shown to Claude",
  "suppressOutput": false,
  "systemMessage": "Additional context for Claude"
}
```

- `continue: false` + `stopReason` stops Claude's response.
- `decision: "block"` + `reason` feeds the reason back as a message.

### `PreToolUse` — `hookSpecificOutput`

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Protected file",
    "updatedInput": { "command": "safe-alternative" },
    "additionalContext": "Use the safe-alternative command instead"
  }
}
```

- `permissionDecision`: `"allow"`, `"deny"`, or `"ask"`.
- `updatedInput`: replace the tool's input before execution.
- `additionalContext`: extra context injected into Claude's conversation.

### `PermissionRequest` — `hookSpecificOutput`

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PermissionRequest",
    "permissionDecision": "allow",
    "permissionDecisionReason": "Approved by policy"
  }
}
```

### `WorktreeCreate`

Write an absolute path to stdout. Claude uses it as the worktree path.

### Prompt / Agent Hook Response

```json
{ "ok": true }
```

```json
{ "ok": false, "reason": "Tests failed: 3 failures in auth.test.ts" }
```

---

## Exit Codes

| Code      | Meaning           | Effect                                             |
| --------- | ----------------- | -------------------------------------------------- |
| `0`       | Success           | Parse stdout JSON; add to context on some events   |
| `2`       | Blocking error    | Block action; stderr becomes feedback to Claude    |
| Other     | Non-blocking      | Continue execution; stderr logged (verbose only)   |

Exit code 2 is the primary way to block an action without JSON output.
Use it in guard scripts when a shell condition fails.

---

## Matchers

Matchers are regex patterns that filter when a hook fires. Omit the
`matcher` field to match all invocations.

### What Each Event Matches Against

| Event                                 | Matches Against       | Examples                  |
| ------------------------------------- | --------------------- | ------------------------- |
| `PreToolUse`, `PostToolUse`           | Tool name             | `Bash`, `Edit\|Write`     |
| `PermissionRequest`                   | Tool name             | `Bash`, `mcp__.*`         |
| `SessionStart`, `SessionEnd`          | Session source/reason | `startup`, `resume`       |
| `Notification`                        | Notification type     | `permission_prompt`       |
| `SubagentStart`, `SubagentStop`       | Agent type            | `Explore`, `Plan`         |
| `PreCompact`                          | Trigger               | `manual`, `auto`          |
| `ConfigChange`                        | Config source         | `project_settings`        |
| `UserPromptSubmit`, `Stop`, others    | No matcher support    | —                         |

### MCP Tool Matching

MCP tools follow the naming pattern `mcp__<server>__<tool>`:

```json
{ "matcher": "mcp__memory__.*" }
{ "matcher": "mcp__.*__write.*" }
{ "matcher": "mcp__github__search.*" }
```

---

## Execution Model

- All matching hooks for an event run **in parallel**.
- Identical hook commands are **automatically deduplicated**.
- Hooks are snapshotted at **session startup**. Use `/hooks` to review
  external changes mid-session.
- Hooks run in the **current working directory** with Claude's full
  environment.

### Lifecycle Order

```text
SessionStart
InstructionsLoaded
    │
    └─► (per prompt)
        UserPromptSubmit
            │
            └─► (per tool call)
                PreToolUse ──► PermissionRequest
                PostToolUse / PostToolUseFail
            │
        Stop
        │
    SubagentStart / SubagentStop
    TaskCompleted / TeammateIdle
    ConfigChange
    WorktreeCreate / WorktreeRemove
    PreCompact
    Notification
SessionEnd
```

---

## Environment Variables

All hooks inherit Claude Code's full environment plus:

| Variable             | Available In    | Description                          |
| -------------------- | --------------- | ------------------------------------ |
| `CLAUDE_PROJECT_DIR` | All hooks       | Project root directory               |
| `CLAUDE_ENV_FILE`    | `SessionStart`  | Path for injecting session variables |
| `CLAUDE_CODE_REMOTE` | All hooks       | `"true"` in remote web environments  |

### Injecting Session-Scoped Variables

Write `export VAR=value` lines to `$CLAUDE_ENV_FILE` in a `SessionStart`
hook. These variables persist across all subsequent Bash tool calls.

```bash
#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${CLAUDE_ENV_FILE:-}" ]]; then
  echo 'export NODE_ENV=development' >> "$CLAUDE_ENV_FILE"
  echo 'export PATH="$PATH:./node_modules/.bin"' >> "$CLAUDE_ENV_FILE"
fi
```

---

## Security

### Shell Profile Interference

Hooks run in non-interactive shells. Unconditional `echo` in `~/.zshrc`
or `~/.bashrc` will prepend to hook stdout and break JSON parsing. Wrap
interactive-only output:

```bash
if [[ $- == *i* ]]; then
  echo "Welcome to my shell"
fi
```

### Permission Mode Awareness

Hooks receive `permission_mode` in the input JSON. Respect it when making
decisions, especially in `dontAsk` or `bypassPermissions` modes where
the user expects reduced friction.

### Config Blocking Limits

`ConfigChange` hooks can block changes from `user_settings`,
`project_settings`, and `skills`, but **cannot** block
`policy_settings` (managed by organization admins).

### Managed Hook Policies

Enterprise admins can set `allowManagedHooksOnly` to prevent user and
project hooks from running. Managed policy hooks always take precedence.

---

## Examples

### Desktop Notification on Idle

```json
{
  "hooks": {
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "osascript -e 'display notification \"Claude needs attention\" with title \"Claude Code\"'"
          }
        ]
      }
    ]
  }
}
```

### Auto-Format After File Edits

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path' | xargs npx prettier --write 2>/dev/null || true"
          }
        ]
      }
    ]
  }
}
```

### Block Protected Files

`.claude/hooks/protect-files.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

PROTECTED=(".env" "package-lock.json" ".git/")

for pattern in "${PROTECTED[@]}"; do
  if [[ "$FILE_PATH" == *"$pattern"* ]]; then
    echo "Blocked: matches protected pattern '$pattern'" >&2
    exit 2
  fi
done
```

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/protect-files.sh"
          }
        ]
      }
    ]
  }
}
```

### Reinject Context After Compaction

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "compact",
        "hooks": [
          {
            "type": "command",
            "command": "echo 'Use bun, not npm. Run bun test before every commit.'"
          }
        ]
      }
    ]
  }
}
```

### Audit Config Changes

```json
{
  "hooks": {
    "ConfigChange": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "jq -c '{ts: now | todate, source: .source}' >> ~/claude-config-audit.log"
          }
        ]
      }
    ]
  }
}
```

### Agent Verification on Stop

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "agent",
            "prompt": "Check that all unit tests pass. Run the test suite and report results. $ARGUMENTS",
            "timeout": 120
          }
        ]
      }
    ]
  }
}
```

### HTTP Audit Hook

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "hooks": [
          {
            "type": "http",
            "url": "http://localhost:9000/audit",
            "headers": { "Authorization": "Bearer $AUDIT_TOKEN" },
            "allowedEnvVars": ["AUDIT_TOKEN"],
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

---

## Troubleshooting

### Hook Does Not Fire

- Open `/hooks` menu to confirm the hook is registered.
- Verify the `matcher` regex is correct (case-sensitive).
- Check that you are triggering the correct event type.
- `PermissionRequest` hooks do not fire in non-interactive (`-p`) mode.

### JSON Parsing Fails

- Test manually: `echo '{"tool_name":"Bash"}' | ./hook.sh`
- Ensure only JSON goes to stdout; move all logging to stderr.
- Guard shell profile output with `if [[ $- == *i* ]]; then ... fi`.

### Hook Throws an Error

- Check exit code: non-zero (not 2) produces a non-blocking warning.
- Use absolute paths or `$CLAUDE_PROJECT_DIR` for script references.
- Ensure scripts are executable: `chmod +x .claude/hooks/script.sh`.
- Install `jq` if your hook parses JSON input.

### Infinite Loop in `Stop` Hook

Guard against recursive invocations with the `stop_hook_active` field:

```bash
#!/usr/bin/env bash
INPUT=$(cat)
ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active')
if [[ "$ACTIVE" == "true" ]]; then
  exit 0
fi
```
