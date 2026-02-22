# Claude Code

Official docs: https://code.claude.com/docs/en/

---

## Context / Instruction Files

All files are loaded hierarchically and merged at startup.

| File | Scope |
|------|-------|
| `~/.claude/CLAUDE.md` | User (all projects) |
| `./CLAUDE.md` or `./.claude/CLAUDE.md` | Project (team-shared, commit to VCS) |
| `./CLAUDE.local.md` | Project (personal, auto-gitignored) |
| `./.claude/rules/*.md` | Modular rules; YAML `paths:` frontmatter enables conditional loading by file glob |

- `@path/to/file` import syntax (max 5 hops deep)
- Child directory `CLAUDE.md` files load on-demand, not at startup
- AI auto-memory at `~/.claude/projects/<project>/memory/MEMORY.md` (first 200 lines loaded)

---

## Settings Files

| File | Scope |
|------|-------|
| `~/.claude/settings.json` | User |
| `.claude/settings.json` | Project (shared) |
| `.claude/settings.local.json` | Project (personal, gitignored) |

Key fields: `hooks`, `permissions`, `env`, `mcpServers`, `model`,
`allowedTools`, and `disallowedTools`

---

## MCP Servers

| File | Scope |
|------|-------|
| `~/.claude.json` | User/local |
| `.mcp.json` | Project (commit to VCS) |

```json
{
  "mcpServers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/",
      "headers": { "Authorization": "Bearer ${GITHUB_TOKEN}" }
    },
    "local-tool": {
      "command": "npx",
      "args": ["-y", "my-mcp-server"]
    }
  }
}
```

Transports: `stdio`, `http` (recommended), `sse` (deprecated).
MCP tools appear as `mcp__<server>__<tool>` in hook matchers.

---

## Skills

Skills are the primary custom command mechanism. Users invoke them as
`/skill-name [args]`.

| Location | Scope |
|----------|-------|
| `~/.claude/skills/<name>/SKILL.md` | User |
| `.claude/skills/<name>/SKILL.md` | Project |
| `.agents/skills/<name>/SKILL.md` | Cross-tool (portable) |

Shared directory mechanism: Claude has no dedicated `skills_path` setting. To use one shared directory, expose it at `.agents/skills/` (or `~/.claude/skills/`) via symlink.

Format: YAML frontmatter + Markdown body.

```yaml
---
name: deploy
description: Deploy the application to production.
allowed-tools: Bash(git:*) Read
model: sonnet
context: fork
argument-hint: "[environment]"
---

Deploy $ARGUMENTS to $0:
1. Run tests: !`npm test`
2. Build: !`npm run build`
```

Key frontmatter fields: `name`, `description`, `allowed-tools`, `model`,
`context` (fork = isolated subagent), `agent`, `hooks`, `argument-hint`,
`once`, `disable-model-invocation`, and `user-invocable`.

Shell execution: `` !`command` `` runs before sending to Claude.
Variables: `$ARGUMENTS`, `$N`, `${CLAUDE_SESSION_ID}`.

Legacy location: `.claude/commands/<name>.md` (still supported, same format).

---

## Hooks

Configured in `hooks` key of `settings.json`, plugin `hooks/hooks.json`, or skill YAML frontmatter.

### Hook Events (17 total)

| Event | Blockable |
|-------|-----------|
| `SessionStart` | No |
| `UserPromptSubmit` | Yes |
| `PreToolUse` | Yes |
| `PermissionRequest` | Yes |
| `PostToolUse` | Partial |
| `PostToolUseFailure` | No |
| `Stop` | Yes |
| `SubagentStart` | No |
| `SubagentStop` | Yes |
| `TaskCompleted` | Yes |
| `TeammateIdle` | Yes |
| `ConfigChange` | Yes |
| `WorktreeCreate` | Yes |
| `WorktreeRemove` | No |
| `PreCompact` | No |
| `Notification` | No |
| `SessionEnd` | No |

### Hook Types
- `type: "command"` — shell script, receives JSON on stdin
- `type: "prompt"` — single-turn LLM evaluation
- `type: "agent"` — multi-turn subagent with Read/Grep/Glob tools

### Exit Codes
- `0` + JSON stdout: structured control (allow/deny/modify input)
- `2`: blocking error (feeds stderr to Claude)
- Other: non-blocking warning

### PreToolUse JSON output
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "updatedInput": { "command": "safe-version" },
    "additionalContext": "Context for Claude"
  }
}
```

Async support: `"async": true` runs hook in background.

---

## Plugins

Plugins bundle skills, hooks, MCP servers, agents, and settings.

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json
├── skills/
├── agents/
├── hooks/
│   └── hooks.json
├── .mcp.json
├── .lsp.json
└── settings.json
```

`plugin.json` manifest fields: `name`, `description`, `version`, `author`,
`homepage`, `repository`, and `license`.
Skills namespaced as `/plugin-name:skill-name`.

---

## Custom Subagents

| Location | Scope |
|----------|-------|
| `.claude/agents/<name>.md` | Project |
| `~/.claude/agents/<name>.md` | User |

Format: YAML frontmatter + Markdown system prompt.

Key frontmatter fields: `name`, `description`, `tools`, `disallowedTools`,
`model`, `permissionMode`, `maxTurns`, `skills`, `mcpServers`, `hooks`,
`isolation`, `memory`, and `background`.

Built-in agents: `Explore`, `Plan`, `general-purpose`, `Bash`.
