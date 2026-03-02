# Overview

Codex CLI runs outside your current conversation context. Pass complete task
state in every prompt.

## Command Selection

- `codex exec`: non-interactive task execution
- `codex review`: non-interactive code review workflow
- `codex exec resume`: continue a non-interactive session
- `codex resume`: continue an interactive session

## Safety and Scope Defaults

- Prefer `--full-auto` for unattended execution.
- Use `-C <dir>` to force the correct repo/worktree root.
- Add `--add-dir <path>` only when extra writable scope is required.
- Use `-s read-only` for analysis-only operations.
- Avoid `--dangerously-bypass-approvals-and-sandbox` unless explicitly
  requested in an externally sandboxed environment.

## Output Modes

- Human-readable summary file:

```bash
codex exec --full-auto -C /repo -o /tmp/codex-task.md "task prompt"
```

- Machine-readable event stream:

```bash
codex exec --full-auto -C /repo --json "task prompt"
```

- Minimal persistent footprint for one-shot jobs:

```bash
codex exec --full-auto -C /repo --ephemeral "task prompt"
```

## High-Value Flags

| Flag | Purpose |
| ---- | ------- |
| `--full-auto` | Alias for sandboxed low-friction execution |
| `-C <DIR>` | Set working root |
| `-o <FILE>` | Write last assistant message to file |
| `--json` | Emit JSONL events |
| `--ephemeral` | Run without session persistence |
| `--skip-git-repo-check` | Allow execution outside a git repo |
| `-m <MODEL>` | Choose model |
| `-i <FILE>` | Attach image(s) |
| `--search` | Enable web search tool for that run |

## Prompt Requirements

Always include:

- task objective
- repository and path context
- file boundaries and constraints
- expected output shape
- validation commands

Treat prompt completeness as mandatory, not optional.
