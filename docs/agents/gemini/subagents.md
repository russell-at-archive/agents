# Gemini CLI Subagents

Observed against:

- repo-local help snapshot in [gemini-help.md](/Users/russelltsherman/.agents/docs/agents/gemini/gemini-help.md)
- repo-local Gemini notes in
  [README.md](/Users/russelltsherman/.agents/docs/agents/gemini/README.md)
- official Gemini CLI docs at
  <https://google-gemini.github.io/gemini-cli/> on `2026-03-19`

This page focuses on one Gemini CLI customization surface:
defining agent behavior for Gemini workflows and invoking it
predictably.

## What a subagent is in Gemini CLI

Gemini CLI appears to have real agent lifecycle and subagent-adjacent
runtime behavior, but it does not expose a Claude-style user-facing
custom subagent format in the documented CLI surface.

Observed evidence in this repo:

- Gemini hook events include `BeforeAgent` and `AfterAgent`, which shows
  there is an explicit agent loop.
- Gemini system prompt override docs reference a `${SubAgents}`
  placeholder, which implies the runtime knows about available
  subagents.
- The documented top-level CLI surface includes `skills`, `extensions`,
  and `hooks`, but not `agents`.

That means Gemini has agent concepts internally, but the stable
customization surface users can define today is centered on skills,
extensions, commands, hooks, and context files.

## Important distinction from Claude Code

Claude Code documents a stable checked-in custom subagent format under
`.claude/agents/<name>.md` and a direct `--agent <name>` selection flow.

Gemini CLI, in the observed docs and help snapshot, does not expose an
equivalent stable path such as:

- `.gemini/agents/<name>.md`
- `gemini agents`
- `gemini --agent <name>`

For Gemini today, there are four separate concepts:

| Concept | Stable surface today? | Best use |
| --- | --- | --- |
| Internal agent loop | Yes | Core Gemini planning and execution |
| Runtime subagent behavior | Implied, but not documented as a user-managed file format | Internal specialization the CLI may use |
| Skills under `.agents/skills/` or `.gemini/skills/` | Yes | Reusable workflow specialization |
| Extensions, commands, hooks, and `GEMINI.md` | Yes | Reusable agent behavior, packaging, and invocation UX |

## What you can define today

There is no documented Gemini equivalent of
`.claude/agents/<name>.md`.

The reliable ways to define reusable agent behavior today are these.

## 1. Skills

Skills are the most direct reusable specialization mechanism for Gemini.

Locations:

| Location | Scope |
| --- | --- |
| `~/.gemini/skills/<name>/` | User-wide |
| `.gemini/skills/<name>/` | Project-local |
| `.agents/skills/<name>/` | Portable cross-tool path, preferred in this repo |

Use a skill when you want Gemini to reuse:

- a workflow
- validation steps
- domain-specific operating rules
- documentation or review conventions

Skills are the closest portable answer to "define a specialist agent"
when the specialization is mostly process and instructions.

## 2. Extensions

Extensions are Gemini's native packaging layer for behavior.

An extension can bundle:

- context files
- custom slash commands
- MCP servers
- tool restrictions

Use an extension when you want a reusable Gemini-native package that can
shape how Gemini behaves across sessions.

This is the closest Gemini-native equivalent to a persistent custom
agent distribution format, even though it is broader than a single
subagent persona.

## 3. Custom commands

Gemini custom commands let you define named prompts with optional shell
expansion and file injection.

Locations:

| Location | Scope |
| --- | --- |
| `~/.gemini/commands/` | User-wide |
| `.gemini/commands/` | Project-local |

Use a command when you want a stable invocation surface such as:

- `/review`
- `/architecture`
- `/docs:update`

This is often the best replacement for "invoke a named agent" because it
gives users a predictable entry point while keeping the actual behavior
in prompts, skills, and extensions.

## 4. Context files and hooks

`GEMINI.md` files define layered instructions.
Hooks define policy, validation, and context injection around the agent
loop.

Use these when you want to control:

- repo rules
- coding standards
- approval or safety behavior
- dynamic context injection before planning or tool execution

This is how you shape the main agent's behavior without inventing a
non-existent subagent file format.

## What is documented versus inferred

These points are documented directly in the sources above:

