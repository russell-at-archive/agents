# Troubleshooting

## Contents

- [Tooling Failures](#tooling-failures)
- [Rule-Specific Failures](#rule-specific-failures)
- [Avoiding Regressions](#avoiding-regressions)
- [Escalation](#escalation)

---

Strategies for resolving persistent lint failures and tooling issues.

## Tooling Failures

### `markdownlint-cli2: command not found`

Fall back to `markdownlint`. If that also fails:

1. Report the missing tooling to the user.
1. List every rule violation you identified by inspection.
1. State clearly that the zero-error gate cannot be verified without the tool.

Do not claim success.

### `Cannot find config` or config not loaded

Run from the project root directory. Pass explicit file targets if needed.
Verify the config file name matches a recognized name
(`.markdownlint.json`, `.markdownlint.jsonc`, `.markdownlint.yaml`).

### Parser error in markdown

Repair malformed structures before running lint:

- Unclosed fenced code blocks (missing closing ` ``` `)
- Broken table rows (mismatched `|` counts)
- Unclosed HTML tags (if inline HTML is used)
- Nested list indentation that is inconsistent

Re-run lint after each structural repair.

## Rule-Specific Failures

### MD001 — Heading jump still reported

Find every heading in the file and map the level sequence. The violation
is always at the point where level skips more than one (e.g., `##` to
`####`). Insert or promote the missing intermediate heading.

### MD022 — Blank line around heading still failing

Look for headings at the very start of the file (no blank line before is
allowed), headings immediately after another heading (blank line required),
and headings at the end of the file before the trailing newline.

### MD031 — Blank line around code block still failing

Check for code blocks at the very start of a list item. The blank line rule
still applies; add the blank line before the opening fence even inside lists.

### MD032 — Blank line around list still failing

Nested lists within a list item do not need surrounding blank lines.
The rule applies to the top-level list block relative to surrounding prose
or other blocks.

### MD034 — Bare URL

Find `https://` or `http://` not wrapped in `<>` or `[]()`. Replace with:

- `<https://example.com>` for standalone URLs
- `[descriptive text](https://example.com)` for links with labels

### MD040 — Fenced block language still failing

Check that the language tag appears on the same line as the opening fence
with no space between the backticks and the tag:

````text
```bash
code here
```
````

Not:

````text
``` bash
code here
```
````

### MD041 — First line not top-level heading

If the file has YAML frontmatter (`---` block), the first heading after
the frontmatter satisfies MD041. If there is no frontmatter and the first
line is not `#`, add the title heading as line 1.

### MD047 — File does not end with single newline

The file must end with exactly one newline character. Ensure there is no
blank line at the end of the file (that would be two newlines) and no
missing newline (zero newlines). Most editors add this automatically;
verify with `cat -A file.md` (the last visible character should be `$`
on its own line representing the newline).

### MD051 — Invalid link fragment

The fragment `#heading-text` must match the slug of a real heading.
Heading slugs are lowercase, spaces replaced with `-`, and most
punctuation removed. Verify by listing all headings in the file and
constructing their slugs manually.

### MD055 / MD056 — Table pipe or column count issues

Rebuild the table from scratch if pipe alignment is severely broken:

1. List every column name and maximum content width.
1. Write the header row with leading and trailing pipes.
1. Write the separator row (`| --- | --- |`) matching column count.
1. Write every data row with the same column count.

### MD058 — Blank line around table still failing

Tables inside list items still require blank lines. If a table is inside
a list, the table itself must be preceded and followed by blank lines even
within the list indentation.

## Avoiding Regressions

When fixing one rule violation, check that the fix does not introduce
another:

- Adding blank lines around headings (MD022) can trigger MD012 if it
  creates two consecutive blank lines.
- Wrapping long lines can break table formatting (check MD055/MD056).
- Converting setext headings to ATX (MD003) — verify the blank lines are
  still present (MD022).

After each fix batch, run lint on all changed files, not just the file
you are currently editing.

## Escalation

If a rule failure persists after three fix attempts:

1. Quote the exact lint output line.
1. Show the exact markdown lines involved.
1. Ask the user whether to suppress the rule in config or restructure
   the content to comply.

Do not silently add lint-disable comments or suppress rules in the config
without user approval.
