---
name: using-github-speckit
description: Use when asked to create a project plan, feature plan, or
  specification using GitHub Spec Kit, including prompts like "create a
  plan", "create a spec", "write a project spec", or "plan this feature".
  Enforce the Spec Kit command sequence and produce complete, review-ready
  planning artifacts.
---

# Using GitHub Spec Kit For Planning

## Overview

Use when asked to create a project plan, feature plan, or
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
