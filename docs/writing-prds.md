# PRD Best Practices

This guide defines the standard for writing high-quality Product Requirements
Documents (PRDs).

Use it when creating a new PRD or revising an existing one.

## Purpose

A PRD aligns cross-functional teams around the "what" and "why" of a product
feature or initiative. It is the contract between Product, Engineering, Design,
and stakeholders before implementation begins.

A good PRD should:

- Define the problem before proposing any solution
- Express requirements as behaviors, not implementations
- Give engineers enough clarity to build the right thing
- Surface risks, assumptions, and constraints early
- Remain a living document as understanding evolves

## The Artifact Hierarchy

PRDs exist within a hierarchy of planning artifacts. Understand where each fits:

| Artifact         | Owner          | Answers     | Scope                    |
| ---------------- | -------------- | ----------- | ------------------------ |
| PRD              | Product Mgr    | What & Why  | Feature or initiative    |
| RFC / Design Doc | Engineer       | How         | Technical implementation |
| ADR              | Eng/Architect  | Which & Why | Single architecture call |
| Technical Spec   | Engineering    | How detail  | System or service design |
| Task Breakdown   | Team           | Steps       | Sprint-level execution   |

PRDs feed into RFCs and Design Docs. ADRs record the architectural decisions
made during that process.

## Standard PRD Structure

A complete PRD contains these 14 sections. Mark each as `TBD` when unknown
rather than omitting it.

### 1. Metadata

Track document lifecycle at the top.

```markdown
| Field   | Value |
| ------- | ----- |
| Status  | Draft / In Review / Approved / Deprecated |
| Author  | {name} |
| Version | 0.1 |
| Updated | YYYY-MM-DD |
| Reviewers | {names or teams} |
```

Version scheme: `0.x` = draft, `1.0` = first approved, `1.x` = minor revision,
`2.0` = major change requiring re-approval.

### 2. Overview

One paragraph. State what you are building and why now. Link to any strategic
context (OKRs, roadmap, customer research).

Do not describe the solution here. Focus on the problem and business context.

### 3. Goals and Success Metrics

Define measurable outcomes—not output.

- **Primary goal**: The core business or user outcome
- **Success metrics**: Quantified targets with timeframes

Example: "Increase checkout completion rate from 62% to 72% within 60 days of
launch."

Include both leading indicators (engagement, activation) and lagging indicators
(retention, revenue). Specify the baseline for each metric.

### 4. Non-Goals

Explicit boundaries prevent scope creep. List what this initiative will NOT
address, and why.

Mark items as:

- **Out of scope now**: May be addressed in a future iteration
- **Intentionally excluded**: Deliberate omission with reasoning

### 5. Users and Use Cases

Identify who you are building for and their jobs to be done.

**Personas**: Primary user segment and their context. Be specific—not "mobile
users" but "users who complete onboarding on a phone but switch to desktop."

**User stories**: Written as:

```text
As a {persona}, I want {capability} so that {outcome}.
```

**Scenarios**: Walk through the full narrative of a user accomplishing their
goal. Include the before and after state.

### 6. Scope

List what is in scope as the smallest set of capabilities to achieve the goals.

```markdown
**In scope:**
- {capability}
- {capability}

**Out of scope (this release):**
- {item} — reason
- {item} — reason
```

### 7. Functional Requirements

Describe what the system must do. Write behaviors, not implementations.

Good: "The system sends an email confirmation within 30 seconds of order
placement."

Bad: "Add a sendConfirmationEmail() call after the order service commits."

Prioritize using MoSCoW:

- **Must have**: Non-negotiable for launch
- **Should have**: Important but not blocking
- **Could have**: Nice to have if capacity allows
- **Won't have (this release)**: Explicitly deferred

Use RICE scoring when comparing multiple features for prioritization:

```text
RICE Score = (Reach × Impact × Confidence) ÷ Effort
```

### 8. Acceptance Criteria

Each requirement must have testable acceptance criteria. Use the
Given/When/Then (Gherkin) format:

```text
Given {precondition or context}
When {user action or system event}
Then {observable outcome}
```

Criteria must be:

- **Specific**: No vague language ("fast", "easy", "reasonable")
- **Measurable**: Use numbers ("< 2 seconds", "100% of records")
- **Testable**: Each criterion maps to a concrete test case

