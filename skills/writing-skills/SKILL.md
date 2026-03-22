---
name: writing-skills
description: Creates or improves agent skills using an iterative draft,
  evaluate, and revise workflow. Use when asked to build, write, add,
  update, or optimize a skill, especially when the workflow should be
  captured as a portable skill with a minimal SKILL.md body.
---

# Creating Skills

## Overview

Creates or improves skills using an iterative authoring loop: define the
skill, draft it, evaluate it on realistic prompts, and revise it. Keep
`SKILL.md` as short as possible and move deferred detail to supporting
files only when needed.

Full procedure: [references/overview.md](references/overview.md)

## When to Use

- Asked to create, build, write, or add a skill
- Asked to revise, improve, benchmark, or optimize an existing skill
- A repeatable agent workflow needs to be captured and made portable
- A skill needs eval prompts, baseline comparison, or trigger tuning

## When Not to Use

- The request is to document a one-off process (write a doc instead)
- The workflow is project-specific and not reusable across repositories

## Prerequisites

- A clear description of what the skill does and when it should activate
- Enough domain knowledge to write the core workflow steps
- The skill name is known and follows naming rules (lowercase, hyphens,
  matches directory name)

## Workflow

1. Confirm the skill name, trigger conditions, and scope with the user
   if any are ambiguous.
2. Create or update the skill directory. Add `references/`, `scripts/`,
   `assets/`, and eval artifacts only if the skill needs them.
3. Write or revise `SKILL.md` as a lean control plane. Keep only
   activation guidance, core workflow, and hard guardrails there.
4. If the skill uses a CLI tool, add
   [references/installation.md](references/installation.md) with concrete
   install paths and point to it when setup matters.
5. Add only the supporting reference files needed to keep `SKILL.md`
   short and the workflow clear.
6. Create realistic eval prompts and compare the skill against a
   baseline when evaluation is worth the cost.
7. Revise the skill using the eval results, then repeat as needed.
8. Run the checklist in [references/overview.md](references/overview.md)
   before declaring done.

## Hard Rules

- `SKILL.md` must stay as short as possible. Move any non-essential
  detail out of the body.
- `name` field must be lowercase, hyphens only, and match the directory.
- `description` must be written in third person and include both what
  the skill does and explicit trigger keywords.
- Do not duplicate policy text between `SKILL.md` and `references/*`.
  `SKILL.md` stays control-plane; references hold deferred detail.
- All file paths must use forward slashes.
- Reference files must be one level deep from `SKILL.md` — no nested
  chains.
- Reference files over 100 lines must have a table of contents.
- Skills for CLI tools must include `references/installation.md`.
- Saying "tool is installed" in prerequisites is not sufficient.

## Failure Handling

- If the skill name conflicts with an existing skill, stop and confirm
  with the user before creating anything.
- If the scope is too broad for one skill (multiple unrelated triggers),
  propose splitting into two skills.
- If required information (name, trigger conditions) is missing, ask
  before writing any files.
- If evals do not discriminate between the skill and the baseline,
  tighten the prompts or assertions before claiming improvement.

## Red Flags

- Skill name contains uppercase letters or underscores
- Description written in first or second person
- SKILL.md body is growing into a manual instead of a control plane
- Reference files reference other reference files (nested chain)
- Skill covers more than one unrelated concern
