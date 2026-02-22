---
name: writing-bash-scripts
description: Produces correct, safe, and portable Bash scripts following
  established best practices for strict mode, variable quoting, argument
  parsing, error handling, traps, and security. Use when asked to write,
  fix, review, or improve shell scripts, bash scripts, or .sh files.
---

# Writing Bash Scripts

## Overview

Produces safe, idiomatic Bash scripts using established best practices:
strict mode, proper quoting, defensive error handling, and clean structure.
Covers script architecture, argument parsing, I/O, arrays, traps, and
security hardening.

For the full reference on every topic, read
[references/overview.md](references/overview.md).

## When to Use

- Asked to write, create, or generate a bash or shell script
- Reviewing or fixing an existing `.sh` file
- Debugging a bash script error or unexpected behavior
- Choosing between shell constructs (e.g., `[[ ]]` vs `[ ]`)
- Adding error handling, argument parsing, logging, or traps to a script

## When Not to Use

- The target shell is explicitly `sh`, `zsh`, `fish`, or `dash`
- The task is a one-liner or alias, not a script file
- The request is for a non-shell language (Python, Ruby, etc.)

## Prerequisites

- `bash` 4.0+ recommended for associative arrays and `mapfile`
- `shellcheck` for linting (optional but strongly recommended)
- Target system's bash version known before writing portability-sensitive code

## Workflow

1. Confirm the script's purpose, inputs, outputs, and target environment.
2. Start every script with the shebang and strict mode — see the Script
   Structure section in [references/overview.md](references/overview.md).
3. Apply the canonical layout: shebang → strict mode → constants →
   functions → argument parsing → `main "$@"`.
4. Apply quoting, conditional, loop, and array patterns from
   [references/overview.md](references/overview.md).
5. Add a `trap` for cleanup and signal handling.
6. For complete working scripts, read [references/examples.md](references/examples.md).
7. For common mistakes and how to correct them, read
   [references/troubleshooting.md](references/troubleshooting.md).
8. Run `shellcheck -x script.sh` and fix all warnings before delivery.

## Hard Rules

- Always use `#!/usr/bin/env bash` as the shebang line.
- Always enable `set -euo pipefail` immediately after the shebang.
- Always quote every variable expansion: `"${var}"`, never `$var`.
- Use `[[ ]]` for conditionals; never `[ ]` or `test` in bash scripts.
- Declare all function-local variables with `local`.
- Never use `eval` with untrusted or external input.
- Use `mktemp` for temporary files; always clean up with `trap ... EXIT`.
- Send errors and diagnostics to stderr: `echo "error" >&2`.

## Failure Handling

- If bash version is below 4.0 and the script needs associative arrays,
  flag the incompatibility and offer a parallel-array alternative.
- If `shellcheck` reports SC2 errors, fix all before delivering the script.
- If the target shell is not confirmed, ask — the shebang choice shapes
  every construct in the script.
- If the task requires `eval` on external data, stop and propose a safe
  alternative (case statement, associative array, or named functions).

## Red Flags

- Missing `set -euo pipefail` — silent failures will propagate
- Unquoted `$var` — word-splitting and glob expansion bugs
- `[ ]` instead of `[[ ]]` — subtle string comparison failures
- `for f in $(ls ...)` or `for f in $(find ...)` — breaks on special filenames
- `cd` without `|| exit 1` — subsequent commands run in the wrong directory
- Temp files created without a `trap ... EXIT` cleanup
- `eval` with any variable containing external input
- `rm -rf "${var}"` without guarding against empty `"${var}"`
