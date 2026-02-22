# Writing EditorConfig: Full Reference

## Contents

- What EditorConfig Is
- File Discovery and Hierarchy
- File Format Rules
- Glob Pattern Syntax
- Universal Properties
- Extended Properties
- Language-Specific Conventions
- Validation

---

## What EditorConfig Is

EditorConfig defines coding style through a plain-text `.editorconfig` file
that editors read natively. No build step or external tool is required.
Support is built into VS Code, JetBrains IDEs, Vim, Neovim, Emacs, Sublime
Text, and many others. Plugins exist for the rest.

EditorConfig enforces whitespace and encoding rules at the editor level. It
does not replace formatters (Prettier, Black, gofmt) — it operates upstream
of them, ensuring files are saved correctly before formatting runs.

---

## File Discovery and Hierarchy

When a file is opened, the editor searches for `.editorconfig` files starting
in the file's own directory and walking up through every parent directory.
The search stops when either:

- The filesystem root is reached, or
- A `.editorconfig` file containing `root = true` is found.

Rules from all discovered files are merged. Closer files take precedence.
Within a single file, later sections take precedence over earlier ones.

**Practical rule:** Always set `root = true` at the top of the
repository-level `.editorconfig`. Omitting it causes editors to merge in
settings from parent directories (home directory, system root), producing
unpredictable results.

---

## File Format Rules

- Encoding: UTF-8 (no BOM)
- Line endings: LF or CRLF (LF preferred)
- Comments: `#` or `;` at the start of a line — never inline
- Key-value separator: `=`, with optional surrounding spaces
- All property names and values are case-insensitive and lowercased on parse
- `root = true` must appear before any section header

```ini
# This is a comment
root = true

[*]
indent_style = space
indent_size = 2
```

---

## Glob Pattern Syntax

Section headers are filepath globs. The following special characters apply:

| Pattern       | Matches                                                   |
| ------------- | --------------------------------------------------------- |
| `*`           | Any string of characters except `/`                       |
| `**`          | Any string including `/` (matches across directories)     |
| `?`           | Any single character except `/`                           |
| `[abc]`       | Any character in the set                                  |
| `[!abc]`      | Any character NOT in the set                              |
| `{s1,s2}`     | Any of the comma-separated strings                        |
| `{num1..num2}`| Any integer in the inclusive range                        |

**Key behaviors:**

- Globs are matched against the full path of the file relative to the
  `.editorconfig` file's location.
- A glob containing `/` is anchored to the `.editorconfig`'s directory.
- A glob without `/` (e.g., `*.py`) matches files in all subdirectories.
- Escape special characters with `\`.

---

## Universal Properties

These properties are supported by all compliant EditorConfig plugins.

### `indent_style`

Controls whether indentation uses tabs or spaces.

```ini
indent_style = tab    # hard tabs
indent_style = space  # soft tabs (spaces)
```

### `indent_size`

Number of columns per indentation level. When `indent_style = tab`, this
also sets the visual width of tabs in editors that honor it.

```ini
indent_size = 2
indent_size = 4
```

### `tab_width`

Visual width of a tab character. Defaults to `indent_size` when not set.
**Only specify this when it must differ from `indent_size`.**

```ini
tab_width = 8
```

### `end_of_line`

Line ending format.

```ini
end_of_line = lf    # Unix/macOS (recommended for cross-platform projects)
end_of_line = crlf  # Windows
end_of_line = cr    # legacy Mac (rare)
```

### `charset`

File character encoding.

```ini
charset = utf-8        # default, recommended
charset = utf-8-bom    # UTF-8 with BOM (avoid unless required)
charset = latin1
charset = utf-16be
charset = utf-16le
```

### `trim_trailing_whitespace`

Removes whitespace characters before line endings on save.

```ini
trim_trailing_whitespace = true   # recommended for most files
trim_trailing_whitespace = false  # required for Markdown (trailing spaces = line break)
```

### `insert_final_newline`

Ensures the file ends with a newline character.

```ini
insert_final_newline = true   # recommended — POSIX compliance, clean diffs
insert_final_newline = false
```

### `max_line_length`

Soft limit for line length. Not universally enforced by all plugins — some
only report violations rather than wrap lines.

```ini
max_line_length = 80
max_line_length = 120
max_line_length = off  # no limit
```

### `unset`

Removes a property inherited from a parent `.editorconfig` or earlier section.

```ini
[*.generated]
indent_size = unset
```

---

## Language-Specific Conventions

These are widely-adopted conventions. Override them when a project has an
established style that differs.

| Language / File type    | `indent_style` | `indent_size` | Notes                              |
| ----------------------- | -------------- | ------------- | ---------------------------------- |
| Python                  | space          | 4             | PEP 8                              |
| JavaScript / TypeScript | space          | 2             | Airbnb, Standard, Google styles    |
| HTML                    | space          | 2             |                                    |
| CSS / SCSS / Less       | space          | 2             |                                    |
| JSON                    | space          | 2             |                                    |
| YAML                    | space          | 2             | Spec prohibits tabs                |
| TOML                    | space          | 2             |                                    |
| Markdown                | space          | 2             | `trim_trailing_whitespace = false` |
| Go                      | tab            | (unset)       | `gofmt` enforces tabs              |
| Rust                    | space          | 4             | `rustfmt` default                  |
| Ruby                    | space          | 2             |                                    |
| Shell / Bash            | space          | 2             |                                    |
| Makefile                | tab            | (unset)       | **tabs are required by make**      |
| C / C++                 | space          | 4             | varies by project                  |
| Java                    | space          | 4             |                                    |
| Kotlin                  | space          | 4             |                                    |
| PHP                     | space          | 4             | PSR-2/PSR-12                       |
| Terraform / HCL         | space          | 2             |                                    |
| XML                     | space          | 2             |                                    |

**YAML note:** The YAML specification prohibits tab characters for
indentation. Always use `indent_style = space` for YAML files.

**Makefile note:** GNU make requires tab characters to introduce recipe
lines. `indent_style = tab` is mandatory and cannot be overridden.

---

## Validation

The `editorconfig` CLI (from `editorconfig-core-c` or the Python/Node
implementations) shows what properties apply to a given file:

```sh
# Install
brew install editorconfig          # macOS
pip install editorconfig           # Python
npm install -g editorconfig        # Node.js

# Query properties for a file
editorconfig path/to/file.py

# Query multiple files
editorconfig src/main.py src/main.go
```

The output lists every effective property for the file, showing which
section in which `.editorconfig` file applied each rule.
