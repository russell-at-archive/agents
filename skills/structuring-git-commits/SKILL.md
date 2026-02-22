---
name: structuring-git-commits
description: Structures repository changes into small, reviewable, and safe git
  commits. Use when asked to split work into atomic commits, decide commit
  boundaries, stage hunks, or order commits before pushing or opening a pull
  request.
---

# Structuring Git Commits

## Overview

Turns a mixed working tree into a clean commit series with clear intent and
low review risk. Full procedure, boundary tests, and ordering details:
[references/overview.md](references/overview.md).

## When to Use

- The user asks to split changes into multiple commits.
- Staged or unstaged edits mix unrelated concerns.
- A branch needs a clean history before review.
- The user asks for help with commit boundaries or staging strategy.

## When Not to Use

- The request is only to format commit messages.
- The user explicitly wants a single squashed checkpoint commit.
- The repository is in merge-conflict recovery not ready for commit planning.

## Prerequisites

- A git repository with local changes.
- Permission to inspect status and diffs.
- A clear feature or fix goal for the branch.

## Workflow

1. Inventory changes by file and hunk (`git status`, `git diff`).
2. Group hunks by intent: behavior, refactor, tests, docs, or tooling.
3. Validate boundaries with the tests in
   [references/overview.md](references/overview.md).
4. Stage one logical unit at a time; prefer patch staging when needed.
5. Order commits so each one keeps the branch buildable and understandable.
6. Check final sequence quality with
   [references/examples.md](references/examples.md).
7. If anything is ambiguous or risky, use
   [references/troubleshooting.md](references/troubleshooting.md).

## Hard Rules

- One logical change per commit.
- Never mix mechanical formatting with behavioral changes unless unavoidable.
- Every commit must either keep tests green or clearly isolate the breakage.
- Commit order must respect dependency flow from base changes to consumers.
- Do not hide risky changes inside large "cleanup" commits.

## Failure Handling

- If boundaries are unclear, stop and propose two candidate split plans.
- If patch staging cannot isolate intent, create a temporary safety stash and
  restage deliberately.
- If the branch cannot be kept buildable, call it out and explain the minimum
  acceptable exception.

## Red Flags

- Commit touches many unrelated directories with no shared intent.
- Subject needs "and" to describe the change.
- Tests are only updated in a later commit after behavior changed.
- Large rename or formatting sweep appears with logic edits.
- Reviewer cannot revert one commit without breaking unrelated work.
