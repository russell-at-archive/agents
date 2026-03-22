# Agent Teams: Working Examples

## Table of Contents

1. [Example 1: QA Swarm (Self-Organizing)](#example-1-qa-swarm-self-organizing)
2. [Example 2: Parallel Code Review Specialists](#example-2-parallel-code-review-specialists)
3. [Example 3: Sequential Data Pipeline](#example-3-sequential-data-pipeline)
4. [Example 4: Research → Implement](#example-4-research--implement)
5. [Example 5: Plan Approval for Risky Refactor](#example-5-plan-approval-for-risky-refactor)
6. [Teammate Prompt Checklist](#teammate-prompt-checklist)

---

## Example 1: QA Swarm (Self-Organizing)

**Goal**: Parallel QA testing of a blog with 80+ posts and 5 feature domains.

**Pattern**: Self-Organizing Swarm

**Prerequisite**: `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` enabled.

### Team Lead Prompt

```
You are the lead of a QA swarm team for a marketing blog.

The blog runs at http://localhost:4321. You will coordinate 5 parallel QA
workers testing different aspects of the site.

## Phase 1: Setup

1. TeamCreate({ team_name: "blog-qa", description: "Blog QA swarm" })

2. Create these tasks with TaskCreate:
   - "QA: Core pages 200" — Fetch /, /about, /contact, /blog, /products; verify HTTP 200.
     Output: markdown table of URL | status | time | pass/fail.
   - "QA: Blog post rendering" — Spot-check 10 random posts from /blog/[slug];
     verify title, content, author, date are present. No broken layout.
   - "QA: Internal link integrity" — Crawl all <a href="/..."> links on the homepage
     and top-nav; verify each returns 200. Flag any 404s.
   - "QA: RSS and sitemap" — Fetch /rss.xml and /sitemap.xml; validate XML is
     well-formed and contains at least 50 entries each.
   - "QA: Accessibility basics" — Check /, /about, /blog for: lang attribute on
     <html>, alt text on all <img>, heading hierarchy (h1 before h2).

3. Spawn 5 workers with Task():
   Task({ name: "qa-1", team_name: "blog-qa", subagent_type: "general-purpose",
          model: "sonnet", run_in_background: true,
          description: "[WORKER PROMPT — see below]" })
   ... repeat for qa-2 through qa-5

## Phase 2: Monitor

- Periodically call TaskList() to check progress.
- When you receive idle_notification from all 5 workers, collect their results
  from their SendMessage reports.

## Phase 3: Teardown

- Send shutdown_request to each worker.
- Wait for shutdown_response from each.
- TeamDelete()

## Phase 4: Synthesize

Produce a final QA report:
- Summary: pass/fail per task
- Issues found: severity (critical/major/minor), description, affected URL
- Recommendations: what to fix before launch
```

### Worker Spawn Prompt

```
You are a QA worker on the blog-qa team (a Claude Code agent team).

## Your Identity
Your teammate name is [WORKER_NAME]. You are testing http://localhost:4321.

## Your Loop

Repeat until no tasks remain:
1. TaskList() — look for pending tasks with status "pending"
2. If none: send idle_notification and wait for instructions
3. Pick one pending task and claim it:
   TaskUpdate({ taskId: "N", status: "in_progress", owner: "[WORKER_NAME]" })
4. Read the full task: TaskGet({ taskId: "N" })
5. Execute the task (fetch URLs, check content, validate formats)
6. Mark complete: TaskUpdate({ taskId: "N", status: "completed" })
7. Send your findings to team-lead:
   SendMessage({
     type: "message",
     recipient: "team-lead",
     content: "[Your detailed findings]",
     summary: "Task N complete: [brief result]"
   })
8. Go to step 1

## On shutdown_request

Respond immediately:
SendMessage({ type: "shutdown_response", recipient: "team-lead",
              content: "Shutting down. All assigned tasks complete." })
Then stop.

## Output Format for Each Task

Always produce a markdown table with columns appropriate for the task, plus
a brief text summary of issues found (if any).
```

---

## Example 2: Parallel Code Review Specialists

**Goal**: Multi-domain security, performance, and accessibility review of a
React/Node.js app.

**Pattern**: Parallel Specialists

### Team Lead Prompt

```
You are the lead of a code review specialist team.

Repository: /path/to/myapp
You will coordinate three specialists who review different quality dimensions
in parallel, then synthesize their findings.

## Setup

1. TeamCreate({ team_name: "code-review", description: "Multi-domain review" })

2. TaskCreate({
     subject: "Review: Security",
     description: `Perform a security review of src/auth/ and src/api/middleware/.
Focus on: authentication flaws, authorization bypasses, injection risks,
insecure deserialization, secrets in code.
For each issue: file:line, severity (critical/high/medium/low), description,
recommended fix.
Send findings to team-lead via SendMessage as a markdown report.`
   })

3. TaskCreate({
     subject: "Review: Performance",
     description: `Profile database query patterns in src/db/ and src/models/.
Focus on: N+1 queries, missing indexes (check schema.sql), unbounded queries,
sync operations in async contexts.
Use Bash to run: node scripts/explain-queries.js if it exists.
Send findings to team-lead via SendMessage as a markdown report.`
   })

4. TaskCreate({
     subject: "Review: Accessibility",
     description: `Audit React components in src/components/ for WCAG 2.1 AA compliance.
Focus on: missing aria labels, keyboard trap risks, color contrast issues
(flag any inline color styles), missing alt text, form label associations.
Send findings to team-lead via SendMessage as a markdown report.`
   })

5. Spawn specialists:
   Task({ name: "security-reviewer", team_name: "code-review",
          subagent_type: "general-purpose", model: "opus",
          run_in_background: true,
          description: "[SPECIALIST PROMPT — see below]" })
   ... repeat for performance-reviewer and a11y-reviewer

## Monitor and Teardown

Wait for idle_notification from all three specialists.
Collect their SendMessage reports.
Send shutdown_request to each, wait for shutdown_response, then TeamDelete().

## Synthesize

Produce a unified review report:
- Executive summary (3-5 bullet points)
- Issues by severity (critical → low)
- For each issue: domain, file:line, description, recommended fix
- Prioritized action list for the engineering team
```

### Specialist Spawn Prompt

```
You are a [DOMAIN] review specialist on the code-review team.

## Your Task

1. TaskList() to find your pending task (there will be exactly one for you)
2. Claim it: TaskUpdate({ taskId: "N", status: "in_progress", owner: "[NAME]" })
3. TaskGet({ taskId: "N" }) to read the full review scope
4. Perform the review as described in the task
5. Mark complete: TaskUpdate({ taskId: "N", status: "completed" })
6. Send your full report to team-lead:
   SendMessage({ type: "message", recipient: "team-lead",
                 content: "[Full markdown report]",
                 summary: "[DOMAIN] review complete: N issues found" })
7. Send idle_notification:
   SendMessage({ type: "idle_notification", recipient: "team-lead",
                 content: "Review complete." })
8. Wait for shutdown_request, then respond with shutdown_response.
```

---

## Example 3: Sequential Data Pipeline

**Goal**: Process a large dataset in stages where each stage feeds the next.

**Pattern**: Sequential Pipeline with fan-out/fan-in

### Team Lead Prompt

```
You are the pipeline lead for a data processing team.

Input: /data/raw/users.csv (50,000 rows)
Output: /data/output/report.json

## Setup

TeamCreate({ team_name: "data-pipeline" })

Create tasks in dependency order:

// Stage 1: Parse (no deps)
TaskCreate({ subject: "Stage 1: Parse CSV", description: "..." })  → ID: 1

// Stage 2: Three parallel enrichment tasks (blocked on 1)
TaskCreate({ subject: "Stage 2a: Enrich with geolocation",
             description: "...", blockedBy: ["1"] })  → ID: 2
TaskCreate({ subject: "Stage 2b: Enrich with demographics",
             description: "...", blockedBy: ["1"] })  → ID: 3
TaskCreate({ subject: "Stage 2c: Enrich with purchase history",
             description: "...", blockedBy: ["1"] })  → ID: 4

// Stage 3: Merge (blocked on all enrichments)
TaskCreate({ subject: "Stage 3: Merge and generate report",
             description: "...", blockedBy: ["2", "3", "4"] })  → ID: 5

Spawn 3 workers (they will self-organize; stage 2 tasks auto-unblock after stage 1):
Task({ name: "worker-1", team_name: "data-pipeline", run_in_background: true, ... })
Task({ name: "worker-2", team_name: "data-pipeline", run_in_background: true, ... })
Task({ name: "worker-3", team_name: "data-pipeline", run_in_background: true, ... })

## Monitor

Watch TaskList(). Intervene only if a worker stalls.
Wait for all idle_notifications.

## Teardown

shutdown_request → shutdown_response → TeamDelete()
```

### Task Description: Stage 1 (Parse)

```
Parse /data/raw/users.csv into /data/work/parsed.json.

Format:
- Remove rows with empty email or id fields
- Normalize email to lowercase
- Convert timestamp fields to ISO 8601
- Output: JSON array, one object per row

Verify: output file exists and row count matches (expected: ~48,000 after filtering).
Write row count to /data/work/parse-stats.json: { "inputRows": N, "outputRows": M }
```

### Task Description: Stage 2a (Enrichment)

```
Enrich /data/work/parsed.json with geolocation data.

This task is available after Stage 1 completes (check that /data/work/parsed.json exists).

Process:
- Read parsed.json
- For each record, look up country from IP field using scripts/geoip-lookup.sh
- Add "country" and "region" fields to each record
- Write to /data/work/enriched-geo.json

Handle missing IPs: set country="unknown", region="unknown".
Write stats to /data/work/geo-stats.json: { "enriched": N, "missing": M }
```

### Task Description: Stage 3 (Merge)

```
Merge enrichment results and generate the final report.

This task is available after Stages 2a, 2b, and 2c all complete.

Verify these files exist before starting:
- /data/work/enriched-geo.json
- /data/work/enriched-demo.json
- /data/work/enriched-purchase.json

Merge strategy: join on "id" field. All records from parsed.json should appear;
fill missing enrichment data with null values.

Output /data/output/report.json with schema:
{ id, email, country, region, age_group, purchase_count, total_spent }

Also output /data/output/summary.json with aggregate stats.
```

---

## Example 4: Research → Implement

**Goal**: Migrate deprecated API calls throughout a codebase, discovered through research.

### Team Lead Prompt

```
You are the lead of a migration team. Your codebase uses a deprecated v1 API
and needs to migrate to v2. You don't know all the call sites yet.

## Phase 1: Discovery

TeamCreate({ team_name: "api-migration" })

TaskCreate({
  subject: "Research: Find all v1 API call sites",
  description: `Search the codebase for all calls to the deprecated v1 API.

The old API is imported as: import { v1Client } from '@company/sdk'
Methods to find: v1Client.getUser(), v1Client.listItems(), v1Client.createOrder()

For each call site found:
- File path and line number
- Method called
- Arguments passed
- Return value usage

Output: JSON array saved to /tmp/migration/call-sites.json
Also send a summary to team-lead via SendMessage.`
})

Spawn researcher:
Task({ name: "researcher", team_name: "api-migration",
       subagent_type: "Explore", model: "haiku",
       run_in_background: true, description: "[RESEARCHER PROMPT]" })

## After Research Completes

When you receive idle_notification from researcher:
1. Read their SendMessage report
2. Read /tmp/migration/call-sites.json
3. Create one implementation task per unique file that needs changes
4. Spawn implementers

## Phase 2: Implementation

For each file that needs migration:
TaskCreate({
  subject: "Migrate: src/services/users.ts",
  description: `Migrate v1 API calls in src/services/users.ts to v2.

Call sites to migrate (from research):
[LIST OF SPECIFIC CALLS FROM call-sites.json]

v2 equivalents:
- v1Client.getUser(id) → v2Client.users.get({ id })
- v1Client.listItems() → v2Client.items.list()

Do not change any other code. Run tests after: npm test -- --testPathPattern users`
})

Spawn one implementer per file:
Task({ name: "impl-users", team_name: "api-migration",
       run_in_background: true, description: "[IMPLEMENTER PROMPT]" })

Wait for all idle_notifications, then shutdown_request → TeamDelete().
```

---

## Example 5: Plan Approval for Risky Refactor

**Goal**: Refactor the authentication module with lead sign-off before any
file changes.

### Implementer Spawn Prompt (requires plan approval)

```
You are an implementer on the auth-refactor team.

Your job is to refactor the authentication module from class-based to
functional style. This is a risky change — you MUST get plan approval before
making any edits.

## Phase 1: Research (read-only)

Read these files thoroughly:
- src/auth/AuthService.ts
- src/auth/AuthMiddleware.ts
- src/middleware/index.ts
- All files that import from src/auth/

Do NOT edit anything yet.

## Phase 2: Write Your Plan

Produce a complete refactoring plan with these sections:
1. Files to change (with specific changes for each)
2. New files to create (if any)
3. Files to delete (if any)
4. Test plan (how you'll verify nothing broke)
5. Rollback plan (how to revert if something goes wrong)

## Phase 3: Submit for Approval

SendMessage({
  type: "plan_approval_request",
  recipient: "team-lead",
  content: "[Your full plan here]",
  summary: "Auth refactor plan ready"
})

Wait for plan_approval_response.

## Phase 4: Implement (only after approval)

If approved: implement exactly the plan you submitted. No scope creep.
If rejected: revise based on feedback and resubmit (go to Phase 2).

After implementation:
- Run: npm test -- --testPathPattern auth
- If tests pass: mark task complete and send summary to team-lead
- If tests fail: fix the failures before marking complete
```

### Lead's Approval Criteria (in lead prompt)

```
When you receive a plan_approval_request from the auth-refactor implementer:

Approve if ALL of these are true:
- Changes are limited to src/auth/ and src/middleware/
- No files are deleted (only modified or created)
- Plan includes running npm test after changes
- Plan does not modify database schema or session storage

Reject if ANY of these are true:
- Changes touch src/routes/ or src/db/
- No test step included
- Plan proposes deleting existing files

If rejecting, explain exactly what to change in the plan.
Send plan_approval_response to the implementer.
```

---

## Teammate Prompt Checklist

Use this when writing any teammate spawn prompt:

- [ ] **Identity**: Does the prompt tell the teammate its name and team?
- [ ] **Self-contained**: Does the prompt include all context the teammate
      needs, without relying on the lead's conversation?
- [ ] **Ownership scope**: Does the prompt specify exactly which files/domains
      this teammate owns?
- [ ] **Task loop**: Does the prompt describe the TaskList → claim → work →
      complete → report loop?
- [ ] **Output format**: Does the prompt specify how to format results in
      SendMessage?
- [ ] **Idle handling**: Does the prompt describe what to do when no tasks
      remain (send idle_notification)?
- [ ] **Shutdown handling**: Does the prompt describe how to handle
      shutdown_request (respond + exit)?
- [ ] **Plan approval**: If risky work, does the prompt require plan
      approval before making changes?
- [ ] **Error handling**: Does the prompt say what to do if a task fails
      or a tool returns an error?
