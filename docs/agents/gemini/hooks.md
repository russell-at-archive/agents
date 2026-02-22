# Gemini CLI Hooks

Hooks are shell commands that Gemini CLI invokes at defined lifecycle
points. They intercept agent behavior to add validation, inject context,
block dangerous operations, and capture observability data.

---

## Hook Events

Ten events fire at distinct points in the agent loop.

| Event | Capability | Trigger Point |
| --- | --- | --- |
| `SessionStart` | Observe | Session initializes, resumes, or clears |
| `SessionEnd` | Observe | CLI exits or session clears |
| `BeforeAgent` | Modify | After user prompt, before planning |
| `AfterAgent` | Retry / Deny | Agent loop completes |
| `BeforeModel` | Modify | Before LLM request is sent |
| `AfterModel` | Redact | After LLM response chunk received |
| `BeforeToolSelection` | Filter | Before tool list sent to model |
| `BeforeTool` | Block / Rewrite | Before a tool executes |
| `AfterTool` | Hide / Modify | After a tool completes |
| `Notification` | Observe | System-level alerts |

Observability-only events (`SessionStart`, `SessionEnd`, `Notification`)
cannot block or modify flow; their output is ignored except for
`systemMessage`.

---

## Configuration

Hooks are defined in the `hooks` key of `settings.json`. Settings merge
across layers with the following precedence (highest first):

1. Project: `.gemini/settings.json`
2. User: `~/.gemini/settings.json`
3. System: `/etc/gemini-cli/settings.json`
4. Extensions

### Schema

```json
{
  "hooks": {
    "<EventName>": [
      {
        "matcher": "<regex-or-exact-string>",
        "hooks": [
          {
            "name": "my-hook",
            "type": "command",
            "command": "$GEMINI_PROJECT_DIR/.gemini/hooks/check.sh",
            "timeout": 5000,
            "description": "What this hook does"
          }
        ]
      }
    ]
  }
}
```

### Configuration Fields

| Field | Required | Description |
| --- | --- | --- |
| `type` | Yes | Hook engine. Only `"command"` is supported. |
| `command` | Yes | Shell command to execute. |
| `name` | No | Friendly identifier shown in `/hooks panel`. |
| `timeout` | No | Milliseconds before hook is killed (default 60000). |
| `description` | No | Purpose text shown in `/hooks panel`. |

### Matchers

- **Tool events** (`BeforeTool`, `AfterTool`, `BeforeToolSelection`):
  use a regex pattern matched against the tool name.
  `"write_file|replace"` matches both tools; `".*"` or `""` matches all.
- **Lifecycle events** (`SessionStart`, `SessionEnd`, etc.): use an
  exact string or leave matcher empty to match always.
- MCP tools appear as `mcp__<server_name>__<tool_name>` and can be
  matched with patterns like `"mcp__github__.*"`.

---

## Execution Protocol

Hooks communicate via standard I/O:

- **stdin**: JSON object describing the event context.
- **stdout**: JSON object with the hook decision. **No plain text.**
- **stderr**: Free-form logs and debug output (safe to write anything).

**The Golden Rule**: `stdout` must contain only a single valid JSON
object. Any plain text on `stdout` causes a parse failure; Gemini CLI
defaults to "Allow" on parse failure.

### Exit Codes

| Code | Meaning |
| --- | --- |
| `0` | Success. Parse `stdout` as JSON for the decision. |
| `2` | System block. Abort the action; `stderr` contains the reason. |
| Other | Non-fatal warning. Interaction proceeds with original parameters. |

Exit code `2` is the "emergency brake": simplest way to block without
returning structured JSON.

---

## JSON Input (stdin)

### Base Schema

All events receive these common fields:

```json
{
  "version": "1.0.0",
  "event": "BeforeTool",
  "sessionId": "h8d2-k9s1-v4l0",
  "projectDir": "/Users/user/project",
  "cwd": "/Users/user/project/src",
  "userPrompt": "Refactor the auth logic",
  "history": [
    { "role": "user", "content": "..." },
    { "role": "model", "content": "..." }
  ],
  "metadata": {
    "model": "gemini-2.0-flash",
    "approvalMode": "default"
  }
}
```

### Event-Specific Fields

Each event appends additional fields to the base schema.

**`SessionStart`**

```json
{ "mode": "startup" }
```

`mode` is `"startup"`, `"resume"`, or `"clear"`.

**`SessionEnd`**

```json
{ "reason": "exit" }
```

`reason` is `"exit"` or `"clear"`.

**`BeforeAgent`**