Cover happy paths, error states, and edge cases.

### 9. Non-Functional Requirements

Use the ISO 25010 checklist to avoid gaps. Include a threshold for each
applicable attribute:

| Attribute      | Requirement      | Threshold     |
| -------------- | ---------------- | ------------- |
| Performance    | p95 latency      | < 500ms       |
| Availability   | Uptime           | 99.9%         |
| Security       | Auth required    | All endpoints |
| Accessibility  | WCAG level       | AA            |
| Scalability    | Concurrent users | 10,000        |
| Data retention | Log history      | 90 days       |

### 10. Design and UX

Link to prototypes and UI specs. Do not describe interface details in prose—
embed or link the artifact directly.

If designs are not yet available, include rough sketches or annotated
wireframes. The majority of UI requirements should live in the design artifact,
not in PRD prose.

### 11. Analytics and Telemetry

List the events and data the feature must emit to measure success.

```markdown
- Event: `checkout_started` — fired when user enters checkout flow
- Event: `checkout_completed` — fired on successful payment confirmation
- Funnel: track drop-off at each checkout step
```

### 12. Dependencies and Constraints

Call out anything that could block or limit implementation:

- External APIs or services required
- Compliance or legal requirements (GDPR, HIPAA, SOC 2)
- Platform or browser constraints
- Localization or accessibility requirements
- Hard deadlines tied to external events

### 13. Risks and Assumptions

Explicitly address the four big risks:

| Risk        | Question                 | Mitigation           |
| ----------- | ------------------------ | -------------------- |
| Value       | Will users want this     | Research + prototype |
| Usability   | Can users use it         | Usability testing    |
| Feasibility | Can engineering build it | Technical spike      |
| Viability   | Legal/financial fit      | Stakeholder review   |

List assumptions separately with owners and due dates for validation:

```markdown
- Assumption: Users complete onboarding within one session. Owner: Research.
  Validate by: YYYY-MM-DD.
```

### 14. Rollout and Operations

Define how the feature ships:

- **Rollout phases**: Percentage rollout, A/B test, feature flag
- **Rollback plan**: How to revert if something goes wrong
- **Migration**: Data migration steps, backward compatibility
- **Support**: Runbook or on-call guidance for incidents

### Changelog

Track every material update at the bottom of the document.

```markdown
| Version | Date | Author | Change |
| ------- | ---- | ------ | ------ |
| 0.1 | YYYY-MM-DD | {name} | Initial draft |
| 0.2 | YYYY-MM-DD | {name} | Added NFRs, updated metrics |
| 1.0 | YYYY-MM-DD | {name} | Approved by stakeholders |
```

---

## Writing Style

- **Solution-agnostic**: Describe behaviors and outcomes.
  Let engineering choose the implementation.
- **Data-backed**: Support problem statements with evidence:
  analytics, support tickets, and user research.
  Vague claims weaken credibility.
- **Concise**: Remove every sentence that does not help a
  reader decide or act. Use bullet points for requirements
  and prose for context.
- **Unambiguous**: Replace "fast", "secure", and "easy"
  with thresholds. Ambiguity forces assumptions.
- **Status-aware**: Mark unresolved sections `TBD [owner]` to signal gaps are
  known, not forgotten.

---

## The Review and Sign-Off Process

1. **Self-review**: Use the quality checklist before sharing.
2. **Team review**: Circulate to design, engineering, and data for comment.
3. **Stakeholder review**: Confirm alignment with business goals and compliance.
4. **Engineering handoff**: Engineers raise questions; update PRD with answers.
5. **Formal approval**: Collect sign-off and update status to `Approved`.

Minimum viable review list: PM author, engineering lead, design lead, and
one stakeholder.

---

## Anti-Patterns to Avoid

| Anti-Pattern      | Symptom                  | Fix                     |
| ----------------- | ------------------------ | ----------------------- |
| Solution first    | UI before problem        | Start with user problem |
| Vacuous content   | Generic filler           | Use specific reqs       |
| Missing evidence  | No supporting data       | Cite analytics/research |
| Vague criteria    | No measurable targets    | Define concrete targets |
| Spec bloat        | Edge cases off-goal      | Tie to user stories     |
| Unfinished draft  | Rough handoff to design  | Include rough mockups   |
| Static document   | Never updated            | Update changelog often  |
| Siloed authorship | Review starts at handoff | Collaborate early       |
| Over-scoping      | Too much in one PRD      | Split into focused PRDs |

