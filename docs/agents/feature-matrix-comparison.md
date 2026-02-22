# Agent Feature Matrix Comparison

This document provides a comparative analysis of the features supported by
**Claude Code**, **Gemini CLI**, **OpenAI Codex CLI**, and **Pi Coding Agent**.

## Overview Matrix

| Feature         | Claude Code       | Gemini CLI        | OpenAI Codex     | Pi Coding Agent      |
| :-------------- | :---------------- | :---------------- | :--------------- | :------------------- |
| **Primary CLI** | `claude`          | `gemini`          | `codex`          | `pi`                 |
| **Skills**      | Custom slash cmds | Agent Skills Std  | Agent Skills Std | Agent Skills Std     |
| **Hooks**       | 17 events, block  | 10 events, shell  | Experimental     | Extension events     |
| **Plugins**     | `.claude-plugin/` | Extensions        | No formal system | TS Extensions        |
| **Agents**      | `.claude/agents/` | Native sub-agents | Experimental     | Via extensions       |
| **Context**     | `CLAUDE.md`       | `GEMINI.md`       | `AGENTS.md`      | `AGENTS.md`          |
| **MCP**         | Native support    | Native support    | Native support   | Via extensions only  |

---

## Commands and Usage

### Claude Code Commands

- **Interactive Mode**: Default behavior of `claude`.
- **Management Subcommands**: `auth`, `mcp`, `plugin`, `agents`, `doctor`,
  `install`, `setup-token`, `update`.
- **Non-interactive**: Use `-p` or `--print` for pipes.

### Gemini CLI Commands

- **Interactive Mode**: Default behavior of `gemini`.
- **Management Subcommands**: `mcp`, `extensions`, `skills`, `hooks`.
- **Non-interactive**: Use `-p` or `--prompt` for headless mode.

### OpenAI Codex Commands

- **Interactive Mode**: Default behavior of `codex`.
- **Management Subcommands**: `exec`, `review`, `login`, `mcp`, `app`,
  `sandbox`, `apply`, `resume`, `fork`.
- **Non-interactive**: `codex exec` or `codex review`.

### Pi Coding Agent Commands

- **Interactive Mode**: Default behavior of `pi`.
- **Management Subcommands**: `install`, `remove`, `update`, `list`, `config`.
- **Non-interactive**: Use `-p` or `--print` for single-shot output.
- **Additional Modes**: `--mode json` for JSON lines, `--mode rpc` for process
  integration, and SDK embedding.

---

## Skills

| Aspect            | Claude Code       | Gemini CLI        | OpenAI Codex  | Pi Coding Agent       |
| :---------------- | :---------------- | :---------------- | :------------ | :-------------------- |
| **Format**        | YAML + Markdown   | `SKILL.md`        | `SKILL.md`    | `SKILL.md`            |
| **Invocation**    | `/skill-name`     | `activate_skill`  | `$skill-name` | `/skill:name` or auto |
| **Locations**     | `.claude/skills/` | `.gemini/skills/` | `~/.agents/`  | `~/.pi/agent/skills/` |
| **Customization** | YAML frontmatter  | Agent Skills spec | `openai.yaml` | Agent Skills spec     |

Pi also discovers skills from `~/.agents/skills/`, `.pi/skills/`,
`.agents/skills/`, parent directories, and installed Pi Packages.

---

## Hooks

Hooks allow for intercepting and modifying the agent's behavior during its
execution cycle.

### Claude Code Hooks (17 Events)

- **Breadth**: Supports the most events (e.g., `UserPromptSubmit`,
  `PreToolUse`, `SubagentStart`, etc).
- **Types**: `command` (shell), `prompt` (LLM single-turn), and `agent` (LLM
  multi-turn).
- **Capability**: Can block execution, modify inputs, or provide additional
  context.

### Gemini CLI Hooks (10 Events)

- **Breadth**: Core lifecycle events (e.g., `BeforeAgent`, `BeforeModel`,
  `BeforeTool`, `AfterTool`).
- **Types**: Currently only `type: "command"` (shell script execution).
- **Capability**: Can block (`decision: "deny"`) or rewrite tool inputs.

### OpenAI Codex Hooks

- **Breadth**: Limited to basic tool interception (`BeforeToolUse`,
  `AfterToolUse`).
- **Status**: Still under active development and considered less mature than
  Claude or Gemini's systems.

### Pi Coding Agent Hooks

- **Breadth**: Event-driven via the Extension API (`tool_call` and other
  lifecycle events).
- **Types**: TypeScript extension event handlers rather than shell scripts.
- **Capability**: Extensions can intercept tool calls, replace built-in tools,
  add permission gates, and modify behavior at runtime. No fixed hook count;
  extensibility is open-ended.

---

## Plugins and Extensions

### Claude Code Plugins

Plugins are the primary way to distribute bundled functionality. A
`.claude-plugin/plugin.json` manifest defines the plugin's metadata. They can
bundle skills, hooks, MCP servers, and custom agents.

### Gemini CLI Extensions

Extensions are the Gemini equivalent of plugins. They use a
`gemini-extension.json` manifest and can bundle context files, slash commands,
and MCP servers. They are managed via the `gemini extensions` command.

### OpenAI Codex Plugins

Codex lacks a formal plugin system. Extensibility is achieved primarily through
the Agent Skills standard and the manual configuration of MCP servers.

### Pi Coding Agent Extensions

TypeScript modules that extend pi with custom tools, commands, keyboard
shortcuts, event handlers, and TUI components. Extensions can:

