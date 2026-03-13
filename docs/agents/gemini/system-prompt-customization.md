# Customizing Gemini CLI System Prompts

The Gemini CLI provides two primary methods for modifying its behavior: hierarchical appending via `GEMINI.md` files and full replacement using a system prompt override.

## 1. Appending Instructions (Hierarchical Context)

For most use cases, you should use `GEMINI.md` files to provide additional context and instructions without replacing the core safety and operational rules of the CLI. The CLI automatically concatenates these files in the following hierarchy:

1. **Global Context:** `~/.gemini/GEMINI.md` (applies to all projects).
1. **Workspace Context:** `GEMINI.md` files found in your project root or parent directories.
1. **Just-in-Time (JIT) Context:** `GEMINI.md` files discovered in specific directories accessed by tools during a session.

### Using the Memory Command

You can quickly append persistent instructions or facts to your global `GEMINI.md` file using the CLI command:

```bash
/memory add "I prefer using tabs for indentation in Go projects."
```

## 2. Overriding the System Prompt (Full Replacement)

You can completely replace the built-in system instructions by using the `GEMINI_SYSTEM_MD` environment variable. This is an advanced feature for users who need to enforce strict, project-specific behavior.

### Configuration

- **Enable with default path:** Set `GEMINI_SYSTEM_MD=true` or `1`. The CLI will look for `./.gemini/system.md` relative to your project directory.
- **Enable with custom path:** Set `GEMINI_SYSTEM_MD=/path/to/your-system.md`.

### Dynamic Content Placeholders

Since this is a full replacement, you must manually include specific placeholders in your Markdown file to keep CLI features functional:

- `${AgentSkills}`: Injects available agent skills.
- `${SubAgents}`: Injects available sub-agents.
- `${AvailableTools}`: Injects a list of enabled tools.

### Recommended Workflow

To customize the existing prompt rather than writing one from scratch, export the default prompt first:

```bash
GEMINI_WRITE_SYSTEM_MD=1 gemini
```

This writes the default prompt to `.gemini/system.md`, which you can then modify.

## Summary Comparison

| Feature | `GEMINI_SYSTEM_MD` (Override) | `GEMINI.md` (Context/Append) |
| :--- | :--- | :--- |
| **Purpose** | Safety, tool protocols, core mechanics. | Persona, goals, coding styles. |
| **Behavior** | Full replacement (not a merge). | Hierarchical concatenation (additive). |
| **Scope** | Per-session or per-project. | Global, workspace, and directory-specific. |
| **UI Indicator** | Displays `\|⌐■_■\|` in the terminal. | Shows number of loaded files in the footer. |
