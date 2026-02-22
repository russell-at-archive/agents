# SDD Micro: Implementation Precision & Templates

Expertise in Spec-Driven Design requires writing specifications that are **machine-readable and human-verifiable.** Use these standardized templates to ensure high-signal collaboration.

---

## 1. Requirement Template (`/requirements/FEATURE_NAME.md`)

```markdown
# Requirement: [Feature Name]

## Job to be Done (JTBD)
As a [user role], I want to [action], so that [benefit].

## Acceptance Criteria (AC)
- [ ] AC 1: Describe a specific, testable behavior.
- [ ] AC 2: Describe an edge case handling.

## Negative Requirements (Constraints)
- The system MUST NOT [unsafe behavior].
- The system MUST NOT [unauthorized dependency].

## Out of Scope
- What are we *not* doing in this spec?
```

## 2. Technical Plan Template (`/plans/FEATURE_NAME.md`)

```markdown
# Plan: [Feature Name]

## Proposed Architecture
Describe the structural changes. Use Mermaid diagrams for clarity.

## Contract Definitions
- **Function/API:** `POST /v1/calculate-tax { amount, rate }`
- **Data Model:** [Interface or Schema definition]

## Validation Strategy
How will we prove this works?
- [ ] Test Case 1: [Command to run] -> [Expected Output]
```

## 3. Task List Template (`/tasks/FEATURE_NAME.md`)

```markdown
# Tasks: [Feature Name]

- [ ] **Task 1: [Title]**
  - **Action:** Surgical change description (e.g., "Implement calculateTax in src/logic.ts").
  - **Validation:** `npm run test -- src/logic.test.ts`
```

---

## Expert Protocol for Implementation

To ensure successful delivery, follow these "Micro" rules during implementation:

1.  **Spec Validation First:** Before writing a Plan, ensure the Requirement is approved.
2.  **Constraint Adherence:** Every code change must respect the global rules in `.specs/constraints/`.
3.  **The "Single Developer Turn" Rule:** If a task takes more than 2-4 hours to implement and validate, it's too big. Decompose it further.
4.  **Finality through Validation:** A task is not "Done" until the `Validation` command passes. A feature is not "Done" until every AC in the Requirement Spec passes.
5.  **The Rule of One:** Every change should reference exactly **one** requirement and **one** plan.

## Advanced Validation Patterns

### Contract-Driven Testing
The spec *is* the validator. Use tools like OpenAPI (Swagger) or shared TypeScript interfaces to ensure that if the code deviates from the spec, the build fails automatically.

### Property-Based Testing
For critical logic, use property-based testing (e.g., `fast-check` in JS) to prove that your spec holds true for *all* possible valid inputs, rather than just specific examples.
