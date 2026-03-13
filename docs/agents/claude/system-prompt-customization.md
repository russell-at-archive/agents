# Customizing Claude Code System Prompts

Claude Code provides two methods for modifying its default system behavior:
appending additional instructions or completely replacing the built-in prompt.

---

## 1. Appending Instructions

Appending adds to the built-in prompt without removing any of its defaults
(tool policies, security rules, tone guidelines, etc.).

### Via CLAUDE.md files (recommended)

Instructions in `CLAUDE.md` files are loaded at startup and take precedence
over built-in defaults. Use these for project- or user-level conventions.

| File                    | Scope         |
| ----------------------- | ------------- |
| `~/.claude/CLAUDE.md`   | User-global   |
| `./CLAUDE.md`           | Project       |
| `./CLAUDE.local.md`     | Personal      |

### Via CLI flag (per-session)

```sh
claude --append-system-prompt "Always respond in bullet points."
```

---

## 2. Overriding the System Prompt (Full Replacement)

A full override replaces the built-in system prompt entirely. No default tool
policies, tone guidelines, or security rules are included unless you write them
into your replacement prompt.

### Via CLI flag (per-session)

```sh
claude --system-prompt "You are a minimal shell assistant. Do only what is asked."
```

### Via settings (persistent)

Add to `~/.claude/settings.json` (user-wide) or `.claude/settings.json`
(project):

```json
{
  "systemPrompt": "You are a minimal shell assistant. Do only what is asked."
}
```

---

## Summary Comparison

| Feature              | Append (`--append-system-prompt` / `CLAUDE.md`) | Override (`--system-prompt` / `systemPrompt`) |
| -------------------- | ----------------------------------------------- | --------------------------------------------- |
| **Behavior**         | Additive — merged with defaults                 | Replacement — defaults removed                |
| **Scope**            | Session or file-based                           | Session or settings-based                     |
| **Retains defaults** | Yes                                             | No                                            |
| **Use case**         | Conventions, style, project rules               | Strict custom agent behavior                  |
