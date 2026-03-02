# Writing Product Requirement Documents Overview

## Procedure

Modern PRD writing for 2025-2026 shifts from "feature lists" to
"grounding contexts" for both human developers and AI agents.

### 1. Context Gathering
- **Identify the Problem**: What pain point are we solving? Use data if
  available.
- **Target Persona**: Who is the primary user? What is their current
  workflow?
- **Strategic Alignment**: How does this fit into broader OKRs or goals?

### 2. Define Outcomes
- **Primary Goal**: One sentence on the core desired outcome.
- **Success Metrics (KPIs)**: Define 2-3 measurable targets.
  - Good: "Increase daily active users (DAU) by 10% in 30 days."
  - Bad: "Make the app more popular."

### 3. Specify Requirements
- **User Stories (INVEST)**: Independent, Negotiable, Valuable,
  Estimable, Small, Testable.
- **Functional Requirements**: Describe *what* the system does, not *how*.
  Focus on behavior and state transitions.

### 4. AI Grounding
- **Entity Catalog**: Define core objects and their properties. This is
  critical for AI tools to understand your domain model.
- **AI Context Block**: Specific instructions for coding agents. Include
  logic rules, "never do" lists, and expected model behaviors.

### 5. Establish Constraints
- **Scope & Non-Goals**: Explicitly list what we are *not* doing to
  prevent scope creep.
- **Non-Functional Requirements (NFRs)**: Use thresholds for performance,
  security, and reliability.
- **Risks & Assumptions**: Document technical unknowns and how they will
  be mitigated.

### 6. Refine & Validate
- **Acceptance Criteria**: Use Given/When/Then format for each story.
- **Rollout Plan**: Define feature flags, rollback strategies, and phases.

---

## Constraints

- **Solution-Agnostic**: Avoid prescribing implementation unless it is a
  hard constraint.
- **Literal Specificity**: Replace "user-friendly" with "completed in 3
  clicks" or "no more than 500ms p95 latency."
- **AI-Native**: Assume the PRD will be parsed by an LLM to generate
  code/tests.

---

## Authoring Checklist

- [ ] Problem statement is clear and data-backed.
- [ ] Goals have specific, measurable metrics with baselines.
- [ ] Non-goals are explicit.
- [ ] Entity catalog defines all core domain objects.
- [ ] AI context block includes specific logic rules and "never do" items.
- [ ] Acceptance criteria use Given/When/Then format.
- [ ] NFRs have measurable thresholds (latency, uptime, etc.).
- [ ] Rollout plan includes a kill-switch/rollback strategy.
- [ ] Document is maintained as Markdown within the repository.
