---
name: writing-git-commits
description: Writes and validates git commit messages using Conventional
  Commits. Use when drafting or revising commit messages, selecting type/scope,
  or adding commit body and footer metadata after commit boundaries are already
  decided.
---

# Writing Git Commits

## Overview

Produces precise, lint-like git commit messages that follow Conventional
Commits for readability, automation, and release hygiene.
Detailed guidance: `references/overview.md`.

## When to Use

- The user asks for a commit message draft or rewrite.
- The user asks which Conventional Commit type or scope to use.
- A commit needs a body, footer, issue reference, or breaking-change footer.
- A staged diff exists and the next step is message authoring.

## When Not to Use

- The main need is splitting mixed changes into multiple commits.
- The request is branch naming, PR writing, or changelog authoring.
- The repository is in conflict resolution and no commit is ready yet.

## Prerequisites

- Repository context and staged or intended commit content are available.
- The logical commit boundary is already chosen.

## Workflow

1. Load `references/overview.md` for core procedure and constraints.
2. Load `references/examples.md` for concrete command or prompt forms.
3. Load `references/troubleshooting.md` for recovery and stop conditions.

## Hard Rules

- Commit subject must follow Conventional Commits syntax.
- Subject must be imperative, lowercase, no period, and <= 72 characters.
- Breaking changes must include both `!` and a `BREAKING CHANGE:` footer.
- If staged changes are clearly mixed, stop and defer to commit structuring.

## Failure Handling

- If type or scope is ambiguous, propose top candidate plus one alternative.
- If commit boundaries are unclear, stop and recommend a split-first workflow.
- On tool/auth failures, report exact error and next required action.

## Red Flags

- Subject contains vague terms like `misc`, `update`, or `wip`.
- Subject describes more than one change (often includes `and`).
- Footer includes `BREAKING CHANGE` but subject lacks `!`.
- Staged changes span unrelated concerns.
