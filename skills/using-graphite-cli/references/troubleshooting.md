# Graphite CLI — Troubleshooting

## Diagnostic Checklist

```bash
gt --version          # confirm CLI is installed and current
gt trunk              # confirm trunk is set correctly
git status            # check working tree state
gt ls                 # inspect stack topology
gt continue           # check for halted operation
```

## Common Failures

| Symptom | Cause | Fix |
|---------|-------|-----|
| Branch has multiple commits | used `git commit` instead of `gt modify` | `gt squash` |
| Wrong PR base / ancestry drift | used `git rebase` directly | `gt restack` |
| Branch missing from `gt log` | untracked by Graphite | `gt track <branch>` |
| Rebase conflict mid-stack | patch collision | resolve markers → `git add` → `gt continue` |
| Force-with-lease false failure | another tool fetched remote refs | `gt submit --force` (get user approval first) |
| Submit overwrites wrong branch | wrong trunk set | `gt move --onto <correct-trunk>` then re-submit |
| Slow first command after upgrade | v1.8+ SQLite migration running | let it complete (safe to interrupt, will restart) |
| `gt rename` breaks PR | GitHub PR branch names are immutable | only rename with intent; use `--force` |
| 500 error after repo rename | stale remote/config | update git remote + `.git/.graphite_repo_config` |
| Duplicate CI runs | GitHub sees both push and Graphite API events | configure GitHub Actions `concurrency.cancel-in-progress` |

## Metadata Corruption

**Mild** — wrong parent pointer:
```bash
gt move --onto <correct-parent>
```

**Moderate** — branch not tracked:
```bash
gt untrack <branch>
gt track <branch>     # re-select parent interactively
```

**Severe** — broken SQLite metadata:
```bash
gt dev cache --clear  # clears metadata cache only (safe)
```

**Nuclear** — total reset:
```bash
gt init --reset       # removes ALL Graphite metadata
# then re-track every branch:
gt track <branch1> --parent main
gt track <branch2> --parent <branch1>
# etc.
```

## Conflict Resolution Flow

```bash
# gt sync or gt restack stops on conflict
git status                    # identify conflicted files
# edit each file, remove <<<< ==== >>>> markers
git add <resolved-files>
gt continue                   # resume halted operation

# if you want to bail:
gt abort
```

If conflicts recur on the same branch repeatedly:
1. `gt restack --only` — restack just this branch
2. Manually resolve with `git rebase <parent-branch>` as a last resort
3. Escalate to user if `gt restack` fails after multiple resolutions

## Red Flags — Stop and Verify

- About to run `git rebase -i`, `git commit`, `git merge`, or `git push -f` on a `gt`-managed branch
- Starting a new `gt` command while a previous operation is halted for conflicts
- `gt log` shows a parent relationship that doesn't make sense — fix topology with `gt move` before submitting
- About to use `--force` on `gt submit` without confirming with the user

## Escalation to User

Escalate when:
- Trunk branch selection is ambiguous
- `gt restack` fails consistently after conflict resolution
- A stack rewrite would invalidate critical existing review comments
- Force push is required on a branch shared with other humans
- `gt sync` cannot resolve deep metadata corruption

## Debug Logs

```bash
# Logs retained for 24 hours at:
~/.local/share/graphite/debug

# Submit a bug report:
gt feedback "description of issue"
```
