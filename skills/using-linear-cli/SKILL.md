---
name: using-linear-cli
description: Uses the Linear CLI (`linear` / `schpet/linear-cli`) for issue management, team and project queries, document CRUD, milestone tracking, raw GraphQL, and VCS-aware workflows. Invoke whenever the user asks to run `linear` commands, create/update/delete Linear issues or documents, list projects or milestones, authenticate to Linear, bootstrap `.linear.toml`, use `linear api` for GraphQL queries, or extract issue context from a git branch. Also trigger when the user mentions `LINEAR_API_KEY`, `schpet/linear-cli`, or integrating Linear into shell scripts or CI pipelines.
---

# Using Linear CLI

The `linear` CLI (`schpet/linear-cli`) is a terminal-first, agent-friendly
interface to Linear. It is VCS-aware: commands like `linear issue view` and
`linear issue id` auto-detect the current issue from the git branch name or jj
commit trailers.

If `linear` is not installed, read [references/installation.md](references/installation.md).

For the complete command reference, read [references/overview.md](references/overview.md).

For practical examples and automation patterns, read [references/examples.md](references/examples.md).

## Core principles

- Prefer explicit flags over interactive prompts — use `--title`, `--team`, etc.
- Use `--description-file`, `--body-file`, or `--content-file` for any markdown
  content; inline strings break on newlines and special characters.
- Always verify VCS context with `linear issue id` before relying on it.
- Use explicit issue IDs (e.g. `ENG-123`) when context detection may be unreliable.
- Gate all delete operations: confirm with the user before running any
  `linear ... delete` command.
- Use `-w <slug>` when multiple workspaces are configured.

## Quick diagnostics

```bash
linear --version          # confirm binary present
linear auth whoami        # confirm identity and workspace
linear auth list          # list all configured workspaces
linear issue id           # confirm VCS context resolves
```

If auth fails: run `linear auth login` or check the `LINEAR_API_KEY` env var.

If the binary is missing: read [references/installation.md](references/installation.md).

If errors persist: read [references/troubleshooting.md](references/troubleshooting.md).
