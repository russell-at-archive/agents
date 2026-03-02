# writing-adrs: Full Procedure and Section-Writing Guide

## Table of Contents

1. [Background](#background)
2. [Decision Criteria](#decision-criteria)
3. [File Conventions](#file-conventions)
4. [Lifecycle and Statuses](#lifecycle-and-statuses)
5. [Section-Writing Rules](#section-writing-rules)
6. [Superseding an Existing ADR](#superseding-an-existing-adr)
7. [Team Workflow](#team-workflow)

---

## Background

Architecture Decision Records were introduced by Michael Nygard in 2011 to solve
a specific failure mode: architectural reasoning evaporates as teams turn over.
Without recorded rationale, new engineers either blindly accept inherited decisions
or discard them without understanding the consequences.

The MADR format (Markdown Architectural Decision Records) is the dominant modern
standard and the format this skill produces.

---

## Decision Criteria

### Write an ADR when the decision

- Affects multiple teams, services, or long-term system structure
- Is hard or expensive to reverse
- Involves a meaningful trade-off between competing forces
- Will confuse future maintainers without explanation
- Resolves a recurring debate

### Do NOT write an ADR for

- Implementation details (algorithm choice inside a single function)
- Coding style or formatting conventions
- Easily reversible configuration choices
- Decisions with only one viable option (document those in comments or docs)

---

## File Conventions

| Element | Rule |
|---------|------|
| Directory | `docs/decisions/` (preferred) or `doc/adr/` |
| Filename | `NNNN-short-hyphenated-title.md` |
| Numbering | Zero-padded 4-digit sequential integer; never reuse or renumber |
| Title case | Kebab-case; present-tense noun phrase describing the decision |
| Example | `0042-use-postgresql-for-primary-data-store.md` |

---

## Lifecycle and Statuses

| Status | Meaning |
|--------|---------|
| `Proposed` | Drafted; open for review; not yet binding |
| `Accepted` | Approved and in effect |
| `Rejected` | Considered and explicitly declined; keep the file |
| `Deprecated` | Was accepted but no longer applies (technology removed, etc.) |
| `Superseded by [ADR-NNNN](NNNN-title.md)` | Replaced by a newer decision |

**Append-only rule**: Never edit the Context, Decision, or Consequences of an
Accepted ADR. Write a new ADR to supersede it, then update the old ADR's Status
line only.

---

## Section-Writing Rules

### Title (`# Title`)

- Present-tense, imperative noun phrase describing **what was decided**, not the problem.
- Good: `Use PostgreSQL for Primary Data Store`
- Bad: `Database Decision`, `Should We Use PostgreSQL?`

### Status (`## Status`)

- Single word, optionally followed by a link: `Superseded by [ADR-0043](0043-migrate-to-aurora.md)`
- Update this line (and only this line) on accepted ADRs that are later superseded.

### Context and Problem Statement (`## Context and Problem Statement`)

- 2–4 sentences. Describe the forces, constraints, and triggering event.
- Write in present tense: "We need to..." not "We needed to..."
- Name relevant non-functional requirements (latency, cost, team expertise).
- **Do not embed the decision here.** A reader should not know which option won
  until they reach Decision Outcome.

### Decision Drivers (`## Decision Drivers`)

- Bulleted list of evaluative forces. These are the criteria options will be judged against.
- Be specific: "must support sub-100ms p99 read latency under 10k RPS" beats "must be fast."
- Include cost, operational burden, team skill level, and ecosystem maturity where relevant.

### Considered Options (`## Considered Options`)

- Short labels only, one per bullet: `* PostgreSQL`, `* MySQL`, `* DynamoDB`
- Always list at least **two** options.
- Include "Do nothing / status quo" when it is a realistic option.
- Expand detail in Pros and Cons of the Options section.

### Decision Outcome (`## Decision Outcome`)

- Format: `Chosen option: "[Option Name]", because [one-sentence rationale citing decision drivers].`
- This is the most-read section. Make it standalone — a reader who reads only this
  section should understand what was chosen and the primary reason why.
- Then list Positive and Negative Consequences as sub-sections.

#### Positive Consequences (`### Positive Consequences`)

- Enumerate what becomes easier, faster, cheaper, or safer.
- Be concrete: "Eliminates manual certificate rotation" beats "Improves security."

#### Negative Consequences (`### Negative Consequences`)

- Enumerate what becomes harder, more expensive, or riskier.
- Negative consequences are **not admissions of failure** — they are honest engineering.
- Every real decision has trade-offs. An ADR with no negative consequences is incomplete.
- Be concrete: "Increases p99 write latency by ~15ms vs. in-memory cache" beats "some overhead."

### Pros and Cons of the Options (`## Pros and Cons of the Options`)

- One sub-section per option using `### [Option Name]`.
- Use `* Good, because [argument]` and `* Bad, because [argument]` phrasing.
- For non-chosen options, this section must explain **why they lost**.
  Pre-answer the question "Why didn't you just use X?"
- Optional one-line description of the option before the bullets.

### Links (`## Links`)

- Use typed link labels: `Supersedes`, `Superseded by`, `Relates to`, `Informed by`, `Required by`.
- Format: `* [Relates to] [ADR-0038](0038-event-sourcing-for-audit-log.md)`
- Omit section if there are no related ADRs.

---

## Superseding an Existing ADR

When writing an ADR that overrides a previous decision:

1. Write the new ADR normally with `Status: Proposed`.
2. In the new ADR's **Links** section, add: `* Supersedes [ADR-NNNN](NNNN-old-title.md)`.
3. After the new ADR is accepted, update the **old** ADR's Status line to:
   `Superseded by [ADR-MMMM](MMMM-new-title.md)` — and change **nothing else** in the old file.

---

## Team Workflow

1. Author identifies a decision worth recording.
2. Create file: next sequential number, `Status: Proposed`, all sections drafted.
3. Open for team review via PR or async comment thread.
4. After consensus, update Status to `Accepted` (or `Rejected`) and merge.
5. Merge the ADR alongside the related code change in the same PR when possible.
6. If a future decision supersedes this one, follow the superseding steps above.
