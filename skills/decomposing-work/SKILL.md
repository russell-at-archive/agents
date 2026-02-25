---
name: decomposing-work
description: Use when breaking a feature plan or technical design into
  implementation tasks. Invoke after a tech plan is approved and before
  any implementation begins. Produces a task list where each task maps
  to exactly one branch and one PR.
---

# Decomposing Work Into Tasks

## Overview

A task list is the bridge between a technical plan and executable
implementation. Each task must be independently completable, independently
verifiable, and sized to fit in a single focused PR.

**Core principle:** One task → one branch → one PR. If a task requires
more than one PR to verify, it is too large. If two tasks cannot be
reviewed independently, they should be one task.

## When to Use

- After a technical plan (`/plan`) is approved
- When a feature has more than one logical change
- Before creating any branch or writing any code
- When asked to "break down" or "decompose" a plan into tasks

## When Not to Use

- For trivial single-commit fixes (just commit directly)
- Before a tech plan exists (decomposing from idea is premature)
- When the user has already provided a task list

## Prerequisites

A technical plan must exist before decomposing. Confirm:

1. The plan covers architecture, data changes, API/UI changes, and risks.
2. Dependencies on other teams or systems are documented.
3. The scope boundary (in/out of scope) is explicit.

If no plan exists, invoke `using-github-speckit` first.

## Decomposition Workflow

### Step 1: Identify delivery units

Read the technical plan and identify all discrete changes. Group
related changes by:

- infrastructure or scaffolding changes first
- data model changes before API changes
- API changes before UI changes
- feature work before cleanup/polish
- test additions last (or alongside their feature)

Never group unrelated concerns into one task because they are
"small enough."

### Step 2: Apply INVEST to each task

Every task must satisfy INVEST before it is added to the list:

| Letter | Check                                                        |
| ------ | ------------------------------------------------------------ |
| **I**  | Can this task start without waiting for an in-progress task? |
| **N**  | Can the scope be adjusted without abandoning the goal?       |
| **V**  | Does it deliver something a reviewer can verify on its own?  |
| **E**  | Is the scope clear enough to begin immediately?              |
| **S**  | Can it fit in one PR under 400 net lines?                    |
| **T**  | Does it have written acceptance criteria?                    |

If a task fails any check, revise it before proceeding.

### Step 3: Write acceptance criteria

Every task needs at least two acceptance criteria in Given/When/Then
format. Write them before writing any code.

```
Given <precondition or context>
When  <action or event>
Then  <observable, measurable outcome>
```

Vague criteria are not acceptable:

| Vague                          | Acceptable                                         |
| ------------------------------ | -------------------------------------------------- |
| "works correctly"              | "Given valid input, when saved, then returns 201"  |
| "is fast"                      | "p95 response time under 200ms under 100 rps load" |
| "handles errors"               | "Given invalid token, when called, then returns 401 with error body" |

### Step 4: Assign branch names and stack order

Every task gets a branch name and a stack parent before implementation
starts. The stack order must match the dependency order from step 1.

Branch naming: `<type>/<task-id>-<short-slug>`

Stack order example:

```
trunk
 └── feat/TASK-001-add-users-table
      └── feat/TASK-002-user-registration-api
           └── feat/TASK-003-registration-form-ui
                └── test/TASK-004-registration-e2e
```

### Step 5: Produce the task list

Output the task list in the template format below. Each task is a
standalone work item with enough context to be implemented without
re-reading the full plan.

## Task Template

```markdown
## TASK-NNN: <imperative title>

**Branch:** <type>/<task-id>-<short-slug>
**Stack parent:** <parent-branch or trunk>
**Depends on:** TASK-NNN, ...  (or "none")
**Estimated scope:** ~NNN lines changed, N files

### What and Why

<2-4 sentences on what this task changes and why it is needed.>

### Acceptance Criteria

- [ ] Given <context>, when <action>, then <outcome>.
- [ ] Given <context>, when <action>, then <outcome>.

### Validation Commands

\`\`\`bash
# Run after completing the task
<validation commands>
\`\`\`

### Definition of Done

- [ ] All acceptance criteria verified
- [ ] Validation commands pass with no errors
- [ ] No lint, type, or test regressions
- [ ] Branch pushed and PR submitted in stack
- [ ] PR body contains summary, task link, and test plan
```

