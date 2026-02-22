---
name: writing-markdown
description: Produces markdownlint-compliant markdown files with zero lint
  errors. Use when writing or editing any .md file, README, ADR, PRD, task
  spec, or PR description.
---

# Writing Markdown

## Overview

Produces markdown documents that exit markdownlint with zero errors. Every
file written or modified must pass a lint run before completion is reported.
For the full procedure, config setup, and fixing strategy, read
[references/overview.md](references/overview.md).

## When to Use

- Writing or rewriting any `.md` file
- Cleaning up existing markdown for lint compliance
- Producing README, ADR, PRD, task spec, or PR description files

## When Not to Use

- Grammar-only review with no markdown structure changes
- Non-markdown content
- Another skill already owns the format and enforces markdownlint

## Prerequisites

- `markdownlint-cli2` available; `markdownlint` as fallback
- Target `.md` files identified before starting

## Workflow

1. Check for a markdownlint config in the project root. If none exists,
   place the default config per
   [references/overview.md](references/overview.md).
2. Run lint on existing files before editing to capture a baseline.
3. Write or edit using [references/rules.md](references/rules.md) for rule
   guidance and [references/patterns.md](references/patterns.md) for
   copy-ready patterns.
4. Lint after every edit pass. Fix all reported errors.
5. For persistent failures, consult
   [references/troubleshooting.md](references/troubleshooting.md).
6. Repeat until lint exits with zero errors.
7. Report the zero-error result explicitly.

## Hard Rules

- Do not report completion until a lint run confirms zero errors.
- Do not suppress lint errors with config overrides unless the user asks.
- Do not change document meaning while fixing lint violations.
- Do not convert tables to lists without explicit user approval.
- Every fenced code block must have a language identifier.

## Failure Handling

- If lint tooling is missing, fall back to `markdownlint`; if both are
  missing, enumerate violations by inspection and state that the
  zero-error gate cannot be verified without the tool.
- If a config conflict arises, explain the trade-off and ask the user
  before proceeding.
- If source content is ambiguous, ask one direct clarifying question.

## Red Flags

- Reporting success without a completed lint run
- Leaving any lint error unresolved
- Changing code block content during formatting
- Modifying the project lint config without user instruction
