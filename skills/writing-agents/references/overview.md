# Writing Meta-Agents: Full Reference

## Contents

- File format
- Storage locations and scoping
- Frontmatter field reference
- Naming rules
- Description writing guide
- Tool scoping guide
- Model selection guide
- Permission mode guide
- System prompt body guide
- Subagent vs skill decision guide

---

## File Format

Subagent configs are Markdown files with YAML frontmatter. The frontmatter
defines identity and runtime settings; the body is the agent's system prompt.

```markdown
---
name: my-agent
description: <role statement>. Use when <trigger conditions>.
tools: Read, Grep, Glob
model: sonnet
---

You are a <role>. When invoked, you <core behavior>.

[Rest of system prompt...]
```

---

## Storage Locations and Scoping

| Scope | Path | Use case |
| ----- | ---- | -------- |
| User-global | `~/.claude/agents/` | Personal agents used across all projects |
| Project | `.claude/agents/` | Team-shared agents, checked into version control |
| Session | `--agents` CLI flag | One-off, ephemeral agents |

Priority order when names conflict: session > project > user-global.

**Rule:** Agents that encode team conventions or project-specific workflows
belong in `.claude/agents/` so they travel with the repo. Personal productivity
agents (code reviewers, writing assistants) belong in `~/.claude/agents/`.

---

## Frontmatter Field Reference

### Required Fields

| Field | Type | Constraints |
| ----- | ---- | ----------- |
| `name` | string | Lowercase, hyphens only, 1–64 chars, unique in scope |
| `description` | string | Third-person, ≤1024 chars, includes trigger keywords |

### Optional Fields

| Field | Type | Values / Notes |
| ----- | ---- | -------------- |
| `tools` | string | Comma-separated allowlist of tool names. Omit to inherit all. |
| `disallowedTools` | string | Comma-separated denylist. Alternative to `tools` allowlist. |
| `model` | string | `sonnet`, `opus`, `haiku`, full model ID, or `inherit` (default) |
| `color` | string | UI color hint: `blue`, `green`, `red`, `yellow`, `purple`, `orange` |
| `permissionMode` | string | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan` |
| `maxTurns` | integer | Maximum agentic turns before stopping |
| `skills` | list | Skill names to inject into the agent's context |
| `mcpServers` | map | MCP servers available to the agent |
| `hooks` | map | Lifecycle hooks: `PreToolUse`, `PostToolUse`, `Stop` |
| `memory` | string | `user`, `project`, or `local` — enables persistent memory |
| `background` | boolean | Run as background task if `true` |
| `effort` | string | `low`, `medium`, `high`, `max` (Opus 4.6+ only) |
| `isolation` | string | `worktree` — run agent in an isolated git worktree |

---

## Naming Rules

- Lowercase letters, numbers, and hyphens only
- 1–64 characters
- No leading or trailing hyphen
- No consecutive hyphens (`--`)
- Must be unique within the scope (project or user-global)
- Use the gerund style for actions: `reviewing-prs`, `analyzing-logs`
- Use noun phrase for roles: `code-reviewer`, `data-analyst`

---

## Description Writing Guide

The `description` field is the primary routing signal. Claude reads it to
decide whether to delegate a task to this agent. A weak description means
the agent is never invoked or invoked at the wrong time.

**Template:**

```
<Role statement>. Use [proactively] when <specific trigger conditions>.
```

**Components:**

1. **Role statement** — what the agent specializes in. Be specific about the
   domain. "code reviewer" is better than "assistant"; "PostgreSQL query
   optimizer" is better than "database expert".
2. **Trigger qualifier** — "Use when", "Use proactively when", or "Use for".
   "Proactively" signals Claude should self-delegate without being asked.
3. **Trigger conditions** — specific situations that call for this agent. Name
   the inputs, files, or actions that make the agent relevant.

**Examples:**

```yaml
# Too vague — will be under-triggered
description: Code review assistant. Use when reviewing code.

# Specific — triggers reliably
description: Senior code reviewer for Python and TypeScript. Use proactively
  after code changes are written to check correctness, security, and style
  against project conventions.

# Domain-specific with clear trigger
description: PostgreSQL query optimizer. Use when given a slow query or
  EXPLAIN ANALYZE output to identify missing indexes, rewrite inefficient
  joins, and suggest schema changes.
