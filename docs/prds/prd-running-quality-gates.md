---
status: Draft
author: "Codex"
version: "0.1"
updated: 2026-02-27
reviewers: "Engineering Lead, QA Lead, Workflow Owner"
---

# Running Quality Gates Skill PRD

## Overview

Pre-merge quality checks are currently inconsistent across tasks. We need a
skill that runs a standard gate sequence and produces auditable evidence for
acceptance criteria, tests, documentation, and unresolved risk before merge.

## Goals and Success Metrics

- **Goal:** Make pre-merge readiness checks consistent and verifiable.
- **Primary metric:** PRs merged with complete quality evidence — baseline:
  48%, target: 95%, timeframe: 45 days after adoption.
- **Secondary metric:** Post-merge defect rate per PR — baseline: 0.34,
  target: 0.15, timeframe: 60 days after adoption.

## Non-Goals

The following are explicitly out of scope for this release:

- Replacing team-specific test frameworks or linters.
- Acting as a deployment approval system.

## Users and Use Cases

**Primary persona:** Engineers and agent operators preparing code for review.

**User story:**

> As a contributor, I want a standard quality-gate workflow so that every PR
> contains trustworthy verification evidence.

**Scenario:** A contributor completes implementation. The skill executes a
checklist and outputs evidence status for acceptance criteria, tests, docs, and
residual risks before PR handoff.

## Scope

**In scope:**

- Standard gate checklist template.
- Evidence capture requirements for each gate.
- Pass/fail/blocked status with reasons.
- Final readiness summary artifact.

**Out of scope (this release):**

- CI platform reconfiguration.
- Policy exceptions workflow automation.

## Functional Requirements

### Must Have

- **FR-1:** The skill evaluates acceptance criteria coverage status.
- **FR-2:** The skill records test evidence and outcomes.
- **FR-3:** The skill verifies required documentation updates.
- **FR-4:** The skill records unresolved critical risks.
- **FR-5:** The skill outputs a single pre-merge readiness summary.

### Should Have

- **FR-6:** The skill flags missing evidence with action items.

### Could Have

- **FR-7:** The skill provides a concise reviewer checklist view.

## Acceptance Criteria

### FR-1: Acceptance criteria coverage

- Given a task with documented acceptance criteria,
  when the skill runs,
  then the output marks each criterion as verified, unverified, or not
  applicable with evidence links.

### FR-2: Test evidence capture

- Given executed tests,
  when the skill runs,
  then the summary includes test scope, result status, and failure notes.

### FR-5: Single readiness summary

- Given all gate checks complete,
  when the skill generates output,
  then it produces one markdown section with final status and blockers.

## Non-Functional Requirements

| Attribute      | Requirement                | Threshold      |
| -------------- | -------------------------- | -------------- |
| Performance    | Gate run completion time   | < 10 minutes   |
| Reliability    | Evidence field completion  | 100% required  |
| Usability      | Reviewer scan time         | < 3 minutes    |
| Auditability   | Evidence traceability      | 100% gate links |
| Maintainability | Checklist update effort   | < 2 hours      |

## Design and UX

- Prototype: TBD
- Design spec: N/A for this release

## Analytics and Telemetry

- Event: `quality_gate_started` — fired when validation begins.
- Event: `quality_gate_failed` — fired when any must-have gate is not met.
- Event: `quality_gate_passed` — fired when all must-have gates pass.

## Dependencies and Constraints

- Must align with existing PR description requirements.
- Must not require changing repository toolchain.
- Must work even when some checks are manual.

## Risks and Assumptions

| Risk                             | Category    | Mitigation              |
| -------------------------------- | ----------- | ----------------------- |
| Teams see gates as process tax   | Value       | Keep output concise     |
| Evidence fields are over-detailed | Usability   | Use strict minimal set  |
| Manual steps create inconsistency | Feasibility | Define explicit rubric  |
| Reviewers ignore summary output  | Viability   | Add reviewer checklist  |

**Assumptions:**

- Contributors can provide test evidence in a consistent structure.
  Owner: QA Lead. Validate by: 2026-03-20.
- Existing review flow can consume a standardized gate summary.
  Owner: Engineering Lead. Validate by: 2026-03-20.

## Rollout and Operations

- **Phase 1:** Pilot on one active feature branch.
- **Phase 2:** Apply to all medium and large changes.
- **Phase 3:** Require for all PRs except emergency fixes.
- **Feature flag:** `skill_quality_gates_v1`.
- **Rollback:** Return to current review checklist usage.
- **Runbook:** `docs/collaboration-process.md`.

## Open Questions

- [ ] Which evidence fields should be mandatory for docs-only changes?
  Owner: Workflow Owner. Due: 2026-03-06.
- [ ] Should emergency fixes use a reduced gate profile?
  Owner: Engineering Lead. Due: 2026-03-06.

## Changelog

| Version | Date       | Author | Change        |
| ------- | ---------- | ------ | ------------- |
| 0.1     | 2026-02-27 | Codex  | Initial draft |
