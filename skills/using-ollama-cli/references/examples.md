# Examples

## One-Shot Inference

```bash
ollama run qwen2.5-coder "Review this diff for correctness risks"
```

```bash
cat README.md | ollama run llama3.3 "Summarize the key operational changes"
```

## Structured Output

```bash
ollama run llama3.3 --format json \
  "Return JSON with keys risks, mitigations, and open_questions"
```

## Remote Host

```bash
OLLAMA_HOST=http://gpu-server.local:11434 \
  ollama run gemma3 "Summarize this incident timeline in five bullets"
```

## Model Inspection

```bash
ollama show llama3.3 --parameters
ollama show my-team-model --modelfile
```

## Model Lifecycle

```bash
ollama pull qwen2.5-coder
ollama list
ollama ps
ollama stop qwen2.5-coder
```

## Custom Model

```bash
ollama create my-team-model -f Modelfile
```

## Integration Launch

```bash
ollama launch codex
```

Use `launch` only when the user wants that integration behavior, not as a
default replacement for direct CLI commands.
