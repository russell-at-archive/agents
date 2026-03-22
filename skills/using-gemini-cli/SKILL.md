---
name: using-gemini-cli
description: Uses the Gemini CLI (`gemini`) correctly for interactive sessions,
  headless `-p` automation, approvals, sandboxing, context files, resume flows,
  and structured output. Use before running any `gemini` command or when the
  user mentions Gemini CLI, `gemini -p`, `--approval-mode`, `GEMINI.md`, or
  Gemini CLI settings.
---

# Using Gemini CLI

## Overview

Use this skill before any `gemini` command. Default to headless mode for
automation and use interactive mode only when the user explicitly wants a live
session.
Detailed guidance: `references/overview.md`.

## When to Use

- running `gemini -p` for repo analysis, summarization, or scripted output
- starting or resuming interactive Gemini CLI sessions
- configuring approvals, sandboxing, `GEMINI.md`, settings, or resume behavior
- capturing JSON or stream output for later integration

## When Not to Use

- when direct local file reads are faster and sufficient
- when the task should stay entirely inside this agent without a second model
- when the user asked for a tool other than Gemini CLI

## Prerequisites

- `gemini` is installed. If missing, read
  [references/installation.md](references/installation.md).
- authentication is configured before non-trivial runs
- the prompt includes task, constraints, and explicit file scope

## Workflow

1. Verify installation and auth using
   [references/installation.md](references/installation.md).
2. Choose execution mode:
   headless `-p` for automation, interactive `gemini` for live sessions,
   `--prompt-interactive` when you need both.
3. Choose approval and sandbox settings intentionally.
4. Build a self-contained prompt with explicit paths and output requirements.
5. Run Gemini, usually with `--output-format json` or `stream-json` for
   automation.
6. Validate important claims against local files before reporting results.
7. Use `references/examples.md` and `references/troubleshooting.md` as needed.

## Hard Rules

- do not assume Gemini shares this chat context; prompts must be self-contained
- use `-p` for non-interactive automation and scripting
- do not combine positional prompts with `-p`, or `-p` with
  `--prompt-interactive`
- default to `--approval-mode plan` for analysis; use `auto_edit` or `yolo`
  only when the user explicitly wants autonomous changes
- treat Gemini output as advisory until verified against local files

## Failure Handling

- if the CLI is missing or auth is broken, follow
  [references/installation.md](references/installation.md)
- if the command appears hung, check whether you accidentally started an
  interactive flow instead of `-p`
- if output is vague, tighten the prompt and broaden file scope
- if results conflict with local files, trust local files and report the
  mismatch

## Red Flags

- stale guidance that assumes old flags or removed options
- vague prompts with no file scope or no output contract
- using permissive approval modes without explicit user intent
- reporting unverified Gemini claims as facts
