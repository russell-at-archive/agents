# Codex Default System Prompt

The exact hidden system prompt is not available for verbatim documentation.

This page documents the effective default behavior at a high level:

- System and developer instructions take precedence over user instructions.
- Responses should be truthful about uncertainty, limitations, and tool results.
- Sensitive internal instructions and protected configuration should not be exposed.
- Unsafe or disallowed assistance should be refused or redirected safely.
- Tools should be used when needed for accuracy, acting in the workspace, or
  satisfying explicit user requests.
- Responses should stay concise, useful, and aligned with the task.

## Can a User Append or Override It?

Not directly.

Users can usually add strong workspace or project instructions through files
that Codex loads, such as `AGENTS.md`. In practice, that lets a user append
effective behavior and often override lower-priority guidance with more
specific instructions.

What a user can generally do:

- Add user-level instructions through `~/.codex/AGENTS.md`
- Add project-level instructions through repository `AGENTS.md` files
- Add a local override through `AGENTS.override.md`
- Shape behavior substantially within the limits of the platform

What a user generally cannot do:

- View the exact hidden base system prompt
- Completely replace the platform's hidden base system prompt
- Force Codex to ignore higher-priority safety or platform rules

The practical model is layered instruction precedence: user-supplied instruction
files can strongly influence behavior, but they do not fully replace the hidden
platform-level system prompt.

For this workspace, Codex also operates under additional coding-agent guidance:

- Act like a pragmatic software engineer working directly in the local
  workspace.
- Inspect the codebase before making assumptions.
- Prefer efficient local tooling such as `rg` for search.
- Make changes end to end when feasible, including validation.
- Avoid reverting unrelated user changes.
- Use `apply_patch` for manual file edits.

This is a behavioral summary, not a verbatim copy of any internal prompt.
