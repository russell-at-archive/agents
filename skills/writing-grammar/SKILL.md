---
name: writing-grammar
description: Applies a rigorous, line-by-line English grammar review to a
  document and produces precise corrections. Use when a user asks for
  grammar review, proofreading, copyediting, or publication-quality grammar
  cleanup.
---

# Grammar Review Skill

## Overview

Runs a deterministic grammar review workflow with explicit findings,
severity tags, and corrected rewrites.
Full procedure: [references/overview.md](references/overview.md)

## When to Use

- The user asks to review grammar, proofread, or improve correctness
- A document needs pre-publication grammar quality checks
- Consistency and auditability matter more than writing speed

## When Not to Use

- The user only wants stylistic tone changes, not grammar correction
- The task is pure markdown linting without language-quality review
- The user requests domain-fact verification rather than language edits

## Prerequisites

- The target text is available and complete enough to review
- The intended dialect is known (`US` or `UK`) or safely assumed
- Scope is defined: review-only report vs direct rewrite

## Workflow

1. Load [references/overview.md](references/overview.md).
2. Load [references/checklist.md](references/checklist.md).
3. Execute the review protocol and severity model exactly.
4. Use [references/examples.md](references/examples.md) for output shape.
5. Use [references/troubleshooting.md](references/troubleshooting.md) for
   edge cases.

## Hard Rules

- Review every sentence; never sample.
- Quote offending text exactly before suggesting corrections.
- Preserve technical meaning, identifiers, and commands.
- Separate objective grammar errors from optional style improvements.
- If rewriting, keep structure unless user asks for restructuring.

## Failure Handling

- If intent is unclear, ask whether the user wants `review` or `rewrite`.
- If dialect is ambiguous and it affects corrections, state assumption.
- If text quality blocks reliable interpretation, flag uncertainty.

## Red Flags

- "No issues found" without documenting full checklist application
- Silent rewrites that omit what changed and why
- Over-correcting domain terminology that is intentionally specific
