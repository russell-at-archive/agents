# Installation

## `obsidian`

The desktop CLI is part of newer Obsidian installers and is registered from the
app.

1. Upgrade to an Obsidian build that includes the CLI surface.
2. Open **Settings** -> **General**.
3. Enable **Command line interface**.
4. Use the in-app registration prompt.
5. Restart the terminal.

Verify:

```bash
obsidian help
obsidian version
```

Platform notes:

- macOS registration adds the app binary directory to `~/.zprofile`
- Linux registration creates a symlink, often in `/usr/local/bin/obsidian`
  with a fallback to `~/.local/bin/obsidian`
- Windows requires the Obsidian installer build that includes the CLI
  redirector

## `ob`

Obsidian Headless is installed separately:

```bash
npm install -g obsidian-headless
```

Verify:

```bash
ob --help
```

Requirements:

- active Obsidian Sync subscription
- Node environment suitable for the package

## `obsidian-export`

Install when the task is vault export rather than app control:

```bash
cargo install obsidian-export
```

Verify:

```bash
obsidian-export --help
```
