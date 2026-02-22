---
name: using-graphite-cli
description: Use when instructed to perform any git operation; branching,
  committing, pushing, syncing, creating pull requests, or managing stacks.
  Must be invoked before using git or gh commands.
---

# Using Graphite CLI (gt)

Use this skill for stack-safe source control operations with Graphite CLI.
Graphite is the default control plane for branch creation, restacking, sync,
and PR submission.

Current local reference version: `gt 1.7.17`.

## Load Order

1. Load `references/overview.md` first.
2. Load `references/examples.md` when translating intent to commands.
3. Load `references/troubleshooting.md` only when blocked or recovering.

## Operating Rules

- Announce usage at start:
  `I'm using the using-graphite-cli skill for stack-safe git operations.`
- Prefer `gt` over raw `git`/`gh` whenever a `gt` equivalent exists.
- Use raw `git` only for inspection or staging (`status`, `diff`, `add`,
  `stash`) and for conflict resolution steps requested by `gt`.
- Do not run destructive operations (`gt delete`, force pushes, branch
  rewrites) without explicit user approval.
- Keep branches small and stack-aware; submit through `gt submit`.
- If `gh` is required, invoke the `using-github-cli` skill first.

## Workflow

1. Verify prerequisites: `gt` installed, repo initialized with `gt init`,
   auth configured, trunk known.
2. Inspect working tree and stack state before mutation.
3. Execute the minimal `gt` command sequence for the task.
4. Restack or sync when branch ancestry may have changed.
5. Submit/update PRs with explicit reviewer and publish intent.
6. Re-check resulting stack graph and report outcomes.

Use exact command guidance from `references/overview.md`.

## Output Standard

When reporting completion, include:

- commands run
- resulting branch/stack state
- PR numbers or URLs when submitted
- unresolved risks, conflicts, or follow-up actions

## Failure Handling

- On missing prerequisites, stop and request only the missing input.
- On command failure, report exact command, exact error, and next action.
- On rebase conflicts, follow Graphite recovery flow (`gt continue` or
  `gt abort`) before any new mutation.

## Definition Of Done

- Requested git/stack operation completed using Graphite-first workflow.
- Stack graph is consistent (`gt log` or equivalent verification).
- PR submission state matches user intent (draft/published, reviewers).
