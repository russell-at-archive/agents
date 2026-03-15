---
name: using-obsidian-cli
description: Provides expert guidance for using the Obsidian CLI to manage
  vaults, notes, search, daily notes, properties, tags, and automation from
  the command line. Use when requests involve the obsidian command, obsidian
  vault operations, obsidian search, obsidian daily, obsidian properties,
  notesmd-cli, obsidian-export, or automating Obsidian from a shell script
  or CI/CD pipeline.
---

# Using Obsidian CLI

## Overview

Guides agents through Obsidian's official CLI (`obsidian` binary, v1.12.4+)
and its ecosystem of community tools for vault automation. The official CLI
communicates with a running Obsidian instance via IPC; for headless
environments use `notesmd-cli` or `obsidian-export` instead.

Full command reference and tool selection guide:
[references/overview.md](references/overview.md)

## When to Use

- Running any `obsidian` command against a vault
- Automating note creation, search, or daily note updates
- Managing properties, tags, or links from the shell
- Exporting vault content for static sites or CI pipelines
- Developing or hot-reloading Obsidian plugins

## When Not to Use

- Editing vault files with a text editor directly (use `$EDITOR` or Write tool)
- Querying Obsidian via REST API directly (use the Local REST API plugin docs)
- Tasks that only need standard Markdown processing with no Obsidian features

## Prerequisites

- Obsidian desktop app v1.12.4+ installed
- CLI registered: **Settings → General → Command line interface → Register CLI**
- Terminal restarted after registration (PATH must include Obsidian binary)
- For headless/CI: `notesmd-cli` (Homebrew) or `obsidian-export` (Cargo)

## Workflow

1. Confirm environment: `obsidian version` — if it fails, check PATH setup in
   [references/troubleshooting.md](references/troubleshooting.md).
2. Identify the target vault: `obsidian vaults`. Use `vault="Name"` as the
   **first** argument when targeting a non-default vault.
3. Select the right tool tier:
   - Obsidian running → official `obsidian` CLI
   - Headless / CI → `notesmd-cli` or `obsidian-export`
4. Execute the command. Use `format=json` for machine-readable output;
   append `--copy` to send output to clipboard.
5. For bulk or complex operations, read
   [references/overview.md](references/overview.md) for the full command
   table and automation patterns.
6. For concrete script examples read
   [references/examples.md](references/examples.md).

## Hard Rules

- `vault=` must be the **first** argument or it is silently ignored.
- `obsidian delete file="…" --permanent` is irreversible — default `delete`
  sends to trash and is safe.
- `obsidian eval code="…"` executes arbitrary JavaScript in the app; review
  scripts before running.
- On Windows, never run the CLI from an admin-elevated terminal (IPC fails
  silently).
- For cron/headless automation, use `notesmd-cli` — the official CLI requires
  Obsidian to be open.

## Failure Handling

- `command not found: obsidian` → CLI not registered or PATH not refreshed;
  see [references/troubleshooting.md](references/troubleshooting.md).
- No output on Windows → launched from admin terminal; restart via
  `Win+R → powershell`.
- Vault not found → run `obsidian vaults` and verify exact name spelling.
- Obsidian not running → CLI auto-launches it, but first command may be slow.

## Red Flags

- `vault=` placed anywhere other than the first argument
- Using `--permanent` on delete without explicit user confirmation
- Running `obsidian eval` with untrusted or generated code
- Using the official CLI in headless CI without confirming Obsidian is running
