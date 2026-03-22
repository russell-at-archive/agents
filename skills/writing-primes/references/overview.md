# Writing Meta-Primes: Full Reference

## Contents

- What prime commands are
- Storage formats and scoping
- Frontmatter field reference
- Prime types and when to use each
- Section structure guide (orient → navigate → instruct)
- Dynamic context injection
- File reference patterns
- Verification step requirements
- Content sizing guide

---

## What Prime Commands Are

A "prime" command is a custom Claude Code slash command whose sole purpose is
to load initial context or guide setup before work begins. It primes Claude's
working state — not to perform a task, but to prepare for all future tasks in
a session.

Prime commands differ from task-execution skills:

| Prime command | Task-execution skill |
| ------------- | ------------------- |
| Runs once at session start | Runs on demand for a specific task |
| Loads context, orients Claude | Performs work (commit, review, deploy) |
| Outcome: Claude understands the project | Outcome: a concrete artifact is produced |
| Often `disable-model-invocation: true` | Often auto-triggered by description match |

Typical prime types:

- **Context prime** — loads project structure, conventions, and current state
  into Claude's working memory for a session
- **Onboarding prime** — guides a new developer through environment setup,
  code orientation, and first-contribution workflow
- **Setup prime** — walks through environment configuration (dependencies,
  env vars, local services) with verification at each step
- **Architecture tour** — orients Claude (or a developer) to the system's
  layers, boundaries, and key design decisions before touching code

---

## Storage Formats and Scoping

Prime commands can be stored in two formats:

### Simple command file

```
.claude/commands/<name>.md
~/.claude/commands/<name>.md
```

- Single Markdown file, no frontmatter required (though supported)
- Best for lean context primes (under 80 lines)
- No supporting files — all content must be inline
- Invoked as `/<name>`

### Skill with SKILL.md

```
.claude/skills/<name>/SKILL.md
~/.claude/skills/<name>/SKILL.md
```

- Full skill directory with optional `references/`, `scripts/`, and `assets/`
- Best for onboarding primes with reference docs or setup scripts
- Supports progressive disclosure: lean `SKILL.md` + deferred reference files
- Invoked as `/<name>`

**Rule:** Use a simple command file unless the prime needs supporting files
(setup scripts, reference docs, architecture diagrams). Do not create a full
skill directory just for structure.

### Scoping

| Scope | Path | Use case |
| ----- | ---- | -------- |
| Project | `.claude/commands/` or `.claude/skills/` | Team-shared, checked into version control |
| User-global | `~/.claude/commands/` or `~/.claude/skills/` | Personal cross-project primes |

Project-scoped primes travel with the repository. User-global primes apply
everywhere. Default to project-scoped for team workflows.

---

## Frontmatter Field Reference

Prime commands support the same frontmatter as other skills:

```yaml
---
name: context-prime
description: Primes Claude with full project context before any session work.
  Use at the start of a session or when asked to load project context.
disable-model-invocation: true
context: fork
agent: Explore
allowed-tools: Read, Glob, Grep
---
```

| Field | Use in primes |
| ----- | ------------- |
| `name` | Lowercase, hyphens only, 1–64 characters. Becomes the `/name` command. |
| `description` | What the prime loads and when to run it. Include "session start" or "onboarding" as trigger keywords if appropriate. |
| `disable-model-invocation` | **Set `true` for all primes.** Primes should run only when explicitly invoked, never auto-triggered by description match. |
| `context: fork` | Runs the prime in an isolated subagent context. Use for read-only exploration primes. |
| `agent: Explore` | Use with `context: fork` for primes that only read files. Prevents accidental writes. |
| `allowed-tools` | Restrict to `Read, Glob, Grep` for context primes. Add `Bash(...)` only for setup primes that need to run commands. |

**Why `disable-model-invocation: true` matters:** Without it, Claude may
auto-invoke the prime mid-session whenever the description keywords match a
user message, polluting the conversation with redundant context loading.

---

## Prime Types and When to Use Each

### Context prime

**Purpose:** Load project understanding at session start — architecture, key
files, current state, and conventions.

**When:** Run once at the start of a Claude Code session for an unfamiliar
project or after a long break from the repo.

**Frontmatter:** `disable-model-invocation: true`, `context: fork`,
`agent: Explore`, `allowed-tools: Read, Glob, Grep`

**Body structure:**
1. Project overview (1–3 sentences)
2. Directory map (key paths and their purpose)
3. Live state injection (current branch, recent commits)
4. Conventions and constraints
5. What to do before starting any task

---

### Onboarding prime

**Purpose:** Guide a new developer through environment setup, code
orientation, and first-contribution steps.

**When:** New team member joins, or someone needs a structured walkthrough
from zero to first PR.

**Frontmatter:** `disable-model-invocation: true`, `allowed-tools: Read, Glob,
Grep, Bash(npm *), Bash(make *)` (or relevant setup commands)

**Body structure:**
1. Environment setup (install, configure, verify)
2. Codebase orientation (key directories, conventions, patterns)
3. Development workflow (branch, test, PR process)
4. Getting help (docs, contacts, Slack channels)

---

### Setup prime

**Purpose:** Configure the local environment step by step with explicit
verification at each stage.

**When:** First-time setup of a complex local environment (databases, env vars,
local services, certificates).

**Frontmatter:** `disable-model-invocation: true`, `allowed-tools: Read, Bash(*)`