- Register custom tools or replace built-in tools entirely.
- Add sub-agents, plan mode, and custom compaction logic.
- Render custom UI: editors, status lines, headers, footers, and overlays.
- Gate permissions and protect paths.
- Integrate MCP servers, Git checkpointing, and sandbox execution.

Extensions are managed via `pi install`, `pi remove`, `pi config`, and can be
shared as Pi Packages through npm or git.

---

## Specialized Agents

### Claude Code Agents

Users can define custom sub-agents in `.claude/agents/<name>.md`. These
sub-agents can have their own system prompts, toolsets, and permission models.
Built-in agents include `Explore` and `Plan`.

### Gemini CLI Agents

Gemini utilizes built-in specialized sub-agents for complex tasks:

- `codebase_investigator`: Deep analysis and architectural mapping.
- `cli_help`: Answers questions about Gemini CLI features and config.
- `generalist`: Handles batch tasks and high-volume data processing.

### OpenAI Codex Agents

Features an experimental `multi_agent` mode that can be enabled in
`config.toml`. It is less structured than the Claude or Gemini implementations.

### Pi Coding Agent Agents

Pi intentionally ships without built-in sub-agents or plan mode. These
capabilities are implemented via extensions, letting users choose or build
the agent orchestration model that fits their workflow. Multiple pi instances
can also be spawned via tmux for parallel work.

---

## Authentication and Context

| Feature           | Claude Code      | Gemini CLI  | OpenAI Codex | Pi Coding Agent      |
| :---------------- | :--------------- | :---------- | :----------- | :------------------- |
| **Context File**  | `CLAUDE.md`      | `GEMINI.md` | `AGENTS.md`  | `AGENTS.md`          |
| **Modular Rules** | `.claude/rules/` | N/A         | N/A          | `.pi/SYSTEM.md`      |
| **System Rules**  | `CLAUDE.md`      | `GEMINI.md` | `AGENTS.md`  | `AGENTS.md`          |

Pi loads context from `AGENTS.md` (or `CLAUDE.md`) at multiple levels: global
(`~/.pi/agent/AGENTS.md`), parent directories walking up from `cwd`, and the
current directory. The system prompt can be replaced via `.pi/SYSTEM.md` or
appended via `APPEND_SYSTEM.md`.

---

## Provider and Model Support

| Aspect                | Claude Code | Gemini CLI | OpenAI Codex | Pi Coding Agent    |
| :-------------------- | :---------- | :--------- | :----------- | :----------------- |
| **Subscription Auth** | Anthropic   | Google     | OpenAI       | 5 providers        |
| **API Key Providers** | 1           | 1          | 1            | 18+ providers      |
| **Model Switching**   | Config      | Config     | Config       | `/model` or Ctrl+L |
| **Custom Providers**  | N/A         | N/A        | N/A          | `models.json`      |

Pi supports subscriptions for Anthropic, OpenAI (Codex), GitHub Copilot,
Google Gemini CLI, and Google Antigravity. API key authentication covers
18+ providers including Anthropic, OpenAI, Azure OpenAI, Google, AWS Bedrock,
Mistral, Groq, xAI, OpenRouter, and more. Custom providers can be added via
`~/.pi/agent/models.json`.

---

## Sessions and Branching

| Aspect             | Claude Code | Gemini CLI  | OpenAI Codex | Pi Coding Agent     |
| :----------------- | :---------- | :---------- | :----------- | :------------------ |
| **Session Format** | Proprietary | Proprietary | Proprietary  | JSONL tree          |
| **Branching**      | N/A         | N/A         | `codex fork` | `/tree` in-place    |
| **Compaction**     | Automatic   | Manual      | N/A          | Auto + manual       |
| **Resume**         | Yes         | Yes         | Yes          | `-c`, `-r`, `/tree` |

Pi sessions are stored as JSONL files with a tree structure (each entry has
`id` and `parentId`). The `/tree` command allows navigating, branching, and
switching between branches in place. `/fork` creates a new session from any
branch point. Compaction runs automatically on context overflow or can be
triggered manually with `/compact`.

---

## Programmatic Usage

| Aspect    | Claude Code | Gemini CLI  | OpenAI Codex | Pi Coding Agent                 |
| :-------- | :---------- | :---------- | :----------- | :------------------------------ |
| **SDK**   | TypeScript  | N/A         | N/A          | TypeScript SDK                  |
| **RPC**   | N/A         | N/A         | N/A          | JSONL over stdin/stdout         |
| **Modes** | Interactive | Interactive | Interactive  | Interactive, print, JSON, RPC   |

Pi offers a TypeScript SDK for embedding (`createAgentSession`), an RPC mode
for non-Node.js integrations, and a JSON lines mode for structured output.

---

## Package Distribution

| Aspect           | Claude Code        | Gemini CLI        | OpenAI Codex | Pi Coding Agent              |
| :--------------- | :----------------- | :---------------- | :----------- | :--------------------------- |
| **Format**       | `.claude-plugin/`  | `gemini-ext.json` | N/A          | Pi Packages                  |
| **Distribution** | Manual             | Manual            | N/A          | npm or git                   |
| **Management**   | Manual             | `gemini ext`      | N/A          | `pi install/remove`          |
| **Contents**     | Skills, hooks, MCP | Context, commands | N/A          | Ext, skills, prompts, themes |

Pi Packages bundle extensions, skills, prompt templates, and themes. They are
installed via `pi install npm:...` or `pi install git:...` and managed with
`pi list`, `pi update`, `pi remove`, and `pi config`.
