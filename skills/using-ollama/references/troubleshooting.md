# Troubleshooting

## Red Flags

Stop and correct if any occur:

- `ollama run` entered interactive mode unexpectedly
- prompt is missing key context
- remote host was intended but command used localhost
- output file collisions in concurrent runs
- model output copied without verification

## Common Failures

### Connection refused

Cause:
Ollama server is not running or host is unreachable.

Fix:

1. Run `ollama list`.
2. Start local service with `ollama serve`, or fix `OLLAMA_HOST`.
3. Retry command.

### Model not found

Cause:
Requested model has not been pulled on target host.

Fix:

1. Run `ollama list`.
2. Run `ollama pull <model>`.
3. Re-run task.

### Interactive hang

Cause:
`ollama run <model>` executed without piped prompt or prompt argument.

Fix:

1. Cancel process.
2. Re-run with piped input using `echo` or `cat`.

### Truncated or weak output

Cause:
Prompt is too broad, or context window is exceeded.

Fix:

1. Reduce input scope.
2. Increase context if model supports it.
3. Split task into smaller prompts.
4. Use a stronger model when needed.

### Remote fallback mistakes

Cause:
`OLLAMA_HOST` not set for a command that should target remote.

Fix:

1. Prefix command with `OLLAMA_HOST=...` for one-off runs.
2. Or export `OLLAMA_HOST` in session.
3. Confirm target with `ollama list`.

## Recovery Flow

1. Identify environment issue, prompt issue, or model issue.
2. Fix one variable at a time.
3. Re-run and compare outputs.
4. Integrate only after manual validation.
