# writing-adrs: Antipatterns and Troubleshooting

## Table of Contents

1. [Critical Antipatterns](#critical-antipatterns)
2. [Section-Level Mistakes](#section-level-mistakes)
3. [Process Mistakes](#process-mistakes)
4. [Red Flags During Review](#red-flags-during-review)
5. [Scope Calibration](#scope-calibration)

---

## Critical Antipatterns

### Post-Hoc Rationalization

**What it looks like**: The ADR is written after the decision is implemented,
with only one realistic "option" and consequences that are all positive.

**Why it's harmful**: Future engineers can't distinguish real trade-off analysis
from justification theater. The ADR provides no signal about what was actually weighed.

**Fix**: If writing after the fact, reconstruct the genuine alternatives that
were considered, even informally. If only one option was ever viable, note that
explicitly and explain why in Context rather than manufacturing fake options.

---

### Editing an Accepted ADR

**What it looks like**: Someone opens a PR that modifies the Decision, Context,
or Consequences sections of a file with `Status: Accepted`.

**Why it's harmful**: Destroys the historical record. Future readers cannot
tell what was actually decided at the time, or why the reasoning changed.

**Fix**: Write a new ADR with the updated decision. Update the old ADR's
Status line only: `Superseded by [ADR-NNNN](NNNN-title.md)`.

---

### Missing Negative Consequences

**What it looks like**: The Negative Consequences section is empty, says
"None identified", or contains only vague entries like "adds some complexity."

**Why it's harmful**: Every real architectural decision involves trade-offs.
An ADR with no downsides signals incomplete analysis and erodes trust in the document.

**Fix**: Ask: What becomes harder? What costs more? What new failure modes does
this introduce? What skills must the team learn? What future options does this foreclose?

---

## Section-Level Mistakes

### Context Embeds the Decision

**Symptom**: A reader knows the chosen option before reaching Decision Outcome.

**Example (bad)**:
> We need a message queue. We chose Kafka because it's battle-tested and our
> team already knows it. SQS would have worked but lacks replay capability.

**Fix**: Context describes forces only. Move the decision and comparison to
Decision Outcome and Pros/Cons.

---

### Decision Drivers Are Too Vague

**Symptom**: Drivers like "must be scalable", "must be maintainable",
"good developer experience" — provide no evaluation criteria.

**Fix**: Quantify where possible. "Scalable" → "must sustain 10k events/second
with p99 < 200ms." "Maintainable" → "must be operable by a team without a
dedicated SRE."

---

### Considered Options Contains Only One Real Choice

**Symptom**: One fully-described option and one strawman ("we could have done
nothing, but that would have been bad").

**Fix**: List at least two options that could have genuinely been chosen.
If only one option was viable, say so in Context: "Only one option satisfied
the hard constraint of X" and do not manufacture a Pros/Cons section.

---

### Pros/Cons Doesn't Explain Losses

**Symptom**: Non-chosen options have only "Bad, because it doesn't meet our
requirements" without specifics.

**Fix**: For each non-chosen option, write at least one concrete reason it
lost relative to the decision drivers. Pre-answer "why didn't you just use X?"

---

### Title Describes the Problem, Not the Decision

**Symptom**: `0014-what-to-do-about-authentication.md`,
`0014-api-gateway-evaluation.md`

**Fix**: Title is the answer, not the question.
`0014-require-jwt-authentication-for-all-api-endpoints.md`

---

## Process Mistakes

### ADR Number Reuse or Gaps

**Symptom**: Two ADRs share a number, or numbers skip (0003, 0005 with no 0004).

**Fix**: Never renumber. Rejected ADRs keep their number. If a file was
accidentally deleted, create a placeholder at the old number with
`Status: Rejected` and a note explaining the history.

---

### ADR Merged Without Review

**Symptom**: ADR goes straight from Proposed to committed on main without
a PR or async review step.

**Fix**: ADRs are decisions that affect the team. Even a 24-hour async comment
window is better than unilateral acceptance.

---

### ADR Written for Implementation Details

**Symptom**: `0021-use-snake-case-for-variable-names.md`,
`0034-set-connection-pool-size-to-10.md`

**Fix**: ADRs are for decisions that are hard to reverse and affect system
structure. Use a CONTRIBUTING.md, linter config, or inline comment for
implementation-level conventions.

---

## Red Flags During Review

These indicate the ADR is not ready to accept:

| Red Flag | Action |
|----------|--------|
| Fewer than two Considered Options | Ask author for the alternatives that were genuinely weighed |
| Negative Consequences is empty or "None" | Return for revision — every decision has trade-offs |
| Context section names the chosen option | Revise so context is decision-neutral |
| Decision Drivers cannot be used to evaluate the options | Rewrite drivers as measurable criteria |
| Consequences are all vague ("improves performance") | Require concrete specifics |
| File is numbered out of sequence | Renumber before merge |
| Status is not updated after team agrees | Update Status before merging |

---

## Scope Calibration

### Too Granular (don't write an ADR)

- Variable naming conventions
- Log format within a single service
- Choosing between two libraries with equivalent trade-offs
- Any decision that takes under a day to reverse

### Too Broad (split into multiple ADRs)

- "Our microservices architecture" — split into: service decomposition,
  inter-service communication, data ownership, deployment strategy
- "Our security posture" — split by domain: authentication, authorization,
  secret management, network segmentation

### Right Scope (write an ADR)

- Choosing a primary database technology
- Adopting an architectural pattern (event sourcing, CQRS, saga)
- Selecting an inter-service communication protocol (REST vs. gRPC vs. messaging)
- Defining the deployment model (containers, serverless, VMs)
- Establishing a public API versioning strategy
