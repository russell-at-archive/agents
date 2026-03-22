# Creating Skills: Examples

## Contents

- Example: minimal skill (no references)
- Example: skill with only installation guidance
- Example: skill with selective references
- Example: domain-partitioned references

---

## Example: Minimal Skill (no references)

Use only when the full procedure fits in the body under 100 lines and
has no situational detail worth deferring.

```text
skills/running-tests/
└── SKILL.md
```

```markdown
---
name: running-tests
description: Runs the project test suite and reports failures. Use when
  asked to run tests, verify changes, or check for regressions before
  submitting a pull request.
---

# Running Tests

## Overview

Runs the project's standard test suite and surfaces failures with enough
context to diagnose the root cause.

## When to Use

- Before any pull request submission
- After any change to application logic
- When asked to verify correctness

## When Not to Use

- For linting or type checking only (use a linting skill instead)
- For end-to-end tests requiring a live environment (document separately)

## Prerequisites

- Project dependencies installed
- Test runner available in PATH

## Workflow

1. Identify the test command from `package.json`, `Makefile`, or
   `justfile`.
2. Run the command and capture output.
3. Report: number of tests, passes, failures, and any failure messages.
4. If failures exist, summarize the root cause before stopping.

## Hard Rules

- Never skip tests to unblock a submission.
- Never mark tests as passing if the command exits non-zero.

## Failure Handling

- If the test command is not found, report the missing dependency and
  stop.
- If tests time out, report the timeout and ask the user how to proceed.

## Red Flags

- Test output contains "skipped" for tests that should run
- Exit code is non-zero but output says all tests passed
```

---

## Example: Skill with Only Installation Guidance

Use this for a CLI-tool skill that does not need any other supporting
files.

```text
skills/using-gh-cli/
├── SKILL.md
└── references/
    └── installation.md
```

### SKILL.md

```markdown
---
name: using-gh-cli
description: Uses GitHub CLI for repository, pull request, and issue
  operations. Use when the user asks for `gh` commands or for GitHub
  tasks that should be completed through the CLI.
---

# Using GitHub CLI

## Overview

Uses `gh` for GitHub operations while keeping setup details out of the
main body.

## When to Use

- When the user asks for `gh` commands
- When GitHub work should be done through the CLI

## When Not to Use

- When the task is not GitHub-related
- When a project-specific wrapper should be used instead

## Prerequisites

- GitHub CLI available on `PATH`

## Workflow

1. Check whether `gh` is installed and authenticated.
2. If setup is incomplete, read
   [references/installation.md](references/installation.md).
3. Run the narrowest non-interactive `gh` command that solves the task.
4. Report the result and any follow-up state.

## Hard Rules

- Do not assume `gh` is installed.
- Use explicit repo and host flags when needed.

## Failure Handling

- If setup is missing, stop after surfacing the install path.
- If auth fails, surface the failing command and stop.

## Red Flags

- The workflow tells the agent to "install if needed" without actual
  install instructions
```

### references/installation.md

````markdown
# Installation

Install GitHub CLI with one of:

- macOS: `brew install gh`
- Windows: `winget install --id GitHub.cli`
- Linux: use the official package instructions for the target distro

Then authenticate with:

```bash
gh auth login
```
````

---

## Example: Skill with Selective References

Use only the references that reduce `SKILL.md` size or hold genuinely
deferred detail.

```text
skills/writing-commits/
├── SKILL.md
└── references/
    ├── formats.md
    └── examples.md
```

## Example: Domain-Partitioned References

Use when a skill covers multiple distinct domains and loading all
reference content on every activation would waste tokens.

```text
skills/querying-data/
├── SKILL.md
└── references/
    ├── finance.md      # revenue, billing queries
    ├── sales.md        # pipeline, opportunity queries
    └── product.md      # usage, adoption queries
```

### SKILL.md workflow section

```markdown
## Workflow

1. Identify the domain from the user's request.
2. Load the relevant reference file:
   - Finance (revenue, ARR, billing) →
     [references/finance.md](references/finance.md)
   - Sales (pipeline, opportunities) →
     [references/sales.md](references/sales.md)
   - Product (usage, adoption) →
     [references/product.md](references/product.md)
3. Write and run the query using the schemas and patterns in that file.
4. Return results with column names and row count.
```

When the user asks about revenue, only `finance.md` loads. The other
files consume zero tokens.

---

## Example: CLI Tool Skill Must Include Installation Reference

For CLI-oriented skills, prerequisites alone are not enough. The skill
must link to `references/installation.md`, which tells the agent how the
tool is installed.

### Bad

```markdown
## Prerequisites

- `gh` is installed and accessible

## Failure Handling

- If `gh` is missing, tell the user to install it
```

This is insufficient because it detects absence but does not provide the
installation path in a first-class reference file.
