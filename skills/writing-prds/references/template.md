---
status: Draft
author: "{Name}"
version: "0.1"
updated: YYYY-MM-DD
reviewers: "{Engineering Lead}, {Design Lead}, {Stakeholder}"
---

# {Feature Name} PRD

## Overview

{One paragraph. State the problem being solved and why it
matters now. Link to any supporting context: OKRs, user
research, support data, or strategic initiative.

Do NOT describe the solution here. Focus on the user need
and business context.}

## Goals and Success Metrics

- **Goal:** {The core user or business outcome}
- **Primary metric:** {KPI name} — baseline: {X}, target:
  {Y}, timeframe: {Z days/weeks after launch}
- **Secondary metric:** {Supporting KPI if applicable}

*Metrics must be measurable. Replace vague goals like
"improve performance" with "reduce p95 latency from 800ms
to under 300ms within 30 days of launch."*

## Non-Goals

The following are explicitly out of scope for this release:

- {Item}: {Reason — e.g., "deferred to Q3 initiative",
  "out of domain for this team", "requires separate RFC"}
- {Item}: {Reason}

## Users and Use Cases

**Primary persona:** {Specific user segment — not "all users"
but "engineers onboarding to a new codebase who need to
understand existing architecture decisions."}

**User story:**

> As a {persona}, I want {capability} so that {outcome}.

**Scenario:** {Walk through the full narrative. Where is the
user? What are they trying to accomplish? What does the
before state look like? What does success look like after?}

## Scope

**In scope:**

- {Capability 1}
- {Capability 2}

**Out of scope (this release):**

- {Item} — {reason}
- {Item} — {reason}

## Functional Requirements

### Must Have

- **FR-1:** {Requirement written as a system behavior, not
  an implementation. "The system sends a confirmation email
  within 30 seconds of order placement." Not "add
  sendEmail() call after order.save()".}
- **FR-2:** {Requirement}

### Should Have

- **FR-3:** {Requirement}

### Could Have

- **FR-4:** {Requirement — nice to have if capacity allows}

## Acceptance Criteria

Criteria are written in Given/When/Then format. Each FR
must have at least one criterion.

### FR-1: {Requirement name}

- Given {precondition or user context},
  when {action or event},
  then {observable, measurable outcome}.
- Given {error condition},
  when {action},
  then {expected error handling behavior}.

### FR-2: {Requirement name}

- Given {precondition},
  when {action},
  then {outcome}.

## Non-Functional Requirements

| Attribute     | Requirement             | Threshold           |
| ------------- | ----------------------- | ------------------- |
| Performance   | p95 response latency    | < 500ms             |
| Availability  | Uptime                  | 99.9%               |
| Security      | Authentication required | All endpoints       |
| Accessibility | WCAG conformance level  | AA                  |
| Scalability   | Concurrent users        | {N}                 |

*Remove rows that do not apply. Add rows for any NFR
specific to this feature.*

## Design and UX

{Link to Figma prototype, wireframes, or design spec.
Do not describe UI details in prose — embed or link the
artifact directly.}

- Prototype: {URL}
- Design spec: {URL}

*If designs are not yet available, note the expected date
and describe any critical UX constraints in bullet form.*

## Analytics and Telemetry

Events this feature must emit to measure the success
metrics defined above:

- Event: `{event_name}` — fired {when it fires, e.g. "when
  user completes checkout step 2"}
- Event: `{event_name}` — fired {condition}
- Funnel: {describe any funnel or conversion tracking}

## Dependencies and Constraints

- {External API or service required, e.g. "Stripe API v3
  for payment processing"}
- {Compliance requirement, e.g. "GDPR: user data must
  not leave EU region"}
- {Platform constraint, e.g. "iOS 15+ only; no Android
  support in this release"}
- {Hard deadline, e.g. "must ship before Q4 marketing
  campaign launch on {date}"}

## Risks and Assumptions

| Risk        | Category    | Mitigation              |
| ----------- | ----------- | ----------------------- |
| {Risk desc} | Value       | {Research / prototype}  |
| {Risk desc} | Usability   | {Usability testing}     |
| {Risk desc} | Feasibility | {Technical spike by X}  |
| {Risk desc} | Viability   | {Stakeholder review}    |

**Assumptions:**

- {Assumption} — Owner: {name} — Validate by: YYYY-MM-DD
- {Assumption} — Owner: {name} — Validate by: YYYY-MM-DD

## Rollout and Operations

- **Phase 1:** {e.g. "Internal dogfood — 100% of employees"}
- **Phase 2:** {e.g. "5% of production traffic, 7 days"}
- **Phase 3:** {e.g. "Full rollout"}
- **Feature flag:** `{flag_name}` — controlled via
  {flag service}
- **Rollback:** {Procedure to revert, e.g. "disable feature
  flag; no data migration required"}
- **Runbook:** {Link to on-call runbook for incidents}

## Open Questions

- [ ] {Question} — Owner: {name} — Due: YYYY-MM-DD
- [ ] {Question} — Owner: {name} — Due: YYYY-MM-DD

## Changelog

| Version | Date       | Author  | Change                   |
| ------- | ---------- | ------- | ------------------------ |
| 0.1     | YYYY-MM-DD | {name}  | Initial draft            |
