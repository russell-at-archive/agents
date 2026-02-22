---
name: using-gemini-cli
description: Use when you need to dispatch tasks to the Gemini CLI for
  large-context analysis, codebase comprehension, summarization, or dependency
  mapping. Invoke before running any gemini command.
---

# Using Gemini CLI

## Overview

Use this skill before any `gemini` command when you need high-context,
cross-file analysis from Gemini CLI.
Detailed guidance: `references/overview.md`.

## When to Use

- analyzing architecture across many files
- mapping dependencies or migration impact across modules
- summarizing large repositories, diffs, or documentation sets

## When Not to Use

- writing or applying code changes directly
- one-file or narrow questions you can answer with direct file reads
- tasks that require shared conversation state with this agent

## Prerequisites

- `gemini` is installed and authenticated
- target files or directories are known
- output destination is defined for non-trivial analysis runs

## Workflow

1. Run the preflight checks in `references/overview.md`.
2. Pick a safe execution mode and approval policy.
3. Build a self-contained prompt with explicit file scope.
4. Execute Gemini and capture output for integration.
5. Validate findings against source files before reporting.
6. Use `references/examples.md` and `references/troubleshooting.md` as needed.

## Hard Rules

- always run Gemini in non-interactive mode with `-p`
- keep prompts self-contained; Gemini has no access to this chat context
- default to read-only analysis modes unless user requests edits
- do not execute destructive or irreversible actions without approval

## Failure Handling

- if preflight fails, stop and report exact failure and remediation
- if output is incomplete, rerun with broader file scope and tighter prompt
- if results conflict with local files, trust local files and cite mismatch

## Red Flags

- asking Gemini to perform implementation that should stay in Codex
- missing file paths or vague prompts that invite hallucinated structure
- reporting Gemini output without verifying key claims against real files
