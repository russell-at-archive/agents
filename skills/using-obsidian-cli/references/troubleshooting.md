# Using Obsidian CLI: Troubleshooting

## Contents

- Diagnosis sequence
- Common errors and fixes
- Platform-specific issues
- Parameter mistakes
- Headless tool issues
- Anti-patterns

---

## Diagnosis Sequence

Run these in order when the CLI does not behave as expected:

```bash
obsidian version          # confirms binary is on PATH
obsidian vaults           # confirms IPC to the running app works
obsidian files total      # confirms vault access
```

If any step fails, use the table below to find the root cause.

---

## Common Errors and Fixes

| Symptom | Cause | Fix |
| ------- | ----- | --- |
| `command not found: obsidian` | Binary not on PATH | Re-run **Register CLI** in Settings; restart terminal |
| No output, no error (Windows) | Admin-elevated terminal | Launch via `Win+R → powershell` (non-admin) |
| `Obsidian.com` not found (Windows) | Not in insider channel | Download the redirector file from the insider Discord |
| Wrong vault selected silently | `vault=` not first argument | Move `vault="Name"` to first position |
| Vault not found by name | Typo or wrong case | Run `obsidian vaults` and copy the exact name |
| Obsidian takes a while to respond | App was not running | CLI auto-launches it; wait for first command to complete |
| Unicode / path errors (Windows) | Old Obsidian version | Upgrade to v1.12.4+ |
| Permission denied creating symlink (Linux) | No sudo rights | Use `~/.local/bin/` instead of `/usr/local/bin/` |
| Snap build not detecting config (Linux) | Wrong `XDG_CONFIG_HOME` | `export XDG_CONFIG_HOME=~/.config` before running |

---

## Platform-Specific Issues

### macOS

- If `~/.zprofile` PATH change not picked up: `source ~/.zprofile` or restart
  terminal.
- Homebrew-managed `obsidian` may shadow the app binary — check
  `which obsidian` to confirm it resolves to the app, not Homebrew.

### Windows

- **Most common failure**: running terminal as Administrator. IPC uses a
  named pipe that is only accessible to the same user session. There is no
  error message — commands simply hang or return nothing.
- The `Obsidian.com` redirector file must be in the same directory as the
  `Obsidian.exe`.
- Spaces in vault path: always quote — `vault="My Vault"`.

### Linux

- Flatpak: symlink is created automatically at install.
- AppImage: no auto-install; create symlink manually:
  `ln -s /path/to/Obsidian.AppImage ~/.local/bin/obsidian`
- Snap: requires the `XDG_CONFIG_HOME` fix if the CLI is not finding vaults.

---

## Parameter Mistakes

### `vault=` argument order

```bash
# Wrong — vault= is silently ignored
obsidian search query="TODO" vault="Work"

# Correct — vault= must be first
obsidian vault="Work" search query="TODO"
```

### Quoting values with spaces

```bash
# Wrong — shell splits "My Note" into two arguments
obsidian read file=My Note

# Correct
obsidian read file="My Note"
```

### Newlines in content

```bash
# Wrong — literal newline breaks the command
obsidian daily:append content="Line 1
Line 2"

# Correct — use \n escape
obsidian daily:append content="Line 1\nLine 2"
```

### Path vs wikilink

```bash
# file= matches by note title (fuzzy, no extension needed)
obsidian read file="Research Notes"

# path= requires the exact vault-relative path including extension
obsidian read path="Projects/Research Notes.md"
```

---

## Headless Tool Issues

### notesmd-cli: vault not found in headless mode

The tool reads `~/.config/obsidian/obsidian.json`. If that file does not
exist or uses `~` in the path:

```json
{
  "vaults": {
    "my-vault": {
      "path": "/Users/username/Documents/MyVault"
    }
  }
}
```

Use the absolute path — `~` is not expanded.

### obsidian-export: non-UTF-8 content

obsidian-export is UTF-8 only. Files with non-UTF-8 characters produce lossy
conversion. Run `file -i *.md` to identify problem files before export.

### obsidian-export: recursive embed error

If the vault contains notes that embed each other:

```bash
obsidian-export vault output --no-recursive-embeds
```

This converts the recursive embed into a standard link rather than erroring.

---

## Anti-Patterns

- **Using the official CLI in cron without Obsidian running.** The CLI
  auto-launches the GUI, which is undesirable on servers. Use `notesmd-cli`
  or `obsidian-export` for any scheduled headless task.

- **Scripting `--permanent` delete.** The default `delete` sends to the OS
  trash and is recoverable. Only use `--permanent` when the user has
  explicitly requested irreversible deletion.

- **Running `obsidian eval` with generated or user-supplied code.** The
  `eval` command executes arbitrary JavaScript inside the Obsidian app
  context. Always review scripts before running.

- **Assuming fuzzy file matching is deterministic.** `file=NoteName` fuzzy-
  matches on title. If two notes share a similar name the wrong one may be
  selected. Use `path=` for precision in scripts.

- **Mixing `obsidian` and `notesmd-cli` in the same script.** They have
  different parameter syntax and behaviors. Pick one per script to avoid
  confusion.
