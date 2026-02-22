# Troubleshooting

## Fast Triage

1. check install: `claude --version`
2. check auth: `claude auth status`
3. confirm mode: interactive vs `-p`
4. verify permission mode and tool constraints
5. rerun with `--debug` for diagnostics

## CLI Not Found

Symptom:

- `command not found: claude`

Fix:

1. install or update Claude Code
2. reopen shell
3. re-run `claude --version`

## Authentication Failure

Symptom:

- command exits early due to auth state

Fix:

```bash
claude auth login
claude auth status
```

## Command Hangs In Automation

Symptom:

- process waits for interactive input

Cause:

- interactive mode used without `-p`

Fix:

```bash
claude -p "Your prompt" --output-format text
```

## Output Too Generic

Symptom:

- broad answer without grounded file details

Fix:

1. add explicit file paths or module directories
2. add strict output schema and acceptance criteria
3. ask for concrete file-path citations in result
4. reduce scope and rerun

## Unexpected Writes Or Risky Autonomy

Symptom:

- CLI attempts actions beyond expected scope

Fix:

1. use `--permission-mode plan` as default safety mode
2. constrain tool usage with `--allowedTools`
3. cap turns with `--max-turns`
4. avoid `--dangerously-skip-permissions` unless explicitly requested

## Resume Or Continue Does Not Match Expectations

Symptom:

- prior context is missing or wrong session restored

Fix:

1. use `--resume` and pick the correct session
2. pass explicit session ID with `--resume <id>`
3. use `--fork-session` when you need a branch from previous context

## Stop Conditions

Stop and escalate when:

- required paths or permissions are unknown and risk is material
- user asks for bypass mode without explicit risk acceptance
- output conflicts with verified local source of truth
