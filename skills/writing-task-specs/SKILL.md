---
name: writing-task-specs
description: Breaks an approved feature plan or technical design into implementation-ready task specifications with clear scope, dependencies, acceptance criteria, and validation steps. Use when asked to decompose a plan, create implementation tasks, or prepare one-task-per-branch PR execution.
---

# Writing Task Specifications

## Overview

Produces implementation-ready task specs that maximize delivery throughput and
minimize integration risk. Core model: one task, one branch, one PR, one
verifiable outcome. Full procedure:
[references/overview.md](references/overview.md).

## When to Use

- Asked to break a plan into engineering tasks
- A technical design is approved and implementation planning is next
- Delivery needs dependency-aware branch and PR sequencing
- Task scope, acceptance criteria, or verification requirements are unclear

## When Not to Use

- The work is a trivial one-step change suitable for a single PR
- No approved plan or scope boundary exists yet
- The request is for a PR description, not task decomposition

## Prerequisites

- Approved source plan (spec, design, or PRD)
- Known constraints (stacking model, CI gates, repo standards)
- At least baseline module ownership and architectural boundaries

## Workflow

1. Read [references/overview.md](references/overview.md) for decomposition,
   dependency ordering, sizing limits, and quality checks.
2. Draft tasks with [references/template.md](references/template.md), ensuring
   each task is independently implementable and reviewable.
3. Calibrate detail and style with
   [references/examples.md](references/examples.md).
4. Apply [references/troubleshooting.md](references/troubleshooting.md) to fix
   scope bleed, hidden dependencies, and weak acceptance criteria.

## Hard Rules

- Every task maps to exactly one branch and one PR
- Every task includes explicit dependencies and stack parent
- Every task has measurable Given/When/Then acceptance criteria
- Validation commands must be runnable as written
- Do not mix unrelated concerns in the same task

## Failure Handling

- If prerequisites are missing, request exact missing artifacts first
- If decomposition creates circular or ambiguous dependencies, stop and
  re-slice tasks before continuing
- If any task cannot be verified independently, split or merge tasks until it
  can be verified

## Red Flags

- Task title contains multiple outcomes joined by "and"
- Acceptance criteria use non-measurable language ("works", "better")
- A task depends on implementation details not yet delivered
- Estimated scope suggests multi-PR execution
