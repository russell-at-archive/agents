---
name: using-codex-cli
description: Operational guide for OpenAI Codex CLI usage. Use before running
  any `codex` command, especially when dispatching non-interactive jobs with
  `codex exec`, running `codex review`, resuming sessions, choosing
  sandbox/approval settings, or collecting outputs for later integration.
---

# Using Codex CLI

## Overview

Run Codex with explicit safety settings, clear task prompts, and predictable
output handling.

Load details from:

- `references/overview.md` for command selection and flags
- `references/examples.md` for ready-to-run patterns
- `references/troubleshooting.md` for failure diagnosis and recovery

## Workflow

1. Verify Codex is available with `codex -V`.
2. Choose the command that matches intent:
   - `codex exec` for non-interactive task execution
   - `codex review` for repository or commit review
   - `codex exec resume` for non-interactive continuation
   - `codex resume` for interactive continuation
3. Set execution boundaries:
   - Set root with `-C <repo-or-worktree>`
   - Add explicit extra writable paths with `--add-dir <path>` only if needed
4. Set safety behavior:
   - Default to `--full-auto` for unattended execution
   - Use `--sandbox read-only` for analysis-only tasks
   - Never use
     `--dangerously-bypass-approvals-and-sandbox` unless explicitly required
5. Build a self-contained prompt:
   - include context, exact goal, constraints, and expected output format
   - include paths and branch/worktree assumptions
   - avoid references to "the discussion above" or hidden context
6. Set result format:
   - use `-o <file>` (`--output-last-message`) for integration workflows
   - use `--json` for machine-readable event streams
7. Execute the command and validate outputs before reporting success.

## Prompt Contract

Use this template for `codex exec` and `codex exec resume`:

```markdown
# Task
[One-sentence objective]

## Context
- Repository: [name]
- Working directory: [absolute path]
- Relevant files: [paths]

## Goal
[Specific deliverable]

## Constraints
- Do not modify: [paths or areas]
- Follow: [lint/test/build requirements]
- Output format: [summary | patch | checklist]

## Validation
[Commands Codex should run before final output]
```

## Hard Rules

- Do not run `codex` commands without this skill's guardrails.
- Do not assume Codex inherits conversation context.
- Do not reuse the same output file for concurrent jobs.
- Do not claim completion without checking returned output.
- Do not run destructive actions without explicit user approval.

## Failure Handling

- On auth or CLI failures, capture the exact command and stderr.
- On ambiguous scope, narrow task boundaries before re-running.
- On partial output, resume with `codex exec resume` and a concrete prompt.
- Use `references/troubleshooting.md` for known failure patterns.

## Red Flags

- Interactive waits caused by missing `--full-auto`
- Missing `-C` causing execution in the wrong repository
- Unsafe flag usage without explicit user request
- Output files overwritten during parallel dispatch
