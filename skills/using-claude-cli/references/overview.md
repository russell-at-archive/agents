# Overview

## Purpose

Use Claude Code CLI (`claude`) for interactive coding sessions, one-shot
automation runs, or structured machine-readable outputs.

Default behavior is interactive. Use `-p` for non-interactive execution.

## When To Use

Use Claude CLI when:

- the user explicitly wants `claude` commands
- you need Claude Code features from terminal workflows
- you need session resume and continuation behavior
- you need structured output (`json` or `stream-json`)

Do not use Claude CLI when:

- a direct local shell command is simpler and lower risk
- the task requires another specific tool or skill instead

## Preflight

Run before substantive work:

```bash
claude --version
claude auth status
```

Confirm command context:

- target directory is correct
- model and effort settings are intentional
- permission mode is explicit for risky tasks

## Execution Modes

### Interactive Session

Use for exploratory or iterative work:

```bash
claude
claude --model sonnet --effort medium
```

### Non-Interactive Print Mode

Use for deterministic automation:

```bash
claude -p "Summarize architecture in src/auth with risks and gaps"
claude -p "Generate a migration checklist" --output-format json
```

### Streaming Integration

Use `stream-json` for real-time tool integration:

```bash
claude -p "Analyze CI failures and propose fixes" \
  --output-format stream-json
```

### Session Continuation

Continue prior context safely:

```bash
claude --continue
claude --resume
```

## Permission And Scope Controls

Set controls explicitly for safety:

```bash
claude -p "Run tests and fix failures" \
  --permission-mode plan \
  --allowedTools "Bash(npm test:*) Edit Read"
```

Useful controls:

- `--permission-mode`:
  `default`, `plan`, `acceptEdits`, `dontAsk`, `bypassPermissions`
- `--allowedTools` and `--disallowedTools` to constrain tool access
- `--add-dir` to permit access to extra directories
- `--max-turns` to cap autonomous loop length

Use `--dangerously-skip-permissions` only when explicitly requested and in
trusted, sandboxed environments.

## Prompt Template

For reliable `-p` runs, provide complete context:

```markdown
# Task
[one-line objective]

## Context
[project, constraints, file paths]

## Requirements
1. [...]
2. [...]

## Output
[format, sections, acceptance criteria]
```

## Verification

Before reporting:

1. verify files and symbols referenced in output exist
2. confirm permissions and tool constraints matched intent
3. rerun with tighter scope if results are too generic
