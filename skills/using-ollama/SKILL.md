---
name: using-ollama
description: Use when you need to dispatch tasks to a local or remote Ollama
  instance for inference, code generation, analysis, or summarization. Invoke
  before running any ollama command.
---

# Using Ollama

## Overview

Dispatch tasks to a local or remote Ollama instance (`ollama run`)
from Claude Code. Ollama runs open-source models with flexible
deployment - locally for privacy and zero-latency inference, or
against a remote server for access to larger models and shared
GPU resources.

**Core principle:** Ollama runs independently with no shared context.
Every task must be self-contained with all necessary information in
the prompt. Ollama models vary widely in capability - choose the
right model for the task.

## When to Use

**Use Ollama when:**

- You need fast, local inference without network round-trips
- Privacy is a concern and data must stay on-device (local mode)
- You want to offload drafting, summarization, or boilerplate generation
- The task benefits from a different model's perspective or strengths
- You're working offline or want to avoid API rate limits (local mode)
- You need access to larger models running on a remote GPU server

**Don't use Ollama when:**

- The task needs access to the current conversation context
- It's a quick lookup or file read (overkill)
- The task requires capabilities beyond the locally available models
- You need tool use, MCP access, or conversation history

## Prerequisites

Ollama must be running and reachable. Verify with:

```bash
ollama list
```

If targeting a local instance and Ollama is not running, start it with `ollama serve` or launch the Ollama application.

## Configuration

By default, Ollama connects to `http://localhost:11434`. To target a remote instance, set `OLLAMA_HOST`:

```bash
# Remote server
export OLLAMA_HOST=http://gpu-server.local:11434

# Remote with custom port
export OLLAMA_HOST=http://192.168.1.100:8080

# Verify connectivity
ollama list
```

### Per-Command Remote Targeting

Prefix individual commands instead of exporting globally:

```bash
OLLAMA_HOST=http://gpu-server.local:11434 ollama run llama3.3 "Your prompt"
```

### Remote API Calls

Swap `localhost` for the remote host in API calls:

```bash
curl -s http://gpu-server.local:11434/api/generate -d '{
  "model": "llama3.3",
  "prompt": "Your prompt here",
  "stream": false
}' | jq -r '.response'
```

### Local vs Remote Tradeoffs

| Factor       | Local                         | Remote                             |
| ------------ | ----------------------------- | ---------------------------------- |
| Latency      | Lowest (no network)           | Network round-trip per request     |
| Privacy      | Data stays on-device          | Data traverses the network         |
| Model size   | Limited by local RAM/VRAM     | Access to larger models on GPU servers |
| Availability | Works offline                 | Requires network connectivity      |
| Concurrency  | Constrained by local hardware | Shared server can handle more parallel requests |

**Tip:** For parallel dispatch across both local and remote, mix `OLLAMA_HOST` values to distribute load:

```bash
# Local instance - lightweight task
echo "Summarize this" | ollama run mistral \
  > /tmp/ollama-local-task.md 2>&1

# Remote instance - heavy task needing a large model
OLLAMA_HOST=http://gpu-server.local:11434 \
  echo "Analyze this codebase" | ollama run llama3.3:70b \
  > /tmp/ollama-remote-task.md 2>&1
```

## Execution Modes

### Fire-and-Forget

Pipe a prompt and move on. Output streams to terminal.

```bash
echo "Your task prompt here" | ollama run <model>
```

### Non-Interactive with File Input

Pass file contents directly to the model:

```bash
cat src/auth/handler.ts | ollama run <model> "Explain this code and identify potential bugs"
```

### Wait-and-Integrate

Run in background via Bash tool with `run_in_background: true`. Capture output with redirection:

```bash
echo "Your analysis prompt" | ollama run <model> > /tmp/ollama-output-TASKNAME.md 2>&1
```

Use unique filenames when dispatching multiple tasks.

### Multi-File Input

Concatenate files for broader context:

```bash
cat src/auth/*.ts | ollama run <model> \
  "Analyze the authentication flow and summarize the architecture"
```

