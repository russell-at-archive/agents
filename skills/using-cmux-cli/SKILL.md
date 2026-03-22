---
name: using-cmux-cli
description: >
  Provides expert guidance for using the cmux CLI to manage workspaces, split
  panes (surfaces), send input to terminals, read screen output, send
  notifications, update the sidebar, and script the built-in browser inside the
  cmux macOS terminal. Use whenever the user asks about cmux commands, managing
  workspaces or surfaces in cmux, sending notifications from scripts or agents,
  using cmux status/sidebar features, orchestrating multiple AI agents in cmux,
  or running any `cmux` CLI subcommand. Invoke this skill even when the user
  just mentions "cmux" in passing — it almost always means they need one of
  these workflows.
---

# Using cmux

cmux is a native macOS terminal built for multi-agent workflows. It exposes a
CLI and Unix socket API that scripts and AI agents can use to drive workspaces,
panes, notifications, and an embedded browser.

See [references/installation.md](references/installation.md) if cmux is not
yet installed or the CLI is not on PATH.

## Before Acting

Always confirm context first — especially when sending input to a surface:

```bash
cmux identify --json          # shows current window / workspace / surface IDs
cmux ping                     # verify daemon is reachable
```

Detection helpers (useful at the top of scripts):

```bash
in_cmux()  { [ -n "${CMUX_WORKSPACE_ID:-}" ] && [ -n "${CMUX_SURFACE_ID:-}" ]; }
has_socket() { [ -S "${CMUX_SOCKET_PATH:-/tmp/cmux.sock}" ]; }
has_cli()    { command -v cmux &>/dev/null; }
```

## Global Flags

`--json` · `--socket PATH` · `--window ID` · `--workspace ID` · `--surface ID`
· `--id-format refs|uuids|both`

## Workspaces

```bash
cmux list-workspaces [--json]
cmux new-workspace
cmux select-workspace --workspace <id>
cmux current-workspace [--json]
cmux rename-workspace            # renames the active workspace
cmux close-workspace --workspace <id>
```

One workspace per task/project is the recommended pattern.

## Surfaces (Panes)

```bash
cmux new-split <left|right|up|down>
cmux list-surfaces [--json]
cmux focus-surface --surface <id>
cmux close-surface
cmux tree [--json] [--all]       # full layout tree
cmux trigger-flash --surface <id>
```

## Sending Input

```bash
cmux send "text"                          # focused surface
cmux send --surface <id> "text"           # specific surface
cmux send-key <key>                       # focused surface
cmux send-key-surface --surface <id> <key>
```

Valid keys: `enter` `tab` `escape` `backspace` `delete` `up` `down` `left` `right`

**Safety**: never send input to a surface you didn't create; always verify the
surface ID with `cmux identify --json` first.

## Reading Screen Output

```bash
cmux read-screen [--surface <id>]
cmux read-screen --scrollback --lines 200
```

## Notifications

Three equivalent methods — prefer the CLI form for readability:

```bash
# CLI (recommended)
cmux notify --title "Build done" --body "All tests passed"
cmux notify --title "T" --subtitle "S" --body "B"

# OSC 777 escape (no CLI required)
printf '\e]777;notify;Title;Body\a'
```

Inspection:

```bash
cmux list-notifications [--json]
cmux clear-notifications
```

## Sidebar / Status

```bash
# Status pills
cmux set-status <key> "<value>" --icon <icon> --color "<hex>"
cmux clear-status <key>
cmux list-status

# Progress bar
cmux set-progress 0.5 --label "Halfway"
cmux clear-progress

# Log entries (levels: info progress success warning error)
cmux log "message"
cmux log --level error --source build "Build failed"
cmux list-log [--limit <n>]
cmux clear-log

# Full sidebar dump
cmux sidebar-state [--workspace <id>]
```

## Browser Pane

```bash
cmux new-pane --type browser --url <URL>
cmux browser open <URL>
cmux browser snapshot --surface <id> --interactive   # returns element refs (e10, e14…)
cmux browser click --surface <id> '<element>'
cmux browser type  --surface <id> '<element>' '<text>'
cmux browser fill  --surface <id> '<selector>' '<value>'
cmux browser wait  --surface <id> --load-state complete
```

## Key Environment Variables

| Variable | Purpose |
|---|---|
| `CMUX_WORKSPACE_ID` | Auto-set — current workspace (read-only) |
| `CMUX_SURFACE_ID` | Auto-set — current surface (read-only) |
| `CMUX_SOCKET_PATH` | Override socket path (default `/tmp/cmux.sock`) |
| `CMUX_SOCKET_MODE` | `cmuxOnly` (default) · `allowAll` · `off` |

## Common Patterns

**Build notification wrapper:**

```bash
notify_after() {
  "$@"; local rc=$?
  if [ $rc -eq 0 ]; then
    cmux notify --title "Done" --body "$1"
  else
    cmux notify --title "Failed" --body "$1 (exit $rc)"
  fi
  return $rc
}
notify_after npm test
```

**Progress reporting in a script:**

```bash
cmux set-progress 0.0 --label "Starting"
step_one && cmux set-progress 0.33 --label "Step 1 done"
step_two && cmux set-progress 0.66 --label "Step 2 done"
step_three && cmux set-progress 1.0 --label "Complete"
cmux clear-progress
```

**Multi-agent layout:**

```bash
cmux new-workspace
cmux new-split right
# surface IDs from cmux list-surfaces --json
cmux send --surface <id1> "claude" && cmux send-key --surface <id1> enter
cmux send --surface <id2> "codex"  && cmux send-key --surface <id2> enter
```

## Troubleshooting

| Symptom | Fix |
|---|---|
| `Failed to connect to socket` | cmux not running, or agent is sandboxed — set `CMUX_SOCKET_MODE=allowAll` |
| CLI not found outside cmux | `sudo ln -sf "/Applications/cmux.app/Contents/Resources/bin/cmux" /usr/local/bin/cmux` |
| Notifications not appearing | `cmux list-notifications`; check ⌘⇧I panel |
| Socket drops intermittently | Daemon has 2 s auto-retry; use `cmux ping` to check |

For more detail see [references/installation.md](references/installation.md).
