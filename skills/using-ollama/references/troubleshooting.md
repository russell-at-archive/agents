# Troubleshooting

## Common Mistakes


**Not checking if Ollama is running:** Always verify with `ollama list`
before dispatching tasks. A connection refused error means the server
isn't running.

**Exceeding model context window:** Local models have smaller context
windows than cloud APIs. Check model limits and trim input accordingly.
Use `--num-ctx` to increase if the model supports it.

**Using interactive mode:** Without piping input, `ollama run`
launches an interactive REPL and hangs. Always pipe prompts via
`echo` or `cat`.

**Same output file for multiple tasks:** Each concurrent task needs
a unique output path or results overwrite each other.

**Over-estimating model capability:** Local models are smaller than
cloud models. Keep tasks focused and well-scoped. Split complex
reasoning into smaller steps.

**Not checking results:** Always read the output file and verify the
work before assuming success. Local models can hallucinate or produce
lower-quality output.

**Forgetting OLLAMA_HOST for remote:** If targeting a remote server,
every command needs `OLLAMA_HOST` set - either exported in the shell
or prefixed per-command. Without it, commands silently fall back to
localhost and may fail or hit the wrong instance.

