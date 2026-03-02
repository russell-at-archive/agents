# Overview

## Overview

Dispatch tasks to Google's Gemini CLI (`gemini`).
Gemini is strongest on broad, cross-file comprehension where a large
context window materially improves result quality.

**Core principle:** Gemini runs independently with no shared context.
Every prompt must include full task intent, constraints, and file scope.

## When to Use

Use Gemini when:

- analyzing architecture across many modules
- mapping dependency impact of proposed changes
- summarizing large repositories or document sets
- producing migration/readiness assessments from many files

Do not use Gemini when:

- you need direct file edits in this workspace
- the question is narrow and answerable from 1-2 files
- you need in-session context from this current conversation

## Preflight

Before any substantial run, confirm:

1. CLI is installed: `gemini --version`
2. Auth works: `gemini -p "Respond with: OK"`
3. File scope is explicit (files/directories selected)
4. Output destination is set for long-running tasks
5. Approval mode is intentionally chosen

## Execution Modes

### Fire-and-Forget

Run once and read output in terminal.

```bash
gemini -p "Analyze auth architecture and trust boundaries" src/auth/ src/middleware/
```

### Wait-and-Integrate

Capture output to a file for later integration.

```bash
gemini -p "Map module dependencies and cyclic imports" src/ \
  > /tmp/gemini-dependency-map.md 2>&1
```

Use unique output file names for parallel dispatch.

### Approval-Controlled Execution

Prefer explicit approval mode:

```bash
# safest default for analysis
gemini --approval-mode plan -p "Summarize domain boundaries" src/

# allow edits only when explicitly requested
gemini --approval-mode auto_edit -p "Generate analysis notes file" src/
```

## Common Flags

| Flag                   | Purpose                                          |
| ---------------------- | ------------------------------------------------ |
| `-p "prompt"`         | Headless mode. Always use for automation.        |
| `-m MODEL`             | Select model, e.g. `-m gemini-2.5-pro`.         |
| `-o FORMAT`            | Output format, e.g. `-o text` or `-o json`.      |
| `--approval-mode MODE` | Approval policy: `plan`, `auto_edit`, `yolo`.    |
| `-y`                   | Auto-approve all actions. Use only if requested. |
| `-s`                   | Sandbox mode for untrusted analysis tasks.       |

## Prompt Template

Use this structure for reliable output:

```markdown
# Task
[one-line objective]

## Context
[project/module purpose and relevant constraints]

## Files to Analyze
[path list; include directories for broad context]

## Questions to Answer
1. [...]
2. [...]

## Output Requirements
[format, sections, and decision criteria]
```

## File Scoping Guidance

- Prefer passing complete module directories over isolated files.
- Include config and entrypoint files (`package.json`, build config,
  main router/DI files) when asking architecture questions.
- If output is too generic, rerun with stricter questions and explicit
  path lists.

## Validation and Integration

Treat Gemini output as advisory analysis. Before reporting:

1. verify critical claims against local files
2. confirm referenced symbols and paths exist
3. separate verified facts from hypotheses
4. rerun with tighter prompts if ambiguity remains
