# Graphite CLI — Full Command Reference

## Navigation

| Command | Alias | Description |
|---------|-------|-------------|
| `gt checkout [branch]` | `gt co` | Switch branches; no arg = interactive picker |
| `gt up [n]` | `gt u` | Move n steps upstack (toward tip) |
| `gt down [n]` | `gt d` | Move n steps downstack (toward trunk) |
| `gt top` | `gt t` | Jump to tip of current stack |
| `gt bottom` | `gt b` | Jump to branch closest to trunk |
| `gt trunk` | | Show/manage trunk branches |
| `gt parent` | | Print parent branch name |
| `gt children` | | Print child branch names |

## Creating and Modifying

### `gt create` (alias `gt c`)
Create a new branch stacked on current, stage changes, and commit.

```bash
gt create -am "feat: add thing"          # stage all + commit + new branch
gt create -m "msg" --insert              # insert between current branch and its child
gt create --ai                           # AI-generated branch name and commit message
gt create -p                             # interactively pick hunks to stage
```

| Flag | Short | Description |
|------|-------|-------------|
| `--message <msg>` | `-m` | Commit message (also becomes branch name if none given) |
| `--all` | `-a` | Stage all changes including untracked files |
| `--update` | `-u` | Stage tracked file changes only |
| `--patch` | `-p` | Interactive hunk selection |
| `--insert` | `-i` | Insert between current branch and its children |
| `--ai` | | AI-generate name + message |

### `gt modify` (alias `gt m`)
Amend the current branch's commit (default) or create a new one. Auto-restacks all upstack branches.

```bash
gt modify -am "msg"          # amend, stage all
gt modify -cam "msg"         # new commit, stage all
gt modify --into feat-base   # amend a specific downstack branch
gt modify --interactive-rebase  # open git interactive rebase
```

| Flag | Short | Description |
|------|-------|-------------|
| `--commit` | `-c` | Create a new commit instead of amending |
| `--all` | `-a` | Stage all changes |
| `--message <msg>` | `-m` | Commit message |
| `--edit` | `-e` | Open editor for commit message |
| `--into <branch>` | | Modify a specific downstack branch |

## Viewing

### `gt log` (alias `gt l`)
Visualize stacks with PR status. Variants:
- `gt log` — full branch + PR info
- `gt log short` / `gt ls` — branches only (fast)
- `gt log long` / `gt ll` — full git ancestry graph

```bash
gt ls --stack          # only current stack
gt ls --all            # all trunks
gt ls --reverse        # upside-down
```

### `gt info [branch]`
Detailed branch info.
```bash
gt info --diff         # show diff vs parent
gt info --stat         # show diffstat
gt info --body         # show PR description
```

## Syncing and Restacking

### `gt sync`
Pull trunk, restack all branches that can be cleanly rebased, prompt to delete merged branches.
```bash
gt sync                # standard daily sync
gt sync --all          # sync across all configured trunks
gt sync --no-restack   # fetch only, skip rebasing
gt sync --force        # no confirmation prompts
```

### `gt restack` (alias `gt r`)
Rebase branches onto their updated parents.
```bash
gt restack                  # restack current branch + all descendants
gt restack --only           # restack only this branch
gt restack --downstack      # restack ancestors only
gt restack --upstack        # restack descendants only
```

### Conflict Flow
```bash
# halted by conflict:
git status
# edit files, resolve markers
git add <file>
gt continue          # resume
# or: gt abort       # bail out
```

## Submitting PRs

### `gt submit` (alias `gt s`)
Push branches to GitHub and create/update PRs. Submits current branch + all downstack.

```bash
gt submit                              # current + downstack
gt submit --stack                      # full stack (gt ss)
gt submit --stack --draft              # open all as drafts
gt submit --stack --no-edit            # skip interactive metadata prompts
gt submit --stack --reviewers alice    # assign reviewers
gt submit --stack --merge-when-ready   # auto-merge when CI + reviews pass
gt submit --stack --update-only        # only push branches with existing open PRs
gt submit --dry-run                    # preview what would be submitted
gt submit --confirm                    # show plan, ask before pushing
```

