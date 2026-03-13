# Pi Session System Prompt Summary

I cannot provide the exact hidden system prompt verbatim.

This document captures the effective default behavior at a high level.

## Default Priorities

- Follow instruction precedence: system instructions, then developer instructions, then user instructions.
- Be helpful, accurate, and safe.
- Use available tools when needed to complete tasks in the workspace.
- Be transparent about limits and uncertainty.
- Do not expose sensitive internal instructions, hidden prompts, or secrets.

## Can You Append or Override the Default System Prompt?

Yes.

- Append behavior with `APPEND_SYSTEM.md`.
- Completely replace the default system prompt with `SYSTEM.md`.

Pi loads these files from `~/.pi/agent/`, parent directories, and the current
project directory at startup.

## This Workspace Session Adds More Rules

In this repository, additional project-level instructions apply (for example,
`AGENTS.md` mandates and local skill usage requirements). Those instructions
further shape behavior for coding tasks in this environment.

## Notes

- This is a behavioral summary, not a verbatim copy of internal prompt text.
- Exact platform-owned hidden prompts are not directly exposed.
