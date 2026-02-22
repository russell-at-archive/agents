# Hooks

**Status:** Actively developed; hooks are newer and less
mature than Claude Code or Gemini CLI.

Configuration in `codex.json` at project level or in `config.toml`.

Known events: `BeforeToolUse`, `AfterToolUse`, file write hooks, prompt
gating, and stop hooks.

The hooks system lacks the breadth of event types and
decision control available in Claude Code and Gemini CLI.
