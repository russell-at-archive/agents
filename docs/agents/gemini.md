# Gemini CLI

Official docs: <https://google-gemini.github.io/gemini-cli/>
GitHub: <https://github.com/google-gemini/gemini-cli>

---

## Context / Instruction Files

All found files are concatenated with origin indicators.

| File                                | Scope            |
| ----------------------------------- | ---------------- |
| `~/.gemini/GEMINI.md`               | User             |
| `GEMINI.md` (project hierarchy)     | Project          |
| Up to 200 subdirectories below cwd  | Sub-project      |
| Extension-bundled context files     | Extension scope  |

- `@path/to/file.md` import syntax (same as Claude Code)
- `/memory show` and `/memory refresh` slash commands
- `context.contextFileName` in `settings.json` can rename the file

---

## Settings Files

| File                              | Scope               |
| --------------------------------- | ------------------- |
| `~/.gemini/settings.json`         | User                |
| `.gemini/settings.json`           | Project override    |
| `/etc/gemini-cli/settings.json`   | System (highest)    |

Format: JSON.

Key sections: `general`, `model`, `context`, `tools`, `mcp`, `mcpServers`,
`hooks`, `security`, `experimental`, and `skills`.

---

## MCP Servers

Configured in `mcpServers` in `settings.json`:

```json
{
  "mcpServers": {
    "github": {
      "httpUrl": "https://api.githubcopilot.com/mcp/",
      "headers": { "Authorization": "Bearer ${GITHUB_TOKEN}" }
    },
    "local-tool": {
      "command": "npx",
      "args": ["-y", "my-mcp-server"],
      "trust": false,
      "includeTools": ["tool1"],
      "excludeTools": ["dangerous-tool"]
    }
  }
}
```

Connection types: `command` (stdio), `url` (SSE), `httpUrl` (streamable HTTP).
MCP tools appear as `mcp__<server_name>__<tool_name>` in hook matchers.

---

## Custom Slash Commands

Project or user-level TOML files.

| Location               | Scope   |
| ---------------------- | ------- |
| `~/.gemini/commands/`  | User    |
| `.gemini/commands/`    | Project |

```toml
description = "Refactor code into pure functions"
prompt = """Analyze: {{args}}

Run: !{npx some-tool {{args}}}
Include: @{path/to/context.md}
"""
```

- `{{args}}` — user arguments
- `!{command}` — execute shell and inject output
- `@{path}` — inject file or directory content
  (supports images, PDFs, audio, video)
- Namespacing: `git/commit.toml` → `/git:commit`
- `/commands reload` to refresh without restart

---

## Skills

Follows the [Agent Skills open standard](https://agentskills.io/specification).
Uses the same `SKILL.md` format as Claude Code and Codex.

| Location                    | Scope                         |
| --------------------------- | ----------------------------- |
| `~/.gemini/skills/<name>`   | User                          |
| `.gemini/skills/<name>`     | Project                       |
| `.agents/skills/<name>`     | Cross-tool (takes precedence) |

Shared directory mechanism: Gemini automatically prefers
`.agents/skills/` for cross-tool skills. For linked development
workflows, use `gemini skills link <path>` to create a link in
Gemini's skills location.

Management:

```bash
gemini skills install <git-url-or-path>
gemini skills link <path>          # Dev mode (symlink)
gemini skills enable/disable <name>
/skills list
```

Skills load name and description at session start. Full content
loads on activation via `activate_skill` after user confirmation.

---

## Hooks

Configured in `hooks` key of `settings.json`.

### Hook Events (10 total)

- `SessionStart` (No): Session begins.
- `SessionEnd` (No): Session ends.
- `BeforeAgent` (Yes): After user prompt, before planning.
- `AfterAgent` (Yes, retry): Agent loop completes; `"deny"`
  forces retry.
- `BeforeModel` (Yes): Before LLM request; can modify or
  replace the request.
- `AfterModel` (Yes): After LLM response; can redact chunks.
- `BeforeToolSelection` (Yes): Before tool selection; can
  filter available tools.
- `BeforeTool` (Yes): Before tool execution; can block or
  rewrite args.
- `AfterTool` (Yes): After tool execution; can hide results.
- `Notification` (No): Observability only.

### Hook Type

Currently only `type: "command"` (shell scripts).

### Configuration

```json
{
  "hooks": {
    "BeforeTool": [
      {
        "matcher": "run_shell_command",
        "hooks": [
          {
            "name": "security-check",
            "type": "command",
            "command": "$GEMINI_PROJECT_DIR/.gemini/hooks/security.sh",
            "timeout": 5000
          }
        ]
      }
    ]
  }
}
```

Matcher: regex for tool events, exact string for lifecycle events.

### Environment Variables in Hooks

- `GEMINI_PROJECT_DIR` (also aliased as `CLAUDE_PROJECT_DIR` for compatibility)
- `GEMINI_SESSION_ID`
- `GEMINI_CWD`

### Exit Codes

- `0` + JSON stdout: structured control (`decision`, `reason`,
  `tool_input`, `additionalContext`)
- `2`: system block
- Other: non-blocking warning

**Security:** Project-level hooks are fingerprinted. Changes
after `git pull` require re-confirmation.

---

## Extensions

Extensions bundle context files, slash commands, and MCP servers. They are
the primary distribution mechanism.

```text
my-extension/
├── gemini-extension.json    # Manifest
├── GEMINI.md               # Context (or custom contextFileName)
├── commands/
│   └── my-command.toml
└── <mcp-server-code>
```

`gemini-extension.json`:

```json
{
  "name": "my-extension",
  "version": "1.0.0",
  "contextFileName": "GEMINI.md",
  "mcpServers": {
    "my-server": {
      "command": "node",
      "args": ["${extensionPath}/dist/server.js"],
      "cwd": "${extensionPath}"
    }
  },
  "excludeTools": ["run_shell_command(rm -rf)"]
}
```

Variables in manifest: `${extensionPath}`, `${workspacePath}`,
and `${/}` (path separator).

Management:

```bash
gemini extensions install <url-or-path>
gemini extensions link ./local-path        # Dev mode
gemini extensions new my-ext mcp-server    # Scaffold
gemini extensions list
gemini extensions enable/disable <name>
gemini extensions update [--all]
gemini extensions uninstall <name>
gemini extensions config <name>
```
