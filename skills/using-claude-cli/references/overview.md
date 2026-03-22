# Claude Code CLI Overview

## Contents

- [Choose the right mode](#choose-the-right-mode)
- [Interactive sessions](#interactive-sessions)
- [Programmatic usage](#programmatic-usage)
- [Permissions and tool approval](#permissions-and-tool-approval)
- [Memory and project context](#memory-and-project-context)
- [MCP, agents, and plugins](#mcp-agents-and-plugins)
- [Session control](#session-control)

## Choose the right mode

Use `claude` for conversational coding work. Use `claude -p` for
non-interactive automation, scripting, CI steps, and structured output.

Useful first checks:

- `claude --version`
- `claude --help`
- `claude <subcommand> --help`

## Interactive sessions

Start a session in the current directory:

```bash
claude
claude "Review the authentication flow"
```

Important built-in slash commands in interactive mode:

- `/help`: show available commands and skills
- `/resume`: pick or search prior sessions
- `/compact [focus]`: compress context without throwing away direction
- `/memory`: inspect or edit loaded memory files
- `/permissions`: inspect and change tool permissions
- `/mcp`: inspect configured MCP servers and auth state
- `/agents`: inspect configured subagents
- `/init`: bootstrap project memory
- `/status`: show version, account, model, and connectivity

Treat slash commands as interactive-only unless the user is clearly asking
about them conceptually. In `--print` mode, describe the desired task in the
prompt instead of assuming `/command` support.

## Programmatic usage

`claude -p` runs a single request and exits:

```bash
claude -p "Summarize the repository"
```

Use structured output when another tool will consume the response:

```bash
claude -p "Summarize the repository" --output-format json
claude -p "Extract exported function names from src/auth.ts" \
  --output-format json \
  --json-schema '{"type":"object","properties":{"functions":{"type":"array","items":{"type":"string"}}},"required":["functions"]}'
```

Use `stream-json` only when the caller benefits from event streaming. Pair it
with `--verbose`, and add `--include-partial-messages` when partial token
events are useful.

## Permissions and tool approval

The safe default is to grant the smallest tool surface that can finish the
task.

Common controls:

- `--allowedTools`: approve only the needed tools or command prefixes
- `--disallowedTools`: block unsafe tools explicitly
- `--permission-mode`: control approval behavior for the session
- `--dangerously-skip-permissions`: bypass approvals entirely

Operational guidance:

- Prefer `--allowedTools "Read,Edit,Bash(...)"` over broad bypasses.
- In automation, combine `-p` with specific allowed tools.
- Recommend `--dangerously-skip-permissions` only when the user explicitly
  accepts the tradeoff and the environment is intentionally constrained.

## Memory and project context

Claude Code loads memory files automatically. The common memory locations are:

- `./CLAUDE.md` or `./.claude/CLAUDE.md` for project-shared memory
- `~/.claude/CLAUDE.md` for user-wide preferences
- enterprise-managed memory locations on supported systems

Relevant behaviors:

- `/init` creates a starter project memory file.
- `/memory` edits or inspects memory files.
- `@path/to/file` imports additional files into memory content.
- Memory is hierarchical, so local project instructions can build on broader
  user or enterprise defaults.

## MCP, agents, and plugins

Inspect local syntax instead of guessing:

```bash
claude mcp --help
claude agents --help
claude plugin --help
```

Useful MCP operations:

- `claude mcp list`
- `claude mcp get <name>`
- `claude mcp add <name> <command-or-url> ...`
- `claude mcp remove <name>`
- `claude mcp serve`

Current CLI builds also expose:

- `claude agents` to list configured custom agents
- `--agent` and `--agents` to select or define agents
- `--plugin-dir` to load plugins for a session

## Session control

Resume and continue work deliberately:

```bash
claude --continue
claude --resume <session-id>
claude -p "Continue the previous review" --continue
```

Capture `session_id` from JSON output when a script needs to continue a
specific conversation.
