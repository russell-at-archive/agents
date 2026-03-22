# Agent Teams: Tool Reference

## Table of Contents

1. [TeamCreate](#teamcreate)
2. [TeamDelete](#teamdelete)
3. [TaskCreate](#taskcreate)
4. [TaskList](#tasklist)
5. [TaskGet](#taskget)
6. [TaskUpdate](#taskupdate)
7. [TaskOutput](#taskoutput)
8. [TaskStop](#taskstop)
9. [SendMessage](#sendmessage)
10. [Task (Spawn Teammate)](#task-spawn-teammate)
11. [Environment Variables](#environment-variables)

---

## TeamCreate

Creates the team namespace, config file, and task directory. Call once, before
creating tasks or spawning teammates.

**Parameters:**

| Parameter | Required | Description |
|---|---|---|
| `team_name` | Yes | Unique identifier for this team (lowercase, hyphens) |
| `description` | No | Human-readable purpose of this team |

**Example:**

```javascript
TeamCreate({
  team_name: "blog-qa",
  description: "Parallel QA team testing the marketing blog"
})
```

**Side effects:**
- Creates `~/.claude/teams/blog-qa/config.json`
- Creates `~/.claude/tasks/blog-qa/` directory
- Creates inbox directories for the lead

**Notes:**
- One team per session — call `TeamDelete` before starting a new team.
- The `team_name` must be unique within the user's Claude installation.

---

## TeamDelete

Removes all team configuration, task files, and inbox files. Call after all
teammates have shut down.

**Parameters:** None (operates on the current session's team).

**Example:**

```javascript
TeamDelete()
```

**Notes:**
- Only the lead should call `TeamDelete`.
- Will fail if called while active teammates are still running.
- Always include in the teardown phase of the lead prompt.

---

## TaskCreate

Defines a unit of work in the shared task queue. Each task is an independent
work item that a teammate can claim and execute.

**Parameters:**

| Parameter | Required | Description |
|---|---|---|
| `subject` | Yes | Short one-line title shown in the task list UI |
| `description` | Yes | Full working brief; serves as the agent's prompt for this task |
| `activeForm` | No | Spinner text shown in the UI while `in_progress` |
| `blockedBy` | No | Array of task IDs that must complete before this task can be claimed |

**Example:**

```javascript
TaskCreate({
  subject: "QA: Core pages respond 200",
  description: `Fetch each of the following pages at http://localhost:4321 and verify the response is HTTP 200:
- / (homepage)
- /about
- /contact
- /blog
- /products

For each page: record URL, status code, and response time.
Output a markdown table with columns: URL | Status | Time (ms) | Pass/Fail.
Send results to the team-lead via SendMessage when done.`,
  activeForm: "Testing core page responses"
})
```

**Notes:**
- Task descriptions are the agent's only working context — write them as
  self-contained briefs.
- Include: what to do, where to find inputs, output format, success criteria.
- Specify boundaries: which files or domains this task covers.
- Tasks are assigned IDs sequentially: "1", "2", "3", etc.

**Creating dependent tasks:**

```javascript
// Create task 1 first
TaskCreate({ subject: "Crawl all URLs", description: "..." })
// Then create task 2 that depends on task 1
TaskCreate({
  subject: "Validate all links",
  description: "...",
  blockedBy: ["1"]  // won't be claimable until task 1 is completed
})
```

---

## TaskList

Returns all tasks with their current status, owner, and metadata. Used by the
lead to monitor progress and by teammates to find available work.

**Parameters:** None.

**Example:**

```javascript
TaskList()
```

**Returns:**

```json
[
  { "id": "1", "subject": "QA: Core pages", "status": "completed", "owner": "qa-pages" },
  { "id": "2", "subject": "QA: Post rendering", "status": "in_progress", "owner": "qa-posts" },
  { "id": "3", "subject": "QA: Link integrity", "status": "pending", "owner": null }
]
```

**Status values:**

| Status | Meaning |
|---|---|
| `pending` | Available to be claimed |
| `in_progress` | Being worked on by `owner` |
| `completed` | Done |

**Notes:**
- Teammates poll `TaskList` to find unclaimed `pending` tasks.
- Tasks with unresolved `blockedBy` dependencies will show as `pending` but
  cannot be claimed until blocking tasks complete.

---

## TaskGet

Retrieves full details for a specific task, including the complete description.

**Parameters:**

| Parameter | Required | Description |
|---|---|---|
| `taskId` | Yes | The ID of the task (e.g., `"2"`) |

**Example:**

```javascript
TaskGet({ taskId: "2" })
```

**Returns:** Full task object including `subject`, `description`, `status`,
`owner`, `blockedBy`, and `activeForm`.

---

## TaskUpdate

Claims a task, marks it complete, or adds/removes dependencies.

**Parameters:**

| Parameter | Required | Description |
|---|---|---|
| `taskId` | Yes | The ID of the task to update |
| `status` | No | New status: `in_progress` or `completed` |
| `owner` | No | Agent name claiming the task (set when moving to `in_progress`) |
| `addBlockedBy` | No | Array of task IDs to add as dependencies |
| `removeBlockedBy` | No | Array of task IDs to remove from dependencies |

**Claiming a task (teammate):**

```javascript
TaskUpdate({
  taskId: "3",
  status: "in_progress",
  owner: "qa-links"  // the teammate's own name
})
```

**Completing a task (teammate):**

```javascript
TaskUpdate({
  taskId: "3",
  status: "completed"
})
```

**Adding a dependency:**

```javascript
TaskUpdate({
  taskId: "5",
  addBlockedBy: ["3", "4"]
})
```

**Notes:**
- File locking prevents two teammates from claiming the same task simultaneously.
- A teammate must claim a task before marking it complete.
- The lead can also update tasks to intervene on stuck or reassigned work.

---

## TaskOutput

Retrieves the output from a background task. Used to read results from tasks
that produce structured output.

**Parameters:**

| Parameter | Required | Description |
|---|---|---|
| `taskId` | Yes | The ID of the background task |

**Example:**

```javascript
TaskOutput({ taskId: "2" })
```

---

## TaskStop

Kills a running background task.

**Parameters:**

| Parameter | Required | Description |
|---|---|---|
| `taskId` | Yes | The ID of the task to stop |

**Example:**

```javascript
TaskStop({ taskId: "2" })
```

---

## SendMessage

Sends an asynchronous message to another agent in the team. Messages are
delivered to the recipient's mailbox and read when that agent's next turn starts.

**Parameters:**

| Parameter | Required | Description |
|---|---|---|
| `type` | Yes | Message type (see table below) |
| `recipient` | Yes | Agent name (e.g., `"team-lead"`, `"qa-pages"`) or `"all"` for broadcast |
| `content` | Yes | Full message body |
| `summary` | No | Short summary shown in the UI |
| `taskId` | No | Task ID for `idle_notification` and task-related messages |

**Message types:**

| Type | Who sends | Who receives | Purpose |
|---|---|---|---|
| `message` | Anyone | One agent | Direct communication |
| `broadcast` | Lead | All teammates | Team-wide announcements |
| `shutdown_request` | Lead | One teammate | Request graceful shutdown |
| `shutdown_response` | Teammate | Lead | Acknowledge shutdown |
| `plan_approval_request` | Teammate | Lead | Submit plan for review |
| `plan_approval_response` | Lead | Teammate | Approve or reject plan |
| `idle_notification` | Teammate (auto) | Lead | Notify lead of idle state |

**Direct message (teammate → lead):**

```javascript
SendMessage({
  type: "message",
  recipient: "team-lead",
  content: "Task #1 complete. All 16 core pages return HTTP 200. Average response time: 47ms.\n\nSee output file at /tmp/qa-results/core-pages.md",
  summary: "Core pages pass (16/16)"
})
```

**Shutdown request (lead → teammate):**

```javascript
SendMessage({
  type: "shutdown_request",
  recipient: "qa-pages",
  content: "All tasks complete. Please shut down gracefully."
})
```

**Plan approval request (teammate → lead):**

```javascript
SendMessage({
  type: "plan_approval_request",
  recipient: "team-lead",
  content: `## Refactor Plan\n\n1. Extract auth middleware to /src/middleware/auth.ts\n2. Update all 12 route files to import from new location\n3. Remove old auth code from /src/routes/index.ts\n\nEstimated impact: 13 files changed, no behavior changes.`,
  summary: "Auth refactor plan ready for review"
})
```

**Broadcast (lead → all):**

```javascript
SendMessage({
  type: "broadcast",
  recipient: "all",
  content: "Priority update: ignore /legacy/* routes, focus only on /api/* endpoints.",
  summary: "Scope change: API routes only"
})
```

**Notes:**
- `broadcast` costs one message per teammate — use sparingly.
- `idle_notification` is sent automatically by teammates; the lead does not
  send it.
- Include the `taskId` in status messages so the lead can cross-reference the
  task list.

---

## Task (Spawn Teammate)

Spawns a new teammate and adds them to the team. This is the standard `Task`
tool with team-specific parameters added.

**Parameters:**

| Parameter | Required | Description |
|---|---|---|
| `description` | Yes | The spawn prompt — the teammate's initial instructions |
| `subagent_type` | No | Agent type: `general-purpose`, `Explore`, `Plan`, `Bash`, or a custom agent name |
| `name` | Yes (for teams) | Unique teammate name within the team (e.g., `"qa-pages"`) |
| `team_name` | Yes (for teams) | Must match the name used in `TeamCreate` |
| `model` | No | `sonnet`, `opus`, `haiku`, or a full model ID |
| `run_in_background` | Yes | Must be `true` for teammates — blocks the lead if false |
| `isolation` | No | `worktree` to run in an isolated git worktree |

**Example:**

```javascript
Task({
  description: `You are a QA agent on the blog-qa team.

Your job: claim and complete QA tasks from the shared task list.

Workflow:
1. Call TaskList() to see available tasks.
2. Claim a pending task: TaskUpdate({ taskId: "N", status: "in_progress", owner: "qa-pages" })
3. Do the work described in the task description.
4. Mark complete: TaskUpdate({ taskId: "N", status: "completed" })
5. Send results to team-lead: SendMessage({ type: "message", recipient: "team-lead", ... })
6. Repeat from step 1 until no pending tasks remain.
7. When done, send: SendMessage({ type: "idle_notification", recipient: "team-lead", content: "No more tasks." })
8. Wait for shutdown_request, then respond with shutdown_response and exit.`,
  subagent_type: "general-purpose",
  name: "qa-pages",
  team_name: "blog-qa",
  model: "sonnet",
  run_in_background: true
})
```

**Notes:**
- The `description` is the teammate's only context — write it as a complete
  standalone brief.
- Do not assume the teammate knows anything from the lead's conversation.
- For custom agent types defined in `.claude/agents/`, use the agent's `name`
  field as `subagent_type`.
- Teammates auto-send `idle_notification` when they finish a turn; the lead
  should listen for this.

---

## Environment Variables

Auto-set for each teammate at spawn time:

| Variable | Value | Purpose |
|---|---|---|
| `CLAUDE_CODE_TEAM_NAME` | `"blog-qa"` | Identifies the team |
| `CLAUDE_CODE_AGENT_ID` | `"qa-pages@blog-qa"` | Fully-qualified agent ID |
| `CLAUDE_CODE_AGENT_NAME` | `"qa-pages"` | Short agent name |
| `CLAUDE_CODE_AGENT_TYPE` | `"general-purpose"` | Agent type |
| `CLAUDE_CODE_PLAN_MODE_REQUIRED` | `"false"` | Whether plan mode is required |

Teammates can read these to identify themselves in output files or log messages.
