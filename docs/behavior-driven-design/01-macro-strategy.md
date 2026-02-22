# 01 Macro Level: Strategic BDD

At the macro level, BDD is a **collaborative design methodology** rather than a testing framework. It answers the fundamental question: **Why are we building this?**

## 1. The Discovery Phase
Discovery is the most critical stage of BDD. It involves multiple stakeholders working together to uncover requirements and eliminate ambiguity.

### Key Practices:
- **The Three Amigos:** A collaborative meeting between a **Product Owner** (the business value), a **Developer** (the technical feasibility), and a **Tester** (the edge cases and verification).
- **Example Mapping:** A technique to structure the discovery conversation using four types of cards:
    - **Story:** The high-level user story.
    - **Rule:** A business logic constraint or rule.
    - **Example:** A concrete scenario illustrating a rule.
    - **Question:** An unresolved point that needs further clarification.

## 2. Business Value & Outcome Focus
Every macro-level behavior should be tied to a specific business goal. 
- Instead of "A user can log in," think "To ensure secure access to private data, a registered user must provide valid credentials."
- Use **Impact Mapping** to visualize how deliverables contribute to high-level goals.

## 3. Ubiquitous Language (DDD Alignment)
Borrowing from Domain-Driven Design (DDD), BDD relies on a shared, unambiguous vocabulary.
- Developers and stakeholders must use the **same terms** in requirements, feature files, and code.
- Create a **Glossary** of terms to ensure everyone understands the same concepts (e.g., Is an "Order" the same as a "Purchase"?).

## 4. Acceptance Criteria as Shared Understanding
Macro-level success is measured by the fulfillment of high-level Acceptance Criteria (AC). These ACs form the skeleton of the Meso-level feature files.

---
[Next: Meso Workflow: The "What"](./02-meso-workflow.md)
