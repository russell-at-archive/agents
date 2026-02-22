---
name: using-github-speckit
description: Use when asked to create a project plan, feature plan, or
  specification using GitHub Spec Kit, including prompts like "create a
  plan", "create a spec", "write a project spec", or "plan this feature".
  Enforce the Spec Kit command sequence and produce complete, review-ready
  planning artifacts.
---

# Using GitHub Spec Kit For Planning

## Overview

Follow GitHub Spec Kit as the default workflow for project and feature planning.

Use this command order unless the user explicitly requests a different flow:

1. `/constitution` (one-time project guardrails, if missing)
2. `/specify` (initial feature or project specification)
3. `/clarify` (optional but recommended to resolve ambiguity)
4. `/plan` (technical design and implementation approach)
5. `/tasks` (execution checklist)
6. `/implement` (optional, only when user asks to execute)

## Operating Rules

- Treat `/specify`, `/plan`, and `/tasks` as the minimum planning pipeline.
- Run `/clarify` before `/plan` when requirements are ambiguous.
- Do not skip `/plan` if the user asks for architecture or technical approach.
- Do not run `/implement` unless the user asks to start implementation.
- Keep each artifact tightly scoped to one feature or project slice.

## Standard Interaction Pattern

When asked to create a spec or plan, do this in order:

1. Confirm scope in one sentence.
2. Draft or refine input for `/specify`.
3. Identify open questions and run `/clarify` if needed.
4. Produce a concrete `/plan` output with architecture and milestones.
5. Produce `/tasks` with small, testable, dependency-aware steps.
6. Ask whether to proceed to `/implement`.

## Prompt Starters

Use these starter prompts and adapt to the user context.

### `/specify` starter

```text
/specify Build <feature name> for <product/project>.
Goal: <user outcome>.
Constraints: <time, platform, compliance, performance>.
Success criteria: <measurable outcomes>.
```

### `/clarify` starter

```text
/clarify Focus on unresolved requirements, edge cases, and non-functional
constraints for <feature name>. Propose defaults where requirements are missing.
```

### `/plan` starter

```text
/plan Create a technical implementation plan for <feature name>.
Include architecture, data model changes, API/UI changes, risks,
rollout strategy, and validation approach.
```

### `/tasks` starter

```text
/tasks Break the approved plan for <feature name> into ordered,
independently verifiable tasks with dependencies and acceptance criteria.
```

## Output Quality Bar

Ensure every planning package includes:

- Problem statement and in-scope versus out-of-scope boundaries
- Key assumptions and explicit open questions
- Architecture or design decisions with tradeoffs
- Delivery phases and task dependencies
- Test and validation strategy
- Rollback or risk mitigation notes

## Red Flags

Stop and correct the workflow if any of these appear:

- Jumping from idea directly to `/tasks` without `/plan`
- Writing implementation code when only a spec or plan was requested
- Missing success criteria or acceptance criteria
- Multi-feature scope packed into one spec without clear boundaries

## References

Use the official Spec Kit sources for command behavior and updates:

- <https://github.com/github/spec-kit>
- <https://github.com/github/spec-kit/blob/main/README.md>
