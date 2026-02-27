# ADR-{NNN}: {Imperative title — e.g. "Use PostgreSQL for persistent storage"}

> **Status:** Proposed
> **Date:** YYYY-MM-DD
> **Decision-makers:** {names or roles}
> **Consulted:** {names, roles, or teams}
> **Informed:** {names, roles, or teams}
> **Supersedes:** ADR-{NNN} *(or "N/A")*
> **Superseded by:** N/A

---

## Context and Problem Statement

{2–3 sentences. Describe the situation and the challenge
that requires a decision. What forces are at play? What
constraints exist? What would happen if no decision is made?

Focus on the problem, not the solution. A reviewer reading
this ADR years from now must understand why this was
important without additional context.

Example: "The service needs to persist user session state
across requests. Session data is currently stored in memory,
which prevents horizontal scaling and causes data loss on
restart. We need to choose a persistence strategy before
beginning the scaling work planned for Q3."}

## Decision Drivers

The primary forces shaping this decision:

- {Driver 1 — force, constraint, or requirement, e.g.
  "Must support horizontal scaling to 10+ instances"}
- {Driver 2 — e.g. "Team has no prior experience with
  distributed systems; operational simplicity preferred"}
- {Driver 3 — e.g. "Must be open source to meet
  procurement requirements"}
- {Driver 4}

## Considered Options

1. {Option A — name it clearly, e.g. "Redis"}
2. {Option B — e.g. "PostgreSQL with advisory locks"}
3. {Option C — e.g. "In-process memory with replication"}

## Decision Outcome

We decided on **{Option X}** because {concise justification
tied directly to the decision drivers listed above. One
to three sentences.}.

### Confidence Level

{High / Medium / Low} — {Brief explanation. What would
change this assessment? Under what conditions should this
decision be revisited?

Example: "Medium — this decision assumes traffic stays
below 50k concurrent sessions. If we exceed that
threshold, revisit sharding strategy."}

### Consequences

**Good:**

- Good, because {positive consequence tied to a driver}
- Good, because {positive consequence}

**Bad:**

- Bad, because {negative trade-off accepted consciously}
- Bad, because {negative trade-off}

**Neutral:**

- Neutral, because {observation that is neither good nor
  bad but worth noting}

---

## Pros and Cons of Each Option

### Option A: {Name}

- Good, because {advantage}
- Good, because {advantage}
- Neutral, because {observation}
- Bad, because {disadvantage}
- Bad, because {disadvantage}

### Option B: {Name}

- Good, because {advantage}
- Neutral, because {observation}
- Bad, because {disadvantage}
- Bad, because {disadvantage}

### Option C: {Name}

- Good, because {advantage}
- Bad, because {disadvantage}
- Bad, because {disadvantage}

---

## Confirmation

{Optional. How will you verify this decision is working?
Include fitness functions, review triggers, or metrics
to monitor.

Example: "Review at 6-month mark. If p99 session lookup
latency exceeds 50ms, reconsider. If operational burden
exceeds 4 hours/week, revisit managed service options."}

## More Information

{Optional. Links to related artifacts, research, or
discussion that informed this decision.}

- Related: ADR-{NNN} — {title}
- Research: {link or description}
- Discussion: {link to RFC, PR, or meeting notes}
- Implementation: {link to task or PR that executes this}
