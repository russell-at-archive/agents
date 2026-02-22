# Claude Agent SDK: Troubleshooting

## Contents

- [Installation and auth errors](#installation-and-auth-errors)
- [Hook not firing](#hook-not-firing)
- [Hook blocks unexpected tool calls](#hook-blocks-unexpected-tool-calls)
- [Modified input not applied](#modified-input-not-applied)
- [Session resume returns empty history](#session-resume-returns-empty-history)
- [Subagent permission prompts multiplying](#subagent-permission-prompts-multiplying)
- [Custom tools not available to Claude](#custom-tools-not-available-to-claude)
- [Agent stops too early](#agent-stops-too-early)
- [Recursive hook loops](#recursive-hook-loops)
- [Hook exception interrupts agent](#hook-exception-interrupts-agent)
- [SessionStart/SessionEnd not firing in Python](#sessionstartsessionend-not-firing-in-python)
- [Anti-patterns](#anti-patterns)

---

## Installation and Auth Errors

**`CLINotFoundError`**

The Claude Code CLI binary is missing or misconfigured.

```bash
pip install --upgrade claude-agent-sdk
```

To use a custom binary path:

```python
options = ClaudeAgentOptions(cli_path="/usr/local/bin/claude")
```

**`CLIConnectionError`**

- Verify `ANTHROPIC_API_KEY` is set and valid.
- For Bedrock: `CLAUDE_CODE_USE_BEDROCK=1` and AWS credentials configured.
- For Vertex: `CLAUDE_CODE_USE_VERTEX=1` and GCP credentials configured.
- For Azure: `CLAUDE_CODE_USE_FOUNDRY=1` and Azure credentials configured.

**`ProcessError`**

Inspect `e.exit_code`. Common causes:

- Tool not in `allowed_tools` — agent attempted a blocked operation
- `cwd` path does not exist
- Model quota exceeded

---

## Hook Not Firing

1. Event name is case-sensitive. Use `"PreToolUse"` not `"preToolUse"`.
2. Check that the hook is registered under the correct event key in `options.hooks`.
3. Verify the `matcher` regex against the actual tool name. Add a no-matcher
   global logger to see all tool names as they fire:

   ```python
   async def debug_all_tools(input_data, tool_use_id, context):
       print(f"[HOOK] {input_data['hook_event_name']} | {input_data.get('tool_name')}")
       return {}

   options = ClaudeAgentOptions(
       hooks={"PreToolUse": [HookMatcher(hooks=[debug_all_tools])]}
   )
   ```

4. Hooks may not fire when the agent hits `max_turns` because the session
   ends before hooks can execute. Increase `max_turns` if needed.
5. MCP tool names follow the pattern `mcp__<server>__<action>`. Use
   `matcher="^mcp__"` to match all MCP tools.

---

## Hook Blocks Unexpected Tool Calls

- Check all `PreToolUse` hooks for accidental `permissionDecision: "deny"` returns.
- An empty matcher (`HookMatcher(hooks=[...])`) matches **every** tool call.
- Priority rule: `deny` > `ask` > `allow` — if any hook denies, the tool is blocked.
- Add logging to each hook to surface which one is denying and why.

---

## Modified Input Not Applied

`updatedInput` must be inside `hookSpecificOutput` and must be accompanied by
`permissionDecision: "allow"`. Returning `updatedInput` at the top level has no effect.

```python
# Wrong — updatedInput at top level, ignored
return {"updatedInput": {"file_path": "/sandbox/file.txt"}}

# Correct
return {
    "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "allow",
        "updatedInput": {"file_path": "/sandbox/file.txt"},
    }
}
```

Always return a new dict; never mutate `input_data["tool_input"]` in place.

---

## Session Resume Returns Empty History

Sessions are stored under `~/.claude/projects/<encoded-cwd>/`. The `<encoded-cwd>`
is the absolute working directory with every non-alphanumeric character replaced
by `-`. If your resume call runs from a different directory, the SDK looks in the
wrong location.

Fix: ensure `cwd` in `ClaudeAgentOptions` matches the original session's working
directory exactly, or pass it explicitly:

```python
options = ClaudeAgentOptions(
    resume=session_id,
    cwd="/Users/me/myproject",  # Must match original session's cwd
)
```

Cross-host resume: copy `~/.claude/projects/<encoded-cwd>/<session-id>.jsonl`
to the same absolute path on the new host.

---

## Subagent Permission Prompts Multiplying

Subagents do not inherit parent agent permissions. Each subagent session may
prompt separately for tools.

Fix: use `PreToolUse` hooks to auto-approve specific tools in subagent sessions,
or set `permission_mode="acceptEdits"` in the parent options (it propagates to
subagents for file operations):

```python
async def auto_approve_reads(input_data, tool_use_id, context):
    if input_data["tool_name"] in ["Read", "Glob", "Grep"]:
        return {
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "allow",
            }
        }
    return {}
```

---

## Custom Tools Not Available to Claude

- Custom tools (`@tool` + `create_sdk_mcp_server`) require `ClaudeSDKClient`,
  not `query()`. They will not work with the standalone `query()` function.
- The tool name in `allowed_tools` must exactly match `mcp__<server>__<tool-name>`.
- Verify the server name matches the key used in `mcp_servers`:

  ```python
  server = create_sdk_mcp_server(name="my-tools", ...)
  options = ClaudeAgentOptions(
      mcp_servers={"my-tools": server},       # key is "my-tools"
      allowed_tools=["mcp__my-tools__greet"],  # must match key
  )
  ```

---

## Agent Stops Too Early

The agent hits `max_turns` before completing the task.

```python
options = ClaudeAgentOptions(
    max_turns=50,  # Increase from default
    allowed_tools=["Read", "Edit", "Bash"],
)
```

If the `ResultMessage.subtype` is `"error_max_turns"`, resume the session with
a higher `max_turns`:

```python
options = ClaudeAgentOptions(resume=session_id, max_turns=100)
```

---

## Recursive Hook Loops

A `UserPromptSubmit` hook that spawns subagents can cause infinite loops if
those subagents trigger the same hook.

Prevention:

- Check `input_data.get("parent_tool_use_id")` inside the hook — subagent
  turns will have this set; top-level turns will not.
- Guard with a module-level flag or session-scoped variable.

---

## Hook Exception Interrupts Agent

An unhandled exception in a hook callback propagates and can stop the agent.

Always wrap hook logic in `try/except`:

```python
async def safe_hook(input_data, tool_use_id, context):
    try:
        await do_something_risky(input_data)
    except Exception as e:
        print(f"Hook error (non-fatal): {e}")
    return {}
```

For async side-effect hooks (logging, webhooks), use `async_` mode so a
failure never blocks the agent:

```python
async def fire_and_forget(input_data, tool_use_id, context):
    asyncio.create_task(send_webhook(input_data))
    return {"async_": True, "asyncTimeout": 10000}
```

---

## SessionStart/SessionEnd Not Firing in Python

`SessionStart` and `SessionEnd` are not available as Python SDK callback hooks.
They are TypeScript-only for programmatic callbacks.

In Python, these events are available as shell command hooks in `.claude/settings.json`.
To load them, use `setting_sources`:

```python
options = ClaudeAgentOptions(setting_sources=["project"])
```

Alternatively, use the first message from `client.receive_response()` as the
session-start trigger in Python.

---

## Anti-Patterns

| Anti-pattern | Problem | Fix |
|---|---|---|
| `allowed_tools` omitted | Grants broad default access | Always specify the minimum tool set |
| `permission_mode="bypassPermissions"` without approval | Security risk | Require explicit user sign-off |
| Using `query()` with custom tools | Tools not registered | Switch to `ClaudeSDKClient` |
| Hook callback raises without `try/except` | Interrupts agent | Always wrap in try/except |
| Session `resume` without session ID capture | Resumes wrong session | Capture from `ResultMessage.session_id` |
| `fork_session=True` without `resume` | Fork has no history to branch | Always combine `fork_session` with `resume` |
| Treating agent output as ground truth | Hallucinations or errors | Validate outputs before using results |
| Subagents spawned without `"Task"` in `allowed_tools` | Task tool blocked | Add `"Task"` to parent `allowed_tools` |
| Mutable `tool_input` in `updatedInput` | Unexpected side effects | Always return a new dict |
| Async HTTP in hook without error handling | Failed webhook stops agent | Wrap in try/except; use `async_` for fire-and-forget |
