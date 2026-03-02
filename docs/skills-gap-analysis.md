# Skills Gap Analysis

## Context

This document captures missing capabilities identified during a holistic review of the current skill collection and maps them to proposed additions required to operationalize the repository's core methodologies (Intent Engineering, CDD, DDD, TDD, and Delivery Standards).

Source processes:
- `docs/collaboration-process.md`
- `docs/delivery-standards.md`
- `docs/methodologies/`

## Existing Strengths

Current skills strongly cover:

- **Planning Artifacts**: `writing-product-requirement-documents`, `writing-task-specs`, `writing-architecture-decision-records`.
- **Repository Operations**: `using-graphite-cli`, `using-github-cli`, `using-git-worktrees`.
- **Workflow Orchestration**: `using-github-speckit`, `planning-speckit-worktrees-graphite`.
- **Quality & Writing**: `writing-markdown`, `writing-grammar`, `writing-git-commits`.
- **Model Delegation**: `using-codex-cli`, `using-gemini-cli`, `using-ollama`.

## Gaps Identified

1.  **Intent Capture & Discovery**: No formalized skill for early intake, ambiguity clarification, and constraint extraction as defined in `intent-engineering.md`.
2.  **Domain & Contract Modeling**: No skills for Domain-Driven Design (DDD) boundary identification or API contract negotiation (CDD) prior to implementation.
3.  **Behavioral Specification**: No skill for translating functional requirements into executable BDD scenarios (Given/When/Then).
4.  **Implementation Discipline**: No skill to enforce the Red-Green-Refactor loop of TDD or the empirical verification required for bug reproduction.
5.  **Quality Enforcement**: No structured skill for post-implementation quality gates (lint/type/test) or peer PR review against architectural constraints.
6.  **Operational Feedback**: No formalized skills for release readiness (rollback/validation) or post-delivery retrospectives to close the learning loop.

## Proposed Additions

### Phase 1: Intake & Design
- `running-intake-discovery`: Clarify goals, extract constraints, and build the "Intent Contract."
- `modeling-domains`: Identify bounded contexts, entities, and aggregates (DDD).
- `designing-api-contracts`: Negotiate and document OpenAPI/GraphQL contracts (CDD).
- `writing-bdd-scenarios`: Convert specs into executable behavioral tests (BDD).

### Phase 2: Implementation & Validation
- `applying-test-driven-development`: Enforce strict Red-Green-Refactor cycles.
- `reproducing-bugs`: Ensure empirical failure via a test case before any fix is applied.
- `running-quality-gates`: Systematic verification of "Definition of Done" before PR submission.
- `reviewing-pull-requests`: Evaluate PRs against delivery standards and architectural constraints.

### Phase 3: Delivery & Learning
- `running-release-readiness`: Verify rollout, monitoring, and rollback plans.
- `running-retrospectives`: Analyze delivery speed and failures to update checklists/templates.

## Expected Outcomes

- **High Intent Fidelity**: Reduced rework by confirming "What and Why" before "How."
- **Contract Stability**: Parallel development enabled by stable, pre-negotiated interfaces.
- **Zero-Regression Implementation**: TDD-first approach ensures behavioral correctness.
- **Review Velocity**: Small, high-quality PRs that satisfy pre-defined quality gates.
- **Continuous Evolution**: A system that matures through structured retrospective feedback.

## Implementation Roadmap (Linked PRDs)

- `docs/prds/prd-running-intake-discovery.md`
- `docs/prds/prd-modeling-domains.md`
- `docs/prds/prd-designing-api-contracts.md`
- `docs/prds/prd-applying-test-driven-development.md`
- `docs/prds/prd-running-quality-gates.md`
- `docs/prds/prd-running-retrospectives.md`
