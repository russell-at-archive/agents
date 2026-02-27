---
status: Draft
author: "Codex"
version: "0.1"
updated: 2026-02-27
reviewers: "Engineering Lead, Workflow Owner, Product Lead"
---

# Running Retrospectives Skill PRD

## Overview

The process defines a post-feature learning loop, but there is no skill that
consistently captures what slowed delivery, what failed, and what should be
standardized. We need a retrospective skill that creates actionable,
owner-assigned follow-ups after each feature.

## Goals and Success Metrics

- **Goal:** Convert post-delivery reflection into concrete process
  improvements.
- **Primary metric:** Features with completed retrospective artifact —
  baseline: 20%, target: 90%, timeframe: 45 days after adoption.
- **Secondary metric:** Retro action closure rate within 30 days — baseline:
  25%, target: 75%, timeframe: 60 days after adoption.

## Non-Goals

The following are explicitly out of scope for this release:

- Replacing incident postmortems for critical outages.
- Team performance evaluation or personnel assessment.

## Users and Use Cases

**Primary persona:** Agent operators and engineering leads closing feature work.

**User story:**

> As a delivery owner, I want a short retro workflow so that lessons become
> tracked actions instead of informal notes.

**Scenario:** A feature reaches completion. The skill runs a structured retro,
records wins, failures, bottlenecks, and next actions with owners and due
dates.

## Scope

**In scope:**

- Standard 10-minute retrospective template.
- Required fields for blockers, breakages, and improvements.
- Action item capture with owner and due date.
- Retro summary artifact in markdown.

**Out of scope (this release):**

- Cross-project portfolio retrospective dashboards.
- Automatic action item ticket creation.

## Functional Requirements

### Must Have

- **FR-1:** The skill captures what slowed delivery.
- **FR-2:** The skill captures what broke or regressed.
- **FR-3:** The skill captures what should be standardized.
- **FR-4:** The skill outputs actions with owner and due date.

### Should Have

- **FR-5:** The skill groups actions by process area.

### Could Have

- **FR-6:** The skill identifies recurring issues from prior retrospectives.

## Acceptance Criteria

### FR-1: Delivery friction capture

- Given a completed feature,
  when the retro skill runs,
  then the output includes at least one documented slowdown factor or
  explicitly states none.

### FR-4: Action assignment

- Given a completed retro,
  when output is generated,
  then every action has an owner and due date.

### FR-3: Standardization capture

- Given recurring patterns,
  when the retro skill runs,
  then the output includes a standardization candidate section.

## Non-Functional Requirements

| Attribute      | Requirement              | Threshold      |
| -------------- | ------------------------ | -------------- |
| Performance    | Retro completion time    | < 15 minutes   |
| Reliability    | Action item completeness | 100% owner/date |
| Usability      | Prompt clarity score     | >= 4/5          |
| Auditability   | Retro artifact coverage  | 90% features   |
| Maintainability | Template update effort  | < 2 hours      |

## Design and UX

- Prototype: TBD
- Design spec: N/A for this release

## Analytics and Telemetry

- Event: `retro_started` — fired when retro workflow begins.
- Event: `retro_completed` — fired when required sections are complete.
- Event: `retro_actions_created` — fired with action count.

## Dependencies and Constraints

- Must align with current collaboration process language.
- Must remain short enough for regular use.
- Must avoid blame-oriented framing.

## Risks and Assumptions

| Risk                          | Category    | Mitigation           |
| ----------------------------- | ----------- | -------------------- |
| Retros skipped under pressure | Value       | Keep retro brief     |
| Output becomes generic        | Usability   | Add specific prompts |
| Actions logged but not tracked | Feasibility | Require owner and due |
| Retros seen as overhead       | Viability   | Track measurable wins |

**Assumptions:**

- Teams can commit 10 minutes after each feature completion.
  Owner: Engineering Lead. Validate by: 2026-03-20.
- Action ownership can be assigned at retro time.
  Owner: Workflow Owner. Validate by: 2026-03-20.

## Rollout and Operations

- **Phase 1:** Pilot on two recently completed features.
- **Phase 2:** Default retro for all feature completions.
- **Phase 3:** Integrate retro actions into planning inputs.
- **Feature flag:** `skill_retrospectives_v1`.
- **Rollback:** Revert to optional freeform retro notes.
- **Runbook:** `docs/collaboration-process.md`.

## Open Questions

- [ ] Should low-risk documentation-only changes require retrospectives?
  Owner: Workflow Owner. Due: 2026-03-06.
- [ ] What cadence should review retro action closure?
  Owner: Product Lead. Due: 2026-03-06.

## Changelog

| Version | Date       | Author | Change        |
| ------- | ---------- | ------ | ------------- |
| 0.1     | 2026-02-27 | Codex  | Initial draft |
