---
name: writing-prompts
description: Writes, critiques, and improves prompts for LLMs using expert
  prompt engineering techniques. Use when asked to write a prompt, improve
  a prompt, review prompt quality, debug why a prompt isn't working, or
  design a system prompt, instruction set, or few-shot example set. Also
  trigger for requests like "help me get better outputs from Claude/GPT",
  "my prompt keeps failing", "how should I structure this instruction", or
  any task where the goal is to craft language that steers an LLM toward
  a desired behavior.
---

# Writing Prompts

## Overview

Produces effective prompts for LLMs by applying proven prompt engineering
techniques: goal clarity, context management, output format control,
few-shot examples, chain-of-thought, and iterative refinement. Full
technique reference: [references/overview.md](references/overview.md).

## When to Use

- Writing a system prompt, user prompt, or instruction set from scratch
- Improving or diagnosing an existing prompt that produces poor outputs
- Designing few-shot examples, chain-of-thought demonstrations, or output
  format constraints
- Choosing between prompting strategies (zero-shot vs few-shot vs CoT)
- Hardening a prompt against hallucination, prompt injection, or instruction
  following failures

## When Not to Use

- The user wants fine-tuning or RLHF — prompting can't substitute for
  training when systematic behavioral changes are needed
- The task requires a code change (e.g., switching models, adjusting
  temperature, adding tool use) rather than prompt text
- The user wants Claude to answer a question directly — write the answer,
  don't write a prompt to answer it

## Prerequisites

- The target task and desired output are described (even roughly)
- The target model is known or can be inferred (Claude, GPT-4, etc.)
- Any constraints (tone, format, length, audience) are stated or can be
  asked for

## Workflow

1. Read [references/overview.md](references/overview.md) for technique
   selection, structure patterns, and output control.
2. Clarify intent: what task, what model, what output format, what
   failure modes matter most.
3. Choose technique level (zero-shot → few-shot → CoT → advanced) based
   on task complexity — start with the simplest that could work.
4. Draft the prompt using the structure pattern that fits (see overview).
5. Surface the draft with an explanation of key choices made.
6. If the user has an existing prompt that's failing, diagnose first using
   [references/troubleshooting.md](references/troubleshooting.md).
7. Use [references/examples.md](references/examples.md) to show before/
   after comparisons when rewriting.

## Hard Rules

- Explain the reasoning behind structural choices — prompts the user
  understands are prompts they can maintain and improve.
- Never add complexity (CoT, few-shot, XML tags) without justification;
  the simplest prompt that works is the right prompt.
- Specify output format explicitly in every prompt that has non-obvious
  formatting needs.
- Ground examples in the user's actual task, not generic placeholders.
- When rewriting an existing prompt, preserve intent; don't silently
  change what the prompt is trying to do.

## Failure Handling

- If the task is ambiguous, ask one clarifying question before drafting.
- If the desired output format is unclear, propose a reasonable default
  and state it explicitly.
- If the user's existing prompt has multiple problems, triage: fix the
  highest-impact issue first, then surface others.

## Red Flags

- Prompts that tell the model what NOT to do without saying what TO do
- Instructions buried in the middle of long context (lost-in-the-middle)
- No output format specification for structured or length-sensitive tasks
- Few-shot examples that contradict each other or the instructions
- Vague role definitions ("You are a helpful assistant")
- Missing escalation path for uncertainty ("If unsure, say so")