**Body structure:**
1. Prerequisites check (required tools and versions)
2. Dependency installation (with verification)
3. Configuration (env vars, config files, secrets)
4. Service startup (with health checks)
5. Full verification (smoke test that everything works together)

---

### Architecture tour

**Purpose:** Orient Claude to the system's layers, boundaries, data flows,
and key design decisions.

**When:** Before touching a complex, multi-service, or legacy codebase where
architecture context is essential to safe changes.

**Frontmatter:** `disable-model-invocation: true`, `context: fork`,
`agent: Explore`, `allowed-tools: Read, Glob, Grep`

**Body structure:**
1. System overview (what it does, who uses it)
2. Component map (services, layers, databases, external dependencies)
3. Data flow (how requests move through the system)
4. Key ADRs or design decisions that constrain changes
5. Where to look first for each type of change

---

## Section Structure Guide: Orient → Navigate → Instruct

Every prime body follows the same three-phase structure:

### Phase 1: Orient

Tell Claude (or the developer) what this project is and what context will be
loaded. 2–5 sentences maximum.

```markdown
This is the payment processing service. It handles charge creation, refunds,
and webhook delivery for the billing platform. Read the architecture overview
below before touching any charge or webhook code.
```

### Phase 2: Navigate

Point to the specific files, directories, and commands that matter — with a
reason for each. Never say "explore the codebase."

```markdown
## Key Files

- `@src/charges/` — charge creation logic; all writes go through ChargeService
- `@src/webhooks/` — delivery pipeline; uses retry with exponential backoff
- `@docs/architecture.md` — system design and service boundaries
- `@CONTRIBUTING.md` — PR process, test requirements, and review SLAs
```

### Phase 3: Instruct

State explicitly what Claude should do or know before starting any task.
Include any non-obvious constraints or conventions.

```markdown
## Before Starting Any Task

1. Check the ADR for the component you're modifying (`docs/adr/`)
2. Run `make test` before and after changes — all tests must pass
3. Charges are idempotent by design — never add retry logic inside ChargeService
4. Webhooks use at-least-once delivery — consumers must be idempotent
```

---

## Dynamic Context Injection

Use `!``command`` ` to inject live project state into the prime before Claude
reads it. The command runs at invocation time; Claude sees the output, not
the command.

```markdown
## Current State

Branch: !`git branch --show-current`
Recent commits: !`git log --oneline -5`
Uncommitted changes: !`git status --short`
```

**Rules for dynamic injection:**

- Output must be bounded. Use flags like `-5`, `--short`, `--count` to limit
  output size.
- Never inject full file contents with `cat`. Reference files with `@path`
  instead, so Claude reads them with proper tooling.
- Never use unbounded commands: `find . -name "*"`, `cat large-file.json`,
  `npm list` (can be thousands of lines).
- Injection runs at invocation, not at authoring time — test the command
  manually to verify it produces bounded, useful output.

**Useful injection patterns:**

```markdown
# Current git state
!`git log --oneline -5`
!`git status --short`
!`git branch --show-current`

# Available commands
!`cat package.json | python3 -c "import sys,json; s=json.load(sys.stdin).get('scripts',{}); [print(f'{k}: {v}') for k,v in s.items()]"`

# Environment status
!`which node && node --version || echo 'node not found'`
!`which docker && docker --version || echo 'docker not found'`

# Recent test results
!`cat .last-test-run 2>/dev/null || echo 'no recent test run'`
```

---

## File Reference Patterns

Reference files using `@path` syntax for Claude to read inline, or explicit
`Read` instructions for progressive disclosure.

```markdown
# Good: named reference with reason
Read @README.md — this is the canonical project overview.

# Good: conditional reference
If you are modifying the authentication flow, read @docs/auth-design.md first.

# Good: scoped directory exploration
The main source is in @src/. Focus on @src/api/ for HTTP handlers and
@src/services/ for business logic.

# Bad: open-ended exploration
Explore the codebase to understand the project structure.

# Bad: reference without reason
See @src/utils/helpers.ts.
```

---

## Verification Step Requirements

Setup primes must include explicit verification at each major step. Do not
let Claude assume a step succeeded — require confirmation.

```markdown
## Step 2: Install dependencies

Run:
```bash
npm install
```

Verify: `node_modules/` should exist and `npm ls --depth=0` should show no
errors. If you see peer dependency warnings, check @docs/known-issues.md
before proceeding.
```

**Verification patterns by setup type:**

| Setup step | Verification command |
| ---------- | ------------------- |
| Node dependencies | `npm ls --depth=0` |
| Python dependencies | `pip check` |
| Database connection | `<db-cli> -c "SELECT 1"` or equivalent |
| Environment variables | `env | grep APP_` (or relevant prefix) |
| Service health | `curl -s localhost:<port>/health` |
| Full smoke test | `make test` or project equivalent |

---

## Content Sizing Guide

| Prime type | Target size | Max size |
| ---------- | ----------- | -------- |
| Context prime | 40–60 lines | 80 lines |
| Architecture tour | 50–80 lines | 100 lines |
| Onboarding prime (SKILL.md) | 60–80 lines | 100 lines |
| Setup prime | 80–120 lines | 150 lines |

If a prime exceeds its max size, move supporting detail to `references/` and
link with trigger conditions. The prime body stays a control plane — it
directs, it does not document.
