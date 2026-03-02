# The Agent OS Operating Manual: Idea to Delivery

This document defines the end-to-end lifecycle for software delivery within this repository. It transforms the theoretical methodologies into a disciplined, repeatable execution pipeline.

---

## The Workflow at a Glance

```text
Discovery ──▶ Specification ──▶ Design ──▶ Planning ──▶ Implementation ──▶ Validation ──▶ Delivery
   (Why)          (What)         (How)      (When)         (Doing)           (Check)       (Done)
```

---

## Phase 1: Discovery & Intent (The "Why")
**Goal**: Normalize ambiguous user requests into a machine-verifiable contract.

1.  **Run Intake**: Use the `running-intake-discovery` skill.
2.  **Clarify**: Resolve ambiguities in the user's goal, constraints, and success criteria.
3.  **Produce Intent Contract**: Define a structured intent representation (Goal, Inputs, Constraints, Success Criteria).
4.  **Confirm**: The user approves the "Intent Contract" before proceeding.

*Related: `docs/methodologies/intent-engineering.md`, `ADR-005: Structured Intent Contracts`*

---

## Phase 2: Specification & Alignment (The "What")
**Goal**: Establish the authoritative source of truth for the feature.

1.  **Draft PRD**: Use `writing-product-requirement-documents` to define outcomes, metrics, and user stories.
2.  **Define Boundaries**: Identify what is in-scope and, crucially, what is **out-of-scope**.
3.  **Establish Truth**: The PRD is now the "Source of Truth." All implementation code is derived from this document.

*Related: `docs/methodologies/specification-engineering.md`, `ADR-006: Specification-as-Truth`*

---

## Phase 3: Technical Design & Architecture (The "How")
**Goal**: Model the domain and interfaces before writing implementation code.

1.  **Domain Modeling**: Use `modeling-domains` to identify Bounded Contexts and Aggregate Roots (DDD).
2.  **Negotiate Contracts**: Use `designing-api-contracts` to draft OpenAPI/GraphQL schemas (CDD).
3.  **Record Decisions**: Use `writing-adrs` to document any significant architectural tradeoffs or choices.

*Related: `docs/methodologies/domain-driven-design.md`, `docs/methodologies/contract-driven-development.md`*

---

## Phase 4: Planning & Decomposition (The "When")
**Goal**: Break the feature into small, atomic, and shippable increments.

1.  **Generate Tech Plan**: Use `using-github-speckit` to define the technical implementation details.
2.  **Decompose into Tasks**: Use `writing-task-specs` to create a list of executable tasks.
3.  **Enforce Sizing**: Every task must be < 400 lines and map to exactly one branch and one PR.
4.  **Define Stacks**: Determine the dependency order for the Graphite stack.

*Related: `docs/delivery-standards.md`, `ADR-002: Stacked Pull Requests`*

---

## Phase 5: Implementation Loop (The "Doing")
**Goal**: Execute the plan with 100% isolation and rigorous testing.

1.  **Isolate**: Create a dedicated environment for each task using `using-git-worktrees`.
2.  **Red-Green-Refactor**: Use `applying-test-driven-development` (TDD). Write the failing test first.
3.  **Implement**: Write the minimal code needed to pass the test.
4.  **Refactor**: Clean the code while maintaining the "Green" state.

*Related: `docs/methodologies/test-driven-development.md`, `ADR-001: Git Worktree Isolation`, `ADR-003: Hybrid TDD Strategy`*

---

## Phase 6: Validation & Review (The "Check")
**Goal**: Ensure the PR is "Review-Ready" before human or system review.

1.  **Run Quality Gates**: Use `running-quality-gates` to execute lint, types, and tests locally.
2.  **Verify DoD**: Confirm the task satisfies the "Definition of Done" and its original Acceptance Criteria.
3.  **Submit Stack**: Use `using-graphite-cli` to publish the branch as part of a stack.
4.  **Peer Review**: Use `reviewing-pull-requests` for cross-agent or human-to-agent feedback.

*Related: `docs/delivery-standards.md`, `ADR-007: Local Quality Gates`*

---

## Phase 7: Learning Loop (The "Done")
**Goal**: Optimize the system based on empirical delivery performance.

1.  **Deploy & Rollout**: Use `running-release-readiness` to verify the deployment and rollback plan.
2.  **Run Retrospective**: Use `running-retrospectives` to identify bottlenecks (e.g., "Why did Task 4 take 3 days?").
3.  **Update OS**: Propose updates to skills, templates, or methodologies to prevent recurring failures.

*Related: `docs/collaboration-process.md`, `prd-running-retrospectives.md`*

---

## Summary of Truth
In this system, we do not **"just code."** We engineer intent, specify outcomes, model boundaries, and verify every increment. Success is not defined by "working code," but by **"verifiable outcomes that match the specification."**
