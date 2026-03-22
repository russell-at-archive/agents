# Troubleshooting

## Fast Triage

1. Check the target host: local default or explicit `OLLAMA_HOST`.
2. Check server reachability with `ollama list`.
3. Check model presence with `ollama list`.
4. Check the exact subcommand help if flags are behaving unexpectedly.

## Common Failures

### Could not connect to a running Ollama instance

Cause: the local server is down, or the remote host is wrong or unreachable.

Fix:

```bash
ollama list
ollama serve
```

Or:

```bash
OLLAMA_HOST=http://gpu-server.local:11434 ollama list
```

### Model not found

Cause: the model does not exist on the selected host.

Fix:

```bash
ollama pull <model>
```

Then retry the original command against the same host.

### Command hung in interactive mode

Cause: `ollama run MODEL` was invoked without a prompt argument or stdin.

Fix: rerun with an explicit prompt or a pipe.

### Weak or truncated output

Cause: prompt too broad, wrong model, or context pressure.

Fix:

- narrow the task
- split large inputs
- use `--format json` only when the output shape is simple
- move to a stronger or more appropriate model

### Wrong target host

Cause: local default was used when the task was intended for remote.

Fix: prefix the exact command with `OLLAMA_HOST=...` instead of relying on
session state.

## Red Flags

- destructive model commands without explicit user intent
- assuming a model exists without checking
- integrating generated output without verification
- using experimental flags unless the task explicitly calls for them