---

## Quality Checklist

Before circulating a PRD for review:

- [ ] Problem statement is backed by data
- [ ] Goals have specific, measurable metrics with baselines
- [ ] Non-goals are explicit
- [ ] User personas are specific, not generic
- [ ] All requirements are behaviors, not implementations
- [ ] Acceptance criteria use Given/When/Then format
- [ ] Every metric has a threshold (no vague terms)
- [ ] NFRs are addressed using ISO 25010 checklist
- [ ] Designs are linked or embedded
- [ ] Four big risks are documented with mitigations
- [ ] Rollout plan includes rollback strategy
- [ ] Changelog is started
- [ ] Open questions have owners and due dates
- [ ] Status is set accurately

---

## Relationship to Adjacent Artifacts

| Write a PRD for          | Use another doc for   |
| ------------------------ | --------------------- |
| New feature/major change | ADR on architecture   |
| Release scope/outcomes   | RFC/design for impl   |
| Stakeholder alignment    | Project timeline plan |
| Needs + success criteria | User research report  |

A PRD should reference related ADRs, RFCs, and design docs. It does not replace
them.

---

## AI-Assisted PRD Writing

AI tools can accelerate drafting but require human judgment. Use this workflow:

1. **Prime with context**: Provide product name, target user, problem, and
   constraints.
2. **Generate a first draft**: Use a prompt like:

   ```text
   Act as a senior product manager. Write a PRD for {feature}.
   Include: problem statement, user personas, functional requirements,
   acceptance criteria, success metrics, risks, and NFRs.
   ```

3. **Identify gaps**: Ask the AI to find missing edge cases, untestable
   criteria, or unaddressed risks.
4. **Refine iteratively**: Treat AI output as a starting point. Apply your
   domain knowledge, user research, and stakeholder context.
5. **Human review**: AI cannot replace user research, stakeholder negotiation,
   or engineering feasibility judgment.

Time savings typically reach 40–60% of previous drafting time when AI is used
well.

---

## Template

Use the following as a starting baseline. Delete or add sections as needed.

```markdown
---
title: {Feature Name} PRD
status: Draft
author: {Name}
version: 0.1
updated: YYYY-MM-DD
reviewers: {Engineering Lead}, {Design Lead}, {Stakeholder}
---

# {Feature Name}

## Overview

{One paragraph: what you are building and why now.}

## Goals and Success Metrics

- **Goal**: {Outcome}
- **Metric**: {KPI} — baseline: {X}, target: {Y}, timeframe: {Z}

## Non-Goals

- {Item}: {reason}

## Users and Use Cases

**Primary persona**: {Description}

**User story**:
As a {persona}, I want {capability} so that {outcome}.

**Scenario**: {Full narrative}

## Scope

**In scope:**
- {capability}

**Out of scope (this release):**
- {item} — reason

## Functional Requirements

### Must Have

- FR-1: {requirement}

### Should Have

- FR-2: {requirement}

## Acceptance Criteria

**FR-1**: {requirement name}
- Given {context}, When {action}, Then {outcome}

## Non-Functional Requirements

| Attribute | Requirement | Threshold |
| --------- | ----------- | --------- |
| Performance | p95 latency | < 500ms |

## Design and UX

{Link to Figma / prototype}

## Analytics and Telemetry

- Event: `{event_name}` — {when it fires}

## Dependencies and Constraints

- {dependency or constraint}

## Risks and Assumptions

| Risk | Category | Mitigation |
| ---- | -------- | ---------- |
| {risk} | {Value/Usability/Feasibility/Viability} | {action} |

**Assumptions:**
- {assumption} — Owner: {name} — Validate by: YYYY-MM-DD

## Rollout and Operations

- **Phase 1**: {description}
- **Rollback**: {procedure}

## Open Questions

- [ ] {Question} — Owner: {name} — Due: YYYY-MM-DD

## Changelog

| Version | Date | Author | Change |
| ------- | ---- | ------ | ------ |
| 0.1 | YYYY-MM-DD | {name} | Initial draft |
```
