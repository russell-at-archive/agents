# Writing Meta-Prompts: Examples

## Contents

- Task-execution command examples
- Reference command examples
- Code generation command examples
- Research command examples
- Workflow automation command examples
- Before/after rewrites

---

## Task-Execution Command Examples

### Fix a GitHub issue

```yaml
---
name: fix-issue
description: Fix a GitHub issue end to end. Use when given an issue number
  and asked to implement the fix, write tests, and commit.
disable-model-invocation: true
argument-hint: "[issue-number]"
allowed-tools: Read, Grep, Glob, Edit, Write, Bash(git *), Bash(gh *)
---

Fix GitHub issue #$ARGUMENTS:

1. Read the issue: `gh issue view $ARGUMENTS --json title,body`
2. Find the relevant code using Grep and Read
3. Implement the fix following the patterns in the surrounding code
4. Write or update tests covering the change
5. Confirm tests pass: `make test` (or project equivalent)
6. Commit with: `fix: <summary> (closes #$ARGUMENTS)`

Stop after the commit. Do not open a PR.
```

### Create a pull request

```yaml
---
name: create-pr
description: Create a pull request for the current branch. Use after all
  changes are committed and tests pass.
disable-model-invocation: true
allowed-tools: Read, Bash(git *), Bash(gh *)
---

Create a pull request for the current branch:

Branch: !`git branch --show-current`
Commits since main: !`git log --oneline origin/main..HEAD`

1. Run `gh pr create --fill` to draft the PR from commit messages
2. Review the generated title and body — edit if the summary is unclear
3. Add reviewers if the team has a default review assignment

Do not push force or amend commits.
```

---

## Reference Command Examples

### API design conventions

```yaml
---
name: api-conventions
description: Load API design conventions for this codebase. Use proactively
  when designing or reviewing HTTP endpoints, response shapes, or error codes.
allowed-tools: Read, Glob, Grep
---

# API Design Conventions

## Endpoint naming
- RESTful: `GET /users/:id`, `POST /users`, `DELETE /users/:id`
- Version via header: `X-API-Version: 1` (not in path)
- Plural resource names always: `/users`, `/orders`, not `/user`

## Error responses
Always return:
```json
{
  "error": {
    "code": "MACHINE_READABLE_CODE",
    "message": "Human-readable message",
    "details": {}
  }
}
```

## Input validation
- All inputs validated with Zod schemas at the handler boundary
- Validation errors return HTTP 422 with field-level `details`
- Never return raw database errors to clients

## Authentication
- All endpoints require `Authorization: Bearer <token>` unless marked public
- Public endpoints are annotated with `@public` in the route file
```

### Testing standards

```yaml
---
name: testing-standards
description: Load testing conventions for this codebase. Use proactively
  when writing, reviewing, or debugging tests.
allowed-tools: Read, Glob, Grep
---

# Testing Standards

## Unit tests
- File location: `<source-file>.test.ts` alongside the source
- Framework: Vitest
- Each test: one assertion of one behavior
- No shared mutable state between tests

## Integration tests
- Location: `tests/integration/`
- Hit real database (no mocks for DB layer)
- Each test owns its data — seed and teardown in `beforeEach`/`afterEach`

## What to mock
- External HTTP calls: mock at the HTTP client boundary
- Time: use `vi.useFakeTimers()`
- File system: use a temp directory, not mocks
- Never mock the database

## Coverage
- Minimum 80% line coverage on business logic in `src/services/`
- CI blocks merges below threshold
```

---

## Code Generation Command Examples

### New React component

```yaml
---
name: new-component
description: Generate a new React component with TypeScript, tests, and
  Tailwind styles. Use when asked to create a new UI component.
disable-model-invocation: true
argument-hint: "[ComponentName]"
allowed-tools: Read, Write, Glob
---

Generate a new React component named $0:

**Files to create:**

1. `src/components/$0/$0.tsx` — component implementation
2. `src/components/$0/$0.test.tsx` — unit tests
3. `src/components/$0/index.ts` — barrel export

**Conventions to follow:**

- TypeScript: define props interface as `$0Props` in the same file
- Styling: Tailwind classes only, no inline styles or CSS modules
- Tests: one test for default render, one per interactive behavior
- Exports: named export in component file, re-exported from `index.ts`

**Pattern:** Follow the structure of `src/components/Button/Button.tsx`.
Read it before generating to match naming and structure exactly.
```

### Scaffold a new service

```yaml
---
name: scaffold-service
description: Generate the boilerplate for a new backend service. Use when
  adding a new domain service to src/services/.
disable-model-invocation: true
argument-hint: "[ServiceName]"
allowed-tools: Read, Write, Glob, Bash(mkdir *)
---

Scaffold a new service named $0:

**Files to create:**

1. `src/services/$0Service.ts` — service class
2. `src/services/$0Service.test.ts` — unit test file
3. `src/types/$0.ts` — TypeScript types for this domain

**Conventions:**

- Service class: `export class $0Service { ... }`
- Constructor: accepts dependencies as named parameters (no IoC container)
- Methods: `async`, return typed results, throw typed errors
- Types file: export all input/output types and domain errors

**Pattern:** Read `src/services/UserService.ts` before generating.
Match the class structure, error handling style, and JSDoc patterns exactly.
```

---

## Research Command Examples

### Investigate a module

```yaml
---
name: investigate
description: Deep investigation of a codebase module or feature area.
  Use when asked to understand how something works before modifying it.
argument-hint: "[module-or-feature-name]"
allowed-tools: Read, Grep, Glob
context: fork
agent: Explore
---

Investigate "$ARGUMENTS" in this codebase:

1. Find all related files with Glob patterns matching the topic
2. Read the entry points (exported APIs, route handlers, or main classes)
3. Map dependencies: what does this call, and what calls this?
4. Identify any TODOs, FIXMEs, or deprecation markers
5. Note any tests and their coverage of the area

**Return a structured summary with:**
- Purpose: what this module/feature does in one paragraph
- Key files: paths and their roles
- Public API: exported functions, types, or endpoints
- Dependencies: upstream and downstream
- Known issues: any TODOs, FIXMEs, or code smells
- Suggested entry point for modifications
```

### Find usages

```yaml
---
name: find-usages
description: Find all usages of a function, type, or pattern in the codebase.
  Use when asked where something is called or referenced.
argument-hint: "[symbol-or-pattern]"
allowed-tools: Read, Grep, Glob
---

Find all usages of "$ARGUMENTS":

1. Search with Grep for exact matches: `$ARGUMENTS`
2. Search for related patterns (aliases, re-exports, type references)
3. Group results by: direct callers, indirect callers, test references

Report:
- Total usage count
- Files that use it, with line numbers
- Any patterns suggesting misuse or inconsistency
```

---

## Workflow Automation Command Examples

### Full release

```yaml
---
name: release
description: Run the full release workflow. Use when asked to cut a release
  with version bump, changelog, tag, and GitHub release.
disable-model-invocation: true
argument-hint: "[major|minor|patch]"
allowed-tools: Read, Edit, Bash(git *), Bash(gh *), Bash(npm version *)
---

Run the release workflow for a $ARGUMENTS version bump:

Current state:
Branch: !`git branch --show-current`
Last tag: !`git describe --tags --abbrev=0 2>/dev/null || echo 'no tags'`
Uncommitted: !`git status --short`

**Steps:**

1. **Verify clean state.** If `git status --short` shows changes, stop and
   report what is uncommitted.
2. **Bump version.** Run `npm version $ARGUMENTS --no-git-tag-version` and
   confirm the new version number.
3. **Update changelog.** Add an entry in `CHANGELOG.md` under `## [new-version]`
   with today's date. Group changes as Added / Changed / Fixed.
4. **Commit.** `git commit -am "chore(release): vX.Y.Z"`
5. **Tag.** `git tag vX.Y.Z`
6. **Push.** `git push origin HEAD --tags`
7. **GitHub release.** `gh release create vX.Y.Z --generate-notes`

Stop at the first failure and report the failing step with its error output.
```

### Format and test

```yaml
---
name: fmt-test
description: Format code, run linter, and run tests. Use before committing
  or when asked to clean up and verify the current state.
disable-model-invocation: true
allowed-tools: Bash(npm run *), Bash(npx *), Read
---

Run the full format-and-test pipeline:

1. **Format:** `npm run format` (or `npx prettier --write .`)
   — show a summary of files changed
2. **Lint:** `npm run lint`
   — stop here if lint errors are unfixable (not auto-fixable)
3. **Type check:** `npm run typecheck` (if present in package.json)
4. **Test:** `npm test`
   — stop and show failure output if tests fail

Report a final status: all green, or which step failed and why.
```

---

## Before/After Rewrites

### Bad: vague description, no trigger condition

```yaml
---
name: review
description: Review code
---

Review the code and provide feedback.
```

**Problems:**
- Description has no trigger condition — Claude won't know when to invoke
- Body has no structure — no checklist, no output format
- No `allowed-tools` — grants accidental write access

### Good: specific description, structured body

```yaml
---
name: review-pr
description: Review the current pull request for code quality, security,
  and test coverage. Use proactively after a PR is created or when asked
  to review changes.
allowed-tools: Read, Grep, Glob, Bash(gh *)
---

Review the current pull request:

Changed files: !`gh pr diff --name-only`

Check each changed file for:

1. **Correctness** — does the logic match the PR description?
2. **Security** — any hardcoded secrets, injection risks, or unvalidated input?
3. **Tests** — is the change covered? Are edge cases handled?
4. **Conventions** — does the code match the patterns in surrounding files?

Format findings as a list per file. Distinguish: blocking issues (must fix),
suggestions (nice to have), and questions (needs clarification).
```

---

### Bad: missing `disable-model-invocation` on side-effecting command

```yaml
---
name: deploy
description: Deploy the application
---

Deploy to production using the deploy script.
```

**Problems:**
- `disable-model-invocation` missing — Claude could auto-invoke this mid-session
- No verification steps
- No `allowed-tools` restriction

### Good: safe, explicit workflow

```yaml
---
name: deploy
description: Deploy the application to production. Use only when explicitly
  asked to deploy and after confirming tests pass.
disable-model-invocation: true
allowed-tools: Bash(make deploy), Bash(make test), Read
---

Deploy to production:

Test status: !`make test --dry-run 2>&1 | tail -3`

1. **Confirm:** Run `make test`. Stop if any tests fail — do not deploy
   with failing tests.
2. **Deploy:** Run `make deploy`
3. **Verify:** Check `https://status.example.com/health` returns 200
4. **Report:** State deployed version and any warnings from deploy output

If step 2 or 3 fails, do not attempt to retry — report the failure and
stop so a human can investigate.
```
