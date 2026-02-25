# Overview

## Overview


Use this skill when the user wants a software planning workflow that:

- uses GitHub Spec Kit for planning artifacts
- uses git worktrees for implementation isolation
- uses Graphite stacked pull requests for delivery

Announce at start:
"I'm using the planning-speckit-worktrees-graphite skill to enforce
Spec Kit planning plus worktree and Graphite delivery gates."

## Required Skill Sequence


Use these skills in this order:

1. `using-github-speckit`
2. `using-git-worktrees`
3. `using-graphite-cli`

If implementation is requested, do not skip `using-git-worktrees` or
`using-graphite-cli`.

## Planning Command Pipeline


Follow this sequence unless the user explicitly asks otherwise:

1. `/constitution` if missing
2. `/specify`
3. `/clarify` when requirements are ambiguous
4. `/plan`
5. `/tasks`
6. `/implement` only after all gates pass

Treat `/specify`, `/plan`, and `/tasks` as mandatory for planning.

## Implementation Gates


All gates must pass before `/implement`.

### Gate A: Isolated Worktree

Implementation must run in a worktree, never in the main workspace.

Required actions:

1. Create and enter a worktree using `using-git-worktrees`.
2. Verify baseline project checks in the worktree.
3. Report the full worktree path before coding starts.

### Gate B: Graphite Workflow

All branch and PR operations must use Graphite stack workflow.

Required actions:

1. Sync and track with Graphite for the worktree branch context.
2. Create real work branches with `gt create`.
3. Keep each branch scoped to one logical task.

Do not use `git checkout -b`, `git push`, or `gh pr create` when a `gt`
equivalent exists.

### Gate C: Local Validation Before Submit

Before any PR submission:

1. Run the repository's required local checks.
2. Fix failures before submission.
3. Submit with `gt submit --stack --no-interactive --publish`.

Do not rely on CI as the first validation layer.

## Task Output Contract


When producing `/tasks`, include delivery structure, not only build tasks.

For each implementation task, include:

- task ID and concise scope
- planned branch name
- parent branch in stack
- acceptance criteria
- validation commands to run
- expected PR position in the stack

If the plan cannot be decomposed into small reviewable branches,
revise `/plan` before implementation.

## Branching and PR Policy


Use these rules by default:

- one focused branch per task slice
- one focused PR per branch
- stacked PRs in dependency order
- no mixed unrelated changes in one PR

If a single PR is requested, confirm it is intentional and document the
tradeoff in `/plan`.

## Minimum Done Criteria


A feature is not done until all are true:

1. Spec Kit artifacts are complete and coherent.
2. Implementation occurred in a worktree.
3. Changes are split into Graphite stack branches.
4. Local validation passed before submit.
5. Stack PRs are published and review-ready.

