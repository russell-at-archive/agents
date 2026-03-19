# Claude Code Subagents

Observed against local CLI `claude 2.1.79 (Claude Code)` on `2026-03-19`.

This page focuses on one Claude Code customization surface:
defining custom subagents and invoking them predictably.

## What a subagent is

A Claude Code subagent is a specialized agent definition with its own
system prompt, tool access, model selection, permissions, and optional
hooks or MCP configuration.

Subagents are Claude-specific. They are not part of the portable
`.agents/skills/` standard.

## Where Claude loads subagents from

| Location | Scope |
| --- | --- |
| `~/.claude/agents/<name>.md` | User-wide |
| `.claude/agents/<name>.md` | Project-local |

Use the project-local path when the subagent is part of team workflow.
Use the user path for personal agents you do not want committed.

## File format

Each subagent is a Markdown file with:

1. YAML frontmatter for configuration.
2. A Markdown body that acts as the subagent's system prompt.

Example:

```md
---
name: reviewer
description: Review code changes for regressions and missing tests.
tools:
  - Read
  - Grep
  - Glob
  - Bash(git diff:*)
disallowedTools:
  - Edit
model: sonnet
permissionMode: default
maxTurns: 12
skills:
  - writing-markdown
background: false
---

You are a focused code review subagent.

Prioritize:

1. Behavioral regressions.
2. Security or data-loss risk.
3. Missing tests.

Return findings first, with file paths and concrete evidence.
```

## Important frontmatter fields

These are the fields already referenced elsewhere in this repo and are
the ones worth standardizing on first:

| Field | Purpose |
| --- | --- |
| `name` | Agent identifier used for selection. |
| `description` | Short summary shown in listings and selection UX. |
| `tools` | Allowed built-in tools for the agent. |
| `disallowedTools` | Explicit deny list. |
| `model` | Model override for this agent. |
| `permissionMode` | Permission behavior for the agent session. |
| `maxTurns` | Cap on autonomous subagent turns. |
| `skills` | Skills made available to that agent. |
| `mcpServers` | MCP servers exposed to the agent. |
| `hooks` | Hooks attached to the agent lifecycle. |
| `isolation` | Isolation settings for the agent runtime. |
| `memory` | Memory behavior for the agent. |
| `background` | Whether the agent can run in the background. |

Practical guidance:

- Keep `tools` narrow. Most custom agents should start with read-only
  tools and only gain edit or shell access when required.
- Set `maxTurns` deliberately. It is an effective guardrail against
  vague looping behavior.
- Treat `permissionMode` as part of the contract. If an agent is meant
  for review or exploration, avoid edit-friendly permission defaults.
- Put the real specialization in the prompt body, not only in the
  field list.

## How to inspect available agents

The local CLI exposes an `agents` subcommand:

```bash
claude agents
```

Observed output in this workspace on `2026-03-19`:

```text
4 active agents

Built-in agents:
  Explore · haiku
  general-purpose · inherit
  Plan · inherit
  statusline-setup · sonnet
```

This is the fastest way to confirm whether Claude discovered your new
agent file.

## Invocation patterns

There are three practical invocation paths.

## 1. Set the session agent with `--agent`

Use `--agent` when you want the whole session to start as a specific
agent.

```bash
claude --agent reviewer
```

For one-shot automation:

```bash
claude --agent reviewer -p "Review the current git diff for regressions."
```

This is the cleanest path when the agent is already defined in
`.claude/agents/` or `~/.claude/agents/`.

## 2. Inject an ephemeral agent with `--agents`

The CLI also supports an inline JSON definition:

```bash
claude \
  --agents '{"reviewer":{"description":"Reviews code","prompt":"You are a strict reviewer."}}' \
  --agent reviewer \
  -p "Review the staged diff."
```

Use this when:

- you want an ad hoc agent for a script or CI step
- you do not want to persist a file under `.claude/agents/`
- you want the definition to live alongside the calling command

This path is good for automation, but it is weaker for team reuse than a
checked-in agent file.

## 3. Let Claude spawn subagents during a task

Claude Code has explicit `SubagentStart` and `SubagentStop` hook events,
which confirms that subagents are a real runtime concept and not only a
static config format.

In practice, once a named agent is available, you can instruct Claude to
use that agent for a bounded subtask inside a broader session. That is a
useful workflow for specialist review, planning, or exploration work.

This last pattern is a usage pattern rather than a strongly documented
CLI contract, so prefer `--agent` or `--agents` when you need
deterministic automation.

## Recommended usage patterns

Use custom subagents for:

- code review specialists
- architecture or dependency explorers
- migration planners
- test investigators
- documentation writers with constrained tools

Do not use custom subagents when a portable skill is the better fit.

Rule of thumb:

- Use a skill when you are packaging a reusable workflow or command.
- Use a subagent when you are packaging a reusable persona with a
  distinct prompt, model, permission profile, and tool budget.

## Minimal workflow for adding one

1. Create `.claude/agents/<name>.md`.
2. Add frontmatter with a narrow tool set and explicit `maxTurns`.
3. Write the prompt body as the agent's long-lived specialization.
4. Run `claude agents` to confirm discovery.
5. Invoke it with `claude --agent <name>` for validation.

## Validation commands

```bash
claude agents
claude --agent reviewer
claude --agent reviewer -p "Summarize the current diff."
claude --agents '{"tmp":{"description":"Temporary agent","prompt":"Be concise."}}' --agent tmp -p "Summarize README changes."
```

## Notes for this repository

- Keep reusable cross-tool workflows in `.agents/skills/`.
- Keep Claude-only agent personas in `.claude/agents/`.
- If a subagent design affects team workflow materially, document the
  decision and rationale in an ADR before treating it as established
  architecture.
