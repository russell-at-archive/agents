# Overview

All markdown output must pass markdownlint with zero errors before you
report completion.

## Procedure

1. Identify target files (`*.md`) in scope.
2. Run lint before editing to capture a baseline.
3. Fix violations in small batches by rule ID.
4. Re-run lint.
5. Repeat until no errors remain.
6. Report what changed and confirm zero-error result.

## Lint Command Order

Use this order:

1. `markdownlint-cli2 "**/*.md"` for repository-wide checks.
2. `markdownlint-cli2 <file1> <file2>` for focused edits.
3. Fallback only if needed: `markdownlint <files>`.

If a repository config exists (for example `.markdownlint.jsonc`), do
not override it unless asked.

## Fixing Strategy By Rule

- `MD013`: hard-wrap prose to 80 columns unless config says otherwise
- `MD022`: add blank lines above and below headings
- `MD031`: add blank lines around fenced code blocks
- `MD032`: add blank lines around lists
- `MD040`: add language identifiers to fenced code blocks
- `MD047`: ensure exactly one trailing newline at file end
- `MD058`: add blank lines around tables
- `MD060`: normalize table pipe style and column alignment

Prefer minimal diffs. Fix structure first, then style.

## Table Handling

- Keep tables when they can remain lint-clean and readable.
- Keep column counts and meaning unchanged.
- Align pipes and pad columns consistently.
- Convert tables to lists only if width or readability is impossible to
  resolve without distortion.

## Completion Gate

You are done only when:

- Lint command exits successfully.
- The output shows zero markdownlint errors.
- Edited markdown still preserves original meaning and intent.
