---
name: using-claude-cli
description: Uses Claude Code CLI (`claude`) correctly for interactive sessions, `--print` automation, resume flows, permissions, memories, MCP servers, agents, plugins, and troubleshooting. Use this whenever the user asks to run `claude`, mentions Claude Code, headless/programmatic CLI usage, session resume, slash commands, MCP setup, or Claude CLI configuration.
---

# Using Claude CLI

Use this skill before running any `claude` command.

## What To Do

1. Confirm whether the task is interactive work, one-shot automation, or
   configuration and choose the command shape accordingly.
2. Check local CLI behavior with `claude --help`, `claude --version`, or the
   relevant subcommand help when flags or subcommands matter.
3. Prefer current official Claude Code docs for semantics that may have changed.
   Use the bundled references only to keep the workflow compact.
4. Keep the user away from unsafe permission bypasses unless the environment is
   intentionally sandboxed and the user explicitly wants that tradeoff.

## Core Workflow

- For interactive coding, use `claude` with an optional initial prompt. Treat
  built-in slash commands such as `/help`, `/resume`, `/memory`, `/permissions`,
  `/mcp`, `/agents`, `/compact`, and `/init` as the first place to look for
  session management.
- For automation, use `claude -p` or `claude --print`. Prefer
  `--output-format json` when another program will consume the result, and add
  `--json-schema` when the output shape must be enforced.
- For continued work, use `--continue` for the most recent local conversation or
  `--resume <session>` for a specific session. Capture `session_id` from JSON
  output when scripting multi-step runs.
- For permission-sensitive automation, start with the narrowest workable
  `--allowedTools` or `--permission-mode`. Do not jump straight to
  `--dangerously-skip-permissions`.
- For project guidance, use `/init` or maintain `CLAUDE.md`. Remember Claude
  Code loads memory hierarchically, so project and user memory can both apply.
- For tool integrations, inspect `claude mcp ...`, `claude agents`, and
  `claude plugin ...` rather than guessing subcommand syntax.

## Hard Rules

- Do not present built-in slash commands as available in `--print` mode when
  the task depends on direct user invocation.
- Do not recommend `--dangerously-skip-permissions` as the default path.
- When documenting automation, distinguish plain text output from
  `json` and `stream-json`.
- If the user wants install or auth help, read
  [references/installation.md](references/installation.md).
- If the user wants concrete commands, read
  [references/examples.md](references/examples.md).
- If the user wants deeper operational guidance, read
  [references/overview.md](references/overview.md).
- If the CLI is failing or behaving unexpectedly, read
  [references/troubleshooting.md](references/troubleshooting.md).
