---
name: writing-design-prompts
description: Produces a system prompt and kickoff template for running
  exhaustive LLM-assisted software design and planning sessions. Use when
  asked to design a meta prompt for software planning, set up a structured
  design session, create a planning prompt, or help exhaustively think
  through and design a software project with an LLM.
---

# Writing Design Prompts

## Overview

Produces two artifacts for structured LLM-assisted software design sessions:

1. **System prompt** — puts the LLM into planning mode with a six-phase
   process: interrogate, mirror requirements, explore alternatives, decide
   with tradeoffs, depth design, pre-mortem, and implementation plan.
2. **Kickoff template** — a structured brief the user fills in to start
   the session; ends with an explicit instruction to interrogate before
   designing.

Full system prompt: [references/system-prompt.md](references/system-prompt.md)
Kickoff template: [references/kickoff-template.md](references/kickoff-template.md)
Techniques and anti-patterns: [references/techniques.md](references/techniques.md)

## When to Use

- Asked to create a meta prompt or planning prompt for software design
- Setting up an exhaustive design or planning session with an LLM
- User wants to think through a project before writing any code
- Asked to help design, architect, or plan a software project from scratch

## When Not to Use

- The user wants to start implementing, not planning — help them directly
- The request is for a one-off design decision, not a full project session
- The user already has a design and wants a review (use a review prompt instead)

## Prerequisites

- A project exists or is being conceived — even a rough idea is enough
- The user understands they will paste the system prompt into their LLM
  session and fill in the kickoff template before sending

## Workflow

1. If the user has a project in mind, ask for a one-sentence description
   so you can pre-fill the kickoff template's project name and rough framing.
   If no project, produce both artifacts as generic templates.
2. Output the system prompt from [references/system-prompt.md](references/system-prompt.md)
   in a code block labeled "System Prompt".
3. Output the kickoff template from [references/kickoff-template.md](references/kickoff-template.md)
   in a code block labeled "Kickoff Template", pre-filled with any project
   details the user has shared.
4. Explain briefly how to use them together (system prompt first, then
   kickoff as the first user message).
5. If the user asks about techniques or anti-patterns, refer to
   [references/techniques.md](references/techniques.md).

## Hard Rules

- Always output both artifacts together — the system prompt without the
  kickoff template leaves the user without a starting point.
- The kickoff template must always end with the interrogation instruction:
  "Do not design yet — tell me what else you need to know."
- Do not collapse the six phases — each phase exists to prevent a specific
  failure mode; skipping phases produces shallow designs.
- Do not add project-specific implementation advice to the system prompt —
  it must remain reusable across all projects.

## Failure Handling

- If the user wants to skip straight to a design, produce the artifacts
  and note that using Phase 0 (interrogation) before designing is the
  primary value of the system prompt.
- If the user's LLM tool doesn't support a system prompt field, instruct
  them to paste it as the first user message followed by "Understood?" and
  wait for confirmation before sending the kickoff template.
