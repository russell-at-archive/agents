# ADR Macro: The Decision Manifesto

Architecture Decision Records (ADRs) are short, focused documents that record the "why" behind significant technical choices. They represent the **history of thinking** in a software project.

## The Problem: Architectural Drift

In long-running projects, developers often encounter code or infrastructure they don't understand. Without the original context, they might:
- **Avoid refactoring** for fear of breaking a hidden rule.
- **Re-solve the same problem** because they didn't know a solution was already chosen.
- **Revert a prior fix** because they didn't understand the trade-offs that made the current "weird" implementation necessary.

This is "Architectural Drift"—when the code evolves away from its intended design because the intent was never recorded.

## The Solution: Documenting the "Why"

While code comments and documentation tell you **what** the system does, an ADR tells you **why** it does it that way.

### The Value of the Log
1. **Tribal Knowledge Elimination:** New team members can read the ADR log to understand the project's history without needing a 3-hour orientation.
2. **Decision Accountability:** ADRs require developers to explicitly consider trade-offs, leading to more thoughtful choices.
3. **Historical Auditability:** ADRs explain why a "legacy" choice was made, often showing it was the correct decision *at that time* given the constraints.
4. **Socialized Architecture:** By using Pull Requests for ADRs, architecture becomes a collaborative effort rather than a top-down mandate.

## What Warrants an ADR?

Not every choice needs an ADR. Focus on **Architecturally Significant Requirements (ASRs)**:
- **Core Technology:** "Why use PostgreSQL over MongoDB?"
- **Integration Patterns:** "Why use GraphQL instead of REST?"
- **Structural Shifts:** "Moving from a monolith to microservices."
- **Security/Auth:** "Adopting OAuth2 for internal services."
- **Critical Libraries:** "Choosing a specific ORM or UI framework."

**The Rule of Thumb:** If a decision would be difficult or expensive to change in 6 months, it needs an ADR.

## Core Principles

- **Immutability:** Once an ADR is "Accepted," it is never edited. If the decision changes, you write a new ADR that **supersedes** the old one.
- **Append-Only:** The ADR folder is a chronological log of how the project's thinking evolved.
- **First-Class Artifact:** ADRs live in the repository with the code. If they are in a wiki or a shared drive, they will rot and be forgotten.
- **Short and Pithy:** An ADR should be readable in 2-3 minutes. It is a record of a decision, not a full design document.