Key flags:
| Flag | Short | Description |
|------|-------|-------------|
| `--stack` | `-s` | Include upstack branches |
| `--draft` | `-d` | Open new PRs as drafts |
| `--publish` | `-p` | Mark PRs as ready for review |
| `--no-edit` | `-n` | Skip PR metadata prompts |
| `--reviewers <list>` | `-r` | Comma-separated GitHub usernames |
| `--merge-when-ready` | `-m` | Enable Graphite auto-merge |
| `--update-only` | `-u` | Skip branches without existing PRs |
| `--force` | `-f` | Force push (instead of --force-with-lease) |
| `--dry-run` | | Preview only, no action |

## Structural Stack Operations

### `gt move`
Rebase current branch (and all descendants) onto a target.
```bash
gt move --onto main           # move to main
gt move --onto release/v2     # move to a different trunk
gt move                       # interactive picker
```

### `gt reorder`
Open an editor to drag-and-drop branches in the stack. Triggers restack on save.

### `gt fold` (alias `gt f`)
Fold current branch's commits into its parent. Children restack onto parent's new state.
```bash
gt fold            # use parent's name
gt fold --keep     # keep current branch's name
```

### `gt squash` (alias `gt sq`)
Squash all commits in the current branch into one.
```bash
gt squash -m "consolidated message"
gt squash --no-edit    # keep first commit message
```

### `gt split` (alias `gt sp`)
Split a branch into multiple branches.
```bash
gt split --by-commit             # split along existing commit boundaries
gt split --by-hunk               # interactive hunk selection per new branch
gt split --by-file "src/**"      # extract files into a new parent (repeatable)
```
> Note: GitHub PR branch names are immutable. When splitting a branch with an open PR, assign the original branch name to whichever new branch should keep the PR.

### `gt absorb` (alias `gt ab`)
Automatically distribute staged changes into the correct commits in the stack.
```bash
gt absorb -a          # stage all unstaged changes first
gt absorb -d          # dry run — show where hunks would land
gt absorb -f          # skip confirmation prompt
```

## Branch Lifecycle

### `gt delete [name]` (alias `gt dl`)
Delete a branch locally. Children restack onto grandparent.
```bash
gt delete feat-branch          # delete a branch
gt delete --upstack            # also delete all children
gt delete --close              # close associated GitHub PR
```

### `gt rename [name]` (alias `gt rn`)
Rename a branch. **Breaks GitHub PR association** (GitHub branch names are immutable).
```bash
gt rename new-name --force     # rename even with an open PR
```

### `gt pop`
Delete current branch but preserve working tree files.

### `gt track [branch]` (alias `gt tr`)
Register an untracked branch with Graphite by specifying its parent.
```bash
gt track --parent main    # set parent directly
gt track --force          # auto-select most recent tracked ancestor
```

### `gt untrack [branch]` (alias `gt utr`)
Remove a branch from Graphite tracking. Children also become untracked.

### `gt freeze [branch]` / `gt unfreeze [branch]`
Prevent/allow local modification of a branch. Useful when stacking on a teammate's work.

### `gt get [branch]`
Fetch a branch and its stack from remote.
```bash
gt get feat-branch              # fetch + checkout
gt get feat-branch --force      # overwrite local branches
gt get feat-branch --no-checkout  # fetch without switching
```

### `gt undo`
Undo the most recent Graphite mutation.

### `gt unlink [branch]`
Detach the GitHub PR association from a branch.

## Configuration

```bash
gt config                 # interactive config menu
gt aliases                # edit command aliases
gt trunk --add <name>     # add additional trunk branch
```

### Default Aliases
| Alias | Expands to |
|-------|-----------|
| `gt ls` | `gt log short` |
| `gt ll` | `gt log long` |
| `gt ss` | `gt submit --stack` |

Config files:
- `~/.config/graphite/user_config` — auth token, user settings, profiles
- `.git/.graphite_repo_config` — trunk, remote, GitHub repo override

## Global Flags

| Flag | Description |
|------|-------------|
| `--no-interactive` | Suppress all prompts/pagers (good for automation) |
| `--no-verify` | Skip git hooks |
| `--quiet` / `-q` | Minimize output |
| `--debug` | Verbose debug output |
| `--cwd <path>` | Set working directory |
