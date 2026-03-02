---
name: writing-adrs
description: >
  Produces complete, ready-to-commit Architecture Decision Records (ADRs) in
  MADR format. Triggers when the user asks to write, create, or update an ADR,
  document an architectural decision, or record a technology choice.
---

# Writing Architecture Decision Records

## When to Use

- User asks to "write an ADR", "create an ADR", or "document an architectural decision"
- User describes a technology or design choice that needs recording
- User asks to update or supersede an existing ADR
- User asks whether a decision warrants an ADR

## When Not to Use

- The decision is an implementation detail or coding-style choice
- The decision is easily reversible with no long-term structural impact
- The user wants a general design doc, RFC, or PRD (use a different skill)

## Prerequisites

Before writing, confirm with the user:

1. **Decision topic** — what was decided (not the problem; the resolution)
2. **Next ADR number** — check the existing `docs/decisions/` or `doc/adr/` directory
3. **Options that were considered** — at least two; ask if unknown
4. **Chosen option** — and the primary reason it won

If any are missing, ask before writing.

## Workflow

1. Determine the next sequential number and derive the filename:
   `NNNN-short-hyphenated-title.md` stored in `docs/decisions/`.
2. Write the ADR section by section — see
   [references/overview.md](references/overview.md) for section-writing rules.
3. Run the quality checklist (below) before presenting the file.
4. Output the complete file, ready to commit.

## Section Order (MADR)

```
# Title
## Status
## Context and Problem Statement
## Decision Drivers
## Considered Options
## Decision Outcome
### Positive Consequences
### Negative Consequences
## Pros and Cons of the Options
### [Each option]
## Links
```

## Quality Checklist

Run every item before declaring done:

- [ ] Title is a present-tense noun phrase describing the decision (not the problem)
- [ ] Context does not pre-justify the decision
- [ ] At least two options are listed under Considered Options
- [ ] Decision Outcome names the chosen option and cites a decision driver
- [ ] Negative Consequences are honest and specific (no vague "some complexity added")
- [ ] Pros/Cons section explains why each non-chosen option lost
- [ ] Status is one of: Proposed, Accepted, Rejected, Deprecated, Superseded by ADR-NNNN
- [ ] Filename is `NNNN-kebab-case-title.md`, zero-padded to four digits
- [ ] No unexplained acronyms or undefined terms

## Hard Rules

- Never edit the Context or Decision of an **Accepted** ADR. Write a new one to supersede it.
- Always update the old ADR's Status to `Superseded by [ADR-NNNN](NNNN-title.md)` when superseding.
- ADRs are append-only and immutable once accepted.

## References

- [Full section-writing guide](references/overview.md)
- [Worked examples](references/examples.md)
- [Antipatterns and troubleshooting](references/troubleshooting.md)
