# modeling-domains PRD

| Field | Value |
| :--- | :--- |
| **Status** | Draft |
| **Author** | Gemini CLI |
| **Updated** | 2026-03-02 |
| **Reviewers** | [User] |

## 1. Context & Problem
The system lacks a structural bridge between a Product Requirement and its implementation. Code often becomes a "Big Ball of Mud" because domain boundaries are not identified early. `docs/methodologies/domain-driven-design.md` outlines the philosophy, but agents need a specific skill to identify bounded contexts, entities, and value objects *before* implementation begins.

## 2. Outcomes & Success Metrics
- **Goal**: To define a clean architectural boundary and a "Ubiquitous Language" that ensures the code structure matches the business problem.
- **KPI-1**: 100% of features touching >2 modules must have a documented Bounded Context Map.
- **KPI-2**: Elimination of "leaky abstractions" where internal IDs or logic bleed across unrelated modules.

## 3. Users & Use Cases
**Primary Persona**: Senior Architecture Agent

**User Story**:
As an agent, I want to map out the domain model and boundaries so that I can implement a modular, maintainable, and decoupled codebase.

## 4. Functional Requirements
- **FR-1**: **Bounded Context Mapping**: Identify and name the logical boundaries within the project (e.g., "Billing," "Inventory").
- **FR-2**: **Ubiquitous Language Definition**: Define a glossary of terms that will be used consistently in both code and documentation.
- **FR-3**: **Entity & Aggregate Identification**: Identify the core stateful objects (Entities) and their clusters (Aggregates).
- **FR-4**: **Context Map Visualization**: Produce a markdown-based relationship map between contexts (e.g., Upstream/Downstream, Customer/Supplier).

## 5. Entity Catalog (AI Grounding)
| Entity | Properties | Description |
| :--- | :--- | :--- |
| **Bounded Context** | name, responsibility, interface | A logical boundary where a specific model is defined and applicable. |
| **Aggregate Root** | entity_id, child_entities | The entry point for a cluster of associated objects treated as a unit. |
| **Ubiquitous Language** | term, definition, code_symbol | A shared vocabulary used by both product and engineering. |

## 6. AI Context Block
- **Logic Rules**:
  - Never share models across bounded contexts without an "Anti-Corruption Layer."
  - Always prioritize domain clarity over "code reuse" if reuse causes coupling.
- **Strict Constraints**:
  - Do not introduce infrastructure details (DB, API) into the domain model.
- **Agent Guidelines**:
  - Follow the principles in `docs/methodologies/domain-driven-design.md`.

## 7. Non-Functional Requirements (NFRs)
- **Modularity**: The resulting model must support a "Trunk-Based" development workflow without blocking other teams.
- **Maintainability**: New engineers should be able to understand the domain by reading the context map.

## 8. Scope & Non-Goals
**In Scope**:
- Domain modeling, boundary identification, and aggregate design.
- Creating a "Context Map" for the tech plan.

**Out of Scope**:
- Physical database schema design (handled by tech plan).
- API implementation details.

## 9. Risks & Assumptions
- **Risk**: Over-engineering simple domains into too many contexts. - **Mitigation**: Start with one context and only split when "friction" (ambiguous terms) occurs.
- **Assumption**: The project is large enough to benefit from DDD (otherwise, keep it simple).

## 10. Rollout & Safety
- **Phased Release**: Apply to "core" modules first to establish the baseline.
- **Rollback Strategy**: If DDD complexity slows down simple features, revert to a "Active Record" or simple service pattern.

## 11. Acceptance Criteria
- **AC-1**: Given a "User Management" feature, When the skill is run, Then it identifies "Identity" and "Profile" as distinct sub-domains.
- **AC-2**: Given a set of entities, When the skill is run, Then it identifies which entity is the "Aggregate Root" for transactional consistency.

## 12. Changelog
| Version | Date | Author | Change |
| :--- | :--- | :--- | :--- |
| 0.1 | 2026-03-02 | Gemini CLI | Initial Draft |
