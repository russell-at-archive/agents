# Notion MCP Setup

## What This Is For

Use this setup when the AI client already supports `MCP` and you want the
fastest path to let the assistant search and write in Notion.

Notion's hosted MCP server is:

```text
https://mcp.notion.com/mcp
```

The legacy SSE transport is:

```text
https://mcp.notion.com/sse
```

## Recommended Setup Paths

### ChatGPT

1. Go to `https://chatgpt.com/#settings/Connectors`.
1. Click `Add Connector`.
1. Enter `https://mcp.notion.com/mcp`.
1. Complete the OAuth flow to connect your Notion workspace.

### Codex

1. Add this to `~/.codex/config.toml`:

```toml
[mcp_servers.notion]
url = "https://mcp.notion.com/mcp"
```

1. Authenticate:

```bash
codex mcp login notion
```

1. Complete the OAuth flow in the browser.

### Cursor

1. Open `Settings -> MCP -> Add new global MCP server`.
1. Paste:

```json
{
  "mcpServers": {
    "notion": {
      "url": "https://mcp.notion.com/mcp"
    }
  }
}
```

1. Save and restart Cursor.
1. Use a Notion tool once and complete the OAuth flow.

### VS Code With GitHub Copilot

1. Create `.vscode/mcp.json`:

```json
{
  "servers": {
    "notion": {
      "type": "http",
      "url": "https://mcp.notion.com/mcp"
    }
  }
}
```

1. Open the command palette and run `MCP: List Servers`.
1. Start the Notion server.
1. Complete OAuth when prompted.

## Generic MCP Client Setup

If the tool supports remote MCP over HTTP, use:

```json
{
  "mcpServers": {
    "notion": {
      "url": "https://mcp.notion.com/mcp"
    }
  }
}
```

If the tool only supports local `stdio`, use the `mcp-remote` bridge:

```json
{
  "mcpServers": {
    "notion": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "https://mcp.notion.com/mcp"]
    }
  }
}
```

## Exact Setup Checklist

1. Confirm your AI client supports `MCP`.
1. Add the Notion MCP server URL to that client.
1. Trigger a Notion action so the client asks for authentication.
1. Complete the Notion OAuth flow as a real user.
1. Approve the workspace connection.
1. Test with a search prompt such as `find pages about terraform`.
1. Test with a write prompt such as `create a page called Integration Notes`.

## Operational Notes

- This is the easiest option because Notion hosts the server and uses OAuth.
- It is best for interactive use by a person in the loop.
- It is not a good fit for fully headless automation because Notion MCP does
  not support bearer-token authentication.

## Cost

- No separate Notion integration fee
- Normal Notion workspace plan cost still applies
- Your AI client may have its own subscription or usage cost

## Source Links

- Notion MCP overview:
  <https://developers.notion.com/guides/mcp/mcp>
- Connecting to Notion MCP:
  <https://developers.notion.com/guides/mcp/get-started-with-mcp>
