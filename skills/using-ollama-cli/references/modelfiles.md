# Modelfiles

## When To Read This

Use this reference when the task involves `ollama create`, custom model
behavior, or inspecting an existing model with `ollama show --modelfile`.

## Core Workflow

1. Inspect an existing base model if relevant:

```bash
ollama show <model> --modelfile
```

2. Write or review a `Modelfile`.
3. Build the model:

```bash
ollama create <new-model> -f Modelfile
```

4. Validate with `ollama run <new-model> "..."`.

## Practical Guidance

- Start from a known base model with `FROM`.
- Keep system instructions narrow and task-specific.
- Treat the `Modelfile` as source code that should be reviewed.
- Rebuild after changes; `create` is not incremental in spirit.
- Use `show --parameters`, `--system`, or `--template` when debugging inherited
  behavior.

## Guardrails

- Do not overwrite or publish a model unless the user asked for that change.
- Do not assume custom models are portable across hosts without validating
  where they were created.
