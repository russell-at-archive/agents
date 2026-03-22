# Writing Meta-Prompts: Full Reference

## Contents

- Command types and when to use each
- Storage formats and scoping
- Frontmatter field reference
- Per-type frontmatter rules
- Argument handling
- Dynamic context injection
- Prompt body structure guide
- Content sizing guide

---

## Command Types

Five types of custom slash command prompts exist in Claude Code. Choose the
type before writing the frontmatter or body — the type determines safe
defaults.

### Task-execution command

**Purpose:** Perform a concrete, side-effecting task: commit, deploy, release,
send a message, create a PR.

**Examples:** `/commit`, `/deploy`, `/fix-issue`, `/create-pr`

**Key constraint:** Always `disable-model-invocation: true`. These commands
must never auto-trigger mid-session.

---

### Reference command

**Purpose:** Load conventions, coding standards, API patterns, or team
guidelines into context on demand.

**Examples:** `/api-conventions`, `/commit-style`, `/testing-standards`

**Key constraint:** No `disable-model-invocation` needed (auto-triggering
context is safe). Use `allowed-tools: Read, Glob, Grep` to prevent writes.

---

### Code generation command

**Purpose:** Scaffold files, generate boilerplate, or produce code following
a template.

**Examples:** `/new-component`, `/scaffold-service`, `/generate-test`

**Key constraint:** `disable-model-invocation: true` if generating files
automatically. May omit it if the command only produces output for review.

---

### Research command

**Purpose:** Investigate a codebase area, summarize findings, or answer
architectural questions through read-only exploration.

**Examples:** `/investigate`, `/explain-module`, `/find-usages`

**Key constraint:** `context: fork` + `agent: Explore` for deep investigation.
`allowed-tools: Read, Glob, Grep` to prevent accidental writes.

---

### Workflow automation command

**Purpose:** Orchestrate a multi-step procedure: format + lint + test, or
a full release pipeline.

**Examples:** `/release`, `/format-and-test`, `/ci-check`

**Key constraint:** `disable-model-invocation: true`. Workflow commands have
broad side effects and must never auto-invoke.

---

## Storage Formats and Scoping

### Simple command file

```
.claude/commands/<name>.md
~/.claude/commands/<name>.md
```

- Single Markdown file, frontmatter optional (but recommended)
- Best for commands under 80 lines with no supporting files
- Invoked as `/<name>`

### Skill directory

```
.claude/skills/<name>/SKILL.md
~/.claude/skills/<name>/SKILL.md
```

- Full directory with optional `references/`, `templates/`, `scripts/`
- Required when the command needs template files, scripts, or reference docs
- Invoked as `/<name>`

**Rule:** Use a simple command file unless supporting files are needed.
Creating a full skill directory for a 20-line command adds noise.

### Scoping

| Scope | Path | Use case |
| ----- | ---- | -------- |
| Project | `.claude/commands/` or `.claude/skills/` | Team-shared; checked into version control |
| User-global | `~/.claude/commands/` or `~/.claude/skills/` | Personal; applies across all projects |

Default to project-scoped for team workflows. Use user-global only for
personal commands that don't belong in any specific repo.

---

## Frontmatter Field Reference

```yaml
---
name: fix-issue
description: Fix a GitHub issue end to end. Use when given an issue number
  and asked to implement the fix, write tests, and open a PR.
disable-model-invocation: true
argument-hint: "[issue-number]"
allowed-tools: Read, Grep, Glob, Edit, Write, Bash(git *), Bash(gh *)
model: sonnet
context: fork
agent: general-purpose
---
```

| Field | Required | Description |
| ----- | -------- | ----------- |
| `name` | No* | Lowercase, hyphens only, 1–64 chars. Becomes `/name`. Defaults to directory name. |
| `description` | Yes | When to use this command. Drives auto-invocation. Must include trigger condition. |
| `disable-model-invocation` | No | Set `true` to prevent auto-triggering. Required for side-effecting commands. |
| `argument-hint` | No | Shown in autocomplete. State expected argument shape: `[issue-number]`. |
| `allowed-tools` | No | Explicit tool allowlist. Required for read-only commands. Omitting grants all tools. |
| `model` | No | `sonnet`, `opus`, `haiku`, or full model ID. Omit to inherit from session. |
| `context` | No | `fork` runs in isolated subagent with fresh context window. |
| `agent` | No | With `context: fork`: `Explore`, `Plan`, or `general-purpose`. |

*`name` defaults to the directory name if omitted.

---

## Per-Type Frontmatter Rules

| Command type | `disable-model-invocation` | `allowed-tools` | `context` |
| ------------ | -------------------------- | --------------- | --------- |
| Task-execution | **`true` required** | Full tool list needed | Optional |
| Reference | Not needed | `Read, Glob, Grep` | Not needed |
| Code generation | `true` if auto-writes files | Full list if writes | Optional |
| Research | Not needed | `Read, Glob, Grep` | `fork` + `Explore` recommended |
| Workflow automation | **`true` required** | Full list needed | Optional |

---

## Argument Handling

### `$ARGUMENTS` — all arguments as a single string

