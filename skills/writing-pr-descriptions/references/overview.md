# Overview

## Purpose

A PR description is the narrative record of a code change.
It explains what changed, why, and how to verify it. It is
the primary document a human reviewer reads during async
review — and the primary audit artifact after the fact.

**Core principle:** The diff shows what. The description
explains why. Never summarize code changes — the diff does
that. Explain the reasoning, the trade-offs, and what the
reviewer should watch for.

## Required Sections

Every PR description must include all of the following:

**Title** — in Conventional Commits format:
`<type>(<scope>): <short description>`

**Summary** — 3–5 bullets explaining what changed and why.
Not a restatement of the diff.

**Type of change** — one checkbox selected from the
standard list.

**Closes / Refs** — a GitHub closing keyword linking to
the task issue. `Closes #NNN` auto-closes the issue on
merge. Use `Refs #NNN` when the PR partially addresses
an issue.

**Approach and alternatives considered** — the
implementation rationale and at least one alternative
that was rejected. This is the audit record: future
reviewers rely on this to understand decisions,
especially for AI-generated PRs.

**Test plan** — the exact commands run to verify the
change, plus a checklist of scenarios tested.

**How to verify** — step-by-step instructions for the
reviewer to independently verify the change.

**Definition of done** — a checklist, fully checked
before requesting review.

## Writing the Approach Section

This section is the most important for audit purposes.
It must answer:

1. What implementation approach was chosen?
2. Why this approach over alternatives?
3. What trade-offs were consciously accepted?

For AI-generated PRs, this section is what allows the
human to understand the agent's reasoning without reading
the full diff. It is also what allows post-mortem analysis
when something goes wrong.

A weak Approach section:

> "Implemented the feature as described in the task."

A strong Approach section:

> "Added rate limiting as Express middleware rather than
> inline in each route, so the logic is reusable across
> all auth endpoints. Considered a decorator pattern but
> rejected it because the codebase does not use
> TypeScript decorators. Considered a Redis-backed
> counter but rejected it to avoid adding an external
> dependency for a threshold of 100 req/min."

## PR Sizing

Keep PRs small and focused:

- Under 400 net lines changed
- Under 10 files touched
- Exactly one logical concern

If the change is larger, it should have been decomposed
into multiple tasks before reaching this stage. Surface
this as a concern in the PR summary if it was unavoidable.

## Quality Checklist

Before marking the PR ready for review:

- [ ] Title follows Conventional Commits format
- [ ] Summary explains why, not what
- [ ] Issue linked with `Closes #NNN` or `Refs #NNN`
- [ ] Approach includes at least one rejected alternative
- [ ] Test plan includes runnable commands
- [ ] How to Verify gives step-by-step reviewer instructions
- [ ] All definition of done boxes are checked
- [ ] No unresolved TODO comments left in the diff
