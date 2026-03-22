---
name: writing-primes
description: Produces correct, well-structured Claude Code custom prime slash
  command prompts for setup and onboarding workflows. Use when asked to write,
  create, design, or improve a prime command, context-prime, onboarding command,
  setup slash command, or any .claude/commands/ file intended to load initial
  project context or guide developer setup.
---

# Writing Meta-Primes

## Overview

Produces Claude Code custom prime slash command prompts: Markdown files stored
in `.claude/commands/` or as `SKILL.md` entries, designed to prime Claude with
project context, guide environment setup, or onboard new developers before work
begins. For the full format reference and best practices, read
[references/overview.md](references/overview.md). For concrete prime command
examples by type, read [references/examples.md](references/examples.md).

## When to Use

- Writing a new prime, context-prime, onboard, or setup slash command
- Improving an existing prime command that loads too much or too little context
- Choosing between a simple `.claude/commands/` file vs a full skill
- Designing the section structure and content order of a prime command
- Deciding which frontmatter flags to set (`disable-model-invocation`, `context: fork`, etc.)
- Converting an informal README or onboarding doc into an executable prime command

## When Not to Use

- Writing a skill that performs a task (commits, reviews, deploys) — use `writing-skills` instead
- Writing a custom subagent config — use `writing-meta-agents` instead
- Writing general-purpose prompts for LLMs — use `writing-prompts` instead
- The goal is documentation for humans, not a Claude-executable command

## Prerequisites

- The project's setup workflow, conventions, or architecture is known well
  enough to summarize
- The target audience is clear: new team members, Claude at session start, or
  both
- The command scope is defined: context loading, environment setup, full
  onboarding, or architectural tour

## Workflow

1. Clarify the prime's purpose and scope. Ask if ambiguous: is this for session
   context loading, developer onboarding, environment setup, or architecture
   orientation?
2. Choose the storage format: simple `.claude/commands/<name>.md` for lean
   context primes; full `SKILL.md` with supporting files for onboarding workflows
   with reference docs or scripts.
3. Write the frontmatter. Set `disable-model-invocation: true` for primes that
   should run only when explicitly invoked. Use `context: fork` + `agent: Explore`
   for read-only exploration primes.
4. Structure the body using the section guide in
   [references/overview.md](references/overview.md): orient → navigate → instruct.
5. Add dynamic context injection (`!``command``) for sections that need live
   project state (current branch, recent commits, available scripts).
6. Link to key files with `@file` syntax or explicit `Read` references, not
   open-ended "explore the codebase" instructions.
7. Validate against the hard rules below. Consult
   [references/examples.md](references/examples.md) for patterns by prime type.

## Hard Rules

- **Prime commands are not manuals.** State what Claude needs to know and what
  it should do — not an exhaustive dump of every file in the repo.
- **Set `disable-model-invocation: true`** on primes that have side effects or
  that should only run at explicit session start, not auto-triggered by keywords.
- **Every `Read` or file reference must state why** the file matters, not just
  what it is. Claude needs to know what to do with the context.
- **Dynamic injection (`!``command``) must produce bounded output.** Never inject
  full file contents or unbounded `find` results; inject summaries, counts, or
  short lists.
- **Verification steps are required** for setup primes. Claude must confirm the
  environment is ready, not assume it.
- **One purpose per prime.** A context prime and a full onboarding guide are
  separate commands. Do not merge them.

## Failure Handling

- If the project's setup workflow is unclear, ask for the key steps before
  drafting — do not guess from README.
- If the scope covers both context loading and environment setup, propose two
  separate prime commands and confirm with the user.
- If a prime file would exceed 150 lines, move supporting detail to reference
  files and link explicitly with trigger conditions.

## Red Flags

- Prime body tells Claude to "explore the codebase" with no scoped direction
- Setup prime has no verification step to confirm environment is ready
- `disable-model-invocation` is missing on a prime with side effects
- Dynamic injection uses unbounded commands (`cat large-file.json`, `find . -name "*"`)
- Prime duplicates content already in CLAUDE.md (point to it instead)
- File references have no explanation of why that file matters
- Prime mixes onboarding content with task-execution instructions
