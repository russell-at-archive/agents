# Examples

## Standard Execution Flow

1. Identify changed markdown files.
2. Run lint.
3. Fix reported rule violations.
4. Re-run lint until zero errors.

## Command Examples

```bash
markdownlint-cli2 skills/writing-markdown/SKILL.md
```

```bash
markdownlint-cli2 skills/writing-markdown/**/*.md
```

```bash
markdownlint skills/writing-markdown/SKILL.md
```

Use the `markdownlint` fallback only when `markdownlint-cli2` is not
available.

## Rewrite Pattern

Input problem types:

- lines exceed max length
- blank lines missing around headings, lists, or code blocks
- code fences missing language tags

Rewrite goals:

- wrap prose to configured limit
- add required blank lines around markdown blocks
- make fenced blocks explicit, for example `bash` or `text`
- preserve original meaning while normalizing markdown structure

## Completion Example

Acceptable completion statement shape:

- "Lint run completed with zero markdownlint errors on edited files."
