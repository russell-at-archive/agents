---
name: using-graphite-cli
description: Manages stacked changes and branch-safe source control operations using the Graphite CLI (gt). Use when creating, restacking, syncing, or submitting stacks of pull requests, or when asked to use graphite, stacked changes, or gt. Invoke this skill any time the user mentions gt commands, stacked PRs, branch stacking, Graphite workflow, or wants to create dependent pull requests.
---

# Using Graphite CLI (gt)

## Core Mental Model

A **stack** is a linear chain of branches where each PR depends on the one below
it. `gt` tracks these relationships in SQLite metadata so rebases stay clean
and PR base-branch pointers stay correct.

Key terms: **trunk** (merge target, usually `main`), **downstack** (ancestors
toward trunk), **upstack** (descendants away from trunk), **restack** (rebase
each branch onto its updated parent).

## Essential Command Map

| Goal | Command |
|------|---------|
| Create new branch + commit | `gt create -am "msg"` (alias `gt c`) |
| Amend current branch | `gt modify -am "msg"` (alias `gt m`) |
| New commit (not amend) | `gt modify -cam "msg"` |
| Navigate up/down stack | `gt up` / `gt down` (aliases `gt u` / `gt d`) |
| Jump to top/bottom | `gt top` / `gt bottom` (aliases `gt t` / `gt b`) |
| Interactive branch picker | `gt checkout` (alias `gt co`) |
| Visualize stacks | `gt log` / `gt log short` (alias `gt ls`) |
| Sync trunk + clean merged | `gt sync` |
| Rebase stack onto parent | `gt restack` (alias `gt r`) |
| Submit current + downstack | `gt submit` (alias `gt s`) |
| Submit full stack | `gt submit --stack` (alias `gt ss`) |
| Insert branch mid-stack | `gt create --insert -am "msg"` |
| Distribute staged changes | `gt absorb` |
| Fetch teammate's stack | `gt get <branch>` |

## Workflow

1. **Orient:** `gt log` to see the stack, `git status` for working tree state.
2. **Create:** `gt create -am "msg"` — stages all changes, commits, creates branch.
3. **Update:** `gt modify -am "msg"` — amends commit, auto-restacks upstack branches.
4. **Repair:** `gt restack` if ancestry drifts; `gt sync` if trunk has moved.
5. **Submit:** `gt submit --stack` — pushes all branches and creates/updates PRs.

## Hard Rules

- Prefer `gt` over raw `git`/`gh` whenever an equivalent exists.
- Use raw `git` only for read-only operations (`git status`, `git diff`, `git show`).
- Never `git rebase`, `git commit`, or `git push -f` on a `gt`-managed branch.
- Don't start new mutations while `gt sync` or `gt restack` is halted for conflicts.
- Don't `--force` on `gt submit` without explicit user approval.

## Conflict Resolution

```bash
# gt restack or gt sync stops on conflict
git status              # see which files are conflicted
# resolve conflict markers in files
git add <file>
gt continue             # resume the halted operation
# or: gt abort          # bail out entirely
```

## Structural Operations

```bash
gt fold                          # merge current branch into parent
gt squash                        # collapse multi-commit branch to one
gt split --by-commit             # split branch along commit boundaries
gt split --by-file "src/**"      # extract files into a new parent branch
gt move --onto <target>          # rebase branch (+ descendants) onto target
gt reorder                       # open editor to reorder branches in stack
gt absorb -a                     # auto-distribute all staged changes to correct commits
```

## Collaborating on a Teammate's Stack

```bash
gt get <branch>        # fetch their stack from remote
gt freeze <branch>     # prevent accidental local modification
gt create -am "msg"    # stack your work on top
gt submit --stack
```

## Submitting PRs

```bash
gt submit --stack --draft                    # draft PRs
gt submit --stack --no-edit                  # skip interactive metadata editing
gt submit --stack --reviewers alice,bob      # assign reviewers
gt submit --stack --merge-when-ready         # auto-merge when checks pass
gt submit --stack --update-only              # only push branches with open PRs
```

## Undoing Mistakes

```bash
gt undo        # undo the most recent Graphite mutation
gt abort       # abort a halted restack/sync
gt pop         # delete current branch but keep file changes
```

## Failure Handling

| Symptom | Fix |
|---------|-----|
| Multiple commits on one branch | `gt squash` |
| Wrong PR base / ancestry drift | `gt restack` |
| Branch not in `gt log` | `gt track <branch>` |
| Totally broken metadata | `gt init --reset`, then `gt track` each branch |
| Slow first run after upgrade | v1.8+ SQLite migration — let it finish |
| Force-with-lease false failures | `gt submit --force` (confirm with user first) |

For detailed troubleshooting, see [references/troubleshooting.md](references/troubleshooting.md).
For installation and authentication, see [references/installation.md](references/installation.md).
