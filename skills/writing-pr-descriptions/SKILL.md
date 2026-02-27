---
name: writing-pr-descriptions
description: Use when writing or updating a pull request description for
  any code change. Produces complete PR descriptions with a summary,
  approach rationale, test plan, reviewer instructions, and definition
  of done. Invoke before opening or updating any PR.
---

# Writing Pull Request Descriptions

## Overview

Use when writing or updating a pull request description.
Detailed guidance: `references/overview.md`.

## When to Use

- before opening any pull request
- when a PR description is incomplete or missing required sections
- when asked to write or update a PR description

## When Not to Use

- when another skill is a clearer, narrower match

## Prerequisites

- the branch is ready or nearly ready to open as a PR
- the linked task issue number is known
- tests have been run and results are available

## Workflow

1. Load `references/overview.md` for core procedure and constraints.
2. Load `references/template.md` for the required document structure.
3. Load `references/examples.md` for concrete examples.
4. Load `references/troubleshooting.md` for recovery and stop conditions.

## Hard Rules

- every PR must link to a task issue with `Closes #NNN` or `Refs #NNN`
- the Approach section must document alternatives considered
- the definition of done checklist must be fully checked before
  requesting review
- do not summarize the diff — explain the reasoning instead

## Failure Handling

- on ambiguity or missing prerequisites, stop and ask for clarification
- on tool/auth failures, report exact error and next required action

## Red Flags

- scope drift beyond this skill's trigger boundaries
- incomplete validation before reporting success
