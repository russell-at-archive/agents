# Writing EditorConfig: Examples

## Contents

- Minimal single-language project
- Polyglot web project
- Go project
- Python project
- Infrastructure / DevOps project
- Monorepo with subdirectory overrides
- Using `unset` to clear inherited properties

---

## Minimal Single-Language Project

A JavaScript project with a single language and no exceptions.

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
indent_size = 2
indent_style = space
insert_final_newline = true
trim_trailing_whitespace = true

[*.md]
trim_trailing_whitespace = false
```

---

## Polyglot Web Project

A project with JavaScript, Python, YAML, and Markdown.

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
indent_size = 2
indent_style = space
insert_final_newline = true
trim_trailing_whitespace = true

[*.py]
indent_size = 4

[*.{yaml,yml}]
indent_size = 2

[*.md]
trim_trailing_whitespace = false

[Makefile]
indent_style = tab
```

---

## Go Project

Go uses tabs enforced by `gofmt`. Leave `indent_size` unset so each
developer can set their preferred visual width in their editor.

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

[*.go]
indent_style = tab

[*.{yaml,yml,json,toml}]
indent_style = space
indent_size = 2

[*.md]
indent_style = space
indent_size = 2
trim_trailing_whitespace = false

[Makefile]
indent_style = tab
```

---

## Python Project

A pure Python project following PEP 8.

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
indent_size = 4
indent_style = space
insert_final_newline = true
trim_trailing_whitespace = true

[*.{yaml,yml,toml,json}]
indent_size = 2

[*.md]
trim_trailing_whitespace = false

[Makefile]
indent_style = tab
```

---

## Infrastructure / DevOps Project

A Terraform + Helm + Kubernetes project. YAML is central; tabs are
forbidden by YAML spec.

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
indent_size = 2
indent_style = space
insert_final_newline = true
trim_trailing_whitespace = true

[*.{yaml,yml}]
indent_size = 2

[*.tf]
indent_size = 2

[*.json]
indent_size = 2

[*.md]
trim_trailing_whitespace = false

[Makefile]
indent_style = tab
```

---

## Monorepo with Subdirectory Overrides

A monorepo where the `legacy/` subtree uses a different style. Sections
with `/` in the glob are anchored to the `.editorconfig` file's location.

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
indent_size = 2
indent_style = space
insert_final_newline = true
trim_trailing_whitespace = true

[*.md]
trim_trailing_whitespace = false

[Makefile]
indent_style = tab

# Legacy subtree uses 4-space indentation
[legacy/**/*.{js,ts}]
indent_size = 4

# Generated files — do not enforce style
[*.{min.js,min.css}]
indent_size = unset
indent_style = unset
trim_trailing_whitespace = unset
insert_final_newline = unset
```

---

## Using `unset` to Clear Inherited Properties

When a subdirectory has a second `.editorconfig` that needs to override
and remove rules set by the parent, use `unset`.

Parent `/.editorconfig`:

```ini
root = true

[*]
indent_style = space
indent_size = 2
max_line_length = 80
```

Child `/vendor/.editorconfig` (no `root = true` — merges with parent,
then overrides):

```ini
[*]
indent_size = unset
max_line_length = unset
```

Result for files in `/vendor/`: `indent_style = space` (inherited),
`indent_size` and `max_line_length` are cleared.