Or use a structured prompt with file contents:

```bash
{
  echo "# Task: Analyze these files for security issues"
  echo ""
  echo "## File: src/auth/handler.ts"
  cat src/auth/handler.ts
  echo ""
  echo "## File: src/auth/middleware.ts"
  cat src/auth/middleware.ts
} | ollama run <model>
```

## Common Models

| Model              | Strengths                        | Use For                           |
| ------------------ | -------------------------------- | --------------------------------- |
| `llama3.3`         | General purpose, good reasoning  | Analysis, code review, summarization |
| `codellama`        | Code-focused                     | Code generation, debugging, refactoring |
| `deepseek-coder-v2` | Strong code generation          | Implementation tasks, code completion |
| `mistral`          | Fast, efficient                  | Quick drafts, simple analysis     |
| `qwen2.5-coder`    | Code generation and understanding | Code tasks, explanations         |
| `gemma2`           | Efficient, well-rounded          | General tasks on constrained hardware |

Check available models with `ollama list`. Pull new models with `ollama pull <model>`.

## Common Flags

| Flag           | Purpose                    | Example              |
| -------------- | -------------------------- | -------------------- |
| `--nowordwrap` | Disable word wrapping      | Cleaner output for piping |
| `--format json` | JSON output               | Structured responses for parsing |
| `--verbose`    | Show timing stats          | Performance analysis |

Model parameters can be set inline:

```bash
echo "prompt" | ollama run <model> --temperature 0.2 --num-ctx 8192
```

## Prompt Structure

Ollama has NO context from Claude Code. Include everything:

```markdown
# Task: [Clear one-line description]

## Context
[What project this is, relevant architecture, file locations]

## Goal
[Exactly what to accomplish]

## Constraints
- [Scope limitations]
- [What to leave alone]

## Expected Output
[What the result should look like -- summary, code changes, analysis]
```

## Parallel Dispatch

For multiple independent tasks, dispatch concurrently using background execution:

```bash
# Task 1 - code analysis
cat src/auth/*.ts | ollama run llama3.3 \
  "Review this auth code for security issues" \
  > /tmp/ollama-auth-review.md 2>&1

# Task 2 - summarization
cat README.md CHANGELOG.md | ollama run llama3.3 \
  "Summarize the project and recent changes" \
  > /tmp/ollama-summary.md 2>&1

# Task 3 - code generation
echo "Write unit tests for the following function: $(cat src/utils/parser.ts)" \
  | ollama run codellama \
  > /tmp/ollama-tests.md 2>&1
```

Make all Bash calls with `run_in_background: true` in a single message for true parallelism.

After all complete, read each output file and integrate results.

## Using the API Directly

For more control, use Ollama's REST API:

```bash
curl -s http://localhost:11434/api/generate -d '{
  "model": "<model>",
  "prompt": "Your prompt here",
  "stream": false
}' | jq -r '.response'
```

The API is useful when you need JSON responses, want to set specific
parameters, or need to check model availability programmatically.

## Common Mistakes

**Not checking if Ollama is running:** Always verify with `ollama list`
before dispatching tasks. A connection refused error means the server
isn't running.

**Exceeding model context window:** Local models have smaller context
windows than cloud APIs. Check model limits and trim input accordingly.
Use `--num-ctx` to increase if the model supports it.

**Using interactive mode:** Without piping input, `ollama run`
launches an interactive REPL and hangs. Always pipe prompts via
`echo` or `cat`.

**Same output file for multiple tasks:** Each concurrent task needs
a unique output path or results overwrite each other.

**Over-estimating model capability:** Local models are smaller than
cloud models. Keep tasks focused and well-scoped. Split complex
reasoning into smaller steps.

**Not checking results:** Always read the output file and verify the
work before assuming success. Local models can hallucinate or produce
lower-quality output.

**Forgetting OLLAMA_HOST for remote:** If targeting a remote server,
every command needs `OLLAMA_HOST` set - either exported in the shell
or prefixed per-command. Without it, commands silently fall back to
localhost and may fail or hit the wrong instance.
