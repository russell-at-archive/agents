---
name: writing-editorconfig
description: Produces correct, portable .editorconfig files following the
  EditorConfig specification. Use when asked to write, create, fix, review,
  or improve an .editorconfig file, editor config, or coding style
  configuration for cross-editor consistency.
---

# Writing EditorConfig

## Overview

Produces `.editorconfig` files that enforce consistent coding style across
editors, IDEs, and developers without requiring external tooling. Applies
the full EditorConfig specification including file hierarchy, glob patterns,
universal properties, and language-specific conventions.

Full property reference and procedure:
[references/overview.md](references/overview.md)

## When to Use

- Asked to write, create, fix, or review an `.editorconfig` file
- A project lacks editor style consistency across contributors
- Onboarding a new repository that needs baseline style enforcement
- A specific language or file type needs style overrides

## When Not to Use

- The request is for a formatter config (Prettier, Black, gofmt) — those
  are separate tools that complement but do not replace EditorConfig
- The project already has a correct `.editorconfig` and no changes are needed

## Prerequisites

- The target repository root is known
- Language(s) and file types used in the project are identified
- Preferred indentation style (tabs vs. spaces) and size are known or can
  be inferred from existing source files

## Workflow

1. Read [references/overview.md](references/overview.md) for the full
   property reference, glob syntax, and hierarchy rules.
2. Identify the project's primary languages and file types.
3. Write a `root = true` declaration at the top of the file.
4. Add a `[*]` catch-all section with universal baseline properties.
5. Add per-language sections overriding only what differs from the baseline.
6. Apply Markdown exception: always set
   `trim_trailing_whitespace = false` for `[*.md]`.
7. Apply Makefile exception: always set `indent_style = tab` for
   `[Makefile]`.
8. Validate with the `editorconfig` CLI if available.

For concrete per-language examples, read
[references/examples.md](references/examples.md).
For mistakes, edge cases, and recovery paths, read
[references/troubleshooting.md](references/troubleshooting.md).

## Hard Rules

- `root = true` must appear at the top of the file, outside any section.
- Every `.editorconfig` must have a `[*]` catch-all section.
- Never set `trim_trailing_whitespace = true` for Markdown files.
- Never set `indent_style = space` for Makefiles — tabs are required by make.
- Do not specify `tab_width` unless it differs from `indent_size`.
- Use `unset` to explicitly remove an inherited property when needed.
- All section glob paths use forward slashes only.

## Failure Handling

- If indentation preference is unknown, inspect existing source files and
  match the dominant style rather than guessing.
- If the `editorconfig` CLI is unavailable, validate manually by checking
  that each section matches its intended file types.
- If a property is needed but not universally supported, add a comment
  noting which editors honor it.

## Red Flags

- Missing `root = true` — EditorConfig will traverse parent directories
  indefinitely
- `trim_trailing_whitespace = true` in a `[*.md]` section
- `indent_style = space` or `indent_size` set for `[Makefile]`
- `tab_width` set to the same value as `indent_size` — redundant
- Sections that match no files in the project
- Properties set with no `indent_style` declared in the same section
