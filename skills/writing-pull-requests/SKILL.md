---
name: writing-pull-requests
description: Writes and updates high-quality pull request descriptions that speed review and improve auditability. Use when asked to draft, improve, or review a PR body, PR summary, reviewer guide, test plan, or merge request description.
---

# Writing Pull Requests

## Overview

Produces review-ready pull request descriptions focused on decision quality,
risk visibility, and fast reviewer verification. Full operating procedure:
[references/overview.md](references/overview.md).

## When to Use

- Asked to write, rewrite, or improve a PR description
- A PR body is missing key context, risks, or validation detail
- A reviewer needs a reproducible test and verification path
- A change is AI-assisted and needs explicit reasoning traceability

## When Not to Use

- Writing issue tickets, ADRs, or product specs without a PR context
- Summarizing commit history without reviewer-facing guidance
- Generating release notes for shipped changes

## Prerequisites

- Diff summary or change intent is available
- Linked issue/task ID is known or explicitly unavailable
- Validation evidence exists (commands, screenshots, logs, metrics)

## Workflow

1. Read [references/overview.md](references/overview.md) for structure,
   sizing rules, and quality bars.
2. Use [references/examples.md](references/examples.md) to match the PR
   type and detail level.
3. Apply [references/troubleshooting.md](references/troubleshooting.md)
   when information is missing, contradictory, or too risky to infer.
4. Output a complete PR description with explicit reviewer actions.

## Hard Rules

- Explain why and trade-offs, not a line-by-line diff recap
- Include issue linkage with `Closes #NNN` or `Refs #NNN` when possible
- Document risk, rollback, and validation signals for non-trivial changes
- Keep claims evidence-based; do not invent test results or metrics
- Call out breaking behavior, migrations, and operator impact explicitly

## Failure Handling

- If evidence is missing, mark unknowns and request exact inputs needed
- If scope is too broad, propose splitting into smaller PRs
- If risk is high and mitigation is unclear, block ready-for-review wording

## Red Flags

- Vague language with no reviewer verification steps
- No alternatives considered for consequential design choices
- Missing rollback plan for infra, schema, or auth changes
- Large mixed-scope PR presented as a single concern