```json
{ "prompt": "User's submitted prompt text" }
```

**`AfterAgent`**

```json
{ "prompt_response": "Full agent response text" }
```

**`BeforeModel`**

```json
{
  "llm_request": {
    "contents": [],
    "tools": []
  }
}
```

**`AfterModel`**

```json
{
  "llm_request": {},
  "llm_response": { "candidates": [] }
}
```

**`BeforeToolSelection`**

```json
{
  "llm_request": {
    "messages": [{ "role": "user", "content": "..." }]
  },
  "availableTools": ["read_file", "write_file", "grep_search"]
}
```

**`BeforeTool`**

```json
{
  "tool_name": "write_file",
  "tool_input": {
    "path": "src/auth.ts",
    "content": "..."
  }
}
```

**`AfterTool`**

```json
{
  "tool_name": "read_file",
  "result": "file content..."
}
```

**`Notification`**

```json
{
  "type": "info",
  "message": "Agent is idle, waiting for input"
}
```

---

## JSON Output (stdout)

### Common Output Fields

| Field | Type | Description |
| --- | --- | --- |
| `decision` | string | `"allow"`, `"deny"`, `"block"`, or `"replace"` |
| `reason` | string | Explanation for deny/block; shown to the agent |
| `systemMessage` | string | Message printed to the CLI for the user |
| `suppressOutput` | boolean | Exclude metadata from logs |
| `context` | string | Additional text injected into LLM context |
| `retry` | boolean | `AfterAgent` only: `true` forces agent retry |

### Event-Specific Output

**`SessionStart`** — inject startup context:

```json
{ "systemMessage": "Project context loaded." }
```

**`BeforeAgent`** — inject additional context:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "BeforeAgent",
    "additionalContext": "Git branch: feature/auth. Last commit: ..."
  }
}
```

**`AfterAgent`** — allow or force retry:

```json
{ "decision": "allow" }
```

```json
{
  "decision": "block",
  "reason": "Response missing required summary section.",
  "systemMessage": "Retrying: response did not meet quality gate."
}
```

`retry: true` is equivalent to `decision: "block"` for `AfterAgent`:

```json
{ "retry": true, "reason": "Quality gate failed." }
```

**`BeforeToolSelection`** — filter available tools:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "BeforeToolSelection",
    "toolConfig": {
      "mode": "ANY",
      "allowedFunctionNames": ["read_file", "grep_search"]
    }
  }
}
```

Return `{}` to allow all tools. Multiple hook results are
union-aggregated (most permissive wins).

**`BeforeTool`** — allow, deny, or rewrite:

```json
{ "decision": "allow" }
```

```json
{
  "decision": "deny",
  "reason": "File path is outside the project directory.",
  "systemMessage": "Blocked: path traversal attempt detected."
}
```

To rewrite tool arguments before execution:

```json
{
  "decision": "replace",
  "replacement": {
    "arguments": { "path": "safe/path/file.ts" }
  }
}
```

**`AfterTool`** — hide results from agent history:

```json
{ "suppressOutput": true }
```

---

## Environment Variables

The following variables are set in the hook process environment:

| Variable | Description |
| --- | --- |
| `GEMINI_PROJECT_DIR` | Root directory of the project |
| `GEMINI_SESSION_ID` | Unique identifier for the current session |
| `GEMINI_CWD` | Working directory where the CLI was invoked |
| `GEMINI_CLI_VERSION` | Installed version of Gemini CLI |
| `GEMINI_CLI_CONFIG` | Path to the active `settings.json` |
| `CLAUDE_PROJECT_DIR` | Alias for `GEMINI_PROJECT_DIR` (compatibility) |

---

## Management Commands

| Command | Description |
| --- | --- |
| `/hooks panel` | Show all configured hooks with status and timing |
| `/hooks enable <name>` | Enable a hook by name |
| `/hooks disable <name>` | Disable a hook by name |
| `/hooks enable-all` | Enable all configured hooks |
| `/hooks disable-all` | Disable all configured hooks |

---

## Migration from Claude Code

Gemini CLI can import hooks from Claude Code's configuration:

```bash
gemini hooks migrate --from-claude
```

This reads `~/.claude/settings.json` and `.claude/settings.json` and
converts hook definitions to the Gemini CLI format. Review the output
before committing; some event names and field shapes differ.

---

## Security

Hooks execute arbitrary shell code with your user privileges. Treat
hook configuration as trusted code.

- **Fingerprinting**: Gemini CLI hashes each hook by name and command.
  Any change to the command string triggers a security warning before
  the hook runs again.
