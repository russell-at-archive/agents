# Troubleshooting Claude Code

## Fast checks

Start with:

```bash
claude --version
claude --help
claude doctor
```

Then inspect the exact subcommand help involved in the failure.

## Common failure patterns

### Automation hangs on permissions

Cause: `claude -p` needs tools that were not approved.

Prefer:

- tightening `--allowedTools`
- setting an appropriate `--permission-mode`

Avoid treating `--dangerously-skip-permissions` as the first fix.

### Output is hard to parse

Cause: using plain text in a scripted context.

Fix:

- `--output-format json` for machine consumption
- `--json-schema` when the output shape matters
- `--output-format stream-json` for event-driven consumers

### Conversation state is missing or surprising

Cause: wrong resume mode or disabled persistence.

Check:

- `--continue` versus `--resume <id>`
- whether `--no-session-persistence` was used
- whether the command ran from a different working directory

### Interactive advice used in `-p` mode

Cause: mixing slash-command guidance with non-interactive automation.

Fix: replace `/command` advice with explicit prompt text and CLI flags.

### MCP tools are unavailable

Check:

```bash
claude mcp list
claude mcp get <name>
```

Also confirm whether the MCP server is HTTP or stdio based and whether it
requires headers, environment variables, or OAuth state.

### Auth problems

Check:

```bash
claude auth status
claude auth login
```

If auth looks valid but requests still fail, verify network reachability and
whether the local CLI version is outdated.

## Red flags

- Recommending built-in slash commands as if they execute in `--print` mode
- Granting broad permissions when narrow `--allowedTools` would work
- Assuming stale flag names without checking `claude --help`
- Ignoring memory files when the CLI appears to be following unexpected rules
