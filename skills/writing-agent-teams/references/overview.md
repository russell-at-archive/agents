# Agent Teams: Concepts and Architecture

## Table of Contents

1. [What Are Agent Teams?](#what-are-agent-teams)
2. [Architecture](#architecture)
3. [Enabling Agent Teams](#enabling-agent-teams)
4. [Subagents vs Agent Teams](#subagents-vs-agent-teams)
5. [Team Lifecycle](#team-lifecycle)
6. [Task System](#task-system)
7. [Messaging System](#messaging-system)
8. [Display Modes](#display-modes)
9. [Quality Gates](#quality-gates)
10. [Token Cost Model](#token-cost-model)
11. [Limitations](#limitations)

---

## What Are Agent Teams?

Agent teams are an experimental Claude Code feature (v2.1.32+) that lets you
orchestrate multiple fully-independent Claude Code instances working together on
a shared project. One session acts as the **team lead**, which creates the team,
spawns teammates, and coordinates work via a shared task list and message
mailboxes.

---

## Architecture

An agent team has four components:

| Component | Role |
|---|---|
| Team lead | Main Claude Code session; creates the team, spawns teammates, coordinates |
| Teammates | Separate Claude instances; each has its own independent context window |
| Task list | Shared work queue (`pending` → `in_progress` → `completed`) with dependency tracking |
| Mailbox | Async messaging system for agent-to-agent communication |

**Storage locations:**

```
~/.claude/teams/{team-name}/config.json          # team membership
~/.claude/teams/{team-name}/inboxes/{agent}.json # per-agent mailbox
~/.claude/tasks/{team-name}/1.json               # task files
```

**Team config structure:**

```json
{
  "name": "my-team",
  "leadAgentId": "team-lead@my-team",
  "members": [
    {
      "agentId": "worker-1@my-team",
      "name": "worker-1",
      "agentType": "general-purpose",
      "backendType": "in-process",
      "cwd": "/path/to/project"
    }
  ]
}
```

---

## Enabling Agent Teams

Set the environment variable in your shell or in `settings.json`:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

Or per-session:

```bash
CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 claude
```

Requires Claude Code v2.1.32+. Verify with `claude --version`.

---

## Subagents vs Agent Teams

| Aspect | Subagents (Agent tool) | Agent Teams |
|---|---|---|
| Context | Own window; result returns to caller | Own window; fully independent |
| Communication | Hub-and-spoke through main agent only | Direct agent-to-agent mesh |
| Coordination | Main agent manages all work | Shared task list with self-coordination |
| History | Main agent reads subagent output | Lead does not read teammate transcripts directly |
| Token cost | ~1.5–2× per subagent | ~3–4× per teammate |
| Best for | Focused tasks where only the result matters | Complex work requiring peer coordination |

**Rule of thumb**: use subagents when you need the output; use teams when you
need the agents to coordinate with each other.

---

## Team Lifecycle

### Phase 1: Setup (Lead)

```
TeamCreate → TaskCreate (×N) → Task (spawn teammate, run_in_background: true) ×N
```

1. `TeamCreate` — registers the team and creates storage directories.
2. `TaskCreate` — creates all tasks up front; define dependencies now.
3. Spawn each teammate via `Task` with `team_name` and `run_in_background: true`.

### Phase 2: Execution

**Lead responsibilities:**
- Monitor progress via `TaskList`
- Handle `idle_notification` messages from teammates
- Respond to `plan_approval_request` if plan approval is required
- Intervene on stuck or failed tasks
- Synthesize results

**Teammate responsibilities (self-organizing):**
- Poll `TaskList` to find unclaimed `pending` tasks
- Claim a task via `TaskUpdate` (set `status: in_progress`, `owner: self`)
- Do the work; mark complete via `TaskUpdate` (set `status: completed`)
- Send `idle_notification` to lead when done

### Phase 3: Teardown (Lead)

```
SendMessage (shutdown_request) → wait for shutdown_response → TeamDelete
```

Send `shutdown_request` to each teammate. Wait for `shutdown_response`. Then
call `TeamDelete` to clean up all team resources.

---

## Task System

Tasks are the coordination primitive. Each task is a JSON file on disk with
file-locking to prevent race conditions.

**Task states:**

```
pending → in_progress → completed
```

**Task fields:**

| Field | Description |
|---|---|
| `subject` | Short one-line title (shown in task list UI) |
| `description` | Full working brief; treated as the agent's prompt for this task |
| `activeForm` | Spinner text shown in the UI while in_progress |
| `status` | `pending`, `in_progress`, `completed` |
| `owner` | Agent name that claimed the task |
| `blockedBy` | Array of task IDs that must complete first |

**Dependency resolution**: tasks with `blockedBy` entries cannot be claimed
until all blocking tasks are `completed`. No manual polling required.

**Best practices for task descriptions:**
- Write task descriptions as self-contained briefs — the agent reads only this
  for context, not the lead's conversation
- Include: what to do, where to find inputs, what constitutes success
- Specify output format if the lead needs to aggregate results
- Be explicit about scope boundaries (which files/domains this task covers)

---

## Messaging System

Agents communicate via `SendMessage`. Messages are delivered asynchronously to
the recipient's mailbox file.

### Message Types

| Type | Direction | Description |
|---|---|---|
| `message` | Any → any | Direct message to one specific agent |
| `broadcast` | Lead → all | Sends to all teammates simultaneously |
| `shutdown_request` | Lead → teammate | Request graceful shutdown |
| `shutdown_response` | Teammate → lead | Acknowledges shutdown (approve or reject) |
| `plan_approval_request` | Teammate → lead | Submit plan for review before implementing |
| `plan_approval_response` | Lead → teammate | Approve or reject plan with feedback |
| `idle_notification` | Teammate → lead | Auto-sent when teammate finishes a turn |

**`idle_notification`** includes a `completedTaskId` field — the lead uses this
to track completion and decide whether to assign more work or shut the teammate
down.

**`broadcast` cost warning**: broadcast scales with team size. Each broadcast
costs one full message per teammate. Use sparingly; prefer direct `message` for
targeted communication.

---

## Display Modes

| Mode | Behavior | Requirement |
|---|---|---|
| `auto` (default) | Split panes if in tmux/iTerm2; in-process otherwise | — |
| `in-process` | All teammates in main terminal; cycle with Shift+Down | Any terminal |
| `tmux` | Each teammate in own pane/window | tmux or iTerm2 |

Set in `settings.json`:

```json
{ "teammateMode": "in-process" }
```

Or per-session:

```bash
claude --teammate-mode in-process
```

**Split panes are NOT supported** in: VS Code integrated terminal, Windows
Terminal, Ghostty. Always recommend `in-process` for those environments.

**Keyboard shortcuts (in-process mode):**
- `Shift+Down` — cycle through teammates
- `Enter` — view a teammate's session
- `Escape` — interrupt their current turn
- `Ctrl+T` — toggle task list

---

## Quality Gates

### Plan Approval Workflow

For destructive or irreversible tasks, require teammates to plan before acting:

1. Spawn the teammate with instructions to submit a plan before implementing.
2. Teammate works in read-only plan mode and sends `plan_approval_request`.
3. Lead reviews and sends `plan_approval_response` (approve or reject with
   feedback).
4. If rejected, teammate revises; if approved, proceeds to implementation.

### Hooks

Two hooks run at the team boundary:

**TeammateIdle** — runs when a teammate is about to go idle:

```bash
#!/bin/bash
# Exit 2 to keep teammate working with feedback; exit 0 to allow idle
if [ ! -f "./expected-output.txt" ]; then
  echo "Expected output file not found. Task incomplete." >&2
  exit 2
fi
exit 0
```

**TaskCompleted** — runs when a task is being marked complete:

```bash
#!/bin/bash
# Exit 2 to block completion; exit 0 to allow
INPUT=$(cat)  # JSON with task_id, task_subject, teammate_name
if ! npm test -- --silent 2>&1; then
  echo "Tests failing. Fix before marking complete." >&2
  exit 2
fi
exit 0
```

Hook input JSON includes: `teammate_name`, `team_name`, `session_id`,
`transcript_path`, `cwd`, `task_id`, `task_subject`, `task_description`.

Exit code behavior:
- Exit 2 + stderr → teammate receives feedback and keeps working
- JSON `{"continue": false, "stopReason": "..."}` → stops the teammate entirely

---

## Token Cost Model

| Configuration | Approx. Token Cost |
|---|---|
| Solo session | ~200k tokens |
| 3 subagents (Agent tool) | ~440k tokens |
| 3-person team | ~800k tokens |
| 5-person team | ~1.2M tokens |

Teams are expensive. Justify the spend with genuine parallelization benefit
(wall-clock time savings, independent workstreams, peer review value).

---

## Limitations

- **No session resumption**: `/resume` and `/rewind` don't restore in-process
  teammates after a crash.
- **One team per session**: clean up (TeamDelete) before starting a new team.
- **No nested teams**: teammates cannot spawn their own teams or teammates.
- **Lead is fixed**: you cannot promote a teammate or transfer leadership.
- **Permissions set at spawn**: teammates start with the lead's permission mode;
  can be changed individually after spawn.
- **Task status lag**: teammates sometimes fail to mark tasks completed — the
  lead should monitor and intervene.
- **Shutdown is async**: teammates finish their current request before shutting
  down; plan for latency.
