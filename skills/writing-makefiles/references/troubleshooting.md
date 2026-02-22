# Writing Makefiles: Troubleshooting

## Contents

- [Missing Separator Error](#missing-separator-error)
- [Shell Variable Escaping](#shell-variable-escaping)
- [Target Always Rebuilds](#target-always-rebuilds)
- [Recursive Variable Loops](#recursive-variable-loops)
- [Multiline Recipes Fail Silently](#multiline-recipes-fail-silently)
- [Parallel Build Races](#parallel-build-races)
- [Directory Not Created in Time](#directory-not-created-in-time)
- [Variables Expand Empty](#variables-expand-empty)
- [Pattern Rule Not Matched](#pattern-rule-not-matched)
- [Implicit Rules Interfere](#implicit-rules-interfere)
- [make sub-invocation Misses Flags](#make-sub-invocation-misses-flags)
- [Anti-Patterns Quick Reference](#anti-patterns-quick-reference)

---

## Missing Separator Error

**Error:**

```text
Makefile:5: *** missing separator.  Stop.
```

**Cause:** Recipe line is indented with spaces, not a TAB.

**Fix:** Convert the leading spaces to a single TAB character. In most editors:

- vim: `:set list` to see whitespace; replace spaces with `<Tab>`
- VS Code: click the indentation indicator in the status bar → "Convert Indentation
  to Tabs"
- `cat -A Makefile | grep '^  '` shows lines starting with spaces (should be `^I`)

**Verification:**

```bash
make -n target   # dry-run; stops at the bad line
cat -A Makefile  # ^I = TAB, spaces show as spaces
```

---

## Shell Variable Escaping

**Problem:** Shell variable `$var` is silently expanded to empty by make before
the shell sees the recipe.

**Wrong:**

```makefile
list:
	for f in *.txt; do echo $f; done
```

**Correct:**

```makefile
list:
	for f in *.txt; do echo $$f; done
```

**Rule:** Inside recipes, `$` is consumed by make. Use `$$` to pass a literal
`$` to the shell. This applies to `$()`, `${}`, `$$`, and all shell variable
references.

**Debugging:** Run `make -n target` to see the expanded recipe before execution.

---

## Target Always Rebuilds

**Scenario 1 — Phony target not declared:**

```makefile
# Bad: if a file named "clean" exists, this never runs
clean:
	rm -rf build/

# Fix:
.PHONY: clean
clean:
	rm -rf build/
```

**Scenario 2 — Target file is never created:**

```makefile
# Bad: recipe runs but never creates "build/app"
build/app: src/main.c
	gcc src/main.c   # forgot -o $@

# Fix:
build/app: src/main.c
	gcc $< -o $@
```

**Scenario 3 — Prerequisite is always newer:**

If a prerequisite is itself a `.PHONY` target, any target depending on it
will also always rebuild. Trace the dependency chain.

---

## Recursive Variable Loops

**Problem:** A recursive `=` variable references itself, causing infinite expansion.

**Wrong:**

```makefile
CFLAGS = $(CFLAGS) -Wall   # infinite loop
```

**Correct:**

```makefile
CFLAGS := -Wall            # initialize with :=
CFLAGS += -Wextra          # then append
```

Or use a different name for the base value:

```makefile
BASE_CFLAGS := -std=c11
CFLAGS = $(BASE_CFLAGS) -Wall
```

**Detection:** `make` will print `Recursive variable 'CFLAGS' references itself`
and abort.

---

## Multiline Recipes Fail Silently

**Problem:** Each recipe line runs in its own subshell. A `cd` in one line has
no effect on the next.

**Wrong:**

```makefile
deploy:
	cd infra/
	terraform apply     # runs in the original directory, not infra/
```

**Fix — chain with `&&`:**

```makefile
deploy:
	cd infra/ && terraform apply
```

**Fix — use backslash continuation:**

```makefile
deploy:
	cd infra/ && \
	terraform init && \
	terraform apply
```

**Fix — use `.ONESHELL:` (GNU make 3.82+):**

```makefile
.ONESHELL:
deploy:
	cd infra/
	terraform init
	terraform apply
```

Note: `.ONESHELL:` applies to the entire Makefile. Recipe modifier prefixes
(`@`, `-`) only apply to the first line when `.ONESHELL:` is active.

---

## Parallel Build Races

**Problem:** `make -j4` runs independent targets concurrently. Two targets that
both create the same directory or write the same file may race.

**Wrong:**

```makefile
build/foo.o: src/foo.c
	mkdir -p build/ && $(CC) -c $< -o $@

build/bar.o: src/bar.c
	mkdir -p build/ && $(CC) -c $< -o $@
```

**Fix — use an order-only prerequisite for the directory:**

```makefile
build/:
	mkdir -p $@

build/foo.o: src/foo.c | build/
	$(CC) -c $< -o $@

build/bar.o: src/bar.c | build/
	$(CC) -c $< -o $@
```

`build/foo.o` and `build/bar.o` can still run in parallel; `build/` is
guaranteed to exist before either starts.

---

## Directory Not Created in Time

**Problem:** Recipe fails because the output directory does not exist yet.

**Wrong:**

```makefile
build/app: $(OBJECTS)
	$(CC) $^ -o $@   # fails if build/ doesn't exist
```

**Fix — order-only prerequisite:**

```makefile
$(BUILD_DIR):
	mkdir -p $@

build/app: $(OBJECTS) | $(BUILD_DIR)
	$(CC) $^ -o $@
```

The `|` separator marks `$(BUILD_DIR)` as order-only: it must exist, but
changes to it do not trigger a rebuild of `build/app`.

---

## Variables Expand Empty

**Problem:** A variable used in a recipe is empty or undefined.

**Diagnosis:**

```makefile
debug:
	@echo "FILES=$(FILES)"
	@echo "TARGET=$(TARGET)"
```

Or at parse time:

```makefile
$(info FILES=$(FILES))
$(info TARGET=$(TARGET))
```

**Common causes:**

1. Typo in variable name (`$(FILE)` vs `$(FILES)`)
2. Variable defined after use with `:=` (should use `=` for forward reference)
3. Variable scoped to a different included file
4. `$(shell ...)` command failed and returned empty

**Fix — add `--warn-undefined-variables` to MAKEFLAGS:**

```makefile
MAKEFLAGS += --warn-undefined-variables
```

This causes make to warn whenever an undefined variable is referenced.

---

## Pattern Rule Not Matched

**Problem:** An explicit target is provided but the pattern rule is not firing.

**Checklist:**

1. Confirm the stem: for `build/%.o: src/%.c`, the stem of `build/foo.o` is
   `foo` — so make looks for `src/foo.c`. Verify that file exists.
2. Pattern rules are only used when no explicit rule matches. If an explicit
   rule exists for the target (even with no recipe), the pattern rule is skipped.
3. Use `make --debug=b target` to see which rules make considered.

```bash
make --debug=b build/foo.o 2>&1 | grep -A5 'Considering'
```

---

## Implicit Rules Interfere

**Problem:** Make applies a built-in implicit rule (e.g., linking `.o` from `.c`)
and produces unexpected behavior.

**Fix — disable built-in implicit rules:**

```makefile
MAKEFLAGS += --no-builtin-rules
.SUFFIXES:
```

Both are needed: `--no-builtin-rules` disables pattern-based implicit rules;
`.SUFFIXES:` clears the legacy suffix rules.

---

## make sub-invocation Misses Flags

**Problem:** Calling `make` inside a recipe loses `MAKEFLAGS`, `-j`, and other
options from the parent invocation.

**Wrong:**

```makefile
all:
	make -C subdir
```

**Correct:**

```makefile
all:
	$(MAKE) -C subdir
```

`$(MAKE)` expands to the path of the current make binary and automatically
forwards `MAKEFLAGS`, including `-j` (parallel job count) and other flags.

---

## Anti-Patterns Quick Reference

| Anti-pattern | Problem | Fix |
| ------------ | ------- | --- |
| Recipe indented with spaces | "missing separator" error | Use TABs |
| `$var` in recipe | Expanded to empty by make | Use `$$var` |
| Non-file target without `.PHONY` | Skipped if file exists | Add to `.PHONY` |
| `make` in recipe | Drops parent flags and `-j` | Use `$(MAKE)` |
| `VAR = $(VAR) more` | Infinite recursive expansion | Use `VAR := ...; VAR += more` |
| `cd dir` on its own line | No effect on next line | Use `cd dir && ...` |
| `mkdir -p` in parallel recipe | Race condition | Use order-only prereqs |
| `rm -rf $(CLEAN_DIR)` | Deletes everything if `CLEAN_DIR` is empty | Guard with `ifdef` or `$(error)` |
| No `.DELETE_ON_ERROR` | Stale partial output on failure | Add `.DELETE_ON_ERROR:` |
| Pattern rule without `$@`/`$<` | Hardcoded paths break for multiple targets | Use automatic variables |
| `$(shell ...)` with `=` | Re-executed on every reference | Use `:=` |
| Built-in implicit rules active | Unexpected compilations | Add `--no-builtin-rules` and `.SUFFIXES:` |
