# Skills Authoring: Optimal Practices

## Purpose

This document defines a research-backed standard for writing high-quality
agent skills that are discoverable, reliable, safe, and maintainable.

It is designed for teams that want:

- deterministic behavior under automation
- small and readable main skill files
- deep guidance available without context bloat
- measurable quality gates before publication

## Research Summary

The strongest patterns across official guidance are consistent:

- keep top-level instructions concise and explicit
- separate routing metadata from implementation detail
- use structured prompts and exact output contracts
- evaluate prompt behavior with repeatable tests
- prioritize clarity and predictable failure handling

These patterns align with Anthropic Agent Skills guidance, OpenAI prompt
engineering and eval guidance, MCP prompt metadata guidance, and technical
writing standards.

## Core Principles

### 1. Design for routing first

The skill `name` and `description` should optimize trigger precision.

- Name should be concise and unique.
- Description should be explicit about when to invoke.
- Include a strong action verb and concrete scope.
- Include at least one explicit "when not to use" boundary.

Why: ambiguous routing metadata causes wrong-skill activation and drift.

### 2. Keep the main body short

Treat `SKILL.md` as a control plane, not a full manual.

- Target: under 100 lines.
- Soft ceiling: 120 lines.
- Move deep examples, command matrices, and edge cases to `references/`.
- Link to specific files, not directories.

Why: smaller top-level instructions improve retrieval and reduce prompt noise.

### 3. Use progressive disclosure

Keep only execution-critical guidance in `SKILL.md`.

- put long procedures and rationale in `references/overview.md`
- put concrete invocations in `references/examples.md`
- put edge cases and recovery steps in `references/troubleshooting.md`
- put deterministic steps in `scripts/`
- put reusable scaffolds in `assets/`

Why: this mirrors Anthropic's guidance to keep main skill files concise while
loading detail on demand.

### 4. Specify explicit output contracts

For each workflow, define what "done" looks like.

- required sections
- required command outputs or checks
- failure actions and escalation path

Why: explicit contracts reduce interpretation variance across agents.

### 5. Prefer deterministic commands

Examples must be runnable and safe.

- prefer non-interactive flags in agent flows
- avoid hidden assumptions and shell-specific tricks
- show exact command form and expected verification step

Why: predictable command behavior is required for reliable automation.

### 6. Encode safety as hard rules

Every skill should include non-negotiable guardrails.

- destructive actions need explicit approval
- auth and permission failures must halt or escalate
- unknown environment state must be surfaced before mutation

Why: safety constraints should be first-class instructions, not suggestions.

### 7. Separate policy from examples

Put policy in top-level bullets and examples in references.

- policy is stable and short
- examples are numerous and change often

Why: this reduces churn and keeps core behavior legible.

### 8. Validate skills with eval-style tests

Treat skill quality as an evaluated artifact.

- define representative invocation prompts
- define expected behavior for each prompt
- run regression checks after edits

Why: eval-driven iteration is the fastest way to reduce prompt regressions.

## Recommended Skill Layout

```text
<skill>/
  SKILL.md
  references/
    overview.md
    examples.md
    troubleshooting.md
  scripts/
    <deterministic helper scripts>
  assets/
    <templates, static scaffolds>
  tests/
    prompts.md
    expected-behavior.md
```

## Optimal `SKILL.md` Template

```markdown
---
name: <skill-name>
description: Use when <specific trigger>. Invoke before <critical action>.
---

# <Skill Title>

## Overview

<one paragraph purpose + hard boundary>
Detailed guidance: `references/overview.md`.

## When to Use

- <positive trigger>
- <positive trigger>

## When Not to Use

- <negative trigger>

## Prerequisites

- <binary/auth/permission requirement>

## Workflow

1. <step>
2. <step>
3. <step>

## Hard Rules

- <non-negotiable safety/routing rule>
- <non-negotiable execution rule>

## Failure Handling

- <known failure>: <required response>

## Red Flags

- <stop-and-correct signal>
```

## Quality Gates

A skill is ready only if all checks pass:

- [ ] `SKILL.md` line count <= 100 (or documented exception)
- [ ] trigger description is specific and testable
- [ ] at least one negative trigger is defined
- [ ] workflow uses concrete, reproducible commands
- [ ] safety and escalation rules are explicit
- [ ] references are linked and paths exist
- [ ] tests include positive and negative invocation cases
- [ ] markdown formatting is lint-clean

## Migration Plan for Existing Libraries

1. Baseline all skills with line count, trigger precision, and safety coverage.
2. Split current long content into `overview`, `examples`, and
   `troubleshooting` references.
3. Trim `SKILL.md` to control-plane content only.
4. Add `tests/prompts.md` with expected behaviors.
5. Run regression checks on representative prompts.
6. Enforce the gates in review policy.

## Common Anti-Patterns

- giant `SKILL.md` files mixing policy, tutorial, and reference text
- generic descriptions like "Use when needed"
- no explicit failure behavior
- examples without verification commands
- conflicting rules across related skills
- no negative triggers, causing over-activation

## Sources

- [Anthropic Agent Skills best practices][src-anthropic-blog-skills]
- [Anthropic docs for Agent Skills][src-anthropic-docs-skills]
- [Anthropic prompt engineering overview][src-anthropic-prompt-overview]
- [Anthropic prompting techniques][src-anthropic-prompt-xml]
- [OpenAI prompt engineering guide][src-openai-prompt-guide]
- [OpenAI eval-driven development cookbook][src-openai-evals]
- [MCP prompt metadata recommendations][src-mcp-prompts]
- [Google developer documentation style guide][src-google-style]

[src-anthropic-blog-skills]: https://www.anthropic.com/engineering/agent-skills
[src-anthropic-docs-skills]: https://docs.anthropic.com/en/docs/claude-code/skills
[src-anthropic-prompt-overview]:
  https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview
[src-anthropic-prompt-xml]:
  https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/use-xml-tags
[src-openai-prompt-guide]: https://platform.openai.com/docs/guides/prompt-engineering
[src-openai-evals]:
  https://cookbook.openai.com/examples/evaluation/use-cases/evalsapi_tools_evaluation
[src-mcp-prompts]:
  https://modelcontextprotocol.io/specification/2025-06-18/server/prompts
[src-google-style]: https://developers.google.com/style
