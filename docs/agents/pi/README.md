# Pi Coding Agent

Official docs: <https://github.com/badlogic/pi-mono>

---

## Philosophy

Pi is a **minimal, extensible coding agent** by Mario Zechner. Its core
principle: *primitives over features*. Pi's system prompt is ~200 tokens
vs Claude Code's ~10,000+. Every token is a performance cost; leave
maximum room for actual work.

> "What you leave out matters more than what you put in."

Pi is **YOLO by default**: no sandbox, full filesystem and bash access.
It assumes you control who runs it. Permissions are opt-in via the
`pi-permissions` extension.

---

## Installation

```bash
npm install -g @mariozechner/pi-coding-agent
```

Pi is npm-only. No Homebrew formula exists.

---

## Authentication

| Method             | Details                                               |
| ------------------ | ----------------------------------------------------- |
| API key (env var)  | `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, etc.           |
| OAuth subscription | Run `/login` inside Pi to authenticate interactively  |
| Auth storage       | `~/.pi/agent/auth.json` — tokens auto-refreshed       |

API key values in config support three forms:

- Literal string value
- Environment variable name
- Shell command prefixed with `!` (e.g. `"!op read 'op://vault/key'"`)

---

## Directory Structure

| Path                                  | Purpose                             |
| ------------------------------------- | ----------------------------------- |
| `~/.pi/agent/auth.json`               | OAuth tokens (auto-refreshed)       |
| `~/.pi/agent/sessions/`               | Session JSONL files per working dir |
| `~/.pi/agent/models.json`             | Custom providers and models         |
| `~/.pi/agent/ssh-policy-global.json`  | Persistent global SSH grants        |
| `~/.pi/agent/git/`                    | Git-based global packages           |
| `.pi/`                                | Project-local installs (`-l` flag)  |

---

## Context / Instruction Files

Loaded from `~/.pi/agent/`, parent directories, and current directory
at startup.

| File                | Scope   | Purpose                         |
| ------------------- | ------- | ------------------------------- |
| `AGENTS.md`         | Project | Project instructions for Pi     |
| `CLAUDE.md`         | Project | Also loaded (compatible format) |
| `SYSTEM.md`         | Project | Replaces default system prompt  |
| `APPEND_SYSTEM.md`  | Project | Appends to system prompt        |

---

## Environment Variables

| Variable                        | Purpose                                       |
| ------------------------------- | --------------------------------------------- |
| `ANTHROPIC_API_KEY`             | Anthropic Claude API key                      |
| `ANTHROPIC_OAUTH_TOKEN`         | Anthropic OAuth token (alternative to key)    |
| `OPENAI_API_KEY`                | OpenAI API key                                |
| `GEMINI_API_KEY`                | Google Gemini API key                         |
| `GROQ_API_KEY`                  | Groq API key                                  |
| `XAI_API_KEY`                   | xAI Grok API key                              |
| `OPENROUTER_API_KEY`            | OpenRouter API key                            |
| `MISTRAL_API_KEY`               | Mistral API key                               |
| `AWS_PROFILE`                   | AWS profile for Amazon Bedrock                |
| `AWS_REGION`                    | AWS region for Bedrock (e.g. `us-east-1`)     |
| `PI_CODING_AGENT_DIR`           | Override agent data directory                 |
| `PI_SMOL_MODEL`                 | Fast/cheap model role override                |
| `PI_SLOW_MODEL`                 | Deep/complex model role override              |
| `PI_PLAN_MODEL`                 | Planning model role override                  |
| `PI_NO_PTY`                     | Disable PTY-based bash execution              |
| `PI_OFFLINE`                    | Disable startup network ops (`1`/`true`/`yes`)|
| `PI_SHARE_VIEWER_URL`           | Base URL for `/share` command                 |

---

## CLI Usage

```text
pi [options] [@files...] [messages...]
```

### Common Flags

| Flag                        | Purpose                                           |
| --------------------------- | ------------------------------------------------- |
| `-p`, `--print`             | Non-interactive: process prompt and exit          |
| `-c`, `--continue`          | Continue previous session                         |
| `-r`, `--resume`            | Select a session to resume interactively          |
| `--mode <mode>`             | Output mode: `text` (default), `json`, `rpc`      |
| `--provider <name>`         | Specify provider (default: google)                |
| `--model <pattern>`         | Model ID or pattern; supports `provider/id:level` |
| `--models <patterns>`       | Comma-separated patterns for Ctrl+P cycling       |
| `--thinking <level>`        | `off`, `minimal`, `low`, `medium`, `high`, `xhigh`|
| `--tools <tools>`           | Comma-separated tools to enable                   |
| `--no-tools`                | Disable all built-in tools                        |
| `--session <path>`          | Use a specific session file                       |
| `--no-session`              | Ephemeral session (not saved)                     |
| `--extension`, `-e <path>`  | Load an extension file                            |
| `--no-extensions`, `-ne`    | Disable extension discovery                       |
| `--skill <path>`            | Load a skill file or directory                    |
| `--no-skills`, `-ns`        | Disable skill discovery                           |
| `--export <file>`           | Export session JSONL to HTML                      |
| `--list-models [search]`    | List available models                             |
| `--offline`                 | Disable startup network operations                |
| `--verbose`                 | Force verbose startup                             |

### Model Specification

```bash
pi --model openai/gpt-4o           # provider/model-id
pi --model sonnet:high             # fuzzy name with thinking level
pi --models "claude-*,gpt-4o"      # glob patterns for Ctrl+P cycling
pi --thinking high                 # set thinking level globally
```

### Examples

```bash
# Interactive session
pi

