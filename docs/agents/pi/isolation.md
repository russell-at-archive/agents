# Pi Agent Runtime Isolation

Specification for running pi as an ephemeral, isolated autonomous agent
worker inside a container. The container clones a fresh copy of the target
repository, performs its work, and publishes a pull request. No host
workspace is mounted.

---

## Problem Statement

Pi is "YOLO by default" — it has full filesystem and bash access with no
sandbox. Running pi directly on the host against a live working tree risks:

- Unreviewed changes to the host filesystem
- Pollution of the host working tree mid-task
- Interference between concurrent agent runs
- Mixing of agent-produced changes with in-progress human work

The goal is a container-based isolation layer that gives pi a clean,
disposable environment per task while preserving shared configuration and
credentials from the host.

---

## What This Is Not

This is **not** a devcontainer. Devcontainers are designed for long-lived,
editor-integrated development environments that mount the existing host
workspace. This pattern is an **ephemeral autonomous agent worker**:

- Launched programmatically by an orchestrating agent, not by an editor
- Each run is isolated and disposable
- Work is surfaced as a pull request, not as local file changes
- The container exits when the task is complete

---

## Architecture

```text
Host machine
├── ~/.pi/agent/                    ← bind-mount (auth, settings, extensions)
├── ~/.pi/sessions/<task-id>/       ← bind-mount read-write (scoped session storage)
├── ~/.agents/                      ← bind-mount read-only (shared skills, docs)
└── orchestrating agent             ← launches containers via shell/bash

Container (ephemeral, Linux)
└── entrypoint.sh
    ├── git clone $REPO_URL
    ├── git checkout -b agent/$TASK_ID
    ├── pi --session-dir /root/.pi/sessions/$TASK_ID \
    │       -p "/speckit.implement $FEATURE_ID"
    │   ├── reads feature spec and task list from cloned repo
    │   ├── executes implementation tasks
    │   ├── commits changes
    │   ├── opens PRs per task spec instructions
    │   └── marks issue ready for review
    ├── on failure: write FAILED marker to session dir
    └── exit
```

---

## Host Mounts

| Host path | Container path | Mode | Purpose |
| --- | --- | --- | --- |
| `~/.pi/agent/auth.json` | `/root/.pi/agent/auth.json` | read-only | API keys and OAuth tokens |
| `~/.pi/agent/settings.json` | `/root/.pi/agent/settings.json` | read-only | Global settings |
| `~/.pi/agent/models.json` | `/root/.pi/agent/models.json` | read-only | Custom model definitions |
| `~/.pi/agent/extensions/` | `/root/.pi/agent/extensions/` | read-only | Global extensions |
| `~/.pi/agent/skills/` | `/root/.pi/agent/skills/` | read-only | Global skills |
| `~/.pi/agent/prompts/` | `/root/.pi/agent/prompts/` | read-only | Global prompt templates |
| `~/.pi/agent/themes/` | `/root/.pi/agent/themes/` | read-only | Custom themes |
| `~/.pi/agent/tools/` | `/root/.pi/agent/tools/` | read-only | Custom tools |
| `~/.pi/agent/npm/` | `/root/.pi/agent/npm/` | read-only | npm-installed packages |
| `~/.pi/agent/git/` | `/root/.pi/agent/git/` | read-only | git-installed packages |
| `~/.pi/sessions/<task-id>/` | `/root/.pi/sessions/<task-id>/` | read-write | Session storage scoped to this task |
| `~/.agents/` | `/root/.agents/` | read-only | Shared skills, docs, context files |

`~/.pi/agent/bin/` is **not mounted**. It contains macOS-compiled binaries
that are non-functional on Linux. All required binaries are built into the
container image.

**Session isolation** is achieved by passing `--session-dir /root/.pi/sessions/<task-id>/`
to pi at launch. Each container writes only to its own task-scoped directory.
No container can read another container's sessions because the mount is
unique per invocation.

The project-local `.pi/` directory is **not** mounted — it lives inside the
fresh clone.

---

## Container Responsibilities

1. Receive `FEATURE_ID`, `REPO_URL`, `TASK_ID`, and `BASE_BRANCH` as
   environment variables.
2. Clone the repository into an ephemeral working directory.
3. Create a new branch scoped to the task: `agent/<task-id>`.
4. Run pi non-interactively with `/speckit.implement $FEATURE_ID` as the
   prompt, directing sessions to the scoped session directory. Pi reads the
   feature spec and task list from the cloned repo and drives the full
   implementation, PR creation, and issue status update.
5. If pi or any step exits with an error, write a `FAILED` marker file to
   the task session directory before exiting.
6. Exit cleanly.

---

## Environment Variables

