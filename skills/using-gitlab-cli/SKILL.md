---
name: using-gitlab-cli
description: Use when instructed to run GitLab CLI (`glab`) commands for merge
  request operations, issue management, CI and pipeline runs, releases,
  repository settings, or GitLab API queries. Invoke before running any glab
  command.
---

# Using GitLab CLI (glab)

## Overview

Use this skill before running any `glab` command.

This skill provides:

- safe, non-interactive execution defaults
- command selection for `mr`, `issue`, `ci`, `release`, and `api`
- verification and reporting steps after each action

Detailed guidance lives in:

- `references/overview.md`
- `references/examples.md`
- `references/troubleshooting.md`

## When to Use

- user asks for any GitLab CLI operation
- task includes merge requests, issues, CI jobs, releases, or GitLab API calls
- task requires machine-readable output (`--output json`)

## When Not to Use

- user did not request GitLab work
- another skill is a tighter match for the full task scope

## Prerequisites

- `glab` is installed and authenticated
- target project is known (`-R/--repo <group>/<project>` when needed)
- required access level exists for the requested operation

## Workflow

1. Run preflight checks:
   `glab auth status` and project context confirmation.
2. Load `references/overview.md` for command selection and safety defaults.
3. Load only the relevant section from `references/examples.md` for the
   requested operation.
4. For write operations, confirm explicit user intent before executing.
5. Execute with explicit flags and prefer JSON output where available.
6. Validate result with a follow-up read command.
7. If a command fails, use `references/troubleshooting.md` and report the
   exact error plus next corrective action.

## Hard Rules

- do not perform destructive or irreversible actions without explicit approval
- avoid interactive prompts in automation contexts
- prefer `--output json` over parsing human-formatted text
- always scope operations to the correct repository for multi-repo contexts
- for mutations, verify outcome before reporting success

## Failure Handling

- if scope or target repo is ambiguous, stop and ask for clarification
- if auth fails, report exact failure and required re-auth command
- if permissions fail, report the missing role/permission and blocked command
- if command output is incomplete, rerun with explicit flags and JSON output

## Red Flags

- running write commands without target confirmation
- relying on interactive prompts when deterministic flags exist
- mutating resources without post-action verification
- using text scraping when JSON output is supported
