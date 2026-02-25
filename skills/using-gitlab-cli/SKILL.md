---
name: using-gitlab-cli
description: Use when instructed to run GitLab CLI (`glab`) commands for merge
  request operations, issue management, pipeline runs, releases, repository
  settings, or GitLab API queries. Invoke before running any glab command.
---

# Using GitLab CLI (glab)

## Overview

Use when instructed to run GitLab CLI (`glab`) commands for merge
Detailed guidance: `references/overview.md`.

## When to Use

- when the trigger conditions in frontmatter match the request

## When Not to Use

- when another skill is a clearer, narrower match

## Prerequisites

- required tools, auth, and repository context are available

## Workflow

1. Load `references/overview.md` for core procedure and constraints.
2. Load `references/examples.md` for concrete command or prompt forms.
3. Load `references/troubleshooting.md` for recovery and stop conditions.

## Hard Rules

- do not execute destructive or irreversible actions without approval
- follow repository-specific constraints before making changes

## Failure Handling

- on ambiguity or missing prerequisites, stop and ask for clarification
- on tool/auth failures, report exact error and next required action

## Red Flags

- scope drift beyond this skill's trigger boundaries
- incomplete validation before reporting success
