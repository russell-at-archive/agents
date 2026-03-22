# Overview

Obsidian now has two official command-line surfaces with different jobs:

- `obsidian`: controls a running desktop Obsidian app and exposes both
  one-shot commands and an interactive TUI.
- `ob`: Obsidian Headless, used for Sync-backed automation without the desktop
  app.

`obsidian-export` is a separate companion tool for converting vault content to
standard Markdown. It is useful in CI and publishing pipelines but it is not an
Obsidian control surface.

## Command Selection

Pick the narrowest tool that matches the task:

- `obsidian`: open, read, create, append, prepend, rename, move, delete notes
- `obsidian`: search, tasks, tags, properties, backlinks, files, folders
- `obsidian`: plugins, themes, workspaces, publish, local history, sync inside
  the running app
- `obsidian`: developer workflows such as `plugin:reload`, `devtools`,
  `dev:console`, `dev:screenshot`, and `eval`
- `ob`: login, list remote or local Sync vaults, set up headless sync, run sync,
  change sync config, inspect status, unlink
- `obsidian-export`: export a vault or subtree into regular Markdown for
  downstream processing

## Desktop CLI Model

Key syntax rules for `obsidian`:

- Command form: `obsidian [vault=<name|id>] <command> [param=value] [flag]`
- `vault=<name|id>` must come before the command
- Parameters are `key=value`
- Flags are bare words such as `open`, `overwrite`, `inline`, `newtab`
- Use quotes around values with spaces
- Use `\n` and `\t` inside content strings
- If neither `file=` nor `path=` is given, many commands default to the active
  file

Vault and file resolution:

- If the current working directory is a vault, `obsidian` uses that vault
- Otherwise it uses the active vault unless `vault=` is supplied
- `file=<name>` uses wikilink resolution by note name
- `path=<path>` uses the exact vault-relative path and is safer for scripts

## High-Value Desktop Commands

Common note operations:

- `obsidian help`
- `obsidian help search`
- `obsidian vaults`
- `obsidian files`
- `obsidian create name="Note"`
- `obsidian read path="Folder/Note.md"`
- `obsidian append path="Folder/Note.md" content="- [ ] Task"`
- `obsidian move path="Old.md" to="Archive/Old.md"`
- `obsidian delete path="Scratch.md"`

Common knowledge-work commands:

- `obsidian search query="meeting notes"`
- `obsidian search:context query="latency"`
- `obsidian tasks todo`
- `obsidian tags counts`
- `obsidian properties active`
- `obsidian property:set path="Projects/Plan.md" name=status value=active`
- `obsidian backlinks file=Plan`

Developer-oriented commands:

- `obsidian plugin:reload id=my-plugin`
- `obsidian dev:console`
- `obsidian dev:errors`
- `obsidian dev:screenshot path=screenshot.png`
- `obsidian eval code="app.vault.getFiles().length"`

## Headless Sync Model

Use `ob` when the user needs Sync-backed automation without the desktop app.

Core flow:

1. `ob login`
2. `ob sync-list-remote`
3. `ob sync-setup --vault "Vault Name" [--path <local-path>]`
4. `ob sync` or `ob sync --continuous`

Useful follow-up commands:

- `ob sync-list-local`
- `ob sync-status`
- `ob sync-config`
- `ob sync-unlink`
- `ob sync-create-remote --name "Vault Name"`

Important constraints:

- Obsidian Headless requires an active Obsidian Sync subscription
- Do not use desktop Sync and Headless Sync on the same device unless the user
  explicitly accepts the conflict risk
- `ob` is for Sync transport and configuration, not rich note editing

## Export Model

Use `obsidian-export` when the user wants filesystem output rather than app
control or sync state.

Typical patterns:

- `obsidian-export /path/to/vault /path/to/output`
- `obsidian-export /path/to/vault --start-at /path/to/vault/Blog /path/to/out`

Use this for:

- static site pipelines
- CI preprocessing
- downstream LLM ingestion on normalized Markdown
- partial vault exports
