---
name: using-ollama-cli
description: Provides expert guidance for using the Ollama CLI to run, inspect,
  pull, create, launch, and troubleshoot local or remote models. Use when the
  user asks to run `ollama` commands, mentions `OLLAMA_HOST`, Modelfiles,
  Ollama model management, local inference, or Ollama-backed coding workflows.
---

# Using Ollama CLI

Use this skill whenever the task involves `ollama` commands or operational
decisions around an Ollama server, model, or Modelfile.

Announce at start:
"Using `using-ollama-cli` to verify the Ollama command surface, choose the
right execution pattern, and validate server and model state before acting."

## Workflow

1. Verify the installed CLI and relevant subcommand help when command behavior
   matters.
2. Read [references/installation.md](references/installation.md) if setup,
   upgrades, or missing CLI/server issues are involved.
3. Read [references/overview.md](references/overview.md) for command selection,
   environment checks, and safe execution patterns.
4. Read [references/modelfiles.md](references/modelfiles.md) if the task
   involves `ollama create`, `ollama show --modelfile`, or custom models.
5. Read [references/examples.md](references/examples.md) for concrete command
   patterns only when they materially help.
6. Read [references/troubleshooting.md](references/troubleshooting.md) before
   finalizing any fix for runtime or connectivity issues.
7. Run the smallest correct command set, preferring non-interactive invocations
   for automation.
8. Validate model availability, host targeting, and output before integrating
   results.

## Hard Rules

- Do not assume hidden conversation context is visible to Ollama; prompts must
  be self-contained.
- Do not use bare `ollama run MODEL` in unattended automation; provide a prompt
  argument or pipe stdin.
- Do not mutate or remove models with `rm`, `cp`, `push`, or `create` unless
  the user asked for that outcome.
- Do not assume localhost when the task mentions a remote host; use
  `OLLAMA_HOST` explicitly.
- Do not treat generated code or analysis as verified until checked against the
  local source of truth.

## Output Contract

When acting with this skill, report:

- the command or subcommand chosen and why
- the target host (`OLLAMA_HOST` or local default)
- the model involved and whether it was already available
- any prompt, Modelfile, or output constraints that mattered
- validation performed and any remaining limits or risks
