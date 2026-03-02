---
name: using-ollama
description: Use when you need to dispatch tasks to a local or remote Ollama
  instance for inference, code generation, analysis, or summarization. Invoke
  before running any ollama command.
---

# Using Ollama

## Overview

Use this skill when delegating work to an Ollama model.

Announce at start:
"I am using the using-ollama skill to choose a model, package complete
context, run Ollama safely, and validate output before integration."

Detailed guidance:
`references/overview.md`, `references/examples.md`, and
`references/troubleshooting.md`.

## When to Use

- User asks to run `ollama` commands.
- User asks for local or remote model inference via Ollama.
- Task can be delegated as a self-contained prompt.

## When Not to Use

- Task depends on hidden conversation context.
- Task is a trivial shell or file operation.
- Tool calling is required inside the delegated run.

## Prerequisites

- `ollama` CLI is installed.
- Ollama server is reachable (`ollama list` succeeds).
- Target model exists or can be pulled.

## Workflow

1. Load `references/overview.md` for command flow and model selection.
2. Load `references/examples.md` for prompt templates and dispatch patterns.
3. Load `references/troubleshooting.md` before finalizing output.
4. Verify server and model availability.
5. Build a complete, explicit prompt with context and constraints.
6. Run `ollama run` non-interactively.
7. Validate response quality before using results.

## Output Contract

For each Ollama dispatch, provide:

- selected model and why
- local or remote target (`OLLAMA_HOST` when remote)
- exact prompt scope and constraints
- output path when writing to files
- validation notes before integration

## Hard Rules

- Never run interactive `ollama run` in unattended workflows.
- Never assume conversation context is visible to Ollama.
- Never treat model output as verified without checks.
- Never switch to `/implement` style coding unless user asked.
- Never run destructive commands without explicit approval.

## Failure Handling

- If `ollama list` fails, report connectivity steps and stop.
- If model is missing, run `ollama pull <model>` before retry.
- If output quality is weak, tighten scope and re-run with better prompt.
- If remote host is wrong, set or prefix `OLLAMA_HOST` and retry.

## Red Flags

- Prompt omits required context or acceptance criteria
- Same output file reused across parallel tasks
- Model chosen does not fit task complexity
- Large input exceeds model context window
- Results integrated without review
