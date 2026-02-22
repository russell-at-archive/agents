---
name: creating-skills
description: Creates a new agent skill directory with a compliant SKILL.md
  and supporting reference files. Use when asked to build, write, add, or
  create a skill, or when a repeatable agent workflow needs to be captured
  as a portable skill.
---

# Creating Skills

## Overview

Produces a complete, standards-compliant skill following the Agent Skills
open standard. The skill must use progressive disclosure: a lean SKILL.md
body under 100 lines that delegates detail to `references/` files loaded
on demand.

Full procedure: [references/overview.md](references/overview.md)

## When to Use

- Asked to create, build, write, or add a skill
- A repeatable agent workflow needs to be captured and made portable
- An existing skill needs to be restructured to meet the standard

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
2. Create the skill directory: `skills/<name>/` and
   `skills/<name>/references/`.
3. Write `SKILL.md` — lean body only; delegate detail to references.
   See [references/overview.md](references/overview.md) for the required
   section structure and body rules.
4. Write `references/overview.md` — full procedure, constraints, and
   the authoring checklist.
5. Write `references/examples.md` — concrete input/output examples.
6. Write `references/troubleshooting.md` — common mistakes, anti-patterns,
   and red flags.
7. Run the authoring checklist from
   [references/overview.md](references/overview.md) before declaring done.
8. Add the skill to `README.md` skills index in alphabetical order.

For a complete worked example of a skill and its reference files, read
[references/examples.md](references/examples.md).

## Hard Rules

- `SKILL.md` body must be under 100 lines.
- `name` field must be lowercase, hyphens only, and match the directory.
- `description` must be written in third person and include both what
  the skill does and explicit trigger keywords.
- Do not duplicate policy text between `SKILL.md` and `references/*`.
  `SKILL.md` stays control-plane; references hold deferred detail.
- All file paths must use forward slashes.
- Reference files must be one level deep from `SKILL.md` — no nested
  chains.
- Reference files over 100 lines must have a table of contents.
- Only `name` and `description` in frontmatter by default. Do not add
  `license`, `allowed-tools`, or other optional fields unless there is
  an explicit reason.

## Failure Handling

- If the skill name conflicts with an existing skill, stop and confirm
  with the user before creating anything.
- If the scope is too broad for one skill (multiple unrelated triggers),
  propose splitting into two skills.
- If required information (name, trigger conditions) is missing, ask
  before writing any files.

## Red Flags

- Skill name contains uppercase letters or underscores
- Description written in first or second person
- SKILL.md body approaching or over 100 lines — move detail to references
- Reference files reference other reference files (nested chain)
- Skill covers more than one unrelated concern
