---
name: using-codex-cli
description: Uses the OpenAI Codex CLI (`codex`) correctly for interactive sessions, non-interactive `codex exec` runs, `codex review`, session resume and fork flows, MCP setup, auth, sandbox selection, and result capture. Use this before running any `codex` command or when the user mentions Codex CLI, `codex exec`, `codex review`, `codex resume`, `codex fork`, `codex apply`, or Codex MCP configuration.
---

# Using Codex CLI

Use this skill before running any `codex` command.

## What To Do

1. Check the installed CLI surface with `codex --version` and the relevant
   `--help` output when flags or subcommands matter.
2. Classify the task before choosing a command:
   interactive work, one-shot automation, code review, session continuation,
   auth or configuration, MCP management, or cloud task application.
3. Set boundaries explicitly:
   repository root with `-C`, writable scope with `--add-dir`, and sandbox mode
   only as broad as the task requires.
4. Write a self-contained prompt. Codex does not inherit your current
   conversation context.
5. Capture results deliberately with `-o`, `--json`, or
   `--output-schema` when another tool or agent must consume the output.
6. Verify the outcome before reporting success.

## Core Workflow

- For interactive work, use `codex [PROMPT]` and treat `resume` or `fork` as
  the continuation primitives.
- For unattended execution, use `codex exec` or `codex exec resume` with an
  explicit root, prompt, and output path.
- For review tasks, prefer `codex review --uncommitted`, `--base`, or
  `--commit` instead of improvising a review prompt through `exec`.
- For auth and setup, inspect `codex login`, `codex logout`, `codex mcp`, and
  profiles or config overrides before editing local config files by hand.
- For remote or generated work that needs to land locally, understand when
  `codex apply` is safer than manually replaying a patch.

## Hard Rules

- Do not run `codex` with assumed defaults when scope or safety matters.
- Do not assume `--full-auto` means unsandboxed execution. It is a convenience
  mode, not a bypass.
- Do not recommend
  `--dangerously-bypass-approvals-and-sandbox` unless the user explicitly wants
  that tradeoff in an externally sandboxed environment.
- Do not reuse the same output file across concurrent `codex exec` runs.
- If the user wants install or login help, read
  [references/installation.md](references/installation.md).
- If the user wants command selection, flags, or prompt structure, read
  [references/overview.md](references/overview.md).
- If the user wants concrete commands, read
  [references/examples.md](references/examples.md).
- If the CLI is failing or behaving unexpectedly, read
  [references/troubleshooting.md](references/troubleshooting.md).
