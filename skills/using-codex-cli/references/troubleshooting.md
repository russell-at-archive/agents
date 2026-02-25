# Troubleshooting

## Common Mistakes


**No context in prompt:** Codex can read files but doesn't know your
conversation. Always include relevant context, file paths, and
architecture notes.

**Forgetting --full-auto:** Without this flag, Codex runs interactively
and hangs waiting for input.

**Same output file for multiple tasks:** Each concurrent task needs a
unique `-o` path or results overwrite each other.

**Over-scoping tasks:** Like dispatching-parallel-agents, keep each
Codex task focused on one problem domain. Split large tasks.

**Not checking results:** In wait-and-integrate mode, always read the
output file and verify the work before assuming success.

