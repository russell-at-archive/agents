# Overview

## Overview


Dispatch tasks to OpenAI's Codex CLI (`codex exec`) from Claude Code.
Use Codex for parallel execution, offloading long tasks, or leveraging
OpenAI models (o3, o4-mini) for specific work.

**Core principle:** Codex runs independently with no shared context.
Every task must be self-contained with all necessary information
in the prompt.

## When to Use


**Use Codex when:**

- You need parallel, sandboxed execution of independent tasks
- A task benefits from OpenAI models (reasoning, code generation)
- You want to offload long-running work and continue in Claude Code
- The task needs isolated filesystem write access

**Don't use Codex when:**

- The task needs access to the current conversation context
- It's a quick lookup or file read (overkill)
- Tasks need interactive user approval mid-execution
- You need Claude-specific capabilities (MCP tools, conversation history)

## Execution Modes


### Fire-and-Forget

Dispatch and move on. Output streams to terminal. User checks results.

```bash
codex exec --full-auto -C /path/to/project "Your task prompt here"
```

### Wait-and-Integrate

Run in background via Bash tool. Read output file later to integrate
results.

```bash
codex exec --full-auto -C /path/to/project \
  -o /tmp/codex-output-TASKNAME.md \
  "Your task prompt here"
```

Use unique filenames for `-o` when dispatching multiple tasks.

## Common Flags


| Flag          | Purpose                                              |
| ------------- | ---------------------------------------------------- |
| `--full-auto` | Non-interactive, sandboxed execution. Always use.    |
| `-C DIR`      | Set working directory: `-C /path/to/worktree`        |
| `-o FILE`     | Write output to file: `-o /tmp/codex-result.md`      |
| `-m MODEL`    | Choose model: `-m o3`, `-m o4-mini`                  |
| `-s SANDBOX`  | Sandbox policy: `-s read-only`, `-s workspace-write` |
| `-i IMAGE`    | Attach image(s): `-i screenshot.png`                 |
| `--json`      | JSONL output for parsing                             |

## Prompt Structure


Codex has NO context from Claude Code. Include everything:

```markdown
# Task: [Clear one-line description]

## Context

[What project this is, relevant architecture, file locations]

## Goal

[Exactly what to accomplish]

## Constraints

- Only modify files in [specific scope]
- Do not change [what to leave alone]

## Expected Output

[What the result should look like - summary, code changes, analysis]
```

## Parallel Dispatch


For multiple independent tasks, dispatch concurrently using background
execution:

```bash
# Task 1 - background
codex exec --full-auto -C /path/to/project \
  -o /tmp/codex-task1.md "Fix failing tests in src/auth/"

# Task 2 - background
codex exec --full-auto -C /path/to/project \
  -o /tmp/codex-task2.md "Add input validation to src/api/handlers.go"

# Task 3 - background
codex exec --full-auto -C /path/to/project \
  -o /tmp/codex-task3.md "Write unit tests for src/utils/parser.ts"
```

Make all three Bash calls with `run_in_background: true` in a single
message for true parallelism.

After all complete, read each output file and integrate results.

