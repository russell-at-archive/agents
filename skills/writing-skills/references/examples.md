# Creating Skills: Examples

## Contents

- Example: minimal skill (no references)
- Example: full skill with references (recommended pattern)
- Example: domain-partitioned references
- Example: README index entry

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

## Example: Full Skill with References (recommended pattern)

The standard pattern for any skill with more than minimal detail.

```text
skills/writing-commits/
├── SKILL.md
└── references/
    ├── overview.md
    ├── examples.md
    └── troubleshooting.md
```

### SKILL.md

```markdown
---
name: writing-commits
description: Writes git commit messages following Conventional Commits
  format. Use when writing any commit, staging changes, or when the user
  asks for a commit message. Enforces type prefixes, scope, and breaking
  change notation.
---

# Writing Commits

## Overview

Produces commit messages that follow the Conventional Commits
specification for readable history and automated changelog generation.

Full procedure and type reference:
[references/overview.md](references/overview.md)

## When to Use

- Before any `git commit` or `gt create`
- When the user asks for a commit message
- When reviewing staged changes for commit readiness

## When Not to Use

- For PR titles or branch names (different conventions)
- For changelog entries (generated from commits, not authored directly)

## Prerequisites

- Staged changes exist (`git status` shows staged files)

## Workflow

1. Read staged diff with `git diff --staged`.
2. Identify the primary type of change (feat, fix, refactor, etc.).
3. Determine scope if the change is bounded to one component.
4. Write subject line: `<type>(<scope>): <description>` — imperative,
   lowercase, ≤72 characters, no period.
5. Write body if the why is not obvious from the subject.
6. Add footer with issue references and breaking change notice if needed.

For the complete type table, body guidelines, and breaking change rules,
read [references/overview.md](references/overview.md).
For examples of good and bad commit messages, read
[references/examples.md](references/examples.md).

## Hard Rules

- One logical change per commit — do not mix unrelated concerns.
- Subject line must use a type prefix.
- Breaking changes require both `!` suffix and `BREAKING CHANGE:` footer.
- Subject line ≤72 characters.

## Failure Handling

- If staged changes mix unrelated concerns, stop and ask the user to
  split them before writing a message.
- If the change type is ambiguous, ask rather than guess.

## Red Flags

- Subject contains "and" — likely two concerns in one commit
- No type prefix in subject
- Subject in past tense or starting with uppercase
- Body repeats the subject instead of explaining why
```

### references/overview.md (excerpt)

```markdown
# Writing Commits: Full Reference

## Contents

- Commit format
- Type table
- Scope guidelines
- Body guidelines
- Breaking changes
- Footer guidelines

---

## Commit Format

\`\`\`
<type>(<scope>): <short description>

[optional body]

[optional footer(s)]
\`\`\`
...
```

---

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

## Example: README Index Entry

```markdown
- [creating-skills](./skills/creating-skills/SKILL.md): Creates a new
  agent skill directory with a compliant SKILL.md and supporting reference
  files. Use when asked to build, write, add, or create a skill.
```

Format: `- [name](path): <description matching frontmatter description,
trimmed to 2–3 lines>.`
