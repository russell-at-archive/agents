# Techniques and Anti-Patterns

## Table of Contents

1. [Cross-Cutting Techniques](#cross-cutting-techniques)
2. [Anti-Patterns](#anti-patterns)
3. [Recovery Moves](#recovery-moves)

---

## Cross-Cutting Techniques

These work at any phase of the design session.

### Perspective Shifting

When a design feels stuck or one-dimensional, inject a new viewpoint:

> "How would a senior security engineer critique this?"
> "What would a DBA say about this schema?"
> "What does the on-call engineer think of this at 2am when it's broken?"
> "How does a product manager trying to ship in 6 weeks see this?"

Each persona surfaces concerns the primary framing misses. Security sees
attack surface. DBAs see query patterns. On-call engineers see observability
gaps. Product managers see over-engineering.

### Explicit Constraint Injection

LLMs treat unstated constraints as flexible. Restate hard constraints at
the start of each phase — don't assume they carry forward:

> "Given these hard constraints: [X, Y, Z] — how does that change this
> phase?"

If you only state constraints once in the kickoff template, they will
silently erode as the conversation progresses.

### Running Decision Log

After any significant design choice, prompt:

> "Summarize the decisions we've made so far and the reasoning behind each."

This produces an ADR-like artifact, keeps the LLM coherent across a long
session, and gives you something to hand to teammates.

Format the log requests the same way each time — the LLM will build on
the previous entry rather than starting over.

### The Naive User Attack

For any interface, API, or workflow:

> "Walk me through how a confused user would break this. Not a malicious
> attacker — just someone using it wrong."

Surfaces usability gaps, missing validation, and error states that pure
architectural thinking skips.

### Challenge the Output

After any design artifact the LLM produces:

> "What's the strongest argument against what you just said?"

LLMs are trained to be helpful and confident. They need explicit permission
to be critical of their own outputs. This one prompt often surfaces the
most important caveat in the design.

### The Specificity Demand

When tradeoffs are vague, demand numbers:

> "Don't say 'it's slower' — how much slower, under what load, on what
> hardware, compared to what baseline?"

"It depends" is also not acceptable. Push for:

> "It depends on X. In our case X is Y, so the answer is Z."

---

## Anti-Patterns

### Single-Shot Design Request

**What it looks like:** "Design me a system that does X."

**Why it fails:** The LLM produces a plausible-sounding answer optimized
for confidence, not correctness. It skips interrogation, presents one
option as the only option, and buries assumptions in the prose.

**Fix:** Use Phase 0. Always interrogate before designing.

### Accepting the First Design

**What it looks like:** LLM produces an architecture diagram in Phase 2
and the user moves on.

**Why it fails:** The first design is the most obvious design. It's what
the LLM sees most often in training data. It may not fit your constraints.

**Fix:** Require 3 fundamentally different approaches before evaluating any.

### Conflating Design and Implementation

**What it looks like:** "OK so we'll use Postgres — how do I set up the
connection pool?"

**Why it fails:** Once the conversation shifts to implementation, the
design conversation is over. Critical design questions go unasked.

**Fix:** Stay in planning mode until Phase 5 (pre-mortem) is complete.
Move to Phase 6 only when the design is explicitly confirmed.

### Vague Tradeoffs

**What it looks like:** "Option A is more scalable but harder to operate."

**Why it fails:** This tells you nothing about whether the tradeoff matters
for your system at your scale.

**Fix:** Push for specifics every time. "Harder to operate how? What breaks
first, at what scale, and who has to fix it?"

### Sparse Context

**What it looks like:** Kickoff template filled in with one-sentence answers
or left mostly blank.

**Why it fails:** Generic context produces generic design. The LLM will
fill the gaps with the most common assumptions from its training data,
which may not match your situation.

**Fix:** The more specific the context, the more specific and useful the
design. Treat blank fields as invitations for the LLM to ask clarifying
questions, not as acceptable gaps.

### Silently Accepting Assumption Drift

**What it looks like:** The LLM changes an earlier recommendation mid-session
without flagging it.

**Why it fails:** You end up with a design that contradicts itself, and
you don't notice until implementation.

**Fix:** The system prompt instructs the LLM to surface conflicts explicitly.
If you notice drift anyway, say: "Earlier you recommended X, now you're
recommending Y. What changed and does that affect other decisions?"

---

## Recovery Moves

When a design session goes off track:

**Session has drifted into implementation too early:**
> "Let's step back. We're in implementation mode. I want to stay in planning
> mode. What design questions haven't we answered yet?"

**LLM is just agreeing with everything:**
> "I want you to actively push back on this design. What would you change
> if you had full authority? What's wrong with what we've built so far?"

**Design feels too abstract:**
> "Walk me through a specific user scenario end-to-end through this
> architecture. What happens at each layer?"

**Too many options, can't decide:**
> "Given only my hard constraints — [X, Y, Z] — which of the 3 options
> do you eliminate first and why?"

**Pre-mortem produced nothing useful:**
> "That pre-mortem was too generic. Name the specific component in our
> design that is most likely to cause a production incident in month 3.
> Why that one?"
