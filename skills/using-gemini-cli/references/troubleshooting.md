# Troubleshooting

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

1. run a probe: `gemini -p "Respond with: OK"`
2. re-authenticate per local Gemini setup
3. retry the real task only after probe succeeds

### Interactive Hang

Symptom: command appears stuck waiting for input.

Cause: missing `-p` prompt flag.

Action: always run headless form:

```bash
gemini -p "Your prompt" <paths>
```

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
3. avoid `-y` unless user requested full autonomy

## Stop Conditions

Stop and escalate to the user when:

- required paths are unknown and materially affect analysis quality
- output claims conflict with local source of truth
- task intent shifts from analysis to implementation
