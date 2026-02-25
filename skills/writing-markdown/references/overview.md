# Overview

## Overview


All markdown documents MUST pass markdownlint with zero errors.
This is non-negotiable. Every `.md` file you write or edit must
strictly adhere to all markdownlint rules (MD001-MD060).

## When to Use


- Writing any new `.md` file
- Editing existing markdown content
- Creating READMEs, documentation, guides, changelogs
- Writing markdown content in any context

## Critical Rules (Most Commonly Violated)


### MD013: Line Length (max 80 characters)

This is the #1 violation. **Wrap all prose at 80 characters.**

- Count characters per line including spaces
- Break long sentences across multiple lines
- URLs on their own line if they push past 80 chars
- Table rows: abbreviate or restructure if over 80 chars
- Headings: keep concise (under 80 chars)
- Exceptions: code blocks, tables (only when unavoidable)

```markdown
<!-- BAD: 120+ characters on one line -->
Docker is a powerful platform for developing,
shipping, and running applications in containers
that ensures consistency.

<!-- GOOD: wrapped at 80 characters -->
Docker is a powerful platform for developing, shipping,
and running applications in containers that ensures
consistency.
```

### MD060: Table Column Style and MD013 in Tables

Tables are the #2 source of violations. Rules:

- **Max 2 columns** unless you can fit 3 in 80 chars
- Every row (including separator) must be under 80 chars
- All pipes in a column MUST align vertically
- Use padded style with spaces after/before pipes
- If a table exceeds 80 chars, convert to a list
- **Each column width must equal the width of its widest
  cell** — pad all shorter cells with trailing spaces
- **Separator dashes must span the full column width** —
  count the widest cell and use exactly that many dashes

```markdown
<!-- BAD: unequal column widths, ragged separators -->
| Command | Description |
| --- | --- |
| docker pull | Download an image from a registry |
| docker run | Create and start a container |

<!-- GOOD: each column padded to its widest cell -->
| Command      | Description                       |
| ------------ | --------------------------------- |
| docker pull  | Download an image from a registry |
| docker run   | Create and start a container      |

<!-- GOOD: list instead of wide table -->
- `docker pull`: Download an image from a registry
- `docker run`: Create and start a container
```

**How to calculate column widths:**

1. Find the longest cell in each column (including header)
2. Pad every other cell in that column with trailing spaces
   to match that length
3. Set separator dashes to exactly that length

### MD022: Blank Lines Around Headings

Always put a blank line before and after every heading.

### MD031: Blank Lines Around Fenced Code Blocks

Always put a blank line before and after code fences.

### MD032: Blank Lines Around Lists

Always put a blank line before and after lists.

### MD058: Blank Lines Around Tables

Always put a blank line before and after tables.

## Line Length Strategy


This is the hardest rule to follow. Use this approach:

1. **Prose paragraphs**: Hard-wrap at 80 characters.
   Break at natural sentence or clause boundaries.
2. **Links**: If a link pushes past 80 chars, use
   reference-style links at the bottom of the section.
3. **Tables**: Limit to 2 columns. Count the total
   row width including pipes and padding. If any row
   exceeds 80 chars, use a definition list instead.
4. **Headings**: Keep under 80 chars. Rephrase if needed.
5. **Code blocks**: Content inside fenced code blocks
   is exempt from MD013 by default, but keep readable.
6. **Blockquotes**: Wrap quoted text at ~76 chars
   (accounting for the `>` prefix).

### Reference-Style Links (for long URLs)

```markdown
<!-- Inline link pushes past 80 chars -->
See the [Docker documentation](https://docs.docker.com/engine/reference/commandline/run/)

<!-- Reference-style keeps lines short -->
See the [Docker documentation][docker-run]

[docker-run]: https://docs.docker.com/engine/reference/commandline/run/
```

## Verification


After writing any markdown file, mentally verify:

1. No line exceeds 80 characters
2. Blank lines surround all headings, code blocks,
   lists, and tables
3. All code fences specify a language
4. Heading hierarchy is sequential (no skipping levels)
5. Only one H1 exists
6. File ends with exactly one newline
7. No trailing spaces on any line
8. All images have alt text
9. All links have descriptive text
10. Consistent markers: `-` for lists, `*` for emphasis
11. Every table column is padded to equal width; separator
    dashes match the widest cell in each column

