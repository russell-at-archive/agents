# Writing Meta-Primes: Examples

## Contents

- Example 1: Lean context prime (simple command file)
- Example 2: Onboarding prime (full skill with references)
- Example 3: Setup prime (environment configuration)
- Example 4: Architecture tour prime
- Common mistakes and corrections

---

## Example 1: Lean Context Prime

**File:** `.claude/commands/prime.md`
**Purpose:** Load project context at the start of every session.
**Format:** Simple command file (no supporting files needed)

```markdown
---
name: prime
description: Primes Claude with full project context for this session. Run
  at session start or when asked to load project context.
disable-model-invocation: true
context: fork
agent: Explore
allowed-tools: Read, Glob, Grep
---

# Project Context Prime

This is the inventory management API — a REST service that tracks warehouse
stock, orders, and shipments for the logistics platform. All HTTP handlers
live in `src/api/`, all business logic in `src/services/`.

## Current State

Branch: !`git branch --show-current`
Recent work: !`git log --oneline -5`
Pending changes: !`git status --short`

## Key Files

- `@README.md` — project overview and quick-start commands
- `@src/api/` — HTTP route handlers; one file per resource
- `@src/services/` — business logic; all database access goes through here
- `@src/models/` — Zod schemas and TypeScript types
- `@docs/architecture.md` — service boundaries and data flow

## Conventions

- All service methods must be idempotent — check before adding write logic
- Database queries use the query builder in `src/db/`; never write raw SQL
- All API responses follow the envelope format in `src/api/response.ts`
- Tests live adjacent to source files as `*.test.ts`

## Before Starting Any Task

1. Read the relevant service file before modifying it
2. Run `npm test` before and after changes
3. If touching database schema, check `docs/adr/` for migration constraints
```

---

## Example 2: Onboarding Prime

**Directory:** `.claude/skills/onboard/`
**Purpose:** Full developer onboarding from zero to first PR.
**Format:** Skill with SKILL.md + supporting reference files

### `SKILL.md`

```markdown
---
name: onboard
description: Guides new developers through full onboarding: environment setup,
  codebase orientation, and first-contribution workflow. Use when a new team
  member joins, when asked "how do I get started?", or when setting up a fresh
  dev environment.
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Bash(npm *), Bash(make *)
---

# Developer Onboarding

Welcome to the team. This guide takes you from zero to first PR in three steps.

## Step 1: Environment Setup (5–10 minutes)

Follow [references/setup.md](references/setup.md) to install dependencies,
configure environment variables, and verify your local environment is ready.

**Done when:** `make verify` exits with no errors.

## Step 2: Codebase Orientation (15 minutes)

Read [references/codebase.md](references/codebase.md) for an overview of the
directory structure, key patterns, and conventions you'll encounter most.

**Done when:** You can answer: where does a new API route go? Where does
business logic live? How are tests organized?

## Step 3: First Contribution (30 minutes)

See [references/workflow.md](references/workflow.md) for the branch, commit,
and PR process. Pick a `good-first-issue` from the backlog and follow the
workflow.

**Done when:** You've opened a draft PR and assigned it for review.

## Getting Help

- `#dev-help` Slack channel for environment issues
- `#eng-general` for architecture questions
- Pair with your onboarding buddy for anything else
```

### `references/setup.md` (excerpt)

```markdown
# Environment Setup

## Prerequisites

Verify these are installed before starting:

```bash
node --version   # must be 18+
npm --version    # must be 9+
docker --version # must be 20+
```

If any are missing, see the installation guide at @docs/toolchain.md.

## Install Dependencies

```bash
npm install
```

Verify: `npm ls --depth=0` should show no errors.

## Configure Environment

```bash
cp .env.example .env.local
```

Edit `.env.local` and fill in the values from the team password manager
(ask your onboarding buddy for access). Required keys are documented in
@docs/env-vars.md.

## Start Local Services

```bash
docker compose up -d
make migrate
```

Verify: `docker compose ps` should show all services as `running (healthy)`.

## Full Verification

```bash
make verify
```

This runs the test suite and a smoke test against local services. All checks
must pass before you start coding.
```

---

## Example 3: Setup Prime

**File:** `.claude/commands/setup.md`
**Purpose:** First-time environment configuration for a complex local stack.

```markdown
---
name: setup
description: Configures the local development environment from scratch.
  Use when setting up a new machine, after a major dependency upgrade, or
  when the local environment is broken and needs to be rebuilt.
disable-model-invocation: true
allowed-tools: Read, Bash(brew *), Bash(npm *), Bash(docker *), Bash(make *)
---

# Local Environment Setup

This guide configures the full local stack: Node, PostgreSQL, Redis, and the
app server. Follow each step in order and verify before continuing.

## Step 1: System Dependencies

Check required tools:

```bash
node --version   # need 18+
psql --version   # need 14+
redis-cli --version # need 7+
```

If anything is missing:
- macOS: `brew install node@18 postgresql@14 redis`
- Ubuntu: see @docs/linux-setup.md

## Step 2: Node Dependencies

```bash
npm install
```

Verify:

```bash
npm ls --depth=0
```

No errors should appear. Peer dependency warnings are acceptable; errors are not.

## Step 3: Database Setup

```bash
createdb myapp_development
npm run db:migrate
npm run db:seed
```

Verify:

```bash
psql myapp_development -c "SELECT COUNT(*) FROM users;"
```

Should return at least one row from seed data.

## Step 4: Environment Variables

```bash
cp .env.example .env.local
```

