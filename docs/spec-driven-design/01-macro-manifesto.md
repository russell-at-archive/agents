# Spec-Driven Design (SDD): The Macro Manifesto

Spec-Driven Design (SDD) is a software engineering methodology where a structured, versioned specification serves as the **Single Source of Truth (SSOT)** and the primary driver for the entire development lifecycle.

## Why SDD Matters

In the era of AI-assisted engineering, SDD is the rigorous alternative to "vibe-coding" (relying on vague, conversational prompts). It ensures that both human developers and AI agents operate with a shared, unambiguous understanding of intent before a single line of code is written.

### The "Spec-First" Mandate
In this architecture, **no code is written before a spec exists.** This mandate is enforced through a dedicated `.specs/` directory in the repository, serving as the "Source of Intent."

### The Problem: Intent Drift
Traditional development often suffers from "intent drift," where the original requirement is lost or misinterpreted during implementation. This leads to:
- **Regressions:** Changes that break existing functionality because the "why" wasn't documented.
- **Context Bloat:** AI agents losing track of the goal in large, unstructured files.
- **Decision Fatigue:** Developers making micro-decisions that diverge from the architectural vision.

### The Solution: Specification as a Contract
By treating the specification as a contract, you move the complexity of "thinking" to a phase that is easier to review, iterate on, and validate.

---

## The Four Pillars of SDD

1. **Specify (The What):** Define user journeys, business logic, and success criteria. Focus on *what* the system does and *why*.
2. **Plan (The How):** Define technical strategy, data models, API contracts, and architectural constraints. Focus on *how* the requirements will be met.
3. **Task (The Execution):** Break the plan into small, atomic, and reviewable tasks. Each task should be implementable and testable in isolation.
4. **Validate (The Truth):** Execute the tasks and compare the implementation against the original specification via automated tests and property-based testing.

---

## Core Principles

- **Single Source of Truth:** The spec is the authoritative reference. If requirements change, update the spec first. If code and spec disagree, the code is incorrect.
- **Outcome-Oriented:** Tell the agent *what* success looks like, not just *how* to get there.
- **Human-Readable, Machine-Executable:** Specs should be clear enough for a human to audit but structured enough for an AI to implement.
- **Traceability:** Every surgical code change must be traceable back to an atomic task, which traces back to a technical plan, which traces back to a requirement.
- **Minimalism:** Specify only what is needed. Avoid "specifying ahead" to prevent unnecessary complexity.
