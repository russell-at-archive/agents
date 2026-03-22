---
name: writing-agents
description: Produces correct, well-scoped Claude Code custom subagent configuration
  files (.md files with YAML frontmatter + system prompt body). Use when asked to
  write, create, design, or improve a Claude Code subagent, custom agent, agent config,
  or .claude/agents file.
---

# Writing Meta-Agents

## Overview

Produces Claude Code custom subagent configuration files: Markdown files with
YAML frontmatter defining the agent's identity, tools, model, and permissions,
plus a system prompt body. Covers field selection, description writing, tool
scoping, model selection, and system prompt design. For the full field reference
and best practices, read [references/overview.md](references/overview.md). For
complete agent config examples, read [references/examples.md](references/examples.md).

## When to Use

- Writing a new custom subagent config file
- Reviewing or improving an existing subagent config
- Choosing which tools, model, or permission mode to assign an agent
- Writing or improving an agent description for better auto-delegation
- Designing the system prompt body for a subagent
- Deciding whether to use a subagent vs a skill

## When Not to Use

- Writing a skill (`SKILL.md`) — use the `writing-skills` skill instead
- Writing a CLAUDE.md file or project instructions
- General Claude API usage — use the `claude-api` skill instead

## Prerequisites

- The agent's purpose and scope are clear enough to write a specific description
- Storage location is known: `~/.claude/agents/` (user-global) or
  `.claude/agents/` (project-scoped, checked into version control)

## Workflow

1. Clarify the agent's purpose, trigger conditions, and scope. If ambiguous, ask.
2. Determine storage: project-scoped (`.claude/agents/`) for team-shared agents;
   user-level (`~/.claude/agents/`) for personal cross-project agents.
3. Choose the required fields: `name` and `description`. See naming rules in
   [references/overview.md](references/overview.md).
4. Write the `description` field using the pattern: `<role statement>. Use
   [proactively] when <specific trigger conditions>.`
5. Select optional fields — tools, model, permissionMode — using the decision
   guide in [references/overview.md](references/overview.md).
6. Write the system prompt body: role statement, workflow steps, output format,
   and tool-usage guidance.
7. Validate the config against the hard rules below.
8. For concrete patterns by agent type, read [references/examples.md](references/examples.md).

## Hard Rules

- **`name`** must be lowercase, hyphens only, no leading/trailing/consecutive
  hyphens, 1–64 characters, unique within the scope.
- **`description`** must be third-person, specific, and include trigger keywords.
  Vague descriptions cause missed or wrong delegation.
- **Scope tools explicitly** when the agent should be restricted. Omitting `tools`
  grants the agent all tools including Write, Bash, and Agent.
- **Choose the right permission mode.** Read-only agents should use `permissionMode:
  plan`; agents that write files should default to `default` or `acceptEdits`.
- **System prompt body is mandatory for non-trivial agents.** A frontmatter-only
  config produces a generic agent with no domain focus.
- **Do not duplicate the description in the system prompt body.** The body should
  expand on behavior; the description drives delegation routing.
- **Store sensitive or team workflows project-scoped,** not user-level, so they
  travel with the repository.

## Failure Handling

- If the agent's purpose overlaps with an existing agent or skill, stop and confirm
  whether to extend the existing one or create a distinct new agent.
- If `tools` is left empty and the agent is read-only, explicitly add a `tools`
  allowlist to prevent accidental writes.
- If the description is too broad (e.g., "helps with code"), the agent will be
  under-triggered or over-triggered. Rewrite with specific domain and trigger
  conditions before saving.

## Red Flags

- Name contains uppercase letters, underscores, or spaces
- Description written in first or second person
- Description has no trigger condition ("when...", "for...", "after...")
- System prompt body is missing or is only one sentence
- `tools: Bash, Write, Edit` granted to a read-only research agent
- `permissionMode: bypassPermissions` used without an explicit justification
- Agent scope covers two unrelated concerns (split into two agents instead)
