---
name: using-github-cli
description: Uses GitHub CLI (`gh`) for GitHub-native operations including pull requests, issues, Actions, releases, repository metadata, and authenticated REST or GraphQL API queries. Use when the user asks to run `gh` commands, manage GitHub resources, inspect CI runs, query GitHub data, or automate GitHub workflows.
---

# Using GitHub CLI

## Overview

Use `gh` as the default tool for GitHub-native operations. Prefer direct
subcommands such as `gh pr`, `gh issue`, `gh run`, `gh workflow`, `gh repo`, and
`gh release`; use `gh api` only when the dedicated subcommand is missing or too
limited.

For full command patterns, read [references/overview.md](references/overview.md).
For concrete command snippets, read
[references/examples.md](references/examples.md) when the task needs a starting
template. For setup or missing-binary cases, read
[references/installation.md](references/installation.md). For failures, read
[references/troubleshooting.md](references/troubleshooting.md).

## When to Use

- The user explicitly asks to use GitHub CLI or `gh`
- The task touches GitHub pull requests, issues, workflows, releases, or repos
- The task needs GitHub API access without hand-rolling raw `curl` requests
- The task needs machine-readable GitHub output for scripting or automation

## When Not to Use

- Local branch stacking or restacking is the main task; use `using-graphite-cli`
- Pure git history manipulation is the main task; use `git`
- The task is provider-neutral and does not need GitHub-specific behavior

## Prerequisites

- `gh` is installed and reachable in `PATH`
- Authentication is valid for the target host
- Repository context is explicit via local checkout, `GH_REPO`, or `--repo`

## Workflow

1. Validate context with `gh auth status` and explicit repository targeting when
   there is any ambiguity.
2. Choose the narrowest command family first: `pr`, `issue`, `run`,
   `workflow`, `release`, `repo`, `search`, then `api`.
3. Force non-interactive execution. Supply required flags and use
   `GH_PROMPT_DISABLED=1` when prompts are risky.
4. Prefer machine-readable output with `--json`, `--jq`, `--template`, or
   structured `gh api` responses.
5. For mutations, read the current state first, perform the write, then verify
   with a follow-up read.
6. Report the exact command path taken, the target resource, and the outcome.

## Hard Rules

- Prefer dedicated `gh` subcommands over `gh api` when both can do the job
- Prefer `--repo` in multi-repo, detached, or unclear working contexts
- Never scrape human-readable output when `--json` or `gh api` can provide
  structure
- Avoid interactive browser or editor flows unless the user explicitly wants
  them
- Use `--match-head-commit` for `gh pr merge` when merging a checked-out branch
- Treat destructive operations such as closing, deleting, canceling, or merging
  as write operations that require explicit target verification
- Do not use admin-only or policy-bypassing flags without explicit user intent

## Failure Handling

- If `gh` is missing, use
  [references/installation.md](references/installation.md)
- If auth or scopes fail, use
  [references/troubleshooting.md](references/troubleshooting.md)
- If a task outgrows built-in subcommands, switch to `gh api` with explicit
  method, fields, and pagination handling
- If the operation is risky and the target is ambiguous, stop and clarify before
  mutating anything

## Red Flags

- Running a mutating command against an implied repo
- Using `gh pr create` or `gh issue create` without fully specified flags in
  automation
- Mixing local git assumptions with cross-repo targets without `--repo`
- Replacing a one-command `gh` workflow with slower manual API plumbing
