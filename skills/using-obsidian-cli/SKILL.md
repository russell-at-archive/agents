---
name: using-obsidian-cli
description: Uses Obsidian CLI correctly for desktop-driven `obsidian` commands, Obsidian Headless `ob` sync automation, vault targeting, note and property workflows, developer commands, and companion export flows. Use when requests mention `obsidian`, `ob`, Obsidian CLI, Obsidian Headless, vault automation, note creation, search, tasks, sync, plugin reload, or `obsidian-export`.
---

# Using Obsidian CLI

Use this skill before running any `obsidian` or `ob` command.

## What To Do

1. Identify which surface the task actually needs:
   live desktop control with `obsidian`, headless Sync with `ob`, or export
   conversion with `obsidian-export`.
2. Check the installed command surface with `--help` or `help <command>`
   before relying on flags or subcommands.
3. Confirm how the target vault is selected:
   current working directory, active vault, or explicit `vault=<name|id>`.
4. Prefer exact file targeting in scripts:
   use `path=<vault-relative-path>` when ambiguity would be risky.
5. Treat destructive or privileged actions carefully:
   permanent delete, restore operations, plugin install or uninstall, and
   `eval` all need explicit intent.
6. Verify the result after any write, sync, or developer operation.

## Core Workflow

- Use `obsidian` when the Obsidian desktop app is available and the task is to
  control the running app: notes, search, tasks, properties, plugins,
  workspaces, publish, sync controls, or developer tooling.
- Use bare `obsidian` for the TUI when interactive help, autocomplete, command
  history, or vault switching is useful.
- Use `ob` only for headless Obsidian Sync workflows. It is not a general note
  editing CLI; it manages remote sync setup, status, configuration, and pulls.
- Use `obsidian-export` when the goal is to convert a vault or subtree into
  standard Markdown for CI, publishing, or downstream processing.
- For desktop CLI tasks, start from `obsidian help` and `obsidian help <cmd>`
  rather than assuming a subcommand exists.
- For automation, prefer machine-readable output when available and validate
  the affected file, property, task, or sync status immediately after.

## Hard Rules

- Do not treat `obsidian`, `ob`, and `obsidian-export` as interchangeable.
- Do not use `obsidian` for headless server automation that lacks a running
  app. Use `ob` for Sync-backed headless workflows or `obsidian-export` for
  file conversion.
- `vault=<name|id>` must be the first parameter before the command or it is
  ignored.
- `file=<name>` uses wikilink-style resolution and can be ambiguous. Use
  `path=<path>` in scripts when precision matters.
- `obsidian eval code="..."` executes JavaScript inside the app. Do not run
  generated or untrusted code without review.
- `delete permanent` is irreversible. Require explicit user intent.
- Do not run desktop Sync and Headless Sync on the same device unless the user
  explicitly accepts the conflict risk called out by Obsidian.
- If the user needs setup help, read
  [references/installation.md](references/installation.md).
- If the user needs command selection or syntax guidance, read
  [references/overview.md](references/overview.md).
- If the user needs concrete commands, read
  [references/examples.md](references/examples.md).
- If the CLI is failing or behaving unexpectedly, read
  [references/troubleshooting.md](references/troubleshooting.md).
