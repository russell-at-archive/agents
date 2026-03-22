# Overview

## Contents

- [Overview](#overview)
- [When to Use](#when-to-use)
- [Preflight](#preflight)
- [Execution Modes](#execution-modes)
- [Common Flags](#common-flags)
- [Prompt Template](#prompt-template)
- [File Scoping Guidance](#file-scoping-guidance)
- [Validation and Integration](#validation-and-integration)

## Overview

Dispatch tasks to Google's Gemini CLI (`gemini`).
Gemini is useful both as an interactive coding agent and as a headless CLI for
automation. For agent-to-agent use from this workspace, prefer headless mode.

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
2. Auth works: `gemini -p "Respond with: OK" --output-format json`
3. File scope is explicit
4. Execution mode is intentional
5. Approval mode and sandbox choice are intentional

## Execution Modes

### Headless Automation

Use `-p` for scripts, captured output, or deterministic one-shot runs.

```bash
gemini -p "Explain the architecture of this codebase"
```

Use structured output when another tool or agent will read the result:

```bash
gemini -p "Explain the architecture of this codebase" --output-format json
```

Use `stream-json` for long-running runs where you want incremental events:

```bash
gemini -p "Run tests and summarize failures" --output-format stream-json
```

### Interactive Session

Use plain `gemini` when the user explicitly wants a live TUI session, slash
commands, or in-session iteration.

```bash
gemini
```

Useful interactive commands include `/help`, `/auth`, `/memory`, `/chat`,
`/resume`, `/directory`, `/model`, and `/docs`.

### Prompt Then Continue Interactively

Use `--prompt-interactive` when you want Gemini to execute an initial prompt
and keep the interactive session open.

```bash
gemini --prompt-interactive "Summarize this repository, then stay interactive"
```

Do not combine `--prompt-interactive` with `-p`.

### Capture and Integrate

Capture output to a file for later integration.

```bash
gemini -p "Map module dependencies and cyclic imports" src/ \
  > /tmp/gemini-dependency-map.md 2>&1
```

Use unique output file names for parallel dispatch.

### Approval and Sandbox

Prefer explicit approval mode:

```bash
# safest default for analysis
gemini --approval-mode plan -p "Summarize domain boundaries" src/

# allow edits only when explicitly requested
gemini --approval-mode auto_edit -p "Generate analysis notes file" src/
```

`--approval-mode` accepts `default`, `auto_edit`, `yolo`, and `plan`.
`-y` is shorthand for full auto-approval and should be treated like `yolo`.

Enable sandboxing with `-s` or `GEMINI_SANDBOX=true` when you want stronger
tool isolation:

```bash
gemini -s -p "analyze the code structure"
```

## Common Flags

| Flag | Purpose |
| --- | --- |
| `-p "prompt"` | Headless mode for automation. |
| `-i "prompt"` | Run prompt and stay interactive. |
| `-m MODEL` | Select model, e.g. `gemini-2.5-flash`. |
| `-o FORMAT` | `text`, `json`, or `stream-json`. |
| `--approval-mode MODE` | `default`, `auto_edit`, `yolo`, or `plan`. |
| `-y` | Shorthand for fully auto-approving actions. |
| `-s` | Enable sandboxing. |
| `--include-directories dir1,dir2` | Add extra workspace directories. |
| `-r [latest|N]` | Resume a previous session. |

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
- Use `--include-directories` when the relevant context spans multiple roots.
- Consider project `GEMINI.md` files for persistent Gemini-side context.
- If output is too generic, rerun with stricter questions and explicit
  path lists.

## Validation and Integration

Treat Gemini output as advisory analysis. Before reporting:

1. verify critical claims against local files
2. confirm referenced symbols and paths exist
3. separate verified facts from hypotheses
4. rerun with tighter prompts if ambiguity remains
