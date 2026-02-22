# AI CLI Tool Portability Guide

Comparison of Claude Code, OpenAI Codex CLI, and Gemini CLI with a focus on
structuring projects so customizations work across all three tools.

Related docs: [claude.md](./claude.md) | [codex.md](./codex.md) | [gemini.md](./gemini.md)

---

## The Core Standard: Agent Skills

The [Agent Skills open standard](https://agentskills.io/specification) (developed by Anthropic, published 2025)
is the single most important portability mechanism. All three tools support it.

**The portable skill path is `.agents/skills/`** — all three tools discover this location.

Skill format: a directory named after the skill containing `SKILL.md` with YAML frontmatter + Markdown body.

```
.agents/skills/
├── code-review/
│   └── SKILL.md
├── deploy/
│   ├── SKILL.md
│   └── scripts/
│       └── deploy.sh
└── test-runner/
    └── SKILL.md
```

Minimum `SKILL.md`:
```yaml
---
name: code-review
description: Reviews code for quality and security issues. Use after making code changes.
license: Apache-2.0
allowed-tools: Read Grep Glob
---

Review the changed files for:
1. Security vulnerabilities
2. Code quality issues
3. Missing error handling
```

---

## Portability Matrix

### Context / Instruction Files

| Tool | Native File | Portable Path | Notes |
|------|-------------|---------------|-------|
| Claude Code | `CLAUDE.md` | — | Supports `@file` imports |
| Codex CLI | `AGENTS.md` | Can fallback to `CLAUDE.md` via `project_doc_fallback_filenames` config | |
| Gemini CLI | `GEMINI.md` | Supports `@file` imports | `contextFileName` setting can rename |

**Best practice:** Maintain both `AGENTS.md` (primary cross-tool file) and `CLAUDE.md` (Claude-specific extras).
Configure Codex to read `CLAUDE.md` as a fallback in `~/.codex/config.toml`:
```toml
project_doc_fallback_filenames = ["AGENTS.md", "CLAUDE.md"]
```

### Skills / Custom Commands

| Tool | Native Path | Portable Path | Format |
|------|-------------|---------------|--------|
| Claude Code | `.claude/skills/` | `.agents/skills/` ✓ | SKILL.md (YAML + Markdown) |
| Codex CLI | `~/.agents/skills/` | `.agents/skills/` ✓ | SKILL.md (YAML + Markdown) |
| Gemini CLI | `.gemini/skills/` | `.agents/skills/` ✓ (takes precedence) | SKILL.md (YAML + Markdown) |

**Verdict: Fully portable.** Skills in `.agents/skills/` work across all three tools without modification.

Gemini CLI also supports TOML-format commands (`.gemini/commands/`) — these are Gemini-only.

### Configure One Shared Skills Directory (Per Service)

Use a single canonical directory (example: `~/shared-agent-skills`) and connect each tool to it using its supported mechanism:

| Tool | Required mechanism | Example |
|------|--------------------|---------|
| Claude Code | Auto-discovers `.agents/skills/`; point that path to shared dir with a symlink (no dedicated settings key). | `ln -s ~/shared-agent-skills .agents/skills` |
| Codex CLI | Auto-discovers `~/.agents/skills/` and project `.agents/skills/`; use a symlink to your shared dir. | `ln -s ~/shared-agent-skills ~/.agents/skills` |
| Gemini CLI | Prefers `.agents/skills/` automatically; can also use `gemini skills link <path>` for linked dev installs. | `gemini skills link ~/shared-agent-skills/my-skill` |

Recommended cross-tool setup for teams: create `.agents/skills -> ~/shared-agent-skills` (symlink) in each project so Claude, Codex, and Gemini all resolve the same directory.

### MCP Servers

| Tool | Config Location | Format |
|------|----------------|--------|
| Claude Code | `.mcp.json` (project) / `~/.claude.json` (user) | JSON |
| Codex CLI | `.codex/config.toml` `[mcp_servers.*]` | TOML |
| Gemini CLI | `.gemini/settings.json` `mcpServers` | JSON |

**Verdict: Server code is portable; config format is not.** You must duplicate MCP server registration in each tool's config file. The MCP protocol itself is the standard — the same server binary/URL works with all three.

### Hooks

| Tool | Events | Types | Maturity |
|------|--------|-------|----------|
| Claude Code | 17 events | command, prompt, and agent | Mature, comprehensive |
| Gemini CLI | 10 events | command only | Mature |
| Codex CLI | ~4-6 events | command | Emerging (2025-2026) |

**Verdict: Not portable.** Event names differ; JSON schemas differ; capabilities differ significantly.
Maintain separate hook configs for each tool. Shell scripts called by hooks CAN be shared.

Shared hook script pattern — put logic in a shared script, reference from each tool's config:
```
.hooks/
├── pre-tool-check.sh       # Shared logic (portable)
└── format-after-write.sh   # Shared logic (portable)

.claude/settings.json       # Claude-specific hook registration
.gemini/settings.json       # Gemini-specific hook registration
.codex/config.toml          # Codex-specific hook registration
```

### Plugins / Extensions

| Tool | Mechanism | Portable? |
|------|-----------|-----------|
| Claude Code | Plugins (`.claude-plugin/plugin.json`) | Claude-only |
| Gemini CLI | Extensions (`gemini-extension.json`) | Gemini-only |
| Codex CLI | None | N/A |

**Verdict: Not portable.** Each tool has its own distribution/packaging format.
However, the *contents* (skills, MCP servers) can use portable formats.

---

## Recommended Project Structure

```
your-project/
│
│   # PORTABLE: Skills work across all three tools
├── .agents/
│   └── skills/
│       ├── code-review/
│       │   └── SKILL.md
│       └── deploy/
│           ├── SKILL.md
│           └── scripts/
│               └── deploy.sh
│
│   # PORTABLE: Shared hook scripts (logic only, not registration)
├── .hooks/
│   ├── pre-tool-check.sh
│   └── post-write-format.sh
│
│   # PARTIALLY PORTABLE: Instruction files
├── AGENTS.md               # Primary cross-tool context (Codex native; others fallback)
├── CLAUDE.md               # Claude-specific instructions (imports AGENTS.md if desired)
│
│   # TOOL-SPECIFIC: Claude Code
├── .mcp.json               # Claude Code MCP servers (committed)
└── .claude/
    ├── settings.json       # Claude hooks + permissions
    ├── settings.local.json # Personal overrides (gitignored)
    ├── rules/              # Modular conditional rules
    └── agents/             # Custom Claude subagents
│
│   # TOOL-SPECIFIC: Gemini CLI
└── .gemini/
    ├── settings.json       # Gemini MCP + hooks
    └── commands/
        └── gemini-only-cmd.toml
│
│   # TOOL-SPECIFIC: Codex CLI
└── .codex/
    └── config.toml         # Codex MCP + hooks + settings
```

---

## What is Portable (Summary)

| What | How | Notes |
|------|-----|-------|
| Skills | `.agents/skills/<name>/SKILL.md` | Full portability across all 3 tools |
| MCP server code | Any MCP-compatible server | Config must be duplicated per tool |
| Hook shell scripts | `.hooks/*.sh` | Registration is tool-specific |
| Context markdown | Markdown content | Filename and import syntax differ slightly |

## What is Tool-Specific

| Feature | Tool |
|---------|------|
| Plugins (`.claude-plugin/`) | Claude Code only |
| Extensions (`gemini-extension.json`) | Gemini CLI only |
| Custom subagents (`.claude/agents/`) | Claude Code only |
| Agent teams | Claude Code only |
| LSP integration (`.lsp.json`) | Claude Code only |
| `BeforeModel`, `AfterModel`, `BeforeToolSelection` hooks | Gemini CLI only |
| Prompt-type and agent-type hooks | Claude Code only |
| Async hooks | Claude Code only |
| `WorktreeCreate`/`WorktreeRemove` hooks | Claude Code only |
| TOML slash commands (`.gemini/commands/`) | Gemini CLI only |
| `approval_policy`, `sandbox_mode` | Codex CLI only |
| `openai.yaml` skill metadata | Codex CLI only |

---

## Key Takeaway

The **Agent Skills standard** (`.agents/skills/`) is the primary portable unit of work.
Structure your reusable automations as skills, and they will work across Claude Code,
Codex CLI, and Gemini CLI without modification.

Everything else — hooks, plugins, extensions, and subagents — requires
tool-specific config,
though the underlying shell scripts and MCP servers can be shared.
