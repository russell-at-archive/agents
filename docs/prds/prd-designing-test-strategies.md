---
status: Draft
author: "Codex"
version: "0.1"
updated: 2026-02-27
reviewers: "Engineering Lead, QA Lead, Workflow Owner"
---

# Designing Test Strategies Skill PRD

## Overview

Current planning artifacts mention test plans, but there is no dedicated skill
for creating balanced, slice-level test strategies before implementation.
We need a skill that maps acceptance criteria to test scope, levels,
and evidence expectations.

## Goals and Success Metrics

- **Goal:** Improve pre-implementation test design quality.
- **Primary metric:** Tasks with explicit test strategy artifact — baseline:
  30%, target: 90%, timeframe: 45 days after adoption.
- **Secondary metric:** Defects traced to missing test coverage — baseline:
  28%, target: 12%, timeframe: 90 days after adoption.

## Non-Goals

The following are explicitly out of scope for this release:

- Replacing framework-specific testing documentation.
- Automatic test generation.

## Users and Use Cases

**Primary persona:** Engineers and agents decomposing work into shippable
slices.

**User story:**

> As an implementer, I want a concrete test strategy per slice so that
> acceptance criteria have planned verification before coding starts.

**Scenario:** During decomposition, the skill produces a test strategy that
maps each acceptance criterion to test type, environment, ownership, and
pass/fail evidence.

## Scope

**In scope:**

- Acceptance-criteria-to-test mapping template.
- Test level guidance (unit, integration, end-to-end, manual).
- Coverage gap and risk identification prompts.
- Output artifact for planning and review.

**Out of scope (this release):**

- Direct CI job configuration.
- Language-specific testing framework recommendations.

## Functional Requirements

### Must Have

- **FR-1:** The skill maps each acceptance criterion to at least one planned
  test.
- **FR-2:** The skill classifies tests by level and objective.
- **FR-3:** The skill identifies untested or high-risk criteria.
- **FR-4:** The skill defines evidence needed for verification.

### Should Have

- **FR-5:** The skill recommends minimal viable coverage for low-risk slices.

### Could Have

- **FR-6:** The skill suggests regression test candidates from prior failures.

## Acceptance Criteria

### FR-1: Criteria-to-test mapping

- Given defined acceptance criteria,
  when the skill runs,
  then every criterion has at least one planned test or explicit risk waiver.

### FR-3: Gap detection

- Given a draft test strategy,
  when the skill completes,
  then uncovered criteria are explicitly listed with risk notes.

### FR-4: Evidence definition

- Given planned tests,
  when output is generated,
  then expected evidence format is documented for each test group.

## Non-Functional Requirements

| Attribute      | Requirement                  | Threshold      |
| -------------- | ---------------------------- | -------------- |
| Performance    | Strategy draft completion    | < 12 minutes   |
| Reliability    | Criteria mapping completeness | 100% mapped    |
| Usability      | Planning comprehension score | >= 4/5          |
| Maintainability | Strategy template updates   | < 2 hours      |
| Auditability   | Traceability to acceptance   | 100% criteria  |

## Design and UX

- Prototype: TBD
- Design spec: N/A for this release

## Analytics and Telemetry

- Event: `test_strategy_started` — fired when planning begins.
- Event: `test_strategy_completed` — fired when mapping is complete.
- Event: `test_strategy_gap_found` — fired when uncovered criteria remain.

## Dependencies and Constraints

- Must align with task-spec and quality-gate workflows.
- Must remain framework-neutral.
- Must be lightweight enough for frequent use.

## Risks and Assumptions

| Risk                             | Category    | Mitigation          |
| -------------------------------- | ----------- | ------------------- |
| Strategy overhead slows delivery | Value       | Keep template lean  |
| Teams over-test low risk work    | Usability   | Add risk tiers      |
| Mapping quality varies           | Feasibility | Add examples        |
| Reviewers skip strategy artifact | Viability   | Link PR checklist   |

**Assumptions:**

- Acceptance criteria are available before implementation starts.
  Owner: Workflow Owner. Validate by: 2026-03-20.
- Teams can classify tests by level without framework-specific instructions.
  Owner: QA Lead. Validate by: 2026-03-20.

## Rollout and Operations

- **Phase 1:** Pilot on two medium-risk features.
- **Phase 2:** Adopt for all features with task decomposition.
- **Phase 3:** Integrate with pre-merge quality gate evidence.
- **Feature flag:** `skill_test_strategies_v1`.
- **Rollback:** Revert to optional test notes in task specs.
- **Runbook:** `docs/collaboration-process.md`.

## Open Questions

- [ ] Should trivial changes allow a reduced strategy mode?
  Owner: Engineering Lead. Due: 2026-03-06.
- [ ] Which risk factors determine minimum test depth?
  Owner: QA Lead. Due: 2026-03-06.

## Changelog

| Version | Date       | Author | Change        |
| ------- | ---------- | ------ | ------------- |
| 0.1     | 2026-02-27 | Codex  | Initial draft |
