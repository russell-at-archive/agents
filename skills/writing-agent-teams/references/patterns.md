# Agent Teams: Orchestration Patterns

## Table of Contents

1. [Choosing a Pattern](#choosing-a-pattern)
2. [Parallel Specialists](#parallel-specialists)
3. [Self-Organizing Swarm](#self-organizing-swarm)
4. [Sequential Pipeline](#sequential-pipeline)
5. [Research → Implement](#research--implement)
6. [Plan Approval Workflow](#plan-approval-workflow)
7. [Competing Hypotheses](#competing-hypotheses)
8. [Pattern Decision Guide](#pattern-decision-guide)

---

## Choosing a Pattern

Ask these questions to select the right pattern:

1. **Can the work be split into independent domains or file sets?** → Parallel Specialists or Swarm
2. **Is there a large pool of similar tasks (10+)?** → Self-Organizing Swarm
3. **Do tasks have strict ordering requirements?** → Sequential Pipeline
4. **Does implementation require research first?** → Research → Implement
5. **Is any step risky or irreversible?** → Plan Approval Workflow
6. **Are there multiple competing theories to test?** → Competing Hypotheses

---

## Parallel Specialists

**When to use**: Work decomposes into distinct domains where each domain
requires a different type of expertise or different access to files. Results
are aggregated by the lead.

**Structure:**
- Lead spawns one specialist per domain simultaneously
- Each specialist owns its domain exclusively
- Lead collects findings and synthesizes

**Task structure**: Pre-assign tasks to specific teammates (no self-claiming
needed). Each teammate gets one task that covers its entire domain.

**Lead prompt template:**

```
You are the lead of a multi-specialist review team.

Your job:
1. Call TeamCreate({ team_name: "X", description: "Y" })
2. Create one task per specialist domain (TaskCreate)
3. Spawn each specialist with Task(..., run_in_background: true)
4. Wait for all idle_notifications from all specialists
5. Collect results and synthesize a final report
6. Send shutdown_request to each specialist
7. Call TeamDelete()

Specialist domains:
- security: analyze for vulnerabilities in src/auth/
- performance: profile database queries in src/db/
- accessibility: check UI components in src/components/

Each specialist should read their task via TaskGet, do the work, and send
results back to you via SendMessage before marking the task complete.
```

**Best for**: Code review, QA audits, multi-domain analysis.

---

## Self-Organizing Swarm

**When to use**: Large pool of similar, independent tasks (10+). Workers
self-assign from the pool; the fastest workers naturally pick up more tasks.

**Structure:**
- Lead creates all tasks up front
- Lead spawns N generic workers
- Workers compete to claim tasks (file locking prevents duplicates)
- Natural load balancing: faster workers claim more tasks

**Task structure**: All tasks in the shared pool; no pre-assignment. Workers
poll `TaskList`, claim available tasks, complete them, repeat.

**Lead prompt template:**

```
You are the lead of a QA swarm team.

Your job:
1. TeamCreate({ team_name: "qa-swarm" })
2. Create all QA tasks with TaskCreate (one per URL/component/file)
3. Spawn 4 worker teammates with Task(..., name: "worker-N", run_in_background: true)
4. Monitor progress with TaskList periodically
5. When all tasks complete, send shutdown_request to all workers
6. TeamDelete()

Workers are self-organizing — they claim and complete tasks independently.
Your job during execution is to monitor and intervene only on failures.
```

**Worker prompt template:**

```
You are a QA worker on the qa-swarm team.

Your loop:
1. TaskList() — find pending tasks
2. If none pending: send idle_notification to team-lead and wait
3. TaskUpdate({ taskId: "N", status: "in_progress", owner: "worker-N" })
4. Do the work (TaskGet to read full description)
5. TaskUpdate({ taskId: "N", status: "completed" })
6. SendMessage to team-lead with your findings
7. Go to step 1

On shutdown_request: respond with shutdown_response and exit.
```

**Best for**: URL crawling, test execution, file processing, anything with
many uniform work items.

---

## Sequential Pipeline

**When to use**: Tasks have clear ordering requirements. Each stage feeds
into the next. Use `blockedBy` to enforce ordering — tasks auto-unblock when
predecessors complete.

**Structure:**
- Lead creates all tasks with explicit `blockedBy` dependencies
- Workers can be spawned all at once; they wait for dependencies to clear
- Earlier tasks unblock later tasks automatically

**Task dependency example:**

```
TaskCreate({ subject: "Stage 1: Crawl URLs" })              # ID: 1
TaskCreate({ subject: "Stage 2: Validate links",
             blockedBy: ["1"] })                             # ID: 2, waits for 1
TaskCreate({ subject: "Stage 3: Generate report",
             blockedBy: ["2"] })                             # ID: 3, waits for 2
```

**Notes:**
- Workers poll `TaskList` and only claim tasks whose dependencies are resolved.
- You can mix sequential and parallel: make stages 2a and 2b both block on 1
  but not on each other — they run in parallel after stage 1.
- For fan-out/fan-in: many tasks blocked on one; then one task blocked on all.

**Fan-out/fan-in example:**

```
TaskCreate({ subject: "Parse all input files" })            # ID: 1
TaskCreate({ subject: "Process chunk A", blockedBy: ["1"] })  # ID: 2
TaskCreate({ subject: "Process chunk B", blockedBy: ["1"] })  # ID: 3
TaskCreate({ subject: "Process chunk C", blockedBy: ["1"] })  # ID: 4
TaskCreate({ subject: "Merge results",
             blockedBy: ["2","3","4"] })                     # ID: 5
```

---

## Research → Implement

**When to use**: Implementation quality depends on upfront research that the
lead cannot predict. A research phase produces findings; an implementation
phase consumes them.

**Structure:**
- Phase 1: Spawn a researcher (or use an Explore subagent) to gather
  information and produce a structured findings document.
- Phase 2: Lead reads the findings and creates implementation tasks based on
  what was discovered.
- Phase 3: Spawn implementers with the findings embedded in their prompts.

**Key difference from Sequential Pipeline**: Phase 2 tasks don't exist yet
at team creation time — the lead creates them dynamically after Phase 1 results
arrive.

**Lead prompt template:**

```
You are a research-then-implement team lead.

Phase 1:
1. TeamCreate({ team_name: "research-impl" })
2. TaskCreate({ subject: "Research: identify all API endpoints" })
3. Spawn researcher: Task({ name: "researcher", subagent_type: "Explore", ... })
4. Wait for idle_notification from researcher

Phase 2 (after research completes):
5. Read researcher's findings from their SendMessage result
6. Create implementation tasks based on findings (TaskCreate × N)
7. Spawn implementers: Task({ name: "impl-N", ... }) × N
8. Wait for all idle_notifications
9. Send shutdown_requests, then TeamDelete()
```

**Notes:**
- The researcher's `SendMessage` to the lead should include structured output
  (JSON or markdown table) that the lead can parse to create implementation tasks.
- For the researcher, use `subagent_type: "Explore"` for read-only codebase
  research (cheaper, uses Haiku by default).

---

## Plan Approval Workflow

**When to use**: A step is risky, irreversible, or requires human (or lead)
sign-off before proceeding. The teammate plans first, submits the plan, and
waits for approval before making any changes.

**Structure:**
- Teammate works in read-only mode initially
- Teammate sends `plan_approval_request` with full plan
- Lead reviews and sends `plan_approval_response` (approve or reject with feedback)
- If rejected, teammate revises; if approved, proceeds

**Teammate prompt template:**

```
You are an implementer on the refactor team.

Your job is to refactor the authentication module. Before making ANY changes:

1. Read all relevant files: src/auth/, src/middleware/, src/routes/
2. Produce a complete refactoring plan:
   - List of files to change
   - For each file: what changes will be made
   - New files to create (if any)
   - Files to delete (if any)
   - Risk assessment
3. Send the plan to team-lead:
   SendMessage({
     type: "plan_approval_request",
     recipient: "team-lead",
     content: "## Refactor Plan\n[your plan here]"
   })
4. Wait for plan_approval_response
5. If approved: implement the plan exactly as written
6. If rejected: revise based on feedback and resubmit

Do NOT make any file changes until the plan is approved.
```

**Lead prompt template (approval criteria):**

```
When you receive a plan_approval_request:
- Approve if: all changes are in src/auth/ and src/middleware/ only
- Reject if: the plan touches src/routes/ or src/db/
- Reject if: the plan proposes deleting any files
- Provide specific feedback explaining what to change

Respond with plan_approval_response.
```

---

## Competing Hypotheses

**When to use**: There are multiple plausible explanations for a bug, or
multiple implementation approaches to evaluate. Teams in parallel test
different hypotheses simultaneously and report evidence for/against each.

**Structure:**
- Lead spawns one investigator per hypothesis
- Each investigator actively tries to disprove its own hypothesis (not just
  confirm it)
- Lead aggregates evidence and reaches a conclusion

**Task design principle**: Frame each task as "prove OR disprove" — agents
that only look for confirmation introduce bias.

**Example tasks:**

```javascript
TaskCreate({
  subject: "Hypothesis A: Memory leak in connection pool",
  description: `Investigate whether the production OOM crashes are caused by a
memory leak in the database connection pool (src/db/pool.ts).

Test:
1. Add memory profiling to pool.ts
2. Simulate heavy load (use the load test script at scripts/load-test.sh)
3. Monitor connection count and memory over 5 minutes
4. Collect heap snapshots before and after

Conclude with: CONFIRMED or REFUTED, plus supporting evidence.
Send findings to team-lead via SendMessage.`
})

TaskCreate({
  subject: "Hypothesis B: Unbounded cache growth",
  description: `Investigate whether the production OOM crashes are caused by
unbounded growth of the in-memory cache (src/cache/lru.ts).
...same structure...`
})
```

**Lead aggregation prompt:**

```
After all investigators report, synthesize their findings:
1. Which hypotheses were confirmed vs. refuted?
2. Which has the strongest evidence?
3. Recommend the most likely root cause and next debugging steps.
```

---

## Pattern Decision Guide

```
Is the work homogeneous (many similar tasks)?
  Yes → Self-Organizing Swarm
  No ↓

Are tasks strictly ordered (A before B before C)?
  Yes → Sequential Pipeline
  No ↓

Do you need research before you know the implementation tasks?
  Yes → Research → Implement
  No ↓

Are there multiple theories or approaches to evaluate in parallel?
  Yes → Competing Hypotheses
  No ↓

Is any step risky or irreversible?
  Yes → Plan Approval Workflow (apply to that step)
  No ↓

Are domains clearly separable (auth vs. db vs. UI)?
  Yes → Parallel Specialists
  No → Consider a single session with sequential subagents instead
```
