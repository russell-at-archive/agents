# Installation: Graphite CLI (gt)

## Install

### macOS (Homebrew — recommended)

```bash
brew install withgraphite/tap/graphite
```

### npm (macOS/Linux)

```bash
npm install -g @withgraphite/graphite-cli
```

Both `gt` and `graphite` binaries are installed.

### mise

```bash
mise use -g graphite@latest
```

### Update

```bash
brew upgrade graphite                                  # Homebrew
npm update -g @withgraphite/graphite-cli               # npm
```

---

## Authentication and Setup

### 1. Get a token

Visit <https://app.graphite.com/settings/cli>, create a CLI token, then:

```bash
gt auth --token <token>
```

Token is stored at `~/.config/graphite/user_config`.

### 2. Initialize the repository

```bash
gt init                    # interactive trunk selection
gt init --trunk main       # non-interactive
```

Repo config is stored at `.git/.graphite_repo_config`.

### 3. Verify

```bash
gt --version
gt trunk
```

---

## Shell Completions

```bash
gt completion >> ~/.zshrc       # zsh
gt completion >> ~/.bashrc      # bash
gt fish >> ~/.config/fish/completions/gt.fish
```

---

## MCP Integration (AI agents)

```bash
# Claude Code
claude mcp add graphite gt mcp
```

For Cursor, add to MCP settings:
```json
{
  "mcpServers": {
    "graphite": { "command": "gt", "args": ["mcp"] }
  }
}
```

---

## Troubleshooting Installation

- **Wrong Homebrew tap:** The tap is `withgraphite/tap/graphite`, not `screen-peek/tap/graphite`.
- **Command not found:** Ensure `$(brew --prefix)/bin` is on your PATH.
- **Downgrade:** `brew install withgraphite/tap/graphite@1.7.17` or `npm install -g @withgraphite/graphite-cli@1.7.17`.
