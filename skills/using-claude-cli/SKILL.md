---
name: using-claude-cli
description: Use when instructed to run Claude CLI (`claude`) commands for
  interactive coding sessions, non-interactive execution, resume flows, agent
  selection, permission controls, or MCP configuration. Invoke before running
  any claude command.
---

# Using Claude CLI (claude)

Use this skill when the task requires Claude Code CLI operations through
`claude`.

## Load Order

1. Load `references/overview.md` first.
2. Load `references/examples.md` when mapping intent to commands.
3. Load `references/troubleshooting.md` when blocked or recovering.

## Operating Rules

- Announce usage at start:
  `I'm using the using-claude-cli skill for Claude CLI operations.`
- Prefer non-interactive runs for automation with `-p` and explicit flags.
- Include complete task context in `-p` prompts; no hidden chat context exists.
- Default to safe permission modes and tool restrictions unless the user asks
  for broader autonomy.
- Use `--output-format json` or `stream-json` when machine-readable output is
  needed.
- Do not run destructive actions without explicit user approval.

## Workflow

1. Confirm prerequisites and repository context.
2. Choose interactive or print mode based on task needs.
3. Set permission mode, tool allow/deny, and directory scope intentionally.
4. Execute the narrowest command that satisfies the request.
5. Verify outputs and resulting files before reporting completion.
6. Report command(s), key outputs, and any residual risks.

## Prerequisites

- `claude` is installed and reachable.
- Authentication is valid.
- Target directory and model requirements are known.

Checks:

```bash
claude --version
claude auth status
```

## Hard Rules

- Never rely on interactive prompts for automation workflows.
- Never bypass permissions unless user intent is explicit and risk is accepted.
- Never grant broad tool access when narrower allowlists satisfy the task.
- Never claim success without validating outputs or changed files.

## Definition Of Done

- Requested Claude CLI operation completed with reproducible commands.
- Output is captured in the required format and validated.
- User receives concise results, blockers, and next action if needed.