Open `.env.local` and set:

- `DATABASE_URL` — use `postgresql://localhost/myapp_development`
- `REDIS_URL` — use `redis://localhost:6379`
- `SECRET_KEY_BASE` — generate with `openssl rand -hex 64`
- `API_KEY` — get from the team password manager

## Step 5: Start Services

```bash
npm run dev
```

Verify (in a second terminal):

```bash
curl -s http://localhost:3000/health | python3 -m json.tool
```

Should return `{"status": "ok"}`.

## Step 6: Run Full Test Suite

```bash
npm test
```

All tests must pass before starting development work. If any tests fail, check
@docs/known-issues.md before debugging from scratch.
```

---

## Example 4: Architecture Tour Prime

**File:** `.claude/commands/tour.md`
**Purpose:** Orient Claude to system architecture before touching complex code.

```markdown
---
name: tour
description: Orients Claude to the system architecture, service boundaries, and
  key design decisions. Run before modifying shared infrastructure, the auth
  system, or any cross-service workflow.
disable-model-invocation: true
context: fork
agent: Explore
allowed-tools: Read, Glob, Grep
---

# Architecture Tour

This is a multi-service platform with four main components. Read this before
modifying any shared infrastructure or cross-service code.

## Components

- **API Gateway** (`services/gateway/`) — public-facing HTTP layer; handles
  auth, rate limiting, and request routing to downstream services
- **User Service** (`services/users/`) — identity, authentication, and
  authorization; owns the `users` and `sessions` tables
- **Billing Service** (`services/billing/`) — Stripe integration, subscription
  management; communicates with User Service via gRPC
- **Worker** (`services/worker/`) — async job processing; consumes from the
  shared Redis queue

## Data Flow

```
Client → API Gateway → (User Service for auth)
                     → (Billing Service for payment routes)
                     → (Worker enqueues async jobs)
```

All inter-service communication is internal gRPC. No service calls another's
database directly.

## Key Design Decisions

- Auth tokens are validated at the gateway; downstream services trust the
  `X-User-Id` header. Do not re-validate in downstream services.
- Billing is eventually consistent with user state. Webhooks from Stripe are
  processed by the Worker, not the Billing Service directly.
- The `users` table is owned exclusively by User Service. Other services store
  only the `user_id` foreign key.

For the full ADR list: read `@docs/adr/` — sort by number, ADR-001 is the
most important for new contributors.

## Where to Look for Each Change Type

| Change type | Start here |
| ----------- | ---------- |
| New API endpoint | `services/gateway/src/routes/` |
| Auth logic | `services/users/src/auth/` |
| Payment flow | `services/billing/src/` + Stripe docs |
| Background job | `services/worker/src/jobs/` |
| Shared database schema | `db/migrations/` — check with DBA first |

## Before Modifying Shared Infrastructure

1. Read the relevant ADR in `@docs/adr/`
2. Check if a migration is needed — schema changes require a zero-downtime plan
3. Confirm with the platform team in `#platform-eng` before PRing
```

---

## Common Mistakes and Corrections

### Mistake 1: Open-ended exploration

```markdown
# Bad
Explore the codebase to understand the project structure and conventions.

# Good
Read @README.md for the project overview. Key source is in @src/api/ (HTTP
handlers) and @src/services/ (business logic). Conventions are in @CONTRIBUTING.md.
```

**Why:** "Explore the codebase" gives Claude no stopping point. It will read
dozens of files looking for "the thing to understand." Scoped references with
explicit reasons are faster and cheaper.

---

### Mistake 2: Missing verification in setup primes

```markdown
# Bad
Run `npm install` to install dependencies. Then copy `.env.example` to `.env.local`.

# Good
Run `npm install`.
Verify: `npm ls --depth=0` should show no errors.

Copy `.env.example` to `.env.local` and fill in the required keys (see @docs/env-vars.md).
Verify: `cat .env.local | grep -c 'your-value-here'` should return 0.
```

**Why:** Setup primes without verification leave Claude (and developers) unable
to detect when a step silently fails.

---

### Mistake 3: Missing `disable-model-invocation`

```markdown
# Bad (prime auto-triggers on "load context" messages)
---
name: prime
description: Loads project context. Use when loading context.
---

# Good
---
name: prime
description: Loads project context at session start.
disable-model-invocation: true
---
```

**Why:** Without `disable-model-invocation: true`, Claude may auto-invoke the
prime mid-session whenever the description keywords match, loading redundant
context into an already-active session.

---

### Mistake 4: Unbounded dynamic injection

```markdown
# Bad (can produce thousands of lines)
Available scripts: !`cat package.json`
Project files: !`find . -name "*.ts"`

# Good (bounded output)
Available scripts: !`cat package.json | python3 -c "import sys,json; [print(f'  {k}') for k in json.load(sys.stdin).get('scripts',{}).keys()]"`
Recent changes: !`git log --oneline -5`
```

**Why:** Unbounded injection can flood the context window with irrelevant data,
leaving less room for the actual task.

---

### Mistake 5: Prime that also executes work

```markdown
# Bad (prime that also writes files)
---
name: prime
description: Load context and create initial scaffolding.
---

Read @README.md, then create a `src/new-feature/` directory with the standard
structure.

# Good (separate commands)
# prime.md — only loads context
# scaffold.md — creates the directory structure
```

**Why:** Primes that mix context loading with task execution are unpredictable —
they fire once at session start (for context) and again during work (for the
task). Keep them separate.
