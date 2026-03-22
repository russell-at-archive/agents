---
name: using-gitlab-cli
description: Uses GitLab CLI (`glab`) for GitLab-native operations including merge requests, issues, pipelines, releases, variables, repositories, and authenticated API queries. Use when instructed to run `glab` commands, manage GitLab resources, inspect CI, or automate GitLab workflows.
---

# Using GitLab CLI

## Overview

Use this skill before running any `glab` command.

Keep `SKILL.md` as the control plane. Read only the reference file needed for
the task:

- setup or missing binary:
  [references/installation.md](references/installation.md)
- command selection, auth precedence, and safety defaults:
  [references/overview.md](references/overview.md)
- concrete command shapes:
  [references/examples.md](references/examples.md)
- failures, auth errors, and repo-scope mistakes:
  [references/troubleshooting.md](references/troubleshooting.md)

## When to Use

- user asks to run `glab`
- task involves GitLab merge requests, issues, pipelines, releases, variables,
  work items, agents, or repositories
- task needs authenticated GitLab API access through `glab api`
- task needs machine-readable GitLab output for automation

## When Not to Use

- the task is plain `git` work with no GitLab operation
- another skill is a tighter match for the main task, such as GitLab CI config
  authoring instead of CLI execution

## Prerequisites

- `glab` is installed. If not, read
  [references/installation.md](references/installation.md).
- authentication is available for the target instance
- target repo, project, group, or hostname is known before write operations

## Workflow

1. Verify the binary and auth state:
   `glab --version` and `glab auth status`.
2. Confirm execution context: current repo, `GITLAB_HOST`, configured host, or
   explicit `-R/--repo`.
3. Read [references/overview.md](references/overview.md) before choosing the
   command family for the task.
4. Read [references/examples.md](references/examples.md) only for the exact
   operation being executed.
5. Prefer non-interactive execution with explicit flags and JSON output when the
   command supports it.
6. For write operations, confirm the exact target object and requested action
   before execution.
7. Validate mutations with a follow-up read command and report the result.
8. If a command fails, use
   [references/troubleshooting.md](references/troubleshooting.md) and surface
   the exact blocker.

## Hard Rules

- do not mutate or delete GitLab resources without clear user intent
- prefer `--output json` and `glab api` over scraping human-readable tables
- pass `-R/--repo` explicitly whenever repository scope is not guaranteed
- use `--yes`, `--stdin`, `--token`, `--job-token`, or other explicit flags
  instead of interactive prompts in automation
- for `mr merge`, prefer `--sha` when the user expects merge safety against
  reviewed commits changing
- treat CI, variables, releases, and group-level operations as high-impact
  writes and verify immediately after running them

## Failure Handling

- if repo, group, or hostname is ambiguous, stop and ask
- if the binary is missing, follow
  [references/installation.md](references/installation.md)
- if auth fails, report whether the blocker is host selection, token scope,
  expired credentials, or CI token limitations
- if a command lacks structured output, prefer a narrower `glab` subcommand or
  `glab api` with explicit fields
- if a mutation partially succeeds, re-read the resource before proposing any
  retry

## Red Flags

- relying on prompts when deterministic flags exist
- assuming the current git remote points at the intended GitLab project
- confusing MR IID, issue IID, pipeline ID, and job ID
- writing secrets with shell history exposure instead of `--stdin` or standard
  input
- using CI job tokens for unsupported commands and assuming parity with PATs
