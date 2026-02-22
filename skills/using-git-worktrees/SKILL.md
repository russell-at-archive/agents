---
name: using-git-worktrees
description: Create and manage isolated git worktrees for feature delivery.
  Use when starting implementation, splitting concurrent efforts, preserving a
  stable main workspace, or preparing stacked branch workflows with Graphite.
  Apply this skill for worktree directory selection, ignore safety checks,
  branch and worktree creation, project bootstrap, baseline validation,
  teardown after merge, and recovery from common worktree errors.
---

# Using Git Worktrees

Use this skill to create a clean, isolated workspace before implementation.
Follow the workflow in order. Do not skip safety or baseline verification.

## Load Order

1. Load `references/overview.md` first.
2. Load `references/examples.md` for command and reporting patterns.
3. Load `references/troubleshooting.md` only when blocked or recovering.

## Operating Rules

- Announce usage at start:
  `I'm using the using-git-worktrees skill to set up an isolated workspace.`
- Invoke `using-graphite-cli` before running any `git`, `gt`, `gh`, or
  Graphite-related command.
- Prefer existing project conventions over assumptions.
- Never create a project-local worktree before verifying the directory is
  ignored by git.
- Never proceed with a failing baseline without explicit user approval.
- Never use destructive cleanup commands unless required and approved.

## Workflow

1. Select worktree directory using this strict priority:
   existing directory, `CLAUDE.md` preference, then ask user.
2. Verify ignore safety for project-local directories.
3. Create worktree and base branch.
4. Run project dependency bootstrap.
5. Discover canonical validation commands.
6. Run baseline validation.
7. Report readiness with path and validation result.

Use exact command sequences from `references/overview.md`.

## Directory Policy

- Prefer `.worktrees/` when both `.worktrees/` and `worktrees/` exist.
- If neither exists, inspect `CLAUDE.md` for project guidance.
- If still unknown, ask the user to choose:
  `.worktrees/` or
  `~/.config/superpowers/worktrees/<project-name>/`.

## Validation Gates

Treat these as mandatory gates:

1. Ignore gate:
   project-local worktree path must be ignored before creation.
2. Bootstrap gate:
   dependencies and project setup must complete successfully.
3. Baseline gate:
   lint, typecheck, and tests must run with a clean result, or user explicitly
   approves proceeding with known failures.

## Required Output

After successful setup, report:

- Absolute worktree path.
- Commands run for setup and validation.
- Baseline status with pass or fail counts.
- Explicit statement that implementation can begin.

Use the response format shown in `references/examples.md`.

## Teardown Standard

When stack PRs are merged, execute full teardown from
`references/overview.md`:
worktree removal, trunk sync, branch deletion, prune, and issue closure.
Local branch deletion is mandatory even after `gt sync`.

## Failure Handling

- On missing prerequisites, stop and request the missing input.
- On tool failure, report exact command, exact error, and next action.
- On ambiguity, prefer asking the user over guessing repository policy.
- Use `references/troubleshooting.md` to resolve recurring failures.

## Definition Of Done

- Worktree exists at approved location.
- Project bootstrap completed.
- Baseline checks verified and reported.
- User has a clean, isolated workspace ready for implementation.
