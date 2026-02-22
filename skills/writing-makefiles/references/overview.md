# Writing Makefiles: Full Reference

## Contents

- [Canonical Header](#canonical-header)
- [Targets and Prerequisites](#targets-and-prerequisites)
- [Variable Flavors](#variable-flavors)
- [Automatic Variables](#automatic-variables)
- [Special Targets](#special-targets)
- [Recipe Modifiers](#recipe-modifiers)
- [Pattern Rules](#pattern-rules)
- [Static Pattern Rules](#static-pattern-rules)
- [Order-Only Prerequisites](#order-only-prerequisites)
- [Double-Colon Rules](#double-colon-rules)
- [Function Reference](#function-reference)
- [Conditional Directives](#conditional-directives)
- [Include Directives](#include-directives)
- [Self-Documenting Help Target](#self-documenting-help-target)
- [Guard Variable Pattern](#guard-variable-pattern)
- [Directory Creation Pattern](#directory-creation-pattern)
- [Parallel Safety](#parallel-safety)
- [Portability Notes](#portability-notes)

---

## Canonical Header

Place these lines at the top of every Makefile:

```makefile
SHELL := /bin/bash
.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
.SUFFIXES:

MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
```

| Setting | Purpose |
| ------- | ------- |
| `SHELL := /bin/bash` | Consistent shell; avoids `/bin/sh` portability issues |
| `.DEFAULT_GOAL` | Explicit default; don't rely on first-target ordering |
| `.DELETE_ON_ERROR:` | Delete partial targets on recipe failure |
| `.SUFFIXES:` | Clear legacy suffix rules to avoid surprises |
| `--warn-undefined-variables` | Error on `$(UNDEF)` expansion |
| `--no-builtin-rules` | Disable implicit rules; speeds up make |

---

## Targets and Prerequisites

```makefile
target: prerequisites
	recipe line one
	recipe line two
```

- Each recipe line runs in a **separate subshell** by default.
- Use `.ONESHELL:` to run all lines in one shell (GNU make 3.82+).
- Indent recipes with a **TAB** character — never spaces.

### Multiline recipes

Chain commands with `&&` or use backslash continuation:

```makefile
build:
	cd src && \
	$(CC) -o ../bin/app main.c
```

Or use `.ONESHELL:` for more readable multiline logic:

```makefile
.ONESHELL:
deploy:
	cd infra
	terraform init
	terraform apply -auto-approve
```

---

## Variable Flavors

| Syntax | Name | Expansion |
| ------ | ---- | --------- |
| `VAR = value` | Recursive | Expanded every time `$(VAR)` is referenced |
| `VAR := value` | Simply-expanded | Expanded once at definition |
| `VAR ?= value` | Conditional | Set only if `VAR` is not already defined |
| `VAR += more` | Append | Appends to existing value (preserves flavor) |
| `override VAR = value` | Override | Wins over command-line assignments |

**Default to `:=`** to avoid recursive expansion surprises:

```makefile
# Bad: FOO expands every reference — expensive or surprising
FILES = $(shell find . -name '*.go')

# Good: expanded once at parse time
FILES := $(shell find . -name '*.go')
```

Recursive `=` is useful for forward references (variable defined after use),
but requires explicit intent.

### Inspecting variables

```makefile
$(info FILES=$(FILES))     # prints at parse time
$(warning FILES=$(FILES))  # prints with file:line context
```

---

## Automatic Variables

Available inside recipe lines only:

| Variable | Expands to |
| -------- | ---------- |
| `$@` | Target name |
| `$<` | First prerequisite |
| `$^` | All prerequisites (deduplicated) |
| `$+` | All prerequisites (with duplicates) |
| `$?` | Prerequisites newer than target |
| `$*` | Stem matched by `%` in a pattern rule |
| `$(@D)` | Directory part of `$@` |
| `$(@F)` | File part of `$@` |
| `$(<D)` | Directory part of `$<` |
| `$(<F)` | File part of `$<` |

```makefile
build/%.o: src/%.c
	mkdir -p $(@D)
	$(CC) -c $< -o $@
```

---

## Special Targets

| Target | Effect |
| ------ | ------ |
| `.PHONY` | Declares non-file targets; always runs recipe |
| `.DEFAULT_GOAL` | Sets the default target |
| `.DELETE_ON_ERROR` | Deletes target if its recipe exits non-zero |
| `.PRECIOUS` | Never delete target, even on error or interrupt |
| `.SECONDARY` | Preserve intermediate files (not auto-deleted) |
| `.INTERMEDIATE` | Mark as intermediate (deleted after use) |
| `.ONESHELL` | Run all recipe lines in one shell process |
| `.SUFFIXES` | Control legacy suffix-based implicit rules |
| `.SILENT` | Suppress recipe echoing for listed targets |
| `.EXPORT_ALL_VARIABLES` | Export all variables to child processes |

```makefile
.PHONY: all build test lint clean help
```

Declare `.PHONY` for every target that does not produce a file with that exact name.

---

## Recipe Modifiers

Prefix individual recipe lines with these characters:

| Prefix | Effect |
| ------ | ------ |
| `@` | Suppress echo (don't print the command) |
| `-` | Ignore non-zero exit code (continue on failure) |
| `+` | Run even with `--dry-run` or `--touch` |

```makefile
clean:
	@echo "Cleaning..."
	-rm -rf build/
	+$(MAKE) -C subdir clean
```

---

## Pattern Rules

Match any target of a given shape:

```makefile
%.o: %.c
	$(CC) -c $(CFLAGS) $< -o $@

%.pdf: %.md
	pandoc $< -o $@
```

`%` matches a non-empty stem. The same stem is used in both target and prerequisite.

---

## Static Pattern Rules

Apply a pattern rule to a specific list of targets:

```makefile
OBJECTS := build/foo.o build/bar.o build/baz.o

$(OBJECTS): build/%.o: src/%.c
	$(CC) -c $(CFLAGS) $< -o $@
```

Preferred over pattern rules when the target list is bounded — prevents unintended matches.

---

## Order-Only Prerequisites

Prerequisites listed after `|` are required to exist but do not trigger a rebuild:

```makefile
$(OBJECTS): | build/

build/:
	mkdir -p $@
```

Use order-only prerequisites for directories that must exist before recipes run.

---

## Double-Colon Rules

Each rule for the same target runs independently:

```makefile
clean::
	rm -rf build/

clean::
	rm -rf dist/
```

Useful when multiple independent components contribute recipes to one target.
Rare — prefer explicit dependency chains in most cases.

---

## Function Reference

### File and path functions

```makefile
$(wildcard src/*.c)              # glob: all .c files in src/
$(dir build/foo/bar.o)           # build/foo/
$(notdir build/foo/bar.o)        # bar.o
$(basename src/foo.c)            # src/foo
$(suffix src/foo.c)              # .c
$(addsuffix .o,foo bar)          # foo.o bar.o
$(addprefix build/,foo.o bar.o)  # build/foo.o build/bar.o
```

### Text functions

```makefile
$(subst .c,.o,foo.c bar.c)          # foo.o bar.o (literal)
$(patsubst %.c,%.o,foo.c bar.c)     # foo.o bar.o (pattern)
$(filter %.c,foo.c foo.h bar.c)     # foo.c bar.c
$(filter-out %.h,foo.c foo.h)       # foo.c
$(sort foo bar foo baz)             # bar baz foo (sorted, deduped)
$(strip "  foo  bar  ")             # foo bar
$(words foo bar baz)                # 3
$(word 2,foo bar baz)               # bar
$(firstword foo bar baz)            # foo
$(lastword foo bar baz)             # baz
$(join foo bar,baz qux)             # foobaz barqux
```

### Control functions

```makefile
$(shell date +%Y-%m-%d)             # run shell command, capture output
$(call MY_FUNC,arg1,arg2)           # call user-defined function
$(if $(VAR),yes,no)                 # conditional: yes if VAR non-empty
$(foreach v,$(LIST),$(v).o)         # loop: append .o to each word
$(eval $(call TEMPLATE,arg))        # evaluate generated makefile text
$(origin VAR)                       # where VAR was defined
$(flavor VAR)                       # recursive or simple
$(error Fatal: $(MSG))              # abort with error message
$(warning Non-fatal: $(MSG))        # print warning, continue
$(info $(MSG))                      # print informational message
$(value VAR)                        # unexpanded variable value
```

### User-defined functions with `call`

```makefile
# Define a function (note: use $(1), $(2) for arguments)
define compile
  $(CC) -c $(CFLAGS) $(1) -o $(2)
endef

build/foo.o: src/foo.c
	$(call compile,$<,$@)
```

---

## Conditional Directives

```makefile
ifeq ($(ENV),production)
  FLAGS := -O2
else
  FLAGS := -g
endif

ifneq ($(DEBUG),)
  CFLAGS += -DDEBUG
endif

ifdef VERBOSE
  AT :=
else
  AT := @
endif
```

Conditionals are evaluated at **parse time**, not recipe-execution time.
Do not use `$(shell ...)` results inside `ifeq` for values that change during a build.

---

## Include Directives

```makefile
include config.mk          # error if file missing
-include optional.mk       # silent if file missing
```

Use `-include` for generated dependency files:

```makefile
DEPS := $(OBJECTS:.o=.d)
-include $(DEPS)

build/%.o: src/%.c
	$(CC) -MMD -MP -c $< -o $@
```

The `-MMD -MP` flags generate `.d` dependency files automatically.

---

## Self-Documenting Help Target

Add `##` comments after targets to enable auto-generated help:

```makefile
.PHONY: help
help: ## Show available targets
	@grep -E '^[a-zA-Z_/-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	  | sort \
	  | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: ## Compile the project
	$(CC) -o bin/app src/main.c

test: ## Run the test suite
	go test ./...
```

Running `make help` (or `make` with `.DEFAULT_GOAL := help`) prints a formatted
table of all documented targets.

---

## Guard Variable Pattern

Fail early with a clear message when a required variable is missing:

```makefile
guard-%:
	@if [ -z "${$*}" ]; then \
	  echo "Variable $* is required but not set"; \
	  exit 1; \
	fi

deploy: guard-ENV guard-REGION ## Deploy to the specified ENV and REGION
	./scripts/deploy.sh $(ENV) $(REGION)
```

Call with `make deploy ENV=prod REGION=us-east-1`.

---

## Directory Creation Pattern

Create output directories as order-only prerequisites:

```makefile
BUILD_DIR := build
DIRS := $(BUILD_DIR) $(BUILD_DIR)/obj $(BUILD_DIR)/bin

$(DIRS):
	mkdir -p $@

$(BUILD_DIR)/obj/%.o: src/%.c | $(BUILD_DIR)/obj
	$(CC) -c $< -o $@

$(BUILD_DIR)/bin/app: $(OBJECTS) | $(BUILD_DIR)/bin
	$(CC) $^ -o $@
```

---

## Parallel Safety

`make -j$(nproc)` runs independent recipes in parallel. Rules:

- Targets that share output paths must have explicit dependencies between them.
- Avoid shell-level side effects (e.g., `mkdir -p`) in parallel recipes — use
  order-only prerequisites with a dedicated directory target instead.
- Use `$(MAKE) -j1` for sub-targets that must run serially.
- `.NOTPARALLEL:` disables parallelism for the entire Makefile (use sparingly).

---

## Portability Notes

| Feature | GNU make | BSD make | Notes |
| ------- | -------- | -------- | ----- |
| `:=` simply-expanded | 3.81+ | Yes | Safe to use |
| `?=` conditional | Yes | Yes | Safe to use |
| `$(shell ...)` | Yes | Yes | Safe to use |
| `.ONESHELL:` | 3.82+ | No | GNU only |
| `$$` in recipes | Yes | Yes | Required for shell vars |
| `include` | Yes | Yes | BSD uses `.include` |
| `-include` | Yes | No | BSD uses `.sinclude` |
| `$(lastword ...)` | 3.81+ | No | GNU only |
| `$(abspath ...)` | 3.81+ | No | GNU only |
| `MAKEFLAGS +=` | Yes | Partial | Verify behavior |

macOS ships GNU make 3.81 by default. Install GNU make 4.x via Homebrew
(`brew install make`) and invoke as `gmake` for newer features.
