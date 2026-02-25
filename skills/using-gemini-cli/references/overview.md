# Overview

## Overview


Dispatch tasks to Google's Gemini CLI (`gemini`) from Claude Code.
Gemini's strength is its massive context window (1M+ tokens), making
it ideal for large-scale comprehension tasks that require reading many
files simultaneously.

**Core principle:** Gemini runs independently with no shared context.
Pass file paths directly - Gemini reads them with its large context
window. Every task must be self-contained.

## When to Use


**Use Gemini when:**

- Analyzing or understanding a large codebase (many files, deep
  dependency trees)
- Summarizing large PRs, long documents, or entire repositories
- Mapping cross-file dependencies ("how does X affect Y across the
  codebase?")
- Assessing migration impact across a project
- Research that requires reading and synthesizing many files
  simultaneously

**Don't use Gemini when:**

- The task needs code generation or execution (use Codex)
- It's a small, focused question about 1-2 files (overkill -- read
  them directly)
- The task needs access to the current conversation context
- You need to modify files (Gemini is best for read/analysis, not
  writes)

## Execution Modes


### Fire-and-Forget

Dispatch and move on. Output streams to terminal.

```bash
gemini -p "Your analysis prompt here" file1.ts file2.ts src/module/
```

### Non-Interactive with Approval Modes

Control what Gemini can do autonomously:

```bash
# Read-only analysis (safest for comprehension tasks)
gemini --approval-mode plan -p "Analyze architecture of this project"

# Auto-approve edits (if Gemini needs to write analysis files)
gemini --approval-mode auto_edit -p "Your prompt" file1.ts

# Full auto-approve (use sparingly)
gemini -y -p "Your prompt" file1.ts
```

### Wait-and-Integrate

Run in background via Bash tool. Capture output with redirection:

```bash
gemini -p "Your analysis prompt" src/ > /tmp/gemini-output-TASKNAME.md 2>&1
```

Use unique filenames when dispatching multiple tasks.

## Common Flags


| Flag                    | Purpose                                          |
| ----------------------- | ------------------------------------------------ |
| `-p "prompt"`           | Non-interactive (headless) mode. Always use.     |
| `-m MODEL`              | Choose model: `-m gemini-2.5-pro`                |
| `-y`                    | Auto-approve all actions (YOLO)                  |
| `--approval-mode MODE`  | Set approval policy: `plan`, `auto_edit`, `yolo` |
| `-o FORMAT`             | Output format: `-o json`, `-o text`              |
| `--include-directories` | Add extra directories to workspace               |
| `-s`                    | Run in sandbox for untrusted analysis            |

## Prompt Structure


Gemini has NO context from Claude Code. Include everything:

```markdown
# Task: [Clear one-line description]

## Context

[What project this is, relevant architecture]

## Goal

[Exactly what to analyze or comprehend]

## Files

[List file paths or directories to examine]

## Expected Output

[What the analysis should cover -- architecture overview,
dependency map, migration impact, summary, etc.]
```

## Passing Files


Gemini's strength is reading many files at once. Pass paths directly
as positional arguments after the prompt:

```bash
# Specific files
gemini -p "Analyze the auth flow" src/auth/*.ts src/middleware/auth.ts

# Entire directories
gemini -p "Map dependencies in this module" src/core/

# Mix of files and directories
gemini -p "Assess migration impact" src/ package.json tsconfig.json
```

Prefer passing **more files** rather than fewer -- Gemini handles
breadth well.

## Parallel Dispatch


For multiple independent analysis tasks, dispatch concurrently:

```bash
# Task 1 - codebase analysis
gemini -p "Analyze architecture of the auth system" \
  src/auth/ > /tmp/gemini-auth-analysis.md 2>&1

# Task 2 - dependency mapping
gemini -p "Map all imports and dependencies for src/core/engine.ts" \
  src/ > /tmp/gemini-deps.md 2>&1

# Task 3 - summarization
gemini -p "Summarize all changes in this PR" \
  $(git diff main...HEAD --name-only) > /tmp/gemini-summary.md 2>&1
```

Make all Bash calls with `run_in_background: true` in a single message
for true parallelism.

