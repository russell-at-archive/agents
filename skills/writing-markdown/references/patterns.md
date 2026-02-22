# Markdown Writing Patterns

## Contents

- [File Skeleton](#file-skeleton)
- [README Pattern](#readme-pattern)
- [Ordered Lists](#ordered-lists)
- [Nested Lists](#nested-lists)
- [Code Blocks — Always Use a Language](#code-blocks--always-use-a-language)
- [Inline Code](#inline-code)
- [Links](#links)
- [Reference-Style Links](#reference-style-links)
- [Images](#images)
- [Tables](#tables)
- [Blockquotes](#blockquotes)
- [Horizontal Rules](#horizontal-rules)
- [YAML Frontmatter](#yaml-frontmatter)
- [Emphasis](#emphasis)
- [Admonitions](#admonitions-no-native-support)
- [Escaping Special Characters](#escaping-special-characters)
- [Long Prose Lines](#long-prose-lines)

---

Concrete, copy-ready patterns for common markdown constructs. Every example
here is lint-clean against the project default config.

## File Skeleton

Every markdown file must follow this basic shape:

```markdown
# Document Title

One or two sentences describing the purpose of this document.

## First Section

Content here.

## Second Section

Content here.
```

Rules satisfied: MD041 (first line is `#`), MD025 (single `#`), MD022 (blank
lines around headings), MD047 (trailing newline).

## README Pattern

A standard README uses this section order: title, short description,
requirements, installation, usage, configuration, and contributing. Each
section is an `##` heading. The title is the single `#` heading (MD025).

Installation and usage sections contain `bash` fenced code blocks showing
the exact commands a user runs. Configuration sections use a table with
columns for key name, default value, and description. Contributing sections
link to `CONTRIBUTING.md` using a relative link.

## Ordered Lists

Use `1.` for every item. Do not manually number items.

```markdown
1. Clone the repository.
1. Install dependencies.
1. Run the tests.
1. Open a pull request.
```

## Nested Lists

Indent two spaces per level. Mix ordered and unordered only when semantics
require it.

```markdown
- Category one
  - Sub-item A
  - Sub-item B
    - Deeper item
- Category two
  1. Ordered sub-step
  1. Another sub-step
```

## Code Blocks — Always Use a Language

Every fenced block needs a language tag. When in doubt:

| Content type             | Tag        |
| ------------------------ | ---------- |
| Shell commands           | `bash`     |
| Shell session with `$`   | `bash`     |
| Terminal output (no cmd) | `text`     |
| JSON data                | `json`     |
| YAML config              | `yaml`     |
| TypeScript               | `ts`       |
| JavaScript               | `js`       |
| Python                   | `python`   |
| Go                       | `go`       |
| Markdown source          | `markdown` |

```bash
echo "shell command example"
```

```text
This is raw output with no syntax.
```

```json
{
  "key": "value"
}
```

## Inline Code

Use backticks for all technical tokens: file names, command names, flag names,
environment variable names, and type names.

```markdown
Run `make build` to compile the project.
Set `NODE_ENV=production` before deploying.
The function returns a `Promise<void>`.
```

## Links

Always use descriptive link text. Never use bare URLs.

```markdown
<!-- good: descriptive text -->
See the [installation guide](docs/install.md) for details.

<!-- good: angle brackets for standalone URLs -->
The canonical source is <https://example.com>.

<!-- bad: bare URL -->
See https://example.com.

<!-- bad: non-descriptive text -->
Click [here](docs/install.md).
```

## Reference-Style Links

Use reference links when a URL is long or used more than once.

```markdown
See the [markdownlint rules][ml-rules] for the full list.

The [CLI documentation][ml-cli] covers installation.

[ml-rules]: https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md
[ml-cli]: https://github.com/igorshubovych/markdownlint-cli2
```

## Images

Always include meaningful alt text. Never leave the brackets empty.

```markdown
<!-- bad -->
![]( diagram.png)

<!-- good -->
![Architecture diagram showing three microservices](diagram.png)

<!-- good: with title -->
![Build status badge](https://ci.example.com/badge.svg "CI build status")
```

## Tables

Tables require: leading and trailing pipes, blank lines before and after, and
consistent column counts in every row.

```markdown
Paragraph before the table.

| Name    | Type     | Required | Description            |
| ------- | -------- | -------- | ---------------------- |
| `id`    | `string` | Yes      | Unique identifier.     |
| `limit` | `number` | No       | Max results. Default 10. |

Paragraph after the table.
```

Column alignment markers are optional but may help readability:

```markdown
| Left align | Center align | Right align |
| :--------- | :----------: | ----------: |
| text       |     text     |        text |
```

## Blockquotes

```markdown
> This is a blockquote. It can span multiple lines within the same block
> by prefixing each line with `>`.
>
> Start a new paragraph inside the blockquote by adding a `>` on the blank
> line.
```

Do not put blank lines without the `>` prefix inside a blockquote.

## Horizontal Rules

Use `---` only. Three hyphens, nothing else.

```markdown
Previous section content.

---

Next section content.
```

## YAML Frontmatter

Frontmatter is allowed at the top of the file before the `#` heading.
MD041 treats the first heading after frontmatter as the first line.

```markdown
---
title: My Document
date: 2026-03-09
---

# My Document

Content starts here.
```

## Emphasis

Use `*` for italic, `**` for bold. Do not use underscores.

```markdown
<!-- good -->
This is *important* and this is **critical**.

<!-- bad -->
This is _important_ and this is __critical__.
```

## Admonitions (No Native Support)

Markdown has no native admonition syntax. Use blockquotes with a bold label:

```markdown
> **Note:** This behavior changed in version 2.0.

> **Warning:** Running this command will delete all local data.
```

## Escaping Special Characters

Use backslash escapes when you need literal markdown characters in prose.

```markdown
Use \`backticks\` around code.
The price is \$10.
```

## Long Prose Lines

Line length is disabled in the project config (MD013 false). You may write
prose at any line length. However, keeping lines under 120 characters
improves diff readability. Wrap at natural sentence or clause boundaries.
