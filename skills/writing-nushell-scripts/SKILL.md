---
name: writing-nushell-scripts
description: Produces correct, safe, and idiomatic Nushell scripts following
  established best practices for script structure, type annotations,
  parameter and flag definitions, error handling, pipeline design, and
  structured data processing. Use when asked to write, fix, review, or
  improve Nushell scripts or .nu files.
---

# Writing Nushell Scripts

## Overview

Produces safe, idiomatic `.nu` scripts using Nushell's type system,
structured data pipelines, and custom command model. Nushell is safe by
design: variables are immutable by default, there is no word-splitting, and
types are checked at parse time. Scripts are built around `def main` with
typed parameters, not ad-hoc top-level code.

For the full reference on every topic, read
[references/overview.md](references/overview.md).

## When to Use

- Asked to write, create, or generate a Nushell script or `.nu` file
- Reviewing or fixing an existing `.nu` file
- Debugging a Nushell script error or unexpected behavior
- Choosing between Nushell constructs (e.g., `try/catch` vs `complete`)
- Adding error handling, argument parsing, or pipeline logic to a script

## When Not to Use

- The target shell is explicitly `bash`, `zsh`, `fish`, or `sh`
- The task is a one-liner typed at the prompt, not a script file
- The request is for a non-shell language (Python, Ruby, etc.)

## Prerequisites

- `nu` installed (any recent version; 0.90+ recommended)
- Script file uses the `.nu` extension
- Target Nushell version known when using newer features (attributes, etc.)

## Workflow

1. Confirm the script's purpose, inputs, outputs, and whether it needs
   subcommands.
2. Start every script with `#!/usr/bin/env nu` and a `def main` — see the
   Script Structure section in [references/overview.md](references/overview.md).
3. Annotate every parameter and flag with explicit types; add documentation
   comments above `def` and after each parameter.
4. Apply pipeline, string interpolation, and structured data patterns from
   [references/overview.md](references/overview.md).
5. Wrap external commands with `complete` or `do -c` for error propagation.
6. For complete working scripts, read [references/examples.md](references/examples.md).
7. For common mistakes and how to correct them, read
   [references/troubleshooting.md](references/troubleshooting.md).

## Hard Rules

- Always use `#!/usr/bin/env nu` as the shebang line.
- Always define a `def main [...]` entry point; never rely on top-level
  imperative code as the primary script body.
- Always annotate parameter and flag types explicitly.
- Use `let` for all bindings; only use `mut` when mutation is required.
- Use `try { } catch { |e| }` for built-in command errors.
- Wrap external commands with `complete` and check `.exit_code` explicitly.
- Use `$"...(expr)..."` for string interpolation; never concatenate with `+`.
- Name commands and variables in `kebab-case`.
- Send diagnostic output via `print --stderr`; reserve stdout for data.

## Failure Handling

- If the Nushell version is unknown and the script uses attributes
  (`@example`, `@deprecated`), note that these require 0.103+.
- If the script mixes external commands in pipelines without `complete`,
  flag the silent-failure risk and add explicit exit-code checks.
- If a parameter type cannot be determined, default to `string` and add a
  comment explaining why `any` was avoided.

## Red Flags

- No `def main` — top-level imperative code fails to accept CLI arguments
- Untyped parameters — missed parse-time safety checks
- `mut` used for every variable — mutation should be the exception
- External command errors silently ignored (no `complete`, no `do -c`)
- String concatenation with `+` instead of `$"...(expr)..."`
- `$env.LAST_EXIT_CODE` checked after a pipeline (unreliable; use `complete`)
- `kebab-case` violated — underscores in command or variable names
