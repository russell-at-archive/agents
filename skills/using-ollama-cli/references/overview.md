# Overview

## Purpose

Use the Ollama CLI to operate local or remote model runtimes safely. The core
split is:

- `serve`: run the Ollama server
- `run`: generate text, embeddings, or image output from a model
- `pull`, `list`, `show`, `ps`, `stop`: inspect and manage model/runtime state
- `create`, `cp`, `push`, `rm`: create or mutate model artifacts
- `launch`: open the Ollama menu or supported integrations

## Readiness Checks

Run these first when the environment is uncertain:

```bash
ollama --help
ollama list
```

If the server is not reachable locally:

```bash
ollama serve
```

For a remote target, prefer per-command scoping:

```bash
OLLAMA_HOST=http://gpu-server.local:11434 ollama list
```

## Command Selection

- Use `ollama run MODEL "prompt"` for one-shot generation.
- Use `echo "... " | ollama run MODEL` when stdin piping is simpler.
- Use `ollama run MODEL --format json` when the caller needs machine-readable
  output and plain JSON is sufficient.
- Use `ollama pull MODEL` before a run when the model is missing.
- Use `ollama show MODEL --modelfile|--parameters|--system|--template` to
  inspect how a model is configured.
- Use `ollama create MODEL -f Modelfile` for a custom model build.
- Use `ollama ps` and `ollama stop MODEL` to manage loaded models.
- Use `ollama launch <integration>` only when the user explicitly wants an
  Ollama-backed integration workflow.

## Important Flags And Env Vars

- `--format json`: structured output for `run`
- `--keepalive 5m`: keep a model loaded after a run
- `--verbose`: include response timing
- `--nowordwrap`: avoid wrapped terminal output
- `--think` and `--hidethinking`: control thinking output on supported models
- `OLLAMA_HOST`: point commands at a remote server
- `OLLAMA_CONTEXT_LENGTH`: server-side default context window
- `OLLAMA_KEEP_ALIVE`, `OLLAMA_MAX_QUEUE`, `OLLAMA_NUM_PARALLEL`: server
  behavior tuning
- `OLLAMA_NO_CLOUD`: disable cloud features such as remote inference and web
  search

## Safe Execution Pattern

1. Confirm the host and model.
2. Choose the narrowest subcommand that solves the task.
3. Make prompts explicit and self-contained.
4. Capture output when follow-up parsing or review is needed.
5. Verify results against local files or runtime state before acting on them.
