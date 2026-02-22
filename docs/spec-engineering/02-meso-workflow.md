# Spec Engineering: The Meso Workflow

## 1. The Spec-Driven Lifecycle

The Spec Engineering workflow is a structured process that moves from
high-level intent to a verified, bug-free implementation. This lifecycle
ensures that both human and AI remain aligned.

1. **Requirement Gathering (The "What"):** Define the business problem, user
   journey, and success criteria.
2. **Technical Specification (The "How"):** Define the architectural strategy,
   data models, and constraints.
3. **Task Decomposition (The "Action"):** Break the technical spec into small,
   atomic, and testable tasks.
4. **Implementation & Validation (The "Result"):** Execute tasks and verify the
   implementation against the original requirements.

---

## 2. Managing the Spec Hierarchy

To avoid "context bloat" and "intent drift," Spec Engineering uses a
hierarchical structure for documentation.

- **Global Project Spec (`SPEC.md`):** High-level roadmap, core principles, and
  architectural vision.
- **Feature/Product Specs:** Deep dives into specific user-facing features or
  modules.
- **Technical Design Specs:** Architectural blueprints for how features will be
  built.
- **Task Specs:** Short-lived, surgical instructions for a single unit of work
  (typically a single commit or PR).

---

## 3. The End-to-End Workflow

### Phase 1: Formalize Requirements

Don't just say "Add a login button." Define:

- Who is the user?
- What is the expected behavior?
- What happens when things go wrong (errors, edge cases)?
- How will success be measured (acceptance criteria)?

### Phase 2: Design the Solution

Before writing code, draft the technical approach:

- What files will be affected?
- What new dependencies are needed?
- What is the data model?
- What are the API contracts?

### Phase 3: Decompose into Atomic Tasks

Break the design into tasks that take less than 2 hours to complete. Each task
must have:

- **A clear input:** "Start from state X."
- **A clear action:** "Modify file Y to do Z."
- **A clear output/validation:** "Run test A to verify Z."

### Phase 4: Execute & Validate (The Loop)

For each task:

1. Provide the AI with the **Global Context** (for architecture) and the
   **Task Spec** (for execution).
2. Review the code.
3. **Run the validation tests.**
4. If it fails, update the **Task Spec** or **Technical Spec**—don't just "fix
   it in the code."

---

## 4. Context Management: The Secret to High-Quality AI

AI performance degrades as the context window becomes cluttered with
irrelevant information. Spec Engineering solves this through **Focus**.

- **Global Context:** Use for understanding the "Big Picture."
- **Local Context:** Use for the specific task at hand.

When executing a task, only provide the AI with what it absolutely needs to
know to finish that task. This prevents the AI from making "creative" decisions
that diverge from the global architecture.

---

**Next:** Master the practical tactics in the
**[Micro Implementation Standards](./03-micro-implementation.md)**.
