# Overview

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

## Output Quality Bar


Ensure every planning package includes:

- Problem statement and in-scope versus out-of-scope boundaries
- Key assumptions and explicit open questions
- Architecture or design decisions with tradeoffs
- Delivery phases and task dependencies
- Test and validation strategy
- Rollback or risk mitigation notes

## References


Use the official Spec Kit sources for command behavior and updates:

- <https://github.com/github/spec-kit>
- <https://github.com/github/spec-kit/blob/main/README.md>

