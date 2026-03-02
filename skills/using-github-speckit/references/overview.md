# Overview

## Purpose

Use GitHub Spec Kit as the default workflow for planning software work
before implementation.

## Command Sequence

Follow this order unless the user explicitly requests a different flow:

1. `/constitution` when guardrails are missing
2. `/specify`
3. `/clarify` when requirements are unclear
4. `/plan`
5. `/tasks`
6. `/implement` only when explicitly requested

Treat `/specify`, `/plan`, and `/tasks` as mandatory for planning.

## Stage Goals

### `/constitution`

Set project-wide constraints and decision principles.
Run once per project, then reuse.

### `/specify`

Define user outcomes, constraints, scope, and measurable success.
Make acceptance intent visible before design.

### `/clarify`

Resolve ambiguity and edge cases.
Record defaults for unresolved areas.

### `/plan`

Produce technical design with architecture, interfaces, data impacts,
tradeoffs, risks, rollout plan, and validation approach.

### `/tasks`

Decompose the approved plan into ordered, dependency-aware,
independently verifiable tasks.
Each task needs acceptance criteria.

### `/implement`

Only execute after the user asks to proceed.
Do not auto-transition from planning to coding.

## Interaction Pattern

1. Restate scope in one sentence.
2. Draft `/specify` content.
3. List open questions.
4. Run `/clarify` if unresolved ambiguity remains.
5. Produce `/plan` with explicit decisions.
6. Produce `/tasks` with ordering and acceptance criteria.
7. Ask whether to proceed to `/implement`.

## Quality Gates

Before final output, verify all are true:

- Scope is one feature or one project slice.
- Success criteria are measurable.
- In-scope and out-of-scope boundaries are explicit.
- Plan includes decisions and tradeoffs, not just a checklist.
- Tasks are small, testable, and dependency-aware.
- Risks, mitigations, and validation are present.

## Primary References

- <https://github.com/github/spec-kit>
- <https://github.com/github/spec-kit/blob/main/README.md>