# Interactive with initial prompt
pi "List all .ts files in src/"

# Include files in prompt
pi @prompt.md @image.png "Review this"

# Non-interactive (scriptable)
pi -p "Summarize the repo structure"

# Continue previous session
pi --continue "What did we discuss?"

# Read-only mode
pi --tools read,grep,find,ls -p "Review the code in src/"

# Pipe output
pi --mode json -p "Explain main.ts"
```

---

## Built-in Tools

Default enabled tools: `read`, `bash`, `edit`, `write`

| Tool    | Purpose                                   | Default |
| ------- | ----------------------------------------- | ------- |
| `read`  | Read file contents                        | On      |
| `bash`  | Execute bash commands                     | On      |
| `edit`  | Surgical find-and-replace edits to files  | On      |
| `write` | Create or overwrite files                 | On      |
| `grep`  | Search file contents (respects .gitignore)| Off     |
| `find`  | Find files by glob pattern                | Off     |
| `ls`    | List directory contents                   | Off     |

**Design rationale**: Give bash — the model can invoke any CLI tool
through it. No need for dozens of specialized tools.

---

## Operating Modes

| Mode        | Flag / Invocation                       | Use Case                       |
| ----------- | --------------------------------------- | ------------------------------ |
| Interactive | `pi` (default)                          | Full TUI with slash commands   |
| Print       | `pi -p`                                 | Scripting, CI, non-interactive |
| JSON stream | `pi --mode json`                        | Structured event output        |
| RPC         | `pi --mode rpc`                         | IDE/app integration via stdin  |
| SDK         | `createAgentSession()` (TypeScript SDK) | Embed in apps                  |

---

## Interactive Slash Commands

Type `/` in interactive mode to access the command dropdown.

| Command   | Purpose                                                   |
| --------- | --------------------------------------------------------- |
| `/plan`   | Toggle plan mode (architecture before execution)          |
| `/model`  | Switch models mid-session                                 |
| `/tree`   | Navigate session tree; select branch points               |
| `/fork`   | Create new session file from current branch point         |
| `/compact`| Manually trigger context compaction                       |
| `/export` | Export session to HTML                                    |
| `/share`  | Upload session to GitHub gist for a shareable URL         |
| `/login`  | OAuth authentication for subscription-based providers     |

### Keyboard Shortcuts

| Shortcut      | Action                        |
| ------------- | ----------------------------- |
| `Ctrl+L`      | Cycle through models          |
| `Ctrl+P`      | Cycle favorite models         |
| `Shift+Enter` | Multi-line input              |
| `Tab`         | File path completion          |

---

## Session Management

Sessions are JSONL files where each entry has `id` + `parentId`,
enabling **in-place branching** without creating new files.

| Action              | How                                        |
| ------------------- | ------------------------------------------ |
| Resume last session | `pi --continue`                            |
| Pick a session      | `pi --resume`                              |
| Use specific file   | `pi --session <path>`                      |
| Navigate branches   | `/tree` in interactive mode                |
| Create a branch     | `/fork`                                    |
| Export to HTML      | `pi --export <session.jsonl> [output.html]`|
| Share via gist      | `/share`                                   |

**Side-quest pattern**: Branch with `/fork` to fix a broken tool or
explore an idea without polluting main session context.

---

## Context Compaction

- Auto-compaction enabled by default.
- Triggers on context overflow (auto-recovers) or when approaching
  the limit (proactive).
- Manual trigger: `/compact`.
- Fully extensible: custom topic-based, code-aware, or RAG-based
  compaction via extensions.

---

## Extensions

Extensions hook into 20+ lifecycle events (message before/after, tool
execution before/after, session state, user input, model responses).

### Installing Packages

```bash
pi install npm:@foo/pi-tools             # From npm
pi install git:github.com/org/pi-skills  # From git
pi install <source> -l                   # Project-local
```

### Managing Packages

```bash
pi list            # List installed extensions
pi update          # Update all (skips pinned)
pi update <source> # Update specific source
pi remove <source> # Remove a source
pi config          # TUI to enable/disable resources
```

### Extension Capabilities

- **Skills** — Capability packages (instructions + tools) loaded
  on-demand; no prompt bloat.
- **Prompt Templates** — Reusable `.md` prompts invoked via `/name`
  with argument expansion.
- **Themes** — Custom TUI appearance.
- **Dynamic context** — RAG, long-term memory, message injection before
  each turn.
- **Custom TUI components** — Spinners, progress bars, file pickers,
  data tables, preview panes.

---

## Permissions Model

**Default**: No permissions, no sandbox — full filesystem and command
access. Assumes the operator controls the environment.

**Optional `pi-permissions` extension** adds per-command consent:

| Grant scope     | Persistence                                  |
| --------------- | -------------------------------------------- |
| Allow Once      | Current invocation only                      |
| Allow Session   | Current session only                         |
| Allow Project   | Persisted to project, survives restarts      |
| Global          | `~/.pi/agent/ssh-policy-global.json`         |
| Deny            | Blocked, not retried                         |

- SSH: enabled by default in the extension.
- Bash: disabled by default in the extension.
- Non-interactive mode honours only persistent grants.

---

## Monorepo Package Structure

| Package                               | Purpose                            |
| ------------------------------------- | ---------------------------------- |
| `@mariozechner/pi-ai`                 | Unified LLM API (multi-provider)   |
| `@mariozechner/pi-agent-core`         | Agent loop, tool calling, state    |
| `@mariozechner/pi-coding-agent`       | Full CLI coding agent              |
| `@mariozechner/pi-tui`                | Terminal UI library                |

---

## Pi vs Claude Code

| Aspect           | Claude Code                   | Pi                            |
| ---------------- | ----------------------------- | ----------------------------- |
| System prompt    | ~10,000+ tokens               | ~200 tokens                   |
| Default tools    | 10+                           | 4                             |
| Security default | Deny-first, sandboxed         | YOLO (opt-in permissions)     |
| Extensibility    | MCP, sub-agents               | Extension API (20+ events)    |
| Workflow         | Opinionated phases            | User-defined                  |
| Target audience  | Teams, predictability         | Power users, hackers          |

---

## Reference Docs

| Topic        | Path                                                      |
| ------------ | --------------------------------------------------------- |
| CLI help     | [pi-help.md](pi-help.md)                                  |
| Extensions   | `pi-mono/packages/coding-agent/docs/extensions.md`        |
| RPC protocol | `pi-mono/packages/coding-agent/docs/rpc.md`               |
| Providers    | `pi-mono/packages/coding-agent/docs/providers.md`         |
