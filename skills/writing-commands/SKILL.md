---
name: writing-commands
description: Produces correct, well-scoped Claude Code custom slash command
  prompt files for task-execution, code generation, reference, research, and
  workflow automation. Use when asked to write, create, design, or improve a
  custom slash command, SKILL.md prompt, .claude/commands/ file, or any
  Claude Code command that performs a task (not a prime or subagent config).
---

# Writing Meta-Prompts

## Overview

Produces Claude Code custom slash command prompt files: Markdown files with
YAML frontmatter defining invocation behavior, plus a prompt body that
instructs Claude how to perform a specific, repeatable task. Covers command
type selection, frontmatter field choices, argument handling, dynamic context
injection, and prompt body structure. For the full field reference and design
patterns, read [references/overview.md](references/overview.md). For concrete
examples by command type, read [references/examples.md](references/examples.md).

## When to Use

- Writing a new task-execution command (commit, deploy, review, fix-issue)
- Writing a reference command that loads conventions or patterns on demand
- Writing a code generation command (scaffold, new-component, generate-test)
- Writing a research or investigation command (investigate, deep-dive)
- Writing a workflow automation command (release, format-and-commit)
- Improving an existing command's description, frontmatter, or prompt body
- Choosing between a simple `.claude/commands/` file and a full `SKILL.md`
- Deciding which frontmatter flags to set for a given command type

## When Not to Use

- Writing a prime, context-prime, or onboarding command — use `writing-meta-primes`
- Writing a custom subagent config — use `writing-meta-agents`
- Writing general-purpose LLM prompts (not Claude Code) — use `writing-prompts`
- The goal is documentation for humans, not a Claude-executable command

## Prerequisites

- The command's purpose and trigger conditions are clear enough to write a
  specific description
- The command type is known: task-execution, reference, code generation,
  research, or workflow automation
- Storage scope is decided: project (`.claude/`) or user-global (`~/.claude/`)

## Workflow

1. Identify the command type. See the type guide in
   [references/overview.md](references/overview.md). Ask if ambiguous.
2. Choose storage format: simple `.claude/commands/<name>.md` for commands
   under 80 lines with no supporting files; full `SKILL.md` directory for
   commands with templates, scripts, or reference docs.
3. Write the frontmatter. Apply the per-type frontmatter rules in
   [references/overview.md](references/overview.md) — especially
   `disable-model-invocation` for commands with side effects.
4. Write the description field using the pattern: `<action verb> <object>.
   Use [proactively] when <specific trigger conditions>.`
5. Write the prompt body. State what Claude must do, in what order, and
   with what output format. Do not describe what Claude should avoid without
   stating what to do instead.
6. Add `$ARGUMENTS` or `$0`/`$1` substitutions where the command takes input.
   Add `argument-hint` when argument shape is non-obvious.
7. Add dynamic context injection (`!``command``) only for live state that
   Claude cannot discover by reading files. Keep output bounded.
8. Validate against the hard rules below. Consult
   [references/examples.md](references/examples.md) for patterns by type.

## Hard Rules

- **`disable-model-invocation: true`** is required for any command with side
  effects (writes files, runs git, sends messages, deploys). Auto-invocation
  of destructive commands is a safety hazard.
- **Description must include a trigger condition.** "Use when..." or "Use
  after..." is required. Vague descriptions cause missed or incorrect
  auto-invocation.
- **Prompt body must state what to do, not only what to avoid.** Negative-only
  instructions are unactionable.
- **`allowed-tools` must be set** for read-only commands. Omitting it grants
  all tools including Write, Edit, and Bash.
- **Arguments must be documented.** If the command takes `$ARGUMENTS`, state
  what they are. Use `argument-hint` for user-facing hints.
- **Dynamic injection must be bounded.** Never inject full file contents or
  unbounded command output. Use `head`, `--short`, or count flags.
- **One command, one concern.** A command that reviews code and then commits
  it should be two commands.

## Failure Handling

- If the command type is ambiguous (task-execution vs reference), ask before
  drafting — the frontmatter differs significantly.
- If the command would exceed 80 lines, move supporting detail to
  `references/` files and link with explicit trigger conditions.
- If the command's trigger conditions overlap significantly with an existing
  command, stop and confirm whether to extend the existing one instead.

## Red Flags

- `disable-model-invocation` missing on a command that writes files or runs git
- Description has no trigger condition ("when...", "after...", "for...")
- Prompt body only says what NOT to do
- `allowed-tools` omitted on a read-only command
- `$ARGUMENTS` used but never explained in the prompt body
- Dynamic injection uses unbounded commands (`cat large-file`, `find . -name "*"`)
- Command mixes task-execution with context loading (split into two)
