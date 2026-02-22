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

Use this skill when the user asks for a project or feature spec, plan,
or task breakdown using GitHub Spec Kit.

Announce at start:
"I am using the using-github-speckit skill to run the Spec Kit planning
pipeline and deliver review-ready artifacts."

Detailed guidance:
`references/overview.md`, `references/examples.md`, and
`references/troubleshooting.md`.

## When to Use

- Request explicitly names Spec Kit, `/specify`, `/plan`, or `/tasks`.
- Request asks for a feature plan, project spec, or implementation tasks.
- Request needs structured planning artifacts before coding.

## When Not to Use

- User asks to implement code now and does not want planning artifacts.
- Request is a quick factual answer, not a planning workflow.
- Another skill is a stricter match for the requested output format.

## Prerequisites

- Repository context is available.
- Scope can be stated as one feature or one project slice.
- No destructive actions are required.

## Workflow

1. Load `references/overview.md` and follow its command sequence.
2. Load `references/examples.md` and adapt starter prompts to context.
3. Load `references/troubleshooting.md` before finalizing outputs.
4. Run the mandatory planning pipeline:
   1. `/specify`
   2. `/clarify` when ambiguity is material
   3. `/plan`
   4. `/tasks`
5. Keep outputs scoped to one feature slice.
6. Ask before moving to `/implement`.

## Output Contract

Every planning package must include:

- problem statement and measurable goals
- clear in-scope and out-of-scope boundaries
- assumptions and open questions
- architecture and tradeoffs
- ordered tasks with dependencies and acceptance criteria
- validation strategy and rollout or risk controls

## Hard Rules

- Do not skip `/plan` when technical design is requested.
- Do not run `/implement` unless the user explicitly asks.
- Do not invent missing requirements; list assumptions explicitly.
- Do not merge multiple unrelated features into one artifact set.
- Do not claim completion without the required artifacts.

## Failure Handling

- If scope is ambiguous, run `/clarify` before `/plan`.
- If prerequisites are missing, report the blocker and next action.
- If sequence is broken, stop and return to the correct stage.

## Red Flags

- Jumping from idea directly to `/tasks`
- Architecture decisions missing from `/plan`
- Tasks not independently testable
- Acceptance criteria missing or vague
- Hidden assumptions treated as facts