- Gemini has `skills`, `extensions`, and `hooks` management surfaces.
- Gemini supports layered `GEMINI.md` context files.
- Gemini hooks include `BeforeAgent` and `AfterAgent`.
- System prompt override supports `${SubAgents}`.

These points are reasonable inferences from the documented surface:

- Gemini likely has internal specialized subagent behavior.
- That behavior is not currently documented as a stable user-authored
  file format.
- Team workflow should not standardize on a fictional
  `.gemini/agents/` convention.

## How to inspect the current capability surface

Use these documented entry points first:

```bash
gemini --help
gemini skills --help
gemini extensions --help
gemini hooks --help
```

If you are auditing the installed CLI in this repo, also review:

- [gemini-help.md](/Users/russelltsherman/.agents/docs/agents/gemini/gemini-help.md)
- [README.md](/Users/russelltsherman/.agents/docs/agents/gemini/README.md)
- [system-prompt-customization.md](/Users/russelltsherman/.agents/docs/agents/gemini/system-prompt-customization.md)
- [hooks.md](/Users/russelltsherman/.agents/docs/agents/gemini/hooks.md)

In this workspace, the checked-in help snapshot shows:

- top-level commands for `skills`, `extensions`, and `hooks`
- no top-level `agents` command
- no documented `--agent <name>` flag

## Invocation patterns that work today

There are four practical patterns.

## 1. Invoke Gemini directly with a bounded prompt

For deterministic automation, use non-interactive mode with a
self-contained prompt.

```bash
gemini -p "Review the current diff for regressions and missing tests."
```

This is the stable baseline.

## 2. Invoke Gemini with a skill-guided prompt

If the specialization is workflow-oriented, drive it through skills.

```bash
gemini -p "Use the writing-markdown skill. Update docs/agents/gemini/subagents.md and keep markdownlint clean."
```

This is the best path when you want a reusable specialization that can
be shared across tools.

## 3. Invoke a custom slash command

If the specialization needs a named entry point, wrap it in a Gemini
command.

Example command file:

```toml
description = "Review code for regressions and missing tests"
prompt = """Review the current diff.

Prioritize:
1. Behavioral regressions
2. Security risk
3. Missing tests
"""
```

Then invoke it inside Gemini as:

```text
/review
```

This is the cleanest Gemini-native substitute for selecting a named
specialist.

## 4. Package the behavior as an extension

If you need a durable Gemini-only specialization, package the prompt,
commands, MCP servers, and restrictions as an extension and enable it
for the session or workspace.

This is the best path when the specialization is not just a workflow,
but a productized Gemini environment.

## Recommended usage patterns

Use Gemini agent-style specialization for:

- code review entry points
- architecture investigation commands
- documentation update workflows
- policy-constrained repo automation

Use a skill instead when you need:

- a portable workflow
- shared validation steps across multiple agent tools
- instructions that should work in Claude, Codex, and Gemini

Use a custom command instead when you need:

- a short named invocation
- a repeatable prompt wrapper
- lightweight task specialization without packaging an extension

Use an extension instead when you need:

- Gemini-native packaging
- bundled commands, MCP servers, and context
- a reusable distribution unit for team workflow

Rule of thumb:

- Use a skill to define how work should be done.
- Use a command to define how users invoke that work.
- Use an extension to package a Gemini-native environment.
- Do not pretend Gemini has a stable `.gemini/agents/` feature unless
  the CLI starts documenting one.

## Minimal workflow for Gemini today

1. Put durable repo guidance in `GEMINI.md`.
2. Put portable workflows in `.agents/skills/`.
3. Add Gemini-specific invocation wrappers in `.gemini/commands/`.
4. Use hooks for policy and dynamic context injection.
5. Package Gemini-native behavior as an extension when reuse justifies
   it.

## Validation commands

```bash
gemini --help
gemini skills --help
gemini extensions --help
gemini hooks --help
gemini -p "Summarize the current diff."
gemini -p "Use the writing-markdown skill. Summarize docs/agents/gemini/README.md."
```

## Notes for this repository

- Keep reusable cross-tool workflows in `.agents/skills/`.
- Keep repo-specific Gemini guidance in `GEMINI.md`.
- Keep Gemini-native invocation UX in `.gemini/commands/` or
  extensions.
- Do not introduce a `.gemini/agents/` convention as if it were a
  documented Gemini CLI feature.
- Revisit this page when Gemini documents a stable user-managed agent or
  subagent definition surface.
