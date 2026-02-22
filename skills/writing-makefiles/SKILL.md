---
name: writing-makefiles
description: Produces correct, portable, and maintainable GNU Makefiles following
  established best practices for targets, variables, pattern rules, functions, and
  self-documentation. Use when asked to write, fix, review, or improve a Makefile,
  GNUmakefile, makefile, or .mk file.
---

# Writing Makefiles

## Overview

Produces correct, idiomatic GNU Makefiles using established best practices:
explicit `.PHONY` declarations, simply-expanded variables, automatic variables,
pattern rules, built-in functions, and self-documenting `help` targets. Covers
variable flavors, recipe modifiers, conditionals, and common project patterns.

For the full reference on every topic, read
[references/overview.md](references/overview.md).

## When to Use

- Asked to write, create, or generate a Makefile or `.mk` file
- Reviewing or fixing an existing Makefile
- Debugging a make error or unexpected rebuild behavior
- Adding targets, variables, pattern rules, or functions to a Makefile
- Choosing between variable flavors (`=` vs `:=`) or rule types
- Implementing build, test, lint, clean, or install automation

## When Not to Use

- The build system is explicitly CMake, Bazel, Ninja, Meson, or another tool
- The task is a shell script or CI pipeline config, not a Makefile
- The target is BSD make — focus here is GNU make

## Prerequisites

- GNU make 3.81+ (`make --version` to confirm)
- Understand whether the project uses GNU make or BSD make before writing
- Know the project's build inputs, outputs, and dependency graph

## Workflow

1. Confirm the Makefile's purpose: build automation, task runner, or both.
2. Set `SHELL`, `.DEFAULT_GOAL`, and `.DELETE_ON_ERROR` at the top — see
   the Canonical Header section in [references/overview.md](references/overview.md).
3. Declare all non-file targets in `.PHONY`.
4. Use `:=` for variable assignment unless lazy evaluation is explicitly needed.
5. Apply automatic variables (`$@`, `$<`, `$^`, `$*`) in pattern and explicit rules.
6. Use built-in functions for file list manipulation — see Function Reference in
   [references/overview.md](references/overview.md).
7. Add a self-documenting `help` target using the `##` comment convention.
8. For complete working Makefiles, read [references/examples.md](references/examples.md).
9. For common mistakes and fixes, read
   [references/troubleshooting.md](references/troubleshooting.md).
10. Run `make -n` (dry run) to verify recipe expansion before executing.

## Hard Rules

- Always use TAB characters — not spaces — to indent recipes.
- Always declare `.PHONY` for every non-file target.
- Use `:=` (simply-expanded) over `=` (recursive) by default.
- Use `$(MAKE)` not `make` for recursive sub-invocations.
- Use `$$var` not `$var` to reference shell variables inside recipes.
- Never use `rm -rf` in `clean` targets without a narrowly scoped path or guard.
- Set `SHELL := /bin/bash` for consistent recipe behavior.
- Use `.DELETE_ON_ERROR` to prevent stale partial build outputs.

## Failure Handling

- If `make` errors with "missing separator", recipes use spaces — convert to TABs.
- If a target always rebuilds, it may be missing from `.PHONY` or the output file
  is never created — read [references/troubleshooting.md](references/troubleshooting.md).
- If variable expansion looks wrong, check flavor (`=` vs `:=`) and insert
  `$(info VAR=$(VAR))` to debug.
- If GNU make version is below 3.81, flag incompatibilities before writing.

## Red Flags

- Recipes indented with spaces instead of TABs
- Non-file targets missing from `.PHONY`
- `$var` inside recipes (must be `$$var` for shell variables)
- `make` instead of `$(MAKE)` in sub-invocations
- Recursive `=` variable referencing itself (infinite expansion)
- `rm -rf $(DIR)` without a guard when `DIR` could be empty or unset
- Pattern rules without automatic variables (`$@`, `$<`, `$^`)
- No `.DEFAULT_GOAL` — depends on fragile first-target ordering
