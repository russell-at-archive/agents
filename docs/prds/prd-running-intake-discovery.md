# running-intake-discovery PRD

| Field | Value |
| :--- | :--- |
| **Status** | Draft |
| **Author** | Gemini CLI |
| **Updated** | 2026-03-02 |
| **Reviewers** | [User] |

## 1. Context & Problem
Currently, the system lacks a formalized entry point for capturing and clarifying user intent. Agents often jump straight from a vague prompt to writing a PRD or Tech Plan, leading to incorrect assumptions, missed constraints, and significant rework. `docs/methodologies/intent-engineering.md` provides a theoretical framework for "Intent Representation," but no operational skill exists to execute this lifecycle.

## 2. Outcomes & Success Metrics
- **Goal**: To transform raw user requests into machine-actionable Intent Contracts that define exactly what, why, and how success is measured.
- **KPI-1**: 30% reduction in PRD/Tech Plan revisions due to "misunderstood requirements."
- **KPI-2**: 100% of Intake sessions produce an explicit "Intent Contract" with measurable success criteria.

## 3. Users & Use Cases
**Primary Persona**: Software Engineering Agent

**User Story**:
As an agent, I want to systematically clarify user goals and constraints so that I can create a robust implementation plan without guessing.

## 4. Functional Requirements
- **FR-1**: **Ambiguity Detection**: Identify missing required fields (Goal, Constraints, Entities) in the initial user request.
- **FR-2**: **Constraint Extraction**: Explicitly prompt for time, budget, policy, and scope limits.
- **FR-3**: **Disambiguation Loop**: Ask targeted questions when multiple interpretation candidates exist.
- **FR-4**: **Intent Contract Generation**: Produce a structured "Intent Representation" (Goal, Inputs, Constraints, Success Criteria, Fallback).

## 5. Entity Catalog (AI Grounding)
| Entity | Properties | Description |
| :--- | :--- | :--- |
| **Intent Contract** | goal, constraints, criteria, fallback | The formal agreement between user and agent on the desired outcome. |
| **Constraint** | type, value, priority | A limit (e.g., "Must use Vanilla CSS") that bounds the solution space. |
| **Success Criterion** | given, when, then | A measurable state that proves the intent was fulfilled. |

## 6. AI Context Block
- **Logic Rules**:
  - Never proceed to planning if confidence in intent is below 80%.
  - Always restate the understood goal and constraints to the user for confirmation.
- **Strict Constraints**:
  - Do not invent constraints; if unknown, mark as "to be clarified."
- **Agent Guidelines**:
  - Use the "Lightweight Intent Spec Template" from `docs/methodologies/intent-engineering.md`.

## 7. Non-Functional Requirements (NFRs)
- **Clarity**: Questions must be concise and avoid "yes/no" if a specific value is needed.
- **Traceability**: The resulting Intent Contract must be linkable to the subsequent PRD or Tech Plan.

## 8. Scope & Non-Goals
**In Scope**:
- Early-stage discovery and clarification.
- Drafting the initial Intent Representation.

**Out of Scope**:
- Writing the full PRD (handled by `writing-product-requirement-documents`).
- Executing implementation (handled by implementation-specific skills).

## 9. Risks & Assumptions
- **Risk**: Over-clarifying simple requests may annoy users. - **Mitigation**: Use a heuristic to skip detailed discovery for trivial tasks.
- **Assumption**: The user is willing to engage in a short dialogue to establish clarity.

## 10. Rollout & Safety
- **Phased Release**: Internal pilot with "complex" feature requests first.
- **Rollback Strategy**: Revert to standard conversational prompting if the discovery skill becomes a bottleneck.

## 11. Acceptance Criteria
- **AC-1**: Given a vague request like "Add auth," When the skill is run, Then it asks for the auth provider, token expiration policy, and session management strategy.
- **AC-2**: Given a clear request, When the skill is run, Then it summarizes the intent and success criteria in under 5 lines for user approval.

## 12. Changelog
| Version | Date | Author | Change |
| :--- | :--- | :--- | :--- |
| 0.1 | 2026-03-02 | Gemini CLI | Initial Draft |
