# cmux Installation

## Requirements

- macOS 14.0 or later (Apple Silicon or Intel)
- cmux is **macOS-only** — no Linux or Windows support

## Install via Homebrew (recommended)

```bash
brew tap manaflow-ai/cmux
brew install --cask cmux
```

Update:

```bash
brew upgrade --cask cmux
```

## Install via DMG

Download the latest DMG from GitHub releases and drag cmux to `/Applications`:

```
https://github.com/manaflow-ai/cmux/releases/latest/download/cmux-macos.dmg
```

cmux auto-updates via the Sparkle framework after DMG install.

## Nightly Builds

A separate nightly app is available from the same GitHub releases page. It
auto-updates independently of the stable release.

## CLI on PATH

Inside a cmux terminal window the `cmux` CLI works automatically (no setup
needed). To use the CLI from _outside_ cmux (e.g., from iTerm or a script):

```bash
sudo ln -sf "/Applications/cmux.app/Contents/Resources/bin/cmux" /usr/local/bin/cmux
```

Or override the socket path if cmux is installed elsewhere:

```bash
export CMUX_SOCKET_PATH=/tmp/cmux.sock   # default; adjust if needed
```

## First-Launch Security Dialog

macOS may block the app on first launch. Click **Open** in the security dialog
— cmux is signed by an identified developer.

## Verify Installation

```bash
cmux ping        # should print: pong (or similar success response)
cmux --version   # prints version string
```

## Ghostty Font / Theme Config

cmux reads `~/.config/ghostty/config` for fonts, themes, colors, and
scrollback settings. Existing Ghostty configs work without modification.

## Official Resources

- Homepage: https://cmux.com/
- Getting started: https://cmux.com/docs/getting-started
- API reference: https://cmux.com/docs/api
- GitHub: https://github.com/manaflow-ai/cmux
- Discord: https://discord.gg/xsgFEVrWCZ
