# Markdownlint Rules Reference

## Contents

- [Document Structure](#document-structure)
- [Heading Formatting](#heading-formatting)
- [Lists](#lists)
- [Code Blocks](#code-blocks)
- [Inline Formatting](#inline-formatting)
- [Links and Images](#links-and-images)
- [Blockquotes](#blockquotes)
- [Tables](#tables)
- [Miscellaneous](#miscellaneous)

---

This file covers every rule relevant to producing clean markdown. Rules are
grouped by category. The default config enables all rules; deviations are noted
where the project config overrides a default.

## Document Structure

### MD001 — Heading levels increment by one

Headings must step down one level at a time. Skipping from `##` to `####` is
a violation.

```markdown
<!-- bad -->
# Title
### Section

<!-- good -->
# Title
## Section
### Subsection
```

### MD003 — Heading style

Use ATX-style headings (`#` prefix) exclusively. Never use setext-style
underlines (`===` or `---`).

```markdown
<!-- bad -->
Title
=====

Section
-------

<!-- good -->
# Title

## Section
```

### MD025 — Single top-level heading

Each file must have exactly one `#` heading. Use it as the document title only.

### MD041 — First line is top-level heading

The first non-blank, non-frontmatter line of every file must be a `#` heading.
YAML frontmatter (`---` block) does not count as the first line.

## Heading Formatting

### MD018 — Space after hash (ATX)

One space is required after the `#` characters.

```markdown
<!-- bad -->
#Title

<!-- good -->
# Title
```

### MD019 — No multiple spaces after hash

Only one space after the `#` characters.

### MD022 — Blank lines around headings

Every heading must be preceded and followed by a blank line, except at the
very start of the file.

```markdown
<!-- bad -->
Some paragraph.
## Heading
Next paragraph.

<!-- good -->
Some paragraph.

## Heading

Next paragraph.
```

### MD023 — Headings start at line beginning

No leading spaces before `#`.

### MD024 — No duplicate headings (siblings only)

With `siblings_only: true` (project default), duplicate heading text is
allowed across different parent sections but not within the same parent.

### MD026 — No trailing punctuation in headings

Headings must not end with `.`, `!`, `?`, `:`, or `,`.

```markdown
<!-- bad -->
## Installation:

<!-- good -->
## Installation
```

## Lists

### MD004 — Unordered list marker style

Use `-` as the unordered list marker consistently throughout the document.

```markdown
<!-- bad -->
* Item one
+ Item two

<!-- good -->
- Item one
- Item two
```

### MD005 — Consistent list indentation at same level

Items at the same nesting level must use the same indentation.

### MD007 — Unordered list indentation

The project config sets `indent: 2`. Use exactly two spaces per nesting level.

```markdown
- Top level
  - Second level
    - Third level
```

### MD029 — Ordered list prefix

Use `1.` for every ordered list item (lazy numbering). The renderer handles
actual numbering.

```markdown
1. First item
1. Second item
1. Third item
```

### MD030 — Spaces after list markers

Use exactly one space after `-`, `*`, `+`, or `1.`.

### MD032 — Blank lines around lists

Every list block must be preceded and followed by a blank line.

```markdown
Paragraph before.

- Item one
- Item two

Paragraph after.
```

## Code Blocks

### MD031 — Blank lines around fenced code blocks

Every fenced code block must be preceded and followed by a blank line. A
paragraph of prose immediately above or below the opening or closing fence
line is a violation. Always leave one blank line between prose and a fence.

### MD040 — Fenced code block language

Every fenced code block must declare a language identifier immediately after
the opening backticks with no space between them. Use `text` for plain
output with no syntax. A fence opened with just ` ``` ` and no language tag
is always a violation.

### MD046 — Code block style

Use fenced code blocks (triple backtick) exclusively. Do not use
four-space-indented code blocks.

### MD048 — Code fence character

Use backticks (`` ` ``) for all fences. Do not use tildes (`~`).

## Inline Formatting

### MD009 — No trailing spaces

No line may end with trailing whitespace. The one exception: two trailing
spaces create a hard line break (`<br>`), but use the `<br>` HTML element
instead (which is allowed by the project config).

### MD010 — No hard tabs

Use spaces everywhere. Hard tab characters (`\t`) are never permitted.

### MD036 — Emphasis is not a heading

Do not use `**bold**` or `*italic*` alone on a line as a substitute for a
heading. Use a proper heading instead.

```markdown
<!-- bad -->
**Installation**

Do the thing.

<!-- good -->
## Installation

Do the thing.
```

### MD037 — No spaces inside emphasis markers

```markdown
<!-- bad -->
* emphasized text *

<!-- good -->
*emphasized text*
```

### MD038 — No spaces inside code spans

```markdown
<!-- bad -->
` code `

<!-- good -->
`code`
```

### MD049 — Emphasis style

Use `*` for emphasis (italic), not `_`.

### MD050 — Strong style

Use `**` for strong (bold), not `__`.

## Links and Images

### MD011 — No reversed link syntax

```markdown
<!-- bad -->
(text)[url]

<!-- good -->
[text](url)
```

### MD034 — No bare URLs

Wrap all URLs in angle brackets or use link syntax.

```markdown
<!-- bad -->
See https://example.com for details.

<!-- good -->
See <https://example.com> for details.

<!-- also good -->
See [the docs](https://example.com) for details.
```

### MD039 — No spaces inside link text

```markdown
<!-- bad -->
[ link text ](url)

<!-- good -->
[link text](url)
```

### MD042 — No empty links

Links must have an `href` that is not empty.

### MD045 — Images must have alt text

```markdown
<!-- bad -->
![]( image.png)

<!-- good -->
![Screenshot of the login page](image.png)
```

### MD051 — Valid link fragments

`#fragment` links must match an existing heading slug in the file.

### MD052 — Defined reference labels

Every `[text][label]` reference must have a matching `[label]: url`
definition.

### MD053 — No unused reference definitions

Every `[label]: url` definition must be referenced at least once.

## Blockquotes

### MD027 — One space after blockquote marker

```markdown
<!-- bad -->
>  Extra space.

<!-- good -->
> Normal space.
```

### MD028 — No blank line inside blockquote

Blank lines within a blockquote break it into separate blockquotes. Avoid
them unless intentional.

## Tables

### MD055 — Table pipe style

Use leading and trailing pipes on every table row.

```markdown
| Column A | Column B |
| -------- | -------- |
| value    | value    |
```

### MD056 — Consistent column count

Every row in a table must have the same number of columns.

### MD058 — Blank lines around tables

Every table must be preceded and followed by a blank line.

## Miscellaneous

### MD012 — No multiple consecutive blank lines

At most one blank line between paragraphs or blocks.

### MD013 — Line length

**Disabled in project config.** No line-length limit is enforced.

### MD033 — Inline HTML

Only `<br>` and `<div>` are allowed (project config). All other HTML tags
are violations.

### MD035 — Horizontal rule style

Use `---` for horizontal rules. Do not use `***` or `___`.

### MD047 — File ends with single newline

Every file must end with exactly one newline character. No trailing blank
lines.
