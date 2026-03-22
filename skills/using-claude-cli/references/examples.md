# Claude Code CLI Examples

## Interactive work

Start a new session:

```bash
claude
```

Start with context:

```bash
claude "Review the recent changes in src/main.ts"
```

Continue the most recent local conversation:

```bash
claude --continue
```

Resume a specific session:

```bash
claude --resume 8b4c0d6e-1111-2222-3333-444455556666
```

Useful interactive slash commands:

```text
/help
/resume
/memory
/permissions
/mcp
/compact focus on test failures
```

## One-shot automation

Plain text result:

```bash
claude -p "Explain the contents of Makefile"
```

JSON output:

```bash
claude -p "Summarize this repository" --output-format json
```

Schema-constrained JSON:

```bash
claude -p "Extract route names from src/router.ts" \
  --output-format json \
  --json-schema '{"type":"object","properties":{"routes":{"type":"array","items":{"type":"string"}}},"required":["routes"]}'
```

Stream events:

```bash
claude -p "Explain recursion" \
  --output-format stream-json \
  --verbose \
  --include-partial-messages
```

Continue an automated thread:

```bash
session_id=$(claude -p "Start a review" --output-format json | jq -r '.session_id')
claude -p "Now focus on auth edge cases" --resume "$session_id"
```

## Permission-aware automation

Allow only what is needed:

```bash
claude -p "Run the tests and fix simple failures" \
  --allowedTools "Bash(pytest *),Read,Edit"
```

Create a commit from staged changes:

```bash
claude -p "Look at my staged changes and create an appropriate commit" \
  --allowedTools "Bash(git diff *),Bash(git log *),Bash(git status *),Bash(git commit *)"
```

## MCP and configuration

List configured MCP servers:

```bash
claude mcp list
```

Add an HTTP MCP server:

```bash
claude mcp add --transport http sentry https://mcp.sentry.dev/mcp
```

Add a stdio MCP server:

```bash
claude mcp add my-server -- npx my-mcp-server
```

Inspect auth state:

```bash
claude auth status
```

Inspect available agents:

```bash
claude agents
```
