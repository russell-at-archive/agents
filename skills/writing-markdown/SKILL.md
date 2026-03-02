---
name: writing-markdown
description: Use when writing or editing any markdown document, README, or .md
  file to ensure strict compliance with all markdownlint rules.
---

# Writing Markdown That Passes Lint

## Overview

Produces markdown documents that pass markdownlint with zero errors.
Load the full protocol from [references/overview.md](references/overview.md).

## When to Use

- The user asks to write, rewrite, or clean up any markdown file
- The task includes README, docs, ADRs, PRDs, PR text, or task specs
- The output must pass markdownlint checks

## When Not to Use

- The task is grammar-only and does not require markdown lint compliance
- The task is non-markdown content
- Another narrower skill owns the format and already enforces markdownlint

## Prerequisites

- Target markdown files are known
- `markdownlint-cli2` is available; use `markdownlint` only as fallback
- Repository markdownlint config is respected when present

## Workflow

1. Read [references/overview.md](references/overview.md) before editing.
2. Apply structural and style fixes needed for lint compliance.
3. Run markdownlint on changed markdown files.
4. Repeat fix and lint until results are zero errors.
5. Use [references/examples.md](references/examples.md) for patterns.
6. Use
   [references/troubleshooting.md](references/troubleshooting.md) on failure.

## Hard Rules

- Do not report completion until markdownlint returns zero errors.
- Keep semantic meaning unchanged unless the user requested rewrites.
- Preserve tables when possible; do not convert to lists without need.
- Follow repository-specific markdownlint configuration when present.

## Failure Handling

- If lint tooling is missing, report exact command failure and next action.
- If the lint config conflicts with user constraints, call out the conflict.
- If source text is ambiguous, ask a direct clarifying question.

## Red Flags

- Claiming success without a lint run
- Leaving known lint errors unresolved
- Reformatting that changes meaning or code behavior
