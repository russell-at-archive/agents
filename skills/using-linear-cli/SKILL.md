---
name: using-linear-cli
description: Provides expert guidance for using the Linear CLI to manage authentication, issues, teams, projects, cycles, initiatives, milestones, documents, labels, and raw GraphQL requests. Use when running `linear` commands, managing Linear objects, or bootstrapping `.linear.toml`.
---

# Using Linear CLI

## Overview

Guides agents through the `linear` CLI (`schpet/linear-cli`) for terminal-first
Linear workflows, emphasizing non-interactive usage, VCS-aware issue context,
and safe mutation patterns.

For the full procedure and command reference, read
[references/overview.md](references/overview.md).

## When to Use

- Running any `linear` command
- Managing Linear issues, teams, cycles, initiatives, projects, or documents
- Bootstrapping or repairing `.linear.toml` configuration
- Extracting rich context (attachments, comments) for agent tasks
- Making raw GraphQL calls through `linear api` or inspecting the `schema`

## When Not to Use

- Using Linear MCP tools or the web UI when explicitly requested
- Editing `.linear.toml` manually without a user request
- Git/PR management better served by `using-graphite-cli` or `using-github-cli`

## Prerequisites

- `linear` (v1.11.1+) installed and available on `PATH`
- Authentication configured with `linear auth login`
- Correct workspace selected (`linear auth list`)

## Workflow

1. Verify binary, auth, and workspace context. If `linear` is missing, read
   [references/installation.md](references/installation.md).
2. Use `linear issue id` to confirm VCS context (git branch or jj trailers).
3. Select the appropriate command for the task (issue, project, document).
4. For the detailed command procedure and flags, read
   [references/overview.md](references/overview.md).
5. Prefer non-interactive flags and file-backed markdown inputs.
6. Verify changes with a corresponding read command.
7. For concrete usage patterns, read
   [references/examples.md](references/examples.md).
8. If errors occur, read [references/troubleshooting.md](references/troubleshooting.md).

## Hard Rules

- Prefer explicit flags over interactive prompts (`--no-interactive`).
- Use `--description-file`, `--body-file`, or `--content-file` for markdown.
- Never assume current issue context without verifying `linear issue id`.
- Treat all delete operations as confirmation-gated.
- Use `-w <slug>` when multiple workspaces are configured.

## Failure Handling

- If auth fails, run `linear auth whoami` or `linear auth list` to diagnose.
- If a binary is missing, follow [references/installation.md](references/installation.md).
- If current issue lookup fails, use an explicit issue ID (e.g., `ENG-123`).

## Red Flags

- Running interactive commands in automation
- Using ambiguous names where IDs or slugs are available
- Updating rich markdown content using inline strings
- Assuming repo context without verification
