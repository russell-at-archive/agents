# 0001-record-architecture-decisions

## Status
Accepted

## Context and Problem Statement
In a complex system with multiple agents and human collaborators, architectural decisions are often made in ephemeral chat sessions or PR comments. This leads to a loss of context, "vibe-based" implementation, and difficulty in understanding the "why" behind structural choices as the codebase evolves. We need a way to maintain a durable, version-controlled history of significant design and technology choices.

## Decision Drivers
- Need for long-term architectural alignment across multiple agents.
- Requirement for clear rationale for design choices to reduce rework.
- Desire for a "Living Document" that evolves with the system.

## Considered Options
1. **Informal Documentation**: Relying on READMEs and PR descriptions to capture decisions.
2. **Architecture Decision Records (ADRs)**: Utilizing a structured, numbered format stored in the repository.

## Decision Outcome
Chosen option: **Architecture Decision Records (ADRs)**.

### Positive Consequences
- Decisions are immutable and version-controlled.
- New agents can quickly "catch up" by reading the history of architectural choices.
- Reduces repetitive discussions about "why" a certain pattern was chosen.
- Forces explicit consideration of alternatives and consequences.

### Negative Consequences
- Slight overhead in documenting decisions before implementation.
- Requires discipline to update the status (e.g., Superseded) when decisions change.

## Pros and Cons of the Options

### Informal Documentation
- **Pros**: Low friction; no specific format required.
- **Cons**: High drift; difficult to search; context is often lost in git history or external tools.

### Architecture Decision Records (ADRs)
- **Pros**: Structured and searchable; durable context; forces rigorous thinking about consequences.
- **Cons**: Requires specialized skills and consistent maintenance.

## Links
- `skills/writing-architecture-decision-records/SKILL.md`
- `docs/operating-manual.md`
