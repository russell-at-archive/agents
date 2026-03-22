# Troubleshooting

## Diagnosis Order

Check the correct tool first:

```bash
obsidian help
ob --help
obsidian-export --help
```

Then validate the specific workflow:

```bash
obsidian vaults
obsidian help search
ob sync-status
```

## Common Problems

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| `obsidian` is not found | CLI not registered or not on `PATH` | Re-enable and register the desktop CLI, then restart the shell |
| `obsidian` launches the app but command behavior is missing | Old or mismatched installer / early-access state | Upgrade Obsidian to a build that includes the CLI surface |
| Wrong vault is targeted | `vault=` omitted or not first | Move `vault=<name|id>` to the first position |
| Wrong file is changed | `file=` matched ambiguously | Switch to exact `path=` targeting |
| `obsidian` fails in headless automation | No running desktop app | Use `ob` or `obsidian-export` instead |
| `ob` is not found | Obsidian Headless not installed | Install `obsidian-headless` and verify with `ob --help` |
| Headless sync is conflicting with desktop sync | Same device used for both sync methods | Pick one sync method per device |
| `obsidian-export` fails on destination path | Output directory does not exist | Create the destination directory first |

## Syntax Mistakes

### `vault=` placement

```bash
# Wrong
obsidian search query="TODO" vault=Work

# Correct
obsidian vault=Work search query="TODO"
```

### Quoting

```bash
# Wrong
obsidian create name=Meeting Notes

# Correct
obsidian create name="Meeting Notes"
```

### Path precision

```bash
# Risky in scripts
obsidian read file=Plan

# Precise
obsidian read path="Projects/Plan.md"
```

## Safety Checks

- Before `delete permanent`, confirm the user explicitly wants irreversible
  deletion.
- Before `eval`, inspect the code and make sure the user intends app-context
  JavaScript execution.
- Before `sync:restore`, `history:restore`, or `ob sync-unlink`, confirm the
  rollback or unlink semantics are acceptable.
