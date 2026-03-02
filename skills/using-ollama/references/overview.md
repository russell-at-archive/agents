# Overview

## Purpose

Use Ollama to run local or remote models for delegated analysis,
generation, summarization, or transformation tasks.

Core constraint: Ollama has no access to hidden agent context.
Every prompt must be self-contained.

## Readiness Checks

Run these checks before dispatching work:

```bash
ollama list
```

If server is down locally, start it:

```bash
ollama serve
```

If targeting remote, set host and verify:

```bash
export OLLAMA_HOST=http://gpu-server.local:11434
ollama list
```

## Command Flow

1. Confirm task is suitable for delegation.
2. Select model for speed versus quality tradeoff.
3. Build prompt with context, goal, constraints, and output contract.
4. Execute non-interactively with `ollama run`.
5. Save output to a unique path when running async or in parallel.
6. Review and validate before integration.

## Model Selection Heuristics

- `mistral` or `gemma2`: fast drafting and lightweight summaries
- `qwen2.5-coder` or `codellama`: coding tasks and refactors
- `llama3.3`: deeper analysis and review
- larger hosted variants: heavy reasoning when remote GPU is available

Always confirm availability with `ollama list`.

## Execution Patterns

### Single prompt

```bash
echo "Summarize this design doc" | ollama run mistral
```

### File plus instruction

```bash
cat src/auth/handler.ts | ollama run qwen2.5-coder \
  "Explain behavior and list likely defects"
```

### Remote one-off

```bash
OLLAMA_HOST=http://gpu-server.local:11434 \
  ollama run llama3.3 "Analyze rollout risks for this change"
```

### Captured output

```bash
echo "Review this module" | ollama run llama3.3 \
  > /tmp/ollama-review-auth.md 2>&1
```

## Prompt Contract

Use this structure:

```markdown
# Task

[One-line objective]

## Context

[Project, files, architecture, constraints]

## Goal

[What done looks like]

## Guardrails

- [Out of scope]
- [Safety or policy limits]

## Expected Output

[Exact shape: bullets, patch notes, test list, etc.]
```

## Validation Checklist

Before using model output:

- Check factual consistency against local files.
- Confirm constraints were respected.
- Verify code suggestions compile or are syntactically valid.
- Re-run with narrower prompts when quality is weak.
