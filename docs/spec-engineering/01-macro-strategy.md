# Spec Engineering: The Macro Strategy

## 1. Specify, Don't Prompt

In traditional AI-assisted development, we "prompt" for code. We ask for a
function, a component, or a fix. But "prompting" is ephemeral, conversational,
and often imprecise.

**Spec Engineering** replaces "prompting" with "specifying." A specification is
a stable, version-controlled, and structured document that defines **intent**
with the same rigor we used to apply to **implementation**.

> "The code is just a byproduct of a high-quality specification."

---

## 2. The Architect's Shift

As a Spec Engineer, your role shifts from **"The Coder"** to
**"The Architect/Orchestrator."**

| From: Coder (Low-Level) | To: Spec Engineer (High-Level) |
| :--- | :--- |
| Writing syntax and logic. | Defining architecture and constraints. |
| Debugging compiler errors. | Debugging "Intent-Implementation" gaps. |
| Refactoring code blocks. | Refactoring and refining specifications. |
| Thinking about *how* to write. | Thinking about *what* to achieve and *why*. |

Your value is no longer in your ability to remember syntax, but in your ability
to **model systems** and **verify outcomes**.

---

## 3. The Core Principles of Spec Engineering

### I. The Single Source of Truth (SSOT)

The specification is the authoritative reference for what the system is and
what it does. If a requirement changes, the specification must be updated
**first**, before any code is changed.

### II. Atomicity and Decomposition

LLMs perform best when the context is narrow and the goal is unambiguous. A
large feature should always be decomposed into small, independent sub-tasks
that can be completed and verified in short cycles.

### III. Verifiability and Evals

A specification is only as good as its validation. Every spec should include
explicit "Evals" (Acceptance Criteria) and test cases that can be automatically
verified.

### IV. Treatment as Source Code

Specifications should live in your Git repository. They should be subject to
peer review, versioning, and continuous improvement.

### V. Separating "What" from "How"

- **The Requirements:** What is the business goal? (The "What")
- **The Design:** How will we architect the solution? (The "How")
- **The Tasks:** What are the discrete steps to build it? (The "Execution")

---

## 4. Avoiding the "Vibe-Coding" Trap

"Vibe-coding" is the process of loosely describing a feature to an AI and
hoping for the best. It works for simple tasks but fails for complex systems.
Spec Engineering eliminates the "vibe" by introducing **Formalization**.

When you feel the urge to "just prompt it," stop and ask yourself:

1. Is this documented in a spec?
2. Are the edge cases defined?
3. How will I know when this is "done" (verified)?

---

**Next:** Learn how to apply these strategies in the
**[Meso Workflow Lifecycle](./02-meso-workflow.md)**.
