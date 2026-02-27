---
name: writing-adrs
description: Use when creating or updating Architectural Decision Records,
  when a significant technical or architectural choice needs documenting, or
  when asked to write an ADR.
---

# Writing Architectural Decision Records

## Overview

Use when creating or updating Architectural Decision Records,
Detailed guidance: `references/overview.md`.

## When to Use

- when the trigger conditions in frontmatter match the request

## When Not to Use

- when another skill is a clearer, narrower match

## Prerequisites

- required tools, auth, and repository context are available

## Workflow

1. Load `references/overview.md` for core procedure and constraints.
2. Load `references/template.md` for the required document structure.
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