- **Project hooks**: Hooks in `.gemini/settings.json` are untrusted by
  default. Opening an unfamiliar project with project-level hooks
  triggers a confirmation prompt.
- **Source risk ranking** (lowest to highest): system → user →
  extension → project.
- **Environment variable redaction**: Enable to prevent secret leakage
  into hook processes. Add explicit exceptions for variables hooks
  require:

```json
{
  "security": {
    "environmentVariableRedaction": {
      "enabled": true,
      "allowed": ["GITHUB_TOKEN"]
    }
  }
}
```

**Key risks**: arbitrary code execution, data exfiltration via stdin
content, prompt injection through hook output.

---

## Best Practices

### Output discipline

Always write logs to `stderr`. Write only the final JSON to `stdout`.

```bash
#!/usr/bin/env bash
set -euo pipefail

# Log to stderr — safe
echo "Checking path: $(echo "$1")" >&2

# Read stdin
input=$(cat)
tool=$(echo "$input" | jq -r '.tool_name')

echo "Tool called: $tool" >&2

# Output JSON to stdout only
echo '{"decision":"allow"}'
```

### Matcher specificity

Avoid catch-all matchers. Specify exact tools to prevent spawning
processes for irrelevant events:

```json
"matcher": "write_file|replace|create_file"
```

### Timeouts

Set strict timeouts on fast validators to prevent agent hangs:

```json
{ "timeout": 3000 }
```

### Caching

Cache expensive computations between invocations using timestamped
files. Hourly keys balance freshness with performance.

### Testing hooks independently

Test scripts with sample input before wiring them in:

```bash
echo '{"event":"BeforeTool","tool_name":"write_file","tool_input":{"path":"test.ts"}}' \
  | .gemini/hooks/security-check.sh
```

### Logging

Write to dedicated log files with timestamps for complex debugging:

```bash
echo "$(date -u +%FT%TZ) $tool" >> /tmp/gemini-hooks.log
```

---

## Examples

### Block writes outside project directory

```bash
#!/usr/bin/env bash
set -euo pipefail
input=$(cat)
path=$(echo "$input" | jq -r '.tool_input.path // empty')
project_dir="${GEMINI_PROJECT_DIR:-}"

if [[ -n "$path" && -n "$project_dir" ]]; then
  real_path=$(realpath "$path" 2>/dev/null || echo "$path")
  if [[ "$real_path" != "$project_dir"* ]]; then
    echo "Path outside project: $real_path" >&2
    printf '{"decision":"deny","reason":"Path is outside project root."}'
    exit 0
  fi
fi

printf '{"decision":"allow"}'
```

Configure in `.gemini/settings.json`:

```json
{
  "hooks": {
    "BeforeTool": [
      {
        "matcher": "write_file|create_file|replace",
        "hooks": [
          {
            "name": "path-guard",
            "type": "command",
            "command": "$GEMINI_PROJECT_DIR/.gemini/hooks/path-guard.sh",
            "timeout": 3000,
            "description": "Block writes outside project root"
          }
        ]
      }
    ]
  }
}
```

### Inject git context before each agent turn

```bash
#!/usr/bin/env bash
set -euo pipefail
branch=$(git -C "${GEMINI_PROJECT_DIR}" rev-parse --abbrev-ref HEAD 2>/dev/null)
log=$(git -C "${GEMINI_PROJECT_DIR}" log --oneline -5 2>/dev/null)
context="Branch: ${branch}\nRecent commits:\n${log}"
printf '{"hookSpecificOutput":{"hookEventName":"BeforeAgent","additionalContext":"%s"}}' \
  "$(echo "$context" | sed 's/"/\\"/g')"
```

### Detect secrets before file writes

```bash
#!/usr/bin/env bash
set -euo pipefail
input=$(cat)
content=$(echo "$input" | jq -r '.tool_input.content // empty')

# Check for common secret patterns
if echo "$content" | grep -qE \
  'AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{36}|sk-[A-Za-z0-9]{48}'; then
  printf '{"decision":"deny","reason":"Possible secret detected in content."}'
  exit 0
fi

printf '{"decision":"allow"}'
```

### Log all tool calls for audit

```bash
#!/usr/bin/env bash
set -euo pipefail
input=$(cat)
tool=$(echo "$input" | jq -r '.tool_name // "unknown"')
ts=$(date -u +%FT%TZ)
echo "${ts} session=${GEMINI_SESSION_ID} tool=${tool}" \
  >> /tmp/gemini-audit.log 2>&1
# AfterTool — no blocking capability; just return empty
printf '{}'
```