## Sizing Guidelines

| Signal                                    | Action                        |
| ----------------------------------------- | ----------------------------- |
| Task touches more than 3 modules          | Split into smaller tasks      |
| Task mixes feature and refactor           | Create separate refactor task |
| Task cannot be described in one sentence  | Scope is too large            |
| Two tasks always need to be reviewed together | Merge into one task       |
| Task has no verifiable output             | Refine acceptance criteria    |
| Single mechanical change across many files | One task is fine              |

## Stack Ordering Rules

- Infrastructure before features (create table before writing to it)
- Data model before API (schema before handlers)
- API before UI (contract before consumer)
- Happy path before error paths (when they are naturally separable)
- Core logic before tests (when tests cannot run on a partial impl)
- Never stack an unrelated change on top of another for convenience

## Example Decomposition

**Feature:** Add user authentication with JWT

**Tasks:**

```markdown
## TASK-001: add users table migration

**Branch:** feat/TASK-001-users-table
**Stack parent:** trunk
**Depends on:** none

### What and Why
Creates the `users` table with id, email, password_hash, and
created_at columns. Required before any user registration or
authentication logic can be implemented.

### Acceptance Criteria
- [ ] Given the migration runs, then `users` table exists with correct schema.
- [ ] Given the migration is rolled back, then the table is removed cleanly.

### Validation Commands
\`\`\`bash
npm run db:migrate
npm run db:rollback
npm run db:migrate
\`\`\`
```

```markdown
## TASK-002: implement password hashing utility

**Branch:** feat/TASK-002-password-hash
**Stack parent:** feat/TASK-001-users-table
**Depends on:** TASK-001

### What and Why
Adds bcrypt-based hash and verify functions for password management.
Isolated as a utility so it can be unit-tested independently before
being used in the registration handler.

### Acceptance Criteria
- [ ] Given plaintext, when hashed, then returns bcrypt hash string.
- [ ] Given correct plaintext and hash, when verified, then returns true.
- [ ] Given wrong plaintext and hash, when verified, then returns false.

### Validation Commands
\`\`\`bash
npm test -- --testPathPattern=password-hash
\`\`\`
```

## Quality Checklist

Before handing off the task list, verify:

- [ ] Every task has a unique sequential ID
- [ ] Every task has a branch name and stack parent
- [ ] Every task passes INVEST
- [ ] Every task has at least 2 acceptance criteria in Given/When/Then
- [ ] Dependency order matches the stack order
- [ ] No task mixes more than one logical concern
- [ ] Validation commands are runnable as-written
- [ ] Total task count accounts for the full plan scope

## Common Mistakes

| Mistake                         | Fix                                            |
| ------------------------------- | ---------------------------------------------- |
| Skipping INVEST on any task     | Apply all 6 checks before finalizing           |
| Vague acceptance criteria       | Rewrite using Given/When/Then with specifics   |
| Missing stack parent            | Every task needs an explicit parent branch     |
| Task that requires another task to verify | Merge the two or reorder the stack   |
| No validation commands          | Tasks without runnable verification are incomplete |
| Task IDs not sequential         | Renumber before handing off                    |

## Red Flags — Stop and Correct

- A task title contains "and" (likely two concerns)
- A task has no acceptance criteria
- A task depends on one that is not yet in the list
- Stack parent does not exist in the plan
- Estimation says ">500 lines" (split it)
- A task cannot be explained in 2-4 sentences

## References

- Full delivery reference: `docs/delivery-standards.md`
- For planning artifacts: `skills/using-github-speckit/SKILL.md`
- For stacked PRs: `skills/using-graphite-cli/SKILL.md`
- For commit messages: `skills/writing-conventional-commits/SKILL.md`
