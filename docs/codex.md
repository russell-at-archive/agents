# OpenAI Codex CLI

Official docs: https://developers.openai.com/codex/
GitHub: https://github.com/openai/codex

---

## Context / Instruction Files

All found files are concatenated from git root downward.

| File | Scope |
|------|-------|
| `~/.codex/AGENTS.md` | User (all projects) |
| `AGENTS.md` (in each dir from git root to cwd) | Project |
| `AGENTS.override.md` | Overrides AGENTS.md at same level |

**Cross-tool fallback:** Configure `project_doc_fallback_filenames` in `config.toml` to also read `CLAUDE.md`:

```toml
project_doc_fallback_filenames = ["AGENTS.md", "CLAUDE.md"]
project_doc_max_bytes = 32768
```

---

## Settings Files

| File | Scope |
|------|-------|
| `~/.codex/config.toml` | User |
| `.codex/config.toml` | Project (trusted projects only) |
| `/etc/codex/config.toml` | System |
| `~/.codex/requirements.toml` | Admin-enforced constraints |

Format: TOML.

```toml
model = "gpt-5.3-codex"
approval_policy = "on-request"
sandbox_mode = "workspace-write"

[features]
multi_agent = true
shell_tool = true

[shell_environment_policy]
inherit = "core"
set = { MY_VAR = "value" }
exclude = ["AWS_*"]
```

---

## MCP Servers

Configured in `config.toml`:

```toml
[mcp_servers.github]
url = "https://api.githubcopilot.com/mcp/"
bearer_token_env_var = "GITHUB_TOKEN"
startup_timeout_sec = 10
enabled = true

[mcp_servers.local-tool]
command = "npx"
args = ["-y", "my-mcp-server"]
enabled_tools = ["tool1", "tool2"]
disabled_tools = ["dangerous-tool"]
```

CLI management:
```bash
codex mcp add <name> -- <command>
codex mcp list
codex mcp login <server-name>   # OAuth flow
```

---

## Skills

Follows the [Agent Skills open standard](https://agentskills.io/specification).
It uses the same `SKILL.md` format as Claude Code.

| Location | Scope |
|----------|-------|
| `/etc/codex/skills` | System/admin |
| `~/.agents/skills/<name>` | User |
| `.agents/skills/<name>` (git root, parent dirs, cwd) | Project (portable) |

Shared directory mechanism: Codex auto-discovers these paths. To use one shared directory, point `~/.agents/skills` (or project `.agents/skills`) to it via symlink.

Additional `agents/openai.yaml` per skill for UI customization:

```yaml
interface:
  display_name: "User-facing name"
  default_prompt: "Surrounding context"
  brand_color: "#3B82F6"
policy:
  allow_implicit_invocation: false
dependencies:
  tools:
    - type: "mcp"
      value: "toolIdentifier"
```

Disable a specific skill in config:
```toml
[[skills.config]]
path = "/path/to/skill/SKILL.md"
enabled = false
```

Invocation: `/skills` command, `$skill-name` mention syntax, or implicit by model.

---

## Hooks

**Status:** Actively developed; hooks are newer and less mature than Claude Code or Gemini CLI.

Configuration in `codex.json` at project level or in `config.toml`.

Known events: `BeforeToolUse`, `AfterToolUse`, file write hooks, prompt
gating, and stop hooks.

The hooks system lacks the breadth of event types and decision control available in Claude Code and Gemini CLI.

---

## Plugin System

No formal plugin/extension system equivalent to Claude Code plugins or Gemini CLI extensions. Extensibility is through:
- Skills (`.agents/skills/`)
- MCP servers
- Agents SDK (programmatic)

---

## Multi-Agent

Experimental. Enable with `features.multi_agent = true` in `config.toml`. Configuration in `[agents]` section.
