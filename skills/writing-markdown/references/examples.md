# Examples

## Contents

- [Config Placement](#config-placement)
- [Baseline Lint Run](#baseline-lint-run)
- [Fixing Common Violations](#fixing-common-violations)
- [Completion Statement](#completion-statement)

---

## Config Placement

Check for an existing config before creating one:

```bash
ls .markdownlint* 2>/dev/null || echo "no config found"
```

If no config exists, create `.markdownlint.json` with the default content
from `references/overview.md`, then confirm placement:

```bash
markdownlint-cli2 --version
```

---

## Baseline Lint Run

Before editing, capture the starting error count:

```bash
markdownlint-cli2 "**/*.md"
```

Example output showing violations to fix:

```text
README.md:3 MD022/headings-should-be-surrounded-by-blank-lines
README.md:12 MD040/fenced-code-language
README.md:45 MD047/single-trailing-newline
```

Record the count. After editing, the same command must produce no output
and exit code 0.

---

## Fixing Common Violations

### MD022 — Blank lines around headings

Before:

```markdown
Some paragraph.
## Section Heading
Next paragraph.
```

After:

```markdown
Some paragraph.

## Section Heading

Next paragraph.
```

### MD040 — Missing language on fenced block

Before: a fenced block opens with only three backticks and no language tag.

After: the opening backticks are followed immediately by the language token,
for example `bash`, `json`, or `text`.

### MD032 — Blank lines around lists

Before:

```markdown
Introduction sentence.
- Item one
- Item two
Closing sentence.
```

After:

```markdown
Introduction sentence.

- Item one
- Item two

Closing sentence.
```

### MD034 — Bare URL

Before:

```markdown
See https://example.com for details.
```

After:

```markdown
See <https://example.com> for details.
```

### MD058 — Blank lines around tables

Before:

```markdown
Paragraph before.
| Col A | Col B |
| ----- | ----- |
| one   | two   |
Paragraph after.
```

After:

```markdown
Paragraph before.

| Col A | Col B |
| ----- | ----- |
| one   | two   |

Paragraph after.
```

---

## Completion Statement

After a clean lint run, state the result explicitly:

> Lint run completed with zero markdownlint errors on `README.md`.

Never state completion without running lint first.
