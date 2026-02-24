# SKILL.md Best Practices

This guide defines a practical standard for writing high-quality
`SKILL.md` files.

Use it when creating a new skill or revising an existing one.

## Purpose

A good `SKILL.md` should:

- trigger reliably from `name` and `description`
- stay concise and procedural
- reduce failure modes in real execution
- defer detail to `references/` when possible

## Frontmatter Rules

Keep frontmatter minimal and accurate.

- `name`: lowercase, hyphenated, action-oriented
- `description`: explicit trigger conditions and scope
- avoid extra fields unless your runtime requires them

Example:

```yaml
---
name: using-example-cli
description: Use when running Example CLI commands for deployment,
  release checks, or incident triage. Invoke before any example
  command execution.
---
```

## Writing Style

Prefer imperative instructions over narrative explanations.

- write commands users can execute directly
- state constraints as hard rules where needed
- avoid motivational or generic language
- keep sections short and skimmable

## Required Sections

Use a stable structure so skills are predictable:

1. `Overview`: what the skill does and key principle
2. `When to Use`: include positive and negative triggers
3. `Prerequisites`: auth, binaries, env vars, permissions
4. `Workflow`: ordered steps with concrete commands
5. `Safety Rules`: destructive actions and guardrails
6. `Common Mistakes`: common failure patterns and fixes
7. `Red Flags`: when to stop and correct course

## Command Quality

Command examples should be production-safe.

- prefer non-interactive flags in automation flows
- avoid ambiguous placeholders
- include output verification when possible
- ensure env var scoping is correct for pipelines

Bad:

```bash
MY_VAR=value echo "task" | tool run
```

Good:

```bash
echo "task" | MY_VAR=value tool run
```

## Scope and Boundaries

Define tool boundaries explicitly.

- name the preferred tool and alternatives
- list what is out of scope
- clarify fallback behavior if primary tooling fails

This avoids cross-skill conflict and command drift.

## Reusable Resources

Keep `SKILL.md` lean and reference local resources.

- put deterministic logic in `scripts/`
- put deep domain detail in `references/`
- put templates and static files in `assets/`

In `SKILL.md`, point to exact files and when to load them.

## Failure Handling

Every skill should define expected failure behavior.

- what to do if auth fails
- what to do if required binaries are missing
- what to do if pre-checks fail
- when to ask the user before proceeding

## Compatibility and Portability

Avoid assumptions that break across environments.

- avoid shell-specific tricks unless required
- avoid OS-specific paths unless documented
- prefer portable commands and clear fallbacks

If behavior is platform-specific, state it explicitly.

## Markdown Quality

`SKILL.md` files should be lint-clean.

- wrap prose at 80 characters
- add blank lines around headings and blocks
- use fenced code blocks with language tags
- avoid overly wide tables

## Review Checklist

Before finalizing a `SKILL.md`, verify:

- [ ] Triggering description is specific and testable
- [ ] Commands are correct and non-interactive where needed
- [ ] Safety rules cover destructive or irreversible actions
- [ ] Failure paths are documented with clear next actions
- [ ] References to local files are valid
- [ ] Scope and exclusions are explicit
- [ ] Content is concise and procedural
- [ ] Markdown formatting is lint-compliant

## Starter Template

Use this as a baseline for new skills:

~~~markdown
---
name: <skill-name>
description: Use when <trigger>. Invoke before <critical action>.
---

# <Skill Title>

## Overview

<One paragraph with purpose and core principle.>

## When to Use

- <positive trigger>
- <positive trigger>

## When Not to Use

- <negative trigger>
- <negative trigger>

## Prerequisites

```bash
<verification command>
```

## Workflow

1. <step>
2. <step>
3. <step>

## Safety Rules

- <guardrail>
- <guardrail>

## Common Mistakes

- <mistake>: <fix>
- <mistake>: <fix>

## Red Flags

- <stop condition>
- <stop condition>
~~~
