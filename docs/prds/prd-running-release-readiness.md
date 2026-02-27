---
status: Draft
author: "Codex"
version: "0.1"
updated: 2026-02-27
reviewers: "Engineering Lead, Operations Lead, Workflow Owner"
---

# Running Release Readiness Skill PRD

## Overview

Releases currently rely on manual judgment with uneven validation depth. We
need a dedicated skill that standardizes release readiness checks, monitoring
expectations, and rollback preparedness before shipping changes.

## Goals and Success Metrics

- **Goal:** Improve release safety and consistency.
- **Primary metric:** Releases with complete readiness checklist — baseline:
  42%, target: 95%, timeframe: 45 days after adoption.
- **Secondary metric:** Incidents requiring unplanned rollback — baseline: 18%
  of releases, target: 8%, timeframe: 90 days after adoption.

## Non-Goals

The following are explicitly out of scope for this release:

- Owning deployment automation tooling.
- Replacing incident management processes.

## Users and Use Cases

**Primary persona:** Engineers and operators preparing production releases.

**User story:**

> As a release owner, I want a structured readiness workflow so that launch,
> monitoring, and rollback decisions are consistent and defensible.

**Scenario:** A release candidate is prepared. The skill verifies checklist
completion, monitoring plans, rollback criteria, and post-release validation
window requirements before launch.

## Scope

**In scope:**

- Pre-release readiness checklist.
- Monitoring and alert validation fields.
- Rollback trigger and rollback steps section.
- Post-release validation window definition.

**Out of scope (this release):**

- Auto-generated dashboards.
- Cross-team release calendar automation.

## Functional Requirements

### Must Have

- **FR-1:** The skill verifies readiness checklist completion before release.
- **FR-2:** The skill records required monitoring checks and owners.
- **FR-3:** The skill requires explicit rollback triggers and rollback steps.
- **FR-4:** The skill captures post-release validation window details.

### Should Have

- **FR-5:** The skill produces a concise release brief for stakeholders.

### Could Have

- **FR-6:** The skill suggests recommended validation checks by change type.

## Acceptance Criteria

### FR-1: Checklist completion

- Given a release candidate,
  when the skill runs,
  then every required readiness field is marked complete or blocked with a
  reason.

### FR-3: Rollback readiness

- Given a release candidate,
  when output is generated,
  then the artifact includes rollback triggers and concrete rollback steps.

### FR-4: Validation window

- Given a release candidate,
  when the skill completes,
  then post-release validation window start, end, and owner are present.

## Non-Functional Requirements

| Attribute      | Requirement               | Threshold      |
| -------------- | ------------------------- | -------------- |
| Performance    | Readiness check runtime   | < 10 minutes   |
| Reliability    | Required field completion | 100% required  |
| Usability      | Release brief scan time   | < 4 minutes    |
| Auditability   | Release decision record   | 100% releases  |
| Maintainability | Checklist update effort  | < 2 hours      |

## Design and UX

- Prototype: TBD
- Design spec: N/A for this release

## Analytics and Telemetry

- Event: `release_readiness_started` — fired at checklist start.
- Event: `release_readiness_blocked` — fired when must-have checks fail.
- Event: `release_readiness_passed` — fired when release is ready.

## Dependencies and Constraints

- Must align with existing release discipline in collaboration docs.
- Must be applicable to small and large releases.
- Must remain usable without new external tooling.

## Risks and Assumptions

| Risk                            | Category    | Mitigation          |
| ------------------------------- | ----------- | ------------------- |
| Readiness skipped for speed     | Value       | Add checkpoint      |
| Checklist too long for smalls   | Usability   | Add tier profiles   |
| Rollback fields stay vague      | Feasibility | Use strict prompts  |
| Validation owner is unclear     | Viability   | Require owner field |

**Assumptions:**

- Teams can define rollback steps for most release classes.
  Owner: Operations Lead. Validate by: 2026-03-20.
- Monitoring expectations can be documented at release time.
  Owner: Engineering Lead. Validate by: 2026-03-20.

## Rollout and Operations

- **Phase 1:** Pilot on one low-risk release.
- **Phase 2:** Adopt for all scheduled releases.
- **Phase 3:** Apply to emergency releases with reduced profile.
- **Feature flag:** `skill_release_readiness_v1`.
- **Rollback:** Revert to existing release notes workflow.
- **Runbook:** `docs/collaboration-process.md`.

## Open Questions

- [ ] What minimum checklist applies to emergency patch releases?
  Owner: Operations Lead. Due: 2026-03-06.
- [ ] Should release readiness require explicit stakeholder sign-off fields?
  Owner: Workflow Owner. Due: 2026-03-06.

## Changelog

| Version | Date       | Author | Change        |
| ------- | ---------- | ------ | ------------- |
| 0.1     | 2026-02-27 | Codex  | Initial draft |
