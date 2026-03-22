# Graphite CLI — Common Workflow Examples

## 1. Build a Stack of PRs

```bash
# Start from trunk
gt checkout --trunk

# First PR: data layer
gt create -am "feat(db): add users table migration"

# Second PR stacked on top
gt create -am "feat(api): add users endpoint"

# Third PR stacked on top
gt create -am "feat(ui): add users page"

gt ls          # verify the stack
gt ss          # submit entire stack (gt submit --stack)
```

## 2. Daily Sync

```bash
gt sync        # pull trunk, restack all branches, offer to delete merged ones
gt ls          # verify nothing broke
```

## 3. Respond to Code Review on a Mid-Stack Branch

```bash
gt checkout feat-api-users    # or use gt down from the top
# edit files
gt modify -a                  # amend + auto-restack everything above
gt ss                         # re-push entire stack
```

## 4. Insert a Branch Mid-Stack

```bash
# Currently on feat-api-users, need to add auth middleware below it
gt down                       # move to parent
gt create --insert -am "feat(auth): add middleware"
# middleware is now the parent of feat-api-users
gt ls
```

## 5. Absorb a Fix Into the Right Commit

```bash
# Staged fixes apply to different commits in the stack
gt absorb -a       # auto-distribute all staged changes to the correct commits
gt ls
gt ss
```

## 6. Resolve a Conflict During Sync or Restack

```bash
gt sync
# halted: conflict on branch feat-api-users

git status                          # see conflicted files
# edit files, resolve <<<< markers
git add src/api/users.ts
gt continue                         # resume the sync
gt ls                               # verify topology
gt ss                               # re-push
```

## 7. Collaborate on a Teammate's Stack

```bash
gt get feat-api-users               # fetch their stack from remote
gt freeze feat-api-users            # lock it so you don't accidentally amend
gt checkout feat-api-users
gt create -am "feat(api): add pagination to users endpoint"
gt ss
```

## 8. Move a Sub-Stack to a Different Base

```bash
# feat-ui-users and its children need to target release/v2 instead of main
gt checkout feat-ui-users
gt move --onto release/v2
gt ls
gt ss --stack
```

## 9. Split a Large Branch Into Two PRs

```bash
gt checkout feat-big-change
gt split --by-commit                # split along existing commits
# interactive prompts assign each commit to a branch
gt ls
gt ss
```

## 10. Submit Automation-Friendly (No Prompts)

```bash
gt ss \
  --no-interactive \
  --no-edit \
  --draft \
  --reviewers alice,bob
```

## 11. Reorder Branches in a Stack

```bash
gt bottom
gt reorder     # opens editor with branch list — move lines to reorder
               # saves trigger automatic restack
gt ls
```

## 12. Clean Up After Merging

```bash
gt sync        # detects merged branches, prompts to delete them
# or manually:
gt delete feat-db-users --close    # delete locally + close PR
```

## 13. Undo a Mistake

```bash
gt undo        # undo the most recent Graphite operation
```
