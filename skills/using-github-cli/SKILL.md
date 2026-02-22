---
name: using-github-cli
description: Use when instructed to run GitHub CLI (`gh`) commands for pull
  request operations, issue management, workflow runs, releases, repository
  settings, or GitHub API queries. Invoke before running any gh command.
---

# Using GitHub CLI (gh)

Use this skill when the task requires GitHub operations through `gh`.

`gh` is the default tool for issues, Actions workflows, releases, and API
queries that are not better handled by Graphite.

## Load Order

1. Load `references/overview.md` first.
2. Load `references/examples.md` when mapping intent to commands.
3. Load `references/troubleshooting.md` only when blocked or recovering.

## Operating Rules

- Announce usage at start:
  `I'm using the using-github-cli skill for GitHub CLI operations.`
- If the task touches branch, stack, or PR branch management, invoke
  `using-graphite-cli` first and prefer `gt` for those operations.
- Prefer non-interactive commands with explicit flags.
- Prefer machine-readable output: `--json` plus `--jq` or `--template`.
- Use explicit repository targeting with `--repo <owner>/<repo>` when outside
  the current repo or when ambiguity exists.
- Do not run destructive actions without explicit user approval.

## Workflow

1. Confirm prerequisites and context.
2. Choose the narrowest `gh` command that satisfies the request.
3. Execute read-only inspection first when a write would be risky.
4. Run mutation commands with explicit flags and explicit repo targeting.
5. Verify outcome with a second read command.
6. Report commands run, outputs that matter, and any residual risks.

## Prerequisites

- `gh` is installed and accessible.
- Authentication is valid for the target host.
- Target repository is known or explicitly passed.

Use these checks when needed:

```bash
gh --version
gh auth status
gh repo set-default --view
```

## Hard Rules

- Never rely on interactive prompts in agent execution.
- Never parse human-readable output when JSON fields are available.
- Never mutate resources in an ambiguous repository context.
- Never perform irreversible actions without explicit user intent.

## Definition Of Done

- Requested GitHub operation completed with explicit, reproducible commands.
- Verification command confirms expected post-change state.
- User receives concise results, errors, and follow-up actions if needed.
