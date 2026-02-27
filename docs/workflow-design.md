# AI-Orchestrated Software Development Workflow

## Purpose

This document defines a system for building high-quality software
using a team of orchestrated AI agents. The human acts as product
owner: approving intent, reviewing outcomes, and handling escalations
— without managing every step of execution.

## Core Principles

**GitHub is the system of record.** Issues, PRs, and commits are
durable, async-friendly, and linkable. Every decision, change, and
agent conversation lives there.

**Every handoff is a structured document.** Agents don't pass
freeform prose to each other. Each stage produces a document with
a defined schema: PRD template, task spec template, PR template.
This makes the audit trail readable and lets agents operate without
ambiguity.

**Quality is a built-in role.** A dedicated Reviewer agent checks
every PR against the original spec's acceptance criteria before the
human ever sees it. The human is the final reviewer, not the first.

**Escalation over guessing.** When an agent hits ambiguity it cannot
resolve, it stops, asks a specific question, and moves to the next
unblocked task. No agent spins or assumes intent.

## The Pipeline

```text
YOU
 │
 ▼
[Problem Statement]
 │
 ▼  ← gate: you approve
[Spec + Acceptance Criteria]
 │
 ▼  ← gate: you approve
[Technical Design + ADRs]
 │
 ▼  (automatic)
[Decomposed Task Graph]
 │
 ├──▶ [Task A] ──▶ [PR A] ──▶ [Review] ──▶ merge
 ├──▶ [Task B] ──▶ [PR B] ──▶ [Review] ──▶ merge
 └──▶ [Task C] ──▶ [PR C] ──▶ [Review] ──▶ merge
                                               │
                                               ▼
                                    [Integration Verification]
                                               │
                                               ▼
                                      YOU (async review)
```

You act twice in the normal flow: approve the spec, approve the
design. Everything else runs autonomously and you review the output
at your own pace.

## Human Gates

### Gate 1: Problem → Spec

You write a rough problem statement. The Planner agent produces a
PRD: goal, success metrics, acceptance criteria, explicit non-goals.
You read it — takes 2 minutes — and either approve or comment. This
is the highest-leverage gate. If the spec is wrong, everything
downstream is wrong.

### Gate 2: Spec → Execution

The Architect produces a tech plan and any ADRs. You review: does
this approach make sense? Are the trade-offs right? Approve or
redirect. After this gate, agents run without interrupting you.

### Async Review (not a gate)

As PRs open, you review them on your schedule. The Reviewer agent
has already checked them. Your job is product and architecture
review, not catching bugs.

## Agent Roles

### Planner

- **Input:** problem statement
- **Output:** PRD with acceptance criteria, success metrics, non-goals
- **Stored:** GitHub issue + `docs/specs/[feature].md`

### Architect

- **Input:** approved PRD
- **Output:** tech plan + ADR(s) documenting trade-offs considered
- **Stored:** `docs/adr/XXXX-*.md` + draft PR

### Decomposer

- **Input:** approved tech plan
- **Output:** GitHub issues, each with acceptance criteria, files to
  change, test requirements, and task dependencies
- **Stored:** GitHub issues, labeled and linked to the parent spec

### Coder

- **Input:** single task issue
- **Output:** code + tests in an isolated git worktree
- **Stored:** feature branch, opens a PR

### Reviewer

- **Input:** PR + original task spec
- **Output:** approval or specific, actionable feedback
- **Stored:** PR review comments

### Integrator

- **Input:** approved PRs
- **Output:** merged stack with CI passing
- **Stored:** main branch

## The Audit Trail

At any point the human can answer these questions from GitHub alone:

- **Why was this built?** → PRD issue
- **How was it designed?** → ADR in repo
- **What were the tasks?** → linked GitHub issues
- **What exactly changed?** → PR diff + conventional commit bodies
- **Was it reviewed?** → PR review by Reviewer agent
- **Did it pass?** → CI status + acceptance criteria checklist in PR

Conventional commits must include a rich body — not just a summary
line, but the full narrative: what was done, what alternatives were
considered, and why this approach was chosen. The commit log is the
decision journal.

## Toolset

**Orchestration:** Claude Code as the orchestrator, spawning
specialized subagents for each pipeline stage.

**Work tracking:** GitHub Issues and Projects. One issue = one
task = one branch = one PR.

**Execution isolation:** Git worktrees. Each coder agent works in
its own worktree — no file conflicts, clean state, easy to discard.

**Stacked PRs:** Graphite or native GitHub stacking for dependent
tasks. Enables incremental review before everything lands.

**CI/CD:** GitHub Actions as the automated quality gate. No PR
merges without green tests.

**Context between agents:** Structured markdown files in the repo
(`docs/specs/`, `docs/adr/`) plus GitHub issue descriptions. No
reliance on session context for inter-agent handoffs.

## Escalation Protocol

When an agent hits ambiguity it cannot resolve:

1. Comment on the GitHub issue with a specific, answerable question
2. Stop work on the blocked task
3. Move to the next unblocked task if one exists
4. Wait — the human sees the question on their next check-in

The human unblocks by replying to the issue comment. The agent
resumes.

## Build Sequence

Build in this order — each layer depends on the previous:

1. **Templates** — PRD, task spec, PR description, and ADR
   templates. These define the schema of every handoff.
2. **Planner skill** — problem statement in, PRD opened as a
   GitHub issue.
3. **Decomposer skill** — approved spec in, GitHub issues out.
4. **Coder workflow** — one issue in, worktree created, PR opened
   with structured description linking back to the issue.
5. **Reviewer skill** — PR in, checks against acceptance criteria,
   leaves structured review.
6. **Orchestrator** — ties all stages into a single command that
   runs the pipeline, gates appropriately, and surfaces
   escalations.
