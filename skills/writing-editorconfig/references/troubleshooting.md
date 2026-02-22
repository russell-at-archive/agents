# Writing EditorConfig: Troubleshooting

## Contents

- Common mistakes
- Anti-patterns
- Edge cases
- Recovery paths

---

## Common Mistakes

### Missing `root = true`

**Symptom:** Editor applies unexpected styles that don't match the
`.editorconfig` in the repository.

**Cause:** Without `root = true`, the editor continues searching parent
directories and merges in settings from `~/.editorconfig` or other ancestor
files.

**Fix:** Add `root = true` as the very first line of the file, before any
section header.

```ini
root = true   # must be first

[*]
...
```

---

### `trim_trailing_whitespace = true` on Markdown

**Symptom:** Markdown line breaks stop working. Two trailing spaces before
a newline (a hard line break in Markdown) are stripped on save.

**Cause:** The `[*]` catch-all section sets `trim_trailing_whitespace = true`
and there is no `[*.md]` override.

**Fix:** Add an explicit Markdown override:

```ini
[*.md]
trim_trailing_whitespace = false
```

---

### Tabs in YAML files

**Symptom:** YAML parsers reject the file with a parse error referencing
tab characters.

**Cause:** The YAML 1.2 specification forbids tab characters as indentation.
If `[*]` sets `indent_style = tab`, YAML files inherit it.

**Fix:** Add a YAML-specific section:

```ini
[*.{yaml,yml}]
indent_style = space
indent_size = 2
```

---

### Spaces in Makefiles

**Symptom:** `make` exits with "missing separator" or "*** missing separator.
Stop."

**Cause:** GNU make requires literal tab characters before recipe lines.
If `[*]` sets `indent_style = space`, Makefiles inherit it.

**Fix:** Add a Makefile-specific section:

```ini
[Makefile]
indent_style = tab
```

---

### `tab_width` equals `indent_size` (redundant)

**Symptom:** No functional problem, but the file is noisier than necessary.

**Cause:** `tab_width` defaults to `indent_size` when not set. Repeating
the same value adds no information.

**Fix:** Remove `tab_width` unless it must differ from `indent_size`.

---

### Inline comments

**Symptom:** Editor plugin misparses the line or ignores the property.

**Cause:** The EditorConfig format does not support inline comments. A `#`
after a value is treated as part of the value, not a comment.

**Bad:**

```ini
indent_size = 2  # 2 spaces
```

**Fix:** Move comments to their own line:

```ini
# 2 spaces
indent_size = 2
```

---

## Anti-Patterns

### Setting every property in every section

Repeating all properties in every language section makes the file hard to
maintain. Use a `[*]` baseline and override only what differs.

**Bad:**

```ini
[*.js]
charset = utf-8
end_of_line = lf
indent_style = space
indent_size = 2
insert_final_newline = true
trim_trailing_whitespace = true

[*.py]
charset = utf-8
end_of_line = lf
indent_style = space
indent_size = 4
insert_final_newline = true
trim_trailing_whitespace = true
```

**Good:**

```ini
[*]
charset = utf-8
end_of_line = lf
indent_style = space
indent_size = 2
insert_final_newline = true
trim_trailing_whitespace = true

[*.py]
indent_size = 4
```

---

### Using backslashes in glob paths

**Symptom:** Section does not match any files on Unix/macOS.

**Cause:** EditorConfig uses forward slashes as path separators on all
platforms, including Windows.

**Bad:**

```ini
[src\*.js]
```

**Good:**

```ini
[src/*.js]
```

---

### Setting `indent_size` without `indent_style`

**Symptom:** `indent_size` has no effect because the editor does not know
whether to use tabs or spaces.

**Fix:** Always pair `indent_size` with `indent_style = space` in the same
section (or ensure it is set in an ancestor section).

---

## Edge Cases

### Generated or minified files

Minified files (`.min.js`, `.min.css`) should not have style enforced.
Use `unset` to opt them out:

```ini
[*.{min.js,min.css}]
indent_style = unset
indent_size = unset
trim_trailing_whitespace = unset
insert_final_newline = unset
```

---

### Binary files and lock files

EditorConfig can interfere with binary files or lock files by appending a
final newline or stripping whitespace. Exclude them explicitly:

```ini
[*.{png,jpg,gif,ico,svg,woff,woff2,ttf,eot}]
insert_final_newline = unset
trim_trailing_whitespace = unset

[package-lock.json]
insert_final_newline = unset
```

---

### Multiple `.editorconfig` files in a repo

When a subdirectory has its own `.editorconfig` (without `root = true`),
its rules merge with the parent. Closer rules win on conflict. This is
intentional for monorepos that need per-package overrides.

To verify which rules apply to a specific file, use the CLI:

```sh
editorconfig path/to/the/file.py
```

---

## Recovery Paths

### Editor ignores `.editorconfig`

1. Confirm the editor has EditorConfig support. VS Code, JetBrains IDEs,
   Neovim with a plugin, and others support it natively.
2. For editors without native support, install the EditorConfig plugin for
   that editor (see editorconfig.org).
3. Verify the `.editorconfig` file is named exactly `.editorconfig` (leading
   dot, all lowercase).
4. Reload the editor after adding or changing `.editorconfig`.

### Rule applies to wrong files

Use the `editorconfig` CLI to inspect effective rules:

```sh
editorconfig src/index.js
editorconfig Makefile
```

If the output is wrong, check that your glob does not contain backslashes,
that sections with `/` in the glob are correctly anchored, and that later
sections are not overriding earlier ones unintentionally.
