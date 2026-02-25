---
name: writing-prds
description: Use when creating or updating a Product Requirements Document,
  when a product feature or initiative needs a formal specification, or when
  asked to write a PRD. Produces complete, review-ready PRDs with measurable
  goals, testable acceptance criteria, and explicit scope boundaries.
---

# Writing Product Requirements Documents

## Overview

A PRD aligns Product, Engineering, and Design on the "what" and "why" of a
feature before implementation begins. It is not a design document or technical
spec—it defines behavior and outcomes, not implementation.

**Core principle:** Define the problem before proposing any solution. Every
requirement must tie back to a measurable user or business outcome.

## When to Write a PRD

Write a PRD when:

- Starting a new feature or significant product change
- Defining scope for a release or milestone
- Aligning stakeholders before engineering begins
- Documenting user needs, success criteria, and constraints

**Do NOT write a PRD for:**

- Bug fixes and minor UX tweaks
- Internal tooling with no user-facing requirements
- Pure technical refactors (write an RFC or ADR instead)
- Work already covered by an existing, approved PRD

## Prerequisites

Load the PRD best practices reference before writing:

```text
docs/writing-prds.md
```

Confirm you have:

- A clear problem statement backed by data
- At least one identified user persona
- Access to any relevant analytics or user research

## Workflow

1. **Define the problem** — State what user or business problem this solves
   and why it matters now. Cite data.
2. **Set measurable goals** — Specify KPIs with baselines and targets.
3. **Identify personas and use cases** — Name the primary user segment and
   write user stories.
4. **Draw scope boundaries** — List in-scope capabilities and explicitly name
   out-of-scope items.
5. **Write functional requirements** — Describe behaviors the system must
   support. Use MoSCoW prioritization.
6. **Write acceptance criteria** — Use Given/When/Then format for every
   requirement. No vague thresholds.
7. **Address non-functional requirements** — Apply the ISO 25010 checklist
   (performance, security, accessibility, reliability).
8. **Link design artifacts** — Embed or link wireframes, prototypes, or UI
   specs. Do not describe UI in prose.
9. **Document risks and assumptions** — Address all four risk categories:
   value, usability, feasibility, business viability.
10. **Define rollout** — Include phasing, feature flags, and rollback plan.
11. **Open questions** — List unresolved items with owners and due dates.
12. **Run the quality checklist** — Confirm every checklist item before
    circulating for review.

## Required Sections

Every PRD must include these sections:

| Section | Purpose |
| ------- | ------- |
| Metadata | Status, author, version, reviewers |
| Overview | Problem and strategic context |
| Goals and Success Metrics | Measurable outcomes |
| Non-Goals | Explicit scope exclusions |
| Users and Use Cases | Personas and user stories |
| Scope | In/out-of-scope list |
| Functional Requirements | Prioritized behaviors |
| Acceptance Criteria | Given/When/Then testable criteria |
| Non-Functional Requirements | ISO 25010 checklist |
| Risks and Assumptions | Four risk categories with mitigations |
| Open Questions | Unresolved items with owners |
| Changelog | Version history |

Optional sections (include when applicable):

- Design and UX — link to prototypes
- Analytics and Telemetry — event tracking plan
- Dependencies and Constraints — external dependencies
- Rollout and Operations — phasing and rollback

## Acceptance Criteria Format

Always use Given/When/Then:

```text
Given {precondition or context}
When {user action or system event}
Then {observable, measurable outcome}
```

Replace all vague language with thresholds:

| Vague | Specific |
| ----- | -------- |
| "fast" | "p95 response < 500ms" |
| "secure" | "all endpoints require authentication" |
| "accessible" | "WCAG 2.1 AA compliant" |

## Safety Rules

- Never describe implementation details (SQL queries, API method names,
  architecture choices) in a PRD. Those belong in an RFC or design doc.
- Never mark a PRD as Approved without documented sign-off from at least
  engineering lead, design lead, and one business stakeholder.
- Never omit Non-Goals. Absence of scope boundaries causes scope creep.
- Never use vague thresholds in acceptance criteria or NFRs.

## Common Mistakes

- **Solution before problem**: Writing feature descriptions before articulating
  the user problem. Fix: start with problem statement and user goals.
- **Vacuous requirements**: "Ensure compliance with best practices." Fix:
  cite the specific standard and the required outcome.
- **Missing evidence**: Stating a problem without data. Fix: cite the metric,
  support volume, or research finding.
- **Untestable criteria**: "The system should be responsive." Fix: "The system
  renders on screens 320px and wider without horizontal scroll."
- **Scope by omission**: Only listing what is in scope. Fix: explicitly list
  what is out of scope with reasons.
- **Static document**: PRD written once, never updated. Fix: update the
  changelog with every material change; keep status accurate.

## Red Flags

Stop and correct if:

- The PRD describes how to build something before defining what problem it
  solves
- Acceptance criteria contain words like "fast", "easy", "appropriate",
  "reasonable", or "etc."
- Success metrics lack baselines or target values
- Non-goals section is empty
- Risks section lists only value risk (ignoring usability, feasibility, and
  business viability)
- The document has not been updated since the initial draft despite ongoing
  discovery

## References

- Full best practices guide: `docs/writing-prds.md`
- Related skill for architectural decisions: `skills/writing-adrs/SKILL.md`
- Related skill for markdown quality: `skills/writing-markdown/SKILL.md`