| Variable | Required | Purpose |
| --- | --- | --- |
| `FEATURE_ID` | Yes | Speckit feature identifier (maps to GitHub issue and repo spec) |
| `REPO_URL` | Yes | Repository to clone (HTTPS; auth via `auth.json`) |
| `TASK_ID` | Yes | Unique identifier for this run (branch name, session dir) |
| `BASE_BRANCH` | No | Branch to PR against (default: `main`) |

GitHub and LLM provider authentication is supplied through the mounted
`~/.pi/agent/auth.json`. No credential environment variables are required
at launch time.

---

## Decisions

### Task delivery — GitHub issues

Feature tasks are stored as GitHub issues. The container entrypoint receives
an `ISSUE_ID` and fetches the full issue body via `gh issue view`. The issue
body becomes the pi task prompt. This keeps task definitions in a single
reviewable location and gives pi access to issue metadata (labels, linked
PRs, comments) via the `gh` CLI during execution.

---

### Trigger mechanism — orchestrating agent

Containers are launched by an orchestrating agent via shell script or direct
`docker run` invocation. The orchestrator is responsible for assigning
`TASK_ID`, creating the per-task session directory on the host, and managing
concurrency across simultaneous runs.

---

### GitHub and LLM authentication — `auth.json` read-only

`~/.pi/agent/auth.json` is mounted read-only. No credential environment
variables are required at container launch time.

Pi's OAuth flow has two distinct operations with different container
compatibility:

- **Initial login** (`/login`): opens a browser for the authorization code
  flow. This cannot work in a headless container and must be performed on
  the host before any container is launched.
- **Token refresh** (automatic background refresh): sends an HTTP POST to
  the provider's token endpoint using the stored refresh token. This
  requires no browser, but does require writing the new tokens back to
  `auth.json`.

Because `auth.json` is read-only, **OAuth token refresh will silently fail
inside the container**. Container runs must therefore rely on API keys for
LLM providers. OAuth tokens stored in `auth.json` from interactive host
sessions are not usable for automated container workloads.

A secondary reason to avoid OAuth in containers: OAuth refresh tokens are
typically single-use. Concurrent containers sharing the same `auth.json`
and attempting simultaneous refresh would race — one container would
invalidate the other's refresh token at the provider level, breaking that
session mid-run. This race cannot be prevented by pi's file-level lockfile
alone.

**Practical requirement:** configure API keys (not OAuth) in
`~/.pi/agent/auth.json` for all providers that container runs will use.

---

### Platform binaries — built into the image

`~/.pi/agent/bin/` contains macOS-compiled binaries that are non-functional
on Linux. All tools required by pi inside the container (`fd`, `rg`, and
any others) are installed directly in the container image via the Dockerfile.
The mounted `bin/` directory is ignored.

---

### Session persistence — scoped per task

Each container receives a unique session directory:

- The orchestrator creates `~/.pi/sessions/<task-id>/` on the host before
  launching the container.
- That directory is bind-mounted into the container at
  `/root/.pi/sessions/<task-id>/`.
- Pi is invoked with `--session-dir /root/.pi/sessions/<task-id>/`.
- Session data persists to the host for debugging and replay.
- No container can read another container's sessions because the mount path
  is unique per `TASK_ID`.

---

### Concurrency — multiple containers per host

Multiple containers may run simultaneously, each working on a different
feature issue. Isolation is guaranteed by:

- Unique `TASK_ID` per launch → unique branch names, unique session dirs
- No shared workspace (each container clones its own fresh copy)
- All `~/.pi/agent/` mounts are read-only; no concurrent write contention
  on shared config

---

### Prompt construction — `/speckit.implement`

The entrypoint does not construct a prompt from the issue body. The prompt
is always `/speckit.implement $FEATURE_ID`. Speckit reads the feature spec
and task list from the cloned repository and drives the full implementation
workflow. The GitHub issue is the authoritative task source; the speckit
spec in the repo is the implementation contract. No entrypoint prompt
templating is needed.

---

### PR descriptions and issue status — pi/speckit responsibility

The implementing agent (pi + speckit) is responsible for writing PR titles,
descriptions, and issue status updates. The feature spec and task list
contain explicit instructions for this. When implementation is complete, pi
marks the issue as ready for review. The entrypoint does not call
`gh pr create` directly.

---

### Failure handling — marker file and session history

If pi or any entrypoint step exits with a non-zero code, the entrypoint
writes a `FAILED` marker file to the task session directory before exiting.
The marker file contains the failing step, exit code, and a timestamp. The
orchestrator detects failure by checking for this file.

Pi's session JSONL file (written to the same directory) captures the full
conversation state at the time of failure — tool calls, model responses, and
any error output — serving as the detailed error record. No separate logging
mechanism is required.

---

## Related Docs

| Topic | Path |
| --- | --- |
| Pi configuration reference | [configuration.md](configuration.md) |
| Pi session format | [sessions.md](sessions.md) |
| Pi CLI reference | [README.md](README.md) |
