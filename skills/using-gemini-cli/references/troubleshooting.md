# Troubleshooting

## Contents

- [Common Failures](#common-failures)
- [Stop Conditions](#stop-conditions)

## Common Failures

### CLI Not Found

Symptom: `command not found: gemini`

Action:

1. install Gemini CLI
2. reopen shell/session
3. verify with `gemini --version`

### Authentication Failure

Symptom: Gemini rejects requests or exits immediately.

Action:

1. run a probe: `gemini -p "Respond with: OK" --output-format json`
2. if using API keys, verify `GEMINI_API_KEY`
3. if using Vertex, unset `GOOGLE_API_KEY` and `GEMINI_API_KEY`, then verify
   `GOOGLE_CLOUD_PROJECT`, `GOOGLE_CLOUD_LOCATION`, and credentials
4. retry the real task only after the probe succeeds

### Interactive Hang

Symptom: command appears stuck waiting for input.

Cause: you started an interactive flow.

Action:

1. use `-p` for headless automation
2. use `--prompt-interactive` only when you want the session to remain open

```bash
gemini -p "Your prompt" <paths>
```

### `--help` or `--version` Appears To Stall

Symptom: help or version does not return promptly in the current environment.

Action:

1. verify the installed package path and version from the package metadata
2. inspect the shipped docs under the installed bundle when needed
3. avoid assuming the TUI is safe to invoke from a non-interactive agent shell

### Low-Quality or Generic Output

Symptom: broad, ungrounded answers.

Action:

1. pass broader file context (whole module dirs)
2. add explicit questions and required output format
3. require file-path citations in prompt
4. rerun and verify claims against source files

### Output Lost During Background Runs

Symptom: no analysis available after run.

Cause: stdout/stderr not redirected.

Action:

```bash
gemini -p "Your prompt" src/ > /tmp/gemini-task.md 2>&1
```

### Unsafe Autonomy Mode

Symptom: unintended writes or risky tool behavior.

Action:

1. default to `--approval-mode plan`
2. use `auto_edit` only when edits are explicitly requested
3. avoid `-y` or `yolo` unless user requested full autonomy

### Session Resume Confusion

Symptom: Gemini resumes the wrong thing or no session is resumed.

Action:

1. list sessions with `gemini --list-sessions`
2. resume with `gemini --resume latest` or `gemini --resume N`
3. remember sessions are project-scoped

## Stop Conditions

Stop and escalate to the user when:

- required paths are unknown and materially affect analysis quality
- output claims conflict with local source of truth
- task intent shifts from analysis to implementation
