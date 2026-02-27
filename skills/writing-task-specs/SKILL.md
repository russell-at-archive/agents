---
name: writing-task-specs
description: Use when breaking a feature plan or technical design into
  implementation tasks. Invoke after a tech plan is approved and before
  any implementation begins. Produces a task list where each task maps
  to exactly one branch and one PR.
---

# Writing Task Specifications

## Overview

Use when breaking a feature plan or technical design into
Detailed guidance: `references/overview.md`.

## When to Use

- when the trigger conditions in frontmatter match the request

## When Not to Use

- when another skill is a clearer, narrower match

## Prerequisites

- required tools, auth, and repository context are available

## Workflow

1. Load `references/overview.md` for core procedure and constraints.
2. Load `references/template.md` for the required task spec structure.
3. Load `references/examples.md` for concrete examples.
4. Load `references/troubleshooting.md` for recovery and stop conditions.

## Hard Rules

- do not execute destructive or irreversible actions without approval
- follow repository-specific constraints before making changes

## Failure Handling

- on ambiguity or missing prerequisites, stop and ask for clarification
- on tool/auth failures, report exact error and next required action

## Red Flags

- scope drift beyond this skill's trigger boundaries
- incomplete validation before reporting success