```yaml
---
name: fix-issue
argument-hint: "[issue-number]"
---

Fix GitHub issue #$ARGUMENTS following the project's contribution guidelines.
```

**Usage:** `/fix-issue 123` → Claude sees "Fix GitHub issue #123 following..."

### `$0`, `$1`, `$2` — positional arguments

```yaml
---
name: migrate-component
argument-hint: "[component] [from-framework] [to-framework]"
---

Migrate the $0 component from $1 to $2.
Preserve all existing behavior and tests.
```

**Usage:** `/migrate-component SearchBar React Vue`

### Automatic appending

If neither `$ARGUMENTS` nor `$0`/`$1` appears in the body, arguments are
appended automatically after the body content.

### Rules

- Always state what arguments are expected in the prompt body itself, not
  just in `argument-hint`. `argument-hint` is a UI hint; the body is what
  Claude reads.
- If arguments are optional, state the default behavior when they are absent.
- Do not use `$ARGUMENTS` as raw shell input. Treat it as untrusted text.

---

## Dynamic Context Injection

Use `` !`command` `` to inject live state at invocation time. The shell command
runs before Claude reads the prompt; Claude sees the output, not the command.

### Useful patterns

```markdown
## Current git state
Branch: !`git branch --show-current`
Staged changes: !`git diff --cached --stat`
Recent commits: !`git log --oneline -5`

## PR context (requires gh)
PR diff: !`gh pr diff --no-color | head -150`
Changed files: !`gh pr diff --name-only`

## Project scripts
Available scripts: !`cat package.json | python3 -c "import sys,json; s=json.load(sys.stdin).get('scripts',{}); [print(f'{k}: {v}') for k,v in s.items()]"`

## Environment state
Node version: !`node --version 2>/dev/null || echo 'not found'`
```

### Rules

- Output must be bounded. Use `head -N`, `--stat`, `--short`, `--oneline -5`,
  or similar flags. Never inject unbounded output.
- Never inject full file contents with `cat`. Use `@file` references so
  Claude reads them via proper tooling.
- Test injected commands manually before committing. Injection runs at
  invocation time, not authoring time.
- Fail gracefully: `command 2>/dev/null || echo 'not available'` prevents
  broken injection from crashing the command.

---

## Prompt Body Structure Guide

### Task-execution body

State the task, enumerate the steps in order, specify the output or artifact
produced, and include any constraints or conventions to follow.

```markdown
Fix GitHub issue #$ARGUMENTS:

1. Read the issue description with `gh issue view $ARGUMENTS`
2. Find the relevant code using Grep and Read
3. Implement the fix following the existing patterns in the file
4. Write or update tests covering the fix
5. Run tests to confirm they pass
6. Commit with a conventional commit message referencing the issue

Do not open a PR — stop after the commit.
```

### Reference body

State what conventions or patterns this loads, organized for fast scanning.
Use headers for each concern. No step-by-step needed.

```markdown
# API Design Conventions

## Endpoint naming
- RESTful: `GET /users/:id`, `POST /users`, `DELETE /users/:id`
- Version via header: `X-API-Version: 1`

## Error responses
Always return `{ "error": { "code": "...", "message": "..." } }`

## Validation
All inputs validated with Zod. Custom error messages required.
```

### Code generation body

State what to generate, the naming rules, file locations, and what template
or pattern to follow. Reference template files explicitly if they exist.

```markdown
Generate a React component named $0:

- Location: `src/components/$0/$0.tsx`
- TypeScript interfaces in the same file
- Test file at `src/components/$0/$0.test.tsx`
- Tailwind for styling, no inline styles
- Follow the pattern in `src/components/Button/Button.tsx`
```

### Research body

State the investigation goal, what to look for, and the output format.
Use `context: fork` + `agent: Explore` in frontmatter.

```markdown
Investigate the $0 module:

1. Find all files in this module with Glob
2. Read the public API surface (exported functions, types)
3. Identify all callers using Grep
4. Note any TODOs, FIXMEs, or deprecation markers

Return a structured summary with: purpose, public API, dependencies,
known issues, and suggested refactors.
```

### Workflow automation body

Enumerate each phase of the workflow. Include verification between phases.
State what to do if a phase fails.

```markdown
Run the full release workflow:

1. **Verify:** Run `make test`. Stop if any tests fail.
2. **Version:** Update `package.json` version using semver ($ARGUMENTS: major|minor|patch)
3. **Changelog:** Add an entry in CHANGELOG.md with the new version and today's date
4. **Tag:** Create a git tag matching the new version
5. **Push:** Push the commit and tag to origin
6. **Release:** Create a GitHub release with `gh release create`

Stop at the first failure and report which step failed.
```

---

## Content Sizing Guide

| Command type | Target size | Max size |
| ------------ | ----------- | -------- |
| Reference command | 30–60 lines | 80 lines |
| Task-execution command | 20–40 lines | 60 lines |
| Code generation command | 20–40 lines | 60 lines |
| Research command | 15–30 lines | 50 lines |
| Workflow automation command | 30–60 lines | 80 lines |

If a command exceeds its max size, move supporting detail (templates,
reference tables, examples) to `references/` files and link with explicit
trigger conditions. The command body is a control plane, not a manual.
