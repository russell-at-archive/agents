---
status: Draft
author: "Codex"
version: "0.1"
updated: 2026-02-27
reviewers: "Engineering Lead, Workflow Owner, Tooling Lead"
---

# Orchestrating Skill Selection PRD

## Overview

Multiple skills can trigger for the same request, and some rules overlap.
This creates ordering ambiguity and inconsistent behavior. We need a skill
that defines deterministic selection, ordering, and conflict resolution across
the skill catalog.

## Goals and Success Metrics

- **Goal:** Remove ambiguity from multi-skill invocation.
- **Primary metric:** Requests requiring manual skill-order correction —
  baseline: 22%, target: 3%, timeframe: 45 days after adoption.
- **Secondary metric:** Workflow consistency score in audits — baseline: 62%,
  target: 95%, timeframe: 60 days after adoption.

## Non-Goals

The following are explicitly out of scope for this release:

- Building a runtime scheduler for external tools.
- Rewriting existing skill content beyond minimal metadata additions.

## Users and Use Cases

**Primary persona:** Agent operators and maintainers managing multi-skill work.

**User story:**

> As an operator, I want deterministic skill orchestration so that repeated
> tasks behave consistently even when trigger conditions overlap.

**Scenario:** A request references planning, git operations, and PR updates.
The skill determines which skills apply, in what order, and how conflicts are
resolved, then outputs a compact orchestration plan.

## Scope

**In scope:**

- Skill applicability decision rules.
- Priority and ordering rules.
- Conflict resolution policy for overlapping triggers.
- Output format for selected skill chain.

**Out of scope (this release):**

- Automatic remediation of low-quality skill definitions.
- Enforcement at runtime beyond documented orchestration output.

## Functional Requirements

### Must Have

- **FR-1:** The skill identifies all applicable skills for a request.
- **FR-2:** The skill produces deterministic ordering of applicable skills.
- **FR-3:** The skill resolves known conflicts with explicit precedence rules.
- **FR-4:** The skill outputs reasons for selection and exclusion.

### Should Have

- **FR-5:** The skill highlights ambiguous cases requiring manual override.

### Could Have

- **FR-6:** The skill suggests metadata updates to reduce future ambiguity.

## Acceptance Criteria

### FR-1: Applicability selection

- Given a request with overlapping triggers,
  when the skill runs,
  then all applicable skills are listed with trigger evidence.

### FR-2: Deterministic ordering

- Given the same request input,
  when the skill runs repeatedly,
  then skill ordering is identical across runs.

### FR-3: Conflict resolution

- Given a known conflict pair,
  when the skill runs,
  then precedence rules are applied and documented in output.

## Non-Functional Requirements

| Attribute      | Requirement                | Threshold      |
| -------------- | -------------------------- | -------------- |
| Performance    | Orchestration runtime      | < 30 seconds   |
| Reliability    | Deterministic ordering     | 100% repeatable |
| Usability      | Operator comprehension     | >= 4/5          |
| Maintainability | Rule update effort        | < 2 hours      |
| Auditability   | Selection rationale fields | 100% populated |

## Design and UX

- Prototype: TBD
- Design spec: N/A for this release

## Analytics and Telemetry

- Event: `skill_orchestration_started` — fired when evaluation begins.
- Event: `skill_orchestration_conflict` — fired when conflict rules are used.
- Event: `skill_orchestration_completed` — fired with selected skill count.

## Dependencies and Constraints

- Must align with current skill frontmatter schema.
- Must remain easy to maintain as skill count grows.
- Must not introduce breaking behavior for single-skill requests.

## Risks and Assumptions

| Risk                             | Category    | Mitigation          |
| -------------------------------- | ----------- | ------------------- |
| Rule set grows too complex       | Value       | Keep rules simple   |
| Output feels hard to trust       | Usability   | Include rationale   |
| Skills lack needed metadata      | Feasibility | Add minimal fields  |
| Rule ownership is unclear        | Viability   | Assign owner        |

**Assumptions:**

- Conflict patterns are limited and can be explicitly enumerated.
  Owner: Tooling Lead. Validate by: 2026-03-20.
- Operators will follow orchestration output when conflicts are resolved.
  Owner: Workflow Owner. Validate by: 2026-03-20.

## Rollout and Operations

- **Phase 1:** Pilot on requests that invoke two or more skills.
- **Phase 2:** Default for all multi-skill requests.
- **Phase 3:** Expand to proactive metadata linting suggestions.
- **Feature flag:** `skill_orchestration_v1`.
- **Rollback:** Revert to manual skill ordering.
- **Runbook:** `docs/collaboration-process.md`.

## Open Questions

- [ ] What is the canonical precedence order across skill categories?
  Owner: Workflow Owner. Due: 2026-03-06.
- [ ] Should conflict handling support explicit per-request overrides?
  Owner: Engineering Lead. Due: 2026-03-06.

## Changelog

| Version | Date       | Author | Change        |
| ------- | ---------- | ------ | ------------- |
| 0.1     | 2026-02-27 | Codex  | Initial draft |
