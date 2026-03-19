# Codex CLI Subagents

Observed against local CLI `codex-cli 0.115.0` on `2026-03-19`.

This page focuses on one Codex CLI customization surface:
defining agent behavior for Codex workflows and invoking subagents
predictably.

## What a subagent is in Codex

In Codex, a subagent is a delegated runtime worker used for a bounded
subtask inside a larger agent session.

Observed evidence in this workspace:

- `codex features list` reports `multi_agent` as `stable` and enabled.
- The installed CLI binary contains internal `spawn_agent`,
  `wait_agent`, `send_input`, and `close_agent` tool strings.

That means Codex has real multi-agent runtime support.

What it does not expose, at least in the observed CLI, is a stable
Claude-style user command for listing, selecting, and loading named
subagent files from disk.

## Important distinction from Claude Code

Claude Code has a documented custom subagent file format under
`.claude/agents/` and a direct `--agent` selection flow.

Codex CLI, in the observed version, does not expose an equivalent stable
user-facing subcommand such as `codex agents`, nor a documented
`--agent <name>` flag for loading reusable subagent definitions.

For Codex today, there are three separate concepts:

| Concept | Stable surface today? | Best use |
| --- | --- | --- |
| Runtime subagents inside Codex | Yes | Parallel or delegated work inside a Codex session |
| Skills under `.agents/skills/` | Yes | Reusable workflows and domain-specific guidance |
| User-defined named subagent files | No stable public CLI contract observed | Do not standardize team workflow on this yet |

## What you can define today

There is no stable checked-in subagent file format comparable to
`.claude/agents/<name>.md` in the observed Codex CLI.

The reliable ways to define reusable agent behavior today are:

## 1. Skills

Skills are the main reusable specialization mechanism Codex already
loads and documents in this repo.

Locations:

| Location | Scope |
| --- | --- |
| `~/.agents/skills/<name>/SKILL.md` | User-wide |
| `.agents/skills/<name>/SKILL.md` | Project-local |

Use a skill when you want Codex to reuse:

- a workflow
- command patterns
- validation steps
- domain-specific operating rules

Skills are portable across tools that implement the same skill format.

## 2. Instruction files

Codex reads layered instruction files and uses them to shape behavior:

| File | Scope |
| --- | --- |
| `~/.codex/AGENTS.md` | User-wide |
| `AGENTS.md` from repo root to current directory | Project and subtree |
| `AGENTS.override.md` | Local override |

Use these when you want to define:

- coding standards
- repository rules
- tool preferences
- review expectations
- safety constraints

These files influence the main agent and, in practice, also shape how
delegated work is carried out.

## 3. Config profiles

Codex supports config profiles through `config.toml` and the `-p,
--profile` flag.

Example:

```bash
codex -p safe
codex exec -p review --full-auto -C /repo "Review the current diff."
```

Profiles are useful for packaging defaults such as:

- model
- sandbox mode
- approval policy
- feature flags

Profiles are not the same thing as named subagents, but they are a real
and stable way to create repeatable agent modes.

## What is experimental or not yet stable

Two observed feature flags are relevant:

| Feature | Observed state |
| --- | --- |
| `multi_agent` | `stable`, enabled |
| `child_agents_md` | `under development`, disabled |

The practical read is:

- multi-agent execution is real and usable
- a Markdown-driven child-agent definition surface appears to be under
  development
- team documentation should not yet assume a stable on-disk subagent
  format for Codex

## How to inspect the current capability surface

Use these commands first:

```bash
codex --version
codex --help
codex exec --help
codex features list
```

Observed facts from this workspace on `2026-03-19`:

- `codex-cli 0.115.0`
- no `agents` top-level subcommand
- no documented `--agent <name>` flag
- `multi_agent` is enabled
- `child_agents_md` exists as a feature flag but is not enabled and is
  marked under development

## Invocation patterns that work today

There are three practical patterns.

## 1. Invoke Codex itself for a specialist task

This is the stable equivalent of selecting a specialized worker from the
outside.

Use a focused prompt, explicit boundaries, and optional profile
selection:

```bash
codex exec --full-auto -C /repo \
  -p review \
  -o /tmp/codex-review.md \
  "Review only the staged diff for regressions, missing tests, and API compatibility issues."
```

This is the best path for deterministic automation.

## 2. Invoke Codex with a skill-guided prompt

If the specialization is workflow-oriented, drive it through skills.

Example:

```bash
codex exec --full-auto -C /repo \
  -o /tmp/codex-docs.md \
  "Use the writing-markdown skill. Update docs/agents/codex/subagents.md and keep markdownlint clean."
```

This is the best path when you want a reusable specialization that can
be checked into the repository.

## 3. Let Codex delegate internally during a task

With `multi_agent` enabled, Codex can use internal subagent tooling for
delegated work inside a larger session.

In practice, this means you can ask Codex to:

- delegate exploration to a read-focused worker
- split independent implementation tasks
- run bounded sidecar analysis in parallel

This pattern is real, but the outer CLI contract is still prompt-driven
rather than a stable named-agent selection interface.

For deterministic scripts, prefer `codex exec` with a complete prompt
over relying on implicit delegation behavior.

## Recommended usage patterns

Use Codex subagent-style delegation for:

- bounded parallel exploration
- narrow implementation subtasks with separate file ownership
- sidecar verification work
- synthesizing independent findings back into one result

Use a skill instead when you need:

- a reusable workflow
- shared validation steps
- portable conventions across agent tools

Use a profile instead when you need:

- repeatable model choice
- stable sandbox and approval defaults
- a named execution mode for scripts

Rule of thumb:

- Use a skill to define how work should be done.
- Use a profile to define execution defaults.
- Use runtime subagents to split work during an active Codex task.

## Minimal workflow for Codex today

1. Put durable repo guidance in `AGENTS.md`.
2. Put reusable workflows in `.agents/skills/`.
3. Put execution defaults in `~/.codex/config.toml` profiles.
4. Use `codex exec` for deterministic automation.
5. Use prompt-directed delegation only where parallel subagent work is
   actually useful.

## Validation commands

```bash
codex --version
codex --help
codex exec --help
codex features list
codex exec --full-auto -C /repo "Summarize the current diff."
codex exec --full-auto -C /repo -p review "Review the current diff for regressions."
```

## Notes for this repository

- Keep reusable cross-tool workflows in `.agents/skills/`.
- Keep durable repo policy in `AGENTS.md`.
- Do not introduce a `.codex/agents/` convention as if it were stable
  Codex CLI behavior.
- Revisit this page when `child_agents_md` becomes documented and stable.
