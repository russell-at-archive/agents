---
status: Draft
author: "Codex"
version: "0.1"
updated: 2026-02-27
reviewers: "Engineering Lead, Product Lead, Workflow Owner"
---

# Running Intake and Discovery Skill PRD

## Overview

Work starts without a consistent intake protocol, which creates scope drift,
late risk discovery, and unclear definitions of done. We need a reusable
skill that captures outcome, constraints, timeline, assumptions, risks, and
acceptance criteria before planning or implementation.

## Goals and Success Metrics

- **Goal:** Standardize project kickoff quality across requests.
- **Primary metric:** Intake completeness rate — baseline: 35%, target: 90%,
  timeframe: 30 days after adoption.
- **Secondary metric:** Clarification loop count per task — baseline: 2.8,
  target: 1.2, timeframe: 30 days after adoption.

## Non-Goals

The following are explicitly out of scope for this release:

- Automated requirement extraction from external systems: deferred pending
  integration planning.
- Team-specific policy engines: intentionally excluded; this release defines a
  common baseline only.

## Users and Use Cases

**Primary persona:** Agent operators initiating new delivery work in this repo.

**User story:**

> As an operator, I want a structured intake workflow so that project scope,
> constraints, and completion criteria are clear before execution starts.

**Scenario:** An operator starts a feature request. The skill captures target
outcome, constraints, deadline, risks, assumptions, and completion criteria,
and produces an intake brief that can be used by planning and implementation
skills.

## Scope

**In scope:**

- Intake question set for outcome, constraints, and timeline.
- Assumption and risk capture with ownership.
- Definition-of-done and acceptance criteria capture.
- Standard output template for intake briefs.

**Out of scope (this release):**

- Direct import from ticketing systems — deferred to future integration work.
- Organization-specific compliance expansions — deferred to v2.

## Functional Requirements

### Must Have

- **FR-1:** The skill captures outcome, constraints, deadline, and
  definition of done for every request.
- **FR-2:** The skill captures explicit assumptions and risk statements.
- **FR-3:** The skill outputs a standardized intake brief in markdown.

### Should Have

- **FR-4:** The skill flags missing critical inputs before completion.

### Could Have

- **FR-5:** The skill suggests follow-up discovery prompts by risk category.

## Acceptance Criteria

### FR-1: Mandatory kickoff fields

- Given a new request,
  when the skill is run,
  then the output includes outcome, constraints, deadline, and definition of
  done.

### FR-2: Risk and assumption capture

- Given a request with uncertainty,
  when the skill is run,
  then the output includes at least one assumption and one risk statement.

### FR-3: Standard output artifact

- Given any completed intake,
  when output is generated,
  then it matches the defined intake brief template sections.

## Non-Functional Requirements

| Attribute     | Requirement              | Threshold      |
| ------------- | ------------------------ | -------------- |
| Performance   | Skill execution latency  | < 60 seconds   |
| Reliability   | Template completion rate | 100% sections  |
| Usability     | Operator completion time | < 8 minutes    |
| Maintainability | Template update effort | < 2 hours      |
| Accessibility | Markdown readability     | Plain text only |

## Design and UX

- Prototype: TBD
- Design spec: N/A for this release

## Analytics and Telemetry

- Event: `intake_started` — fired when intake workflow begins.
- Event: `intake_completed` — fired when all mandatory fields are present.
- Event: `intake_blocked_missing_inputs` — fired when required fields are
  absent.

## Dependencies and Constraints

- Must align with existing documentation standards in `docs/`.
- Must remain compatible with `writing-prds` and `writing-task-specs` outputs.
- Must be lightweight enough for frequent daily use.

## Risks and Assumptions

| Risk                               | Category    | Mitigation           |
| ---------------------------------- | ----------- | -------------------- |
| Intake skipped for speed           | Value       | Require checkpoint   |
| Prompts feel too heavy             | Usability   | Pilot and trim       |
| Field meanings vary by author      | Feasibility | Add definitions      |
| Done criteria disagree by reviewer | Viability   | Add review owner     |

**Assumptions:**

- Operators prefer a concise intake form over freeform kickoff notes.
  Owner: Workflow Owner. Validate by: 2026-03-20.
- Existing planning artifacts will consume intake briefs without major changes.
  Owner: Engineering Lead. Validate by: 2026-03-20.

## Rollout and Operations

- **Phase 1:** Internal trial on three new feature requests.
- **Phase 2:** Default usage for all new feature requests in this repo.
- **Phase 3:** Make intake artifact required before task decomposition.
- **Feature flag:** `skill_intake_discovery_v1`.
- **Rollback:** Revert to existing ad hoc intake notes.
- **Runbook:** `docs/collaboration-process.md`.

## Open Questions

- [ ] What minimum fields are mandatory for urgent hotfix requests?
  Owner: Workflow Owner. Due: 2026-03-06.
- [ ] Should intake include effort estimate confidence at this stage?
  Owner: Engineering Lead. Due: 2026-03-06.

## Changelog

| Version | Date       | Author | Change        |
| ------- | ---------- | ------ | ------------- |
| 0.1     | 2026-02-27 | Codex  | Initial draft |
