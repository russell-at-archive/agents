# Writing Markdown: Full Procedure

## Contents

- [Config Setup](#config-setup)
- [Lint Commands](#lint-commands)
- [Full Workflow](#full-workflow)
- [Fixing Strategy by Rule](#fixing-strategy-by-rule)
- [Table Handling](#table-handling)
- [Completion Gate](#completion-gate)

---

## Config Setup

Before linting or editing, check the project root for a markdownlint config.
Recognized names in order of precedence:

1. `.markdownlint.jsonc`
1. `.markdownlint.json`
1. `.markdownlint.yaml`
1. `.markdownlint.yml`

If none exists, create `.markdownlint.json` in the project root with this
exact content:

```json
{
  "default": true,
  "MD007": {
    "indent": 2
  },
  "MD013": false,
  "MD024": {
    "siblings_only": true
  },
  "MD033": {
    "allowed_elements": [
      "br",
      "div"
    ]
  }
}
```

If a config already exists, use it as-is. Do not modify the project lint
config unless the user explicitly asks.

---

## Lint Commands

Use tools in this order:

1. Repository-wide: `markdownlint-cli2 "**/*.md"`
1. Focused: `markdownlint-cli2 file.md`
1. Fallback: `markdownlint file.md`

Run from the project root so the config file is discovered automatically.

---

## Full Workflow

1. Identify all `.md` files in scope.
1. Apply config setup above.
1. Run lint before editing to capture a baseline error count.
1. Write or edit in small batches. Use `references/rules.md` for rule
   definitions and `references/patterns.md` for copy-ready patterns.
1. Run lint after each batch.
1. Fix every reported error. Prefer minimal diffs. Fix structure before
   style.
1. Repeat until lint exits with zero errors.
1. Report the zero-error result explicitly. State the file names and
   confirm the error count is zero.

---

## Fixing Strategy by Rule

| Rule | Fix |
| --- | --- |
| `MD003` | Convert setext headings (`===`, `---`) to ATX (`#`) style. |
| `MD007` | Re-indent list items to 2 spaces per level. |
| `MD009` | Strip trailing whitespace from every line. |
| `MD010` | Replace hard tabs with spaces. |
| `MD013` | Disabled in default config; no action required. |
| `MD022` | Add one blank line before and after every heading. |
| `MD024` | Rename duplicate headings within the same parent section. |
| `MD025` | Reduce to a single `#` heading per file. |
| `MD026` | Remove trailing punctuation from heading text. |
| `MD031` | Add one blank line before and after every fenced code block. |
| `MD032` | Add one blank line before and after every list block. |
| `MD034` | Wrap bare URLs in `<>` or convert to `[text](url)` links. |
| `MD036` | Replace bold or italic used as a heading with a real heading. |
| `MD040` | Add a language tag to every opening fence with no space. |
| `MD041` | Make the first non-frontmatter line a `#` heading. |
| `MD047` | Ensure the file ends with exactly one newline character. |
| `MD049` | Replace `_italic_` with `*italic*`. |
| `MD050` | Replace `__bold__` with `**bold**`. |
| `MD055` | Add leading and trailing pipes to every table row. |
| `MD056` | Align every row to the same column count as the header. |
| `MD058` | Add one blank line before and after every table. |
| `MD060` | Pad cell content so pipes align with the header separator. |

Prefer minimal diffs. Fix structure violations (blank lines, heading
levels) before style violations (pipe alignment, emphasis markers).

---

## Table Handling

- Keep tables when they can remain lint-clean and readable.
- Keep column counts and meaning unchanged.
- Pad cells so pipes align with the header separator row.
- Convert a table to a list only when column width makes alignment
  impossible and the user approves.

---

## Completion Gate

Done only when all of the following are true:

- The lint command exits with code 0.
- The output shows zero markdownlint errors.
- The edited markdown preserves the original meaning and intent.
