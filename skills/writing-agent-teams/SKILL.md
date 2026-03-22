---
name: writing-agent-teams
description: Designs and writes Claude Code agent team configurations — team
  structure, task decomposition, teammate prompts, and orchestration patterns.
  Use when asked to set up an agent team, orchestrate multiple Claude Code
  sessions in parallel, write a team lead prompt, design a swarm workflow,
  decompose work for parallel agents, or produce TeamCreate/TaskCreate/SendMessage
  coordination sequences.
---

# Writing Agent Teams

## Overview

Produces complete, ready-to-run Claude Code agent team configurations: team
structure, task lists, teammate spawn prompts, and coordination logic for the
team lead.

Concept guide and architecture: [references/overview.md](references/overview.md)
Tool reference with parameters: [references/tools-reference.md](references/tools-reference.md)
Orchestration patterns: [references/patterns.md](references/patterns.md)
Working examples: [references/examples.md](references/examples.md)

## When to Use

- Asked to set up, design, or write an agent team
- Decomposing a large task into parallel workstreams for multiple Claude sessions
- Writing a team lead prompt or teammate spawn prompts
- Choosing the right orchestration pattern for a workflow
- Designing task lists with dependency chains
- Configuring quality gates (plan approval, TeammateIdle/TaskCompleted hooks)

## When Not to Use

- Sequential tasks with many inter-step dependencies — single session is more
  efficient
- Same-file edits by multiple agents — causes overwrites and conflicts
- Routine low-complexity tasks — team overhead exceeds the benefit
- Nested teams — teammates cannot spawn their own teams

## Prerequisites

- `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` set in environment or `settings.json`
- Claude Code v2.1.32 or later
- The work can be parallelized across distinct domains or file sets

## Workflow

1. Clarify the goal, scope, and constraints. Identify genuine parallelization
   opportunities. If tasks are mostly sequential, recommend subagents instead.
2. Choose the orchestration pattern — see [references/patterns.md](references/patterns.md).
3. Decompose work into discrete tasks (aim for 5–6 tasks per teammate).
4. Write the team lead prompt using the three-phase structure: Setup →
   Execution → Teardown.
5. Write spawn prompts for each teammate with sufficient standalone context —
   teammates do not inherit the lead's conversation history.
6. Write precise task descriptions — they serve as the agent's working brief.
7. Add quality gates for high-risk or irreversible steps.
8. Validate against the hard rules before delivering the configuration.

## Hard Rules

- **Teammate isolation**: each teammate must own a distinct set of files or
  domains — shared file edits cause data loss.
- **Standalone prompts**: teammate spawn prompts must include all needed
  context; do not assume access to the lead's conversation.
- **No nesting**: teammates cannot spawn their own teams; only the lead manages
  the team lifecycle.
- **Always teardown**: include `TeamDelete` in the lead's teardown phase after
  all teammates shut down.
- **Token budget**: estimate 3–4× token cost per teammate vs. a solo session;
  confirm the parallelization benefit justifies the spend.
- **Task granularity**: 5–6 tasks per teammate; too few wastes capacity, too
  many causes context thrash.
- **Plan approval for risky work**: use `plan_approval_request` workflow for
  destructive or irreversible operations.

## Failure Handling

- If work cannot be meaningfully parallelized, produce a sequential pipeline
  with explicit `blockedBy` dependencies instead of a true parallel team.
- If the user's terminal doesn't support split panes (VS Code integrated
  terminal, Windows Terminal, Ghostty), recommend `--teammate-mode in-process`
  explicitly.
- If scope is unclear, ask before decomposing — wrong task decomposition wastes
  significant token budget.
- If a teammate type doesn't exist as a built-in, recommend defining a custom
  subagent in `.claude/agents/` and referencing it by name.

## Red Flags

- Teammates editing the same files (recipe for overwrites)
- Spawn prompts that say "see the lead's instructions" (leads have no shared
  context with teammates)
- More than 5 teammates for a first team (start small, expand)
- TeamDelete omitted from teardown (leaves orphaned team state)
- No `blockedBy` dependencies when tasks genuinely require sequential ordering
- `run_in_background: false` for teammates (blocks the lead until the teammate
  finishes all turns)
