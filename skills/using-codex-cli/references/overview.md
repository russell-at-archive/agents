# Overview

Codex CLI does not automatically inherit task context from your current
conversation. Treat prompt completeness, execution scope, and output handling
as first-class concerns.

## Command Selection

Use the narrowest command that matches the task:

- `codex [PROMPT]`: start an interactive session in the terminal UI
- `codex exec [PROMPT]`: run a non-interactive task
- `codex exec resume`: continue a prior non-interactive session
- `codex review`: run review mode against `--uncommitted`, `--base`, or
  `--commit`
- `codex resume`: reopen an interactive session
- `codex fork`: branch a prior interactive session into a new one
- `codex apply <TASK_ID>`: apply the latest diff from a Codex task locally
- `codex login`, `logout`: manage authentication
- `codex mcp ...`: inspect and manage MCP servers
- `codex sandbox ...`: run commands inside Codex-managed sandbox helpers

## Safety Model

- For interactive sessions, explicitly choose `-s read-only`,
  `-s workspace-write`, or `-s danger-full-access` when the default matters.
- `--full-auto` is the low-friction sandboxed mode. In the current CLI it maps
  to approval-on-request plus `workspace-write`; it is not an unsandboxed mode.
- `--dangerously-bypass-approvals-and-sandbox` removes both approvals and
  sandboxing. Use it only with explicit user intent and external containment.
- Use `--add-dir <path>` only when the primary root set by `-C <dir>` is not
  sufficient.
- Use `--skip-git-repo-check` only for tasks that genuinely do not need repo
  context.

## Output and Automation

- Use `-o <file>` when you need the final assistant message captured for later
  integration.
- Use `--json` when another tool will consume the event stream.
- Use `--output-schema <file>` when the final response shape must be enforced.
- Use `--ephemeral` for one-shot runs that should not persist session state.
- Use unique output paths for concurrent jobs.

## Prompt Contract

Include all of the following in any `codex exec` prompt:

- objective
- exact working root or repo name
- relevant files or directories
- constraints and forbidden edits
- expected output format
- validation commands or checks

Use this template:

```markdown
# Task
[single-sentence objective]

## Context
- Working root: [/absolute/path]
- Relevant files: [paths]

## Constraints
- Change only: [paths]
- Do not modify: [paths]
- Output: [summary | patch | checklist | JSON-compatible shape]

## Validation
[commands Codex should run before finishing]
```

## High-Value Flags

| Flag | Purpose |
| ---- | ------- |
| `-C <DIR>` | Set working root explicitly |
| `--add-dir <DIR>` | Extend writable scope |
| `-s <MODE>` | Choose sandbox mode for interactive runs |
| `--full-auto` | Sandbox-backed low-friction execution |
| `-o <FILE>` | Capture final message |
| `--json` | Emit JSONL events |
| `--output-schema <FILE>` | Constrain final response shape |
| `--ephemeral` | Avoid session persistence |
| `--search` | Enable web search for that run |
| `-m <MODEL>` | Select model |
| `-p <PROFILE>` | Apply config profile |
| `-c key=value` | Override config.toml values |
