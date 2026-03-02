# Decomposition

## Purpose

Decomposition is the practice of breaking a complex problem, system, or
delivery goal into smaller parts that can be designed, built, tested,
and operated with lower risk.

Good decomposition creates clear boundaries, reduces coordination cost,
and improves delivery predictability.

## Core Concepts

- `Whole to parts`: Split large goals into coherent subproblems.
- `Boundaries`: Define what each part owns and what it does not.
- `Interfaces`: Specify contracts between parts.
- `Recomposition`: Ensure parts integrate into the intended whole.

## Why It Matters

- Makes complex work understandable and estimable.
- Enables parallel execution across teams.
- Limits blast radius when failures occur.
- Improves testability through smaller units.
- Supports incremental delivery and rollback.

## Decomposition Dimensions

Different views are useful for different risks:

- Functional: Break by features or user capabilities.
- Domain: Break by business entities and bounded contexts.
- Technical: Break by services, modules, or layers.
- Data: Break by ownership, lifecycle, and access patterns.
- Workflow: Break by stages in a process or pipeline.
- Time: Break by release increments and milestones.

## Design Principles

- Cohesion: Keep related behavior together.
- Loose coupling: Minimize dependencies between parts.
- Explicit contracts: Define inputs, outputs, and failure behavior.
- Replaceability: Make components swappable when feasible.
- Observability: Add ownership and measurable signals per part.
- Evolution: Allow decomposition to change as requirements shift.

## Decomposition Workflow

1. Define objective, scope, and success criteria.
2. Identify constraints, risks, and critical unknowns.
3. Choose decomposition dimension for current problem.
4. Draft components with responsibilities and boundaries.
5. Map dependencies and integration points.
6. Sequence work by risk and dependency order.
7. Validate design with walkthroughs and edge cases.
8. Execute incrementally and refine boundaries with feedback.

## Dependency Management

- Label dependencies as hard or soft.
- Isolate high-volatility interfaces behind adapters.
- Prefer one-directional dependency graphs.
- Create stubs or mocks to unblock parallel work.
- Track cross-part assumptions as explicit contracts.

## Common Failure Modes

- Splitting too early without clear objectives.
- Creating components with vague ownership.
- Hidden shared state across boundaries.
- Circular dependencies that block independent progress.
- Over-decomposition that adds unnecessary coordination overhead.
- Ignoring integration and only optimizing local parts.

## Evaluation Metrics

- Lead time per decomposed work item.
- Rework rate caused by boundary mistakes.
- Number of cross-team blockers per milestone.
- Defect concentration at integration boundaries.
- Percentage of items deliverable independently.

## Lightweight Decomposition Template

```text
Objective:
[target outcome]

Scope:
- In scope: [items]
- Out of scope: [items]

Components:
- [component A]: [responsibility]
- [component B]: [responsibility]

Interfaces:
- [A -> B]: [input/output contract]

Dependencies:
- Hard: [list]
- Soft: [list]

Delivery Plan:
- Increment 1: [slice]
- Increment 2: [slice]

Success Criteria:
- [measurable result 1]
- [measurable result 2]
```

## Practical Guidance

- Start with the minimum decomposition that lowers risk.
- Prefer vertical slices when user value must ship quickly.
- Prefer horizontal layers when platform consistency dominates.
- Revisit boundaries after each release cycle.
- Record rationale so future changes are easier.

## Summary

Decomposition is a leverage tool for complex delivery. Strong
decomposition balances clarity, independence, and integration so teams
can ship faster with fewer coordination failures.