```

---

## Tool Scoping Guide

Use an **allowlist** (`tools`) when the agent should be restricted to specific
tools. Use a **denylist** (`disallowedTools`) when the agent needs most tools
but not a few specific ones. Omit both to inherit all tools.

**Available tools:**

| Tool | Description |
| ---- | ----------- |
| `Read` | Read files |
| `Edit` | Edit files |
| `Write` | Create files |
| `Bash` | Run shell commands |
| `Grep` | Search file contents |
| `Glob` | Find files by pattern |
| `WebFetch` | Fetch URLs |
| `WebSearch` | Search the web |
| `Agent` | Spawn further subagents |
| `NotebookEdit` | Edit Jupyter notebooks |

**Decision guide by agent type:**

| Agent type | Recommended tools |
| ---------- | ----------------- |
| Read-only researcher | `Read, Grep, Glob` |
| Read-only + web | `Read, Grep, Glob, WebFetch, WebSearch` |
| Code reviewer | `Read, Grep, Glob, Bash` |
| File writer | `Read, Edit, Write, Grep, Glob` |
| Full-access | Omit `tools` (inherit all) |
| Web researcher | `WebSearch, WebFetch` |

**Rule:** Grant only what the agent needs. An agent with `Bash` can run
arbitrary shell commands; an agent with `Write` can create files anywhere.

---

## Model Selection Guide

| Model | Use when |
| ----- | -------- |
| `haiku` | Fast, cheap tasks: keyword extraction, simple transforms, short queries |
| `sonnet` | Default for most agents: analysis, code review, multi-step reasoning |
| `opus` | Complex reasoning, long-context synthesis, strategic planning |
| `inherit` | Agent inherits the model from the parent conversation (default) |

Omit `model` to use `inherit`. Explicit model selection locks the agent to
that model regardless of what the parent is using.

---

## Permission Mode Guide

| Mode | Behavior | Use when |
| ---- | -------- | -------- |
| `default` | Prompts user for each tool use requiring permission | General-purpose agents |
| `acceptEdits` | Auto-approves file edits without prompting | Agents that write code iteratively |
| `dontAsk` | Auto-denies permission prompts | Read-only agents that must not write |
| `bypassPermissions` | Skips all permission checks | Fully automated pipelines only |
| `plan` | Read-only exploration; no writes | Research, architecture review agents |

**Rule:** Default to `default`. Only escalate to `acceptEdits` or
`bypassPermissions` when there is a clear need and the risk is understood.

---

## System Prompt Body Guide

The body is the agent's system prompt. It runs in a separate context window
from the main conversation, so it must be self-contained.

**Required sections:**

1. **Role statement** — "You are a [specific role]."
2. **Core behavior** — What the agent does when invoked, in 2–4 sentences.
3. **Workflow steps** — Numbered steps for complex or multi-stage tasks.
4. **Output format** — What the agent should return (summary, report, diffs, etc.).

**Optional sections:**

- Tool usage guidance (which tools to use for which subtasks)
- Constraints and guardrails (what the agent must not do)
- Error handling (what to do when inputs are missing or ambiguous)

**Anti-patterns:**

- System prompt is a single sentence with no workflow
- System prompt duplicates the `description` field verbatim
- System prompt promises behavior that the assigned `tools` cannot support
  (e.g., "edit files" when only `Read` is granted)

---

## Subagent vs Skill Decision Guide

| Factor | Subagent | Skill |
| ------ | -------- | ----- |
| Context | Separate context window | Main conversation context |
| Tools | Custom subset, configurable | Inherits all tools from main conversation |
| System prompt | Custom, per-agent | Main conversation system prompt |
| Good for | Complex workflows, context isolation, tool-restricted work | Teaching processes, templates, domain knowledge |
| Returns | Summary to main conversation | Results stay in main conversation |

**Choose a subagent when:**
- The task needs context isolation (large context, separate focus)
- The task should run with a restricted tool set
- The task is a complete independent workflow (research, review, analysis)
- The task should run in the background or on a schedule

**Choose a skill when:**
- You want to inject expertise or templates into the current conversation
- The workflow is a recipe the main agent should follow itself
- The task requires access to the full main conversation context
