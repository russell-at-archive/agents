# Overview

## Overview


Git worktrees create isolated workspaces sharing the same repository,
allowing work on multiple branches simultaneously without switching.

**Core principle:** Systematic directory selection + safety verification
= reliable isolation.

**Announce at start:** "I'm using the using-git-worktrees skill to set
up an isolated workspace."

## Directory Selection Process


Follow this priority order:

### 1. Check Existing Directories

```bash
# Check in priority order
ls -d .worktrees 2>/dev/null     # Preferred (hidden)
ls -d worktrees 2>/dev/null      # Alternative
```

**If found:** Use that directory. If both exist, `.worktrees` wins.

### 2. Check CLAUDE.md

```bash
grep -i "worktree.*director" CLAUDE.md 2>/dev/null
```

**If preference specified:** Use it without asking.

### 3. Ask User

If no directory exists and no CLAUDE.md preference:

```text
No worktree directory found. Where should I create worktrees?

1. .worktrees/ (project-local, hidden)
2. ~/.config/superpowers/worktrees/<project-name>/ (global location)

Which would you prefer?
```

## Safety Verification


### For Project-Local Directories (.worktrees or worktrees)

**MUST verify directory is ignored before creating worktree:**

```bash
# Check if directory is ignored (respects local, global, and system gitignore)
git check-ignore -q .worktrees 2>/dev/null || git check-ignore -q worktrees 2>/dev/null
```

**If NOT ignored:**

Fix this immediately:

1. Add appropriate line to .gitignore
2. Commit the change
3. Proceed with worktree creation

**Why critical:** Prevents accidentally committing worktree contents to repository.

### For Global Directory (~/.config/superpowers/worktrees)

No .gitignore verification needed - outside project entirely.

## Creation Steps


### 1. Detect Project Name

```bash
project=$(basename "$(git rev-parse --show-toplevel)")
```

### 2. Create Worktree

```bash
# Determine full path
case $LOCATION in
  .worktrees|worktrees)
    path="$LOCATION/$BRANCH_NAME"
    ;;
  ~/.config/superpowers/worktrees/*)
    path="~/.config/superpowers/worktrees/$project/$BRANCH_NAME"
    ;;
esac

# Create worktree with new branch
git worktree add "$path" -b "$BRANCH_NAME"
cd "$path"

# Register the base branch with Graphite immediately
gt sync --no-interactive
gt track --parent main --no-interactive
```

**Important — the empty base branch problem:** `git worktree add` creates
a branch with zero commits of its own. Graphite will refuse to submit it
(`ERROR: GitHub does not allow empty PRs`). The base branch is only a
container for the stack; the real work goes on branches created with
`gt create` inside the worktree.

Before running `gt submit --stack`, re-parent the **first real branch**
directly onto `main` so the empty base branch is excluded:

```bash
# From inside the worktree, after creating your work branches:
gt checkout <first-work-branch>
gt track --parent main --no-interactive
gt checkout <top-of-stack>

# Now submit — only real branches are submitted
gt submit --stack --no-interactive --publish
```

### 3. Run Project Setup

Auto-detect and run appropriate setup:

```bash
# Node.js
if [ -f package.json ]; then npm install; fi

# Rust
if [ -f Cargo.toml ]; then cargo build; fi

# Python
if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
if [ -f pyproject.toml ]; then poetry install; fi

# Go
if [ -f go.mod ]; then go mod download; fi
```

### 4. Discover Project Validation Commands

Before implementation, identify the project's canonical local checks:
typecheck, lint, and tests. Prefer commands documented in:

- `README.md`
- `CONTRIBUTING.md`
- project task runners (`package.json`, `Makefile`, `justfile`, etc.)

If no standard checks are defined, ask the user which baseline command
should be used before implementation.

### 5. Verify Clean Baseline

Run the discovered validation commands to ensure the worktree starts clean.
Example commands (project-dependent):

```bash
npm test
cargo test
pytest
go test ./...
```

**If tests fail:** Report failures, ask whether to proceed or investigate.

**If tests pass:** Report ready.

### 6. Report Location

```text
Worktree ready at <full-path>
Tests passing (<N> tests, 0 failures)
Ready to implement <feature-name>
```

## Teardown After Merge


Once all PRs in the worktree's stack are merged, clean up in this order:

### 1. Confirm all PRs are merged

```bash
gh pr list --repo <owner>/<repo> --state open --head <branch-name>
# Should return nothing if all merged
```

### 2. Remove the worktree

**Important:** Remove the worktree before running `gt sync` if a branch
is checked out in it. Graphite cannot delete a branch that is currently
checked out in a worktree.

```bash
git worktree remove .worktrees/<name>
# If the worktree has untracked files blocking removal:
git worktree remove --force .worktrees/<name>
```

### 3. Sync trunk from the main workspace

```bash
# From the main workspace root:
gt sync --no-interactive
# This pulls latest main, rebases any remaining stacks,
# and prompts to delete merged branches
```

### 4. Delete local branches

**This step is mandatory.** `gt sync` does not reliably delete local
branches after a squash or rebase merge on GitHub. Always delete them
explicitly after removing the worktree.

```bash
# List what remains
git branch

# Delete each merged branch (force required for squash/rebase merges)
git branch -D <branch-name> [<branch-name> ...]
```

If unsure whether a branch is truly merged, confirm first:

```bash
gh pr view <number> --json state   # must show "MERGED" before -D
```

### 5. Prune stale metadata

```bash
git worktree prune
```

### 6. Update the issue

```bash
gh issue close <N> --repo <owner>/<repo> --comment "Closed by merged PR stack."
# Or verify the 'Closes #N' in the PR body auto-closed it
```

### Teardown checklist

- [ ] All PRs in the stack show as merged on GitHub
- [ ] `git worktree remove .worktrees/<name>` succeeded (one per worktree)
- [ ] `gt sync` run from main workspace — local main is up to date
- [ ] Local branches deleted with `git branch -D` (one per branch)
- [ ] `git worktree prune` run to clean stale refs
- [ ] Issue closed (auto or manual)

## Integration


**Called by:**

- **brainstorming** (Phase 4) - REQUIRED when design is approved and
  implementation follows
- **subagent-driven-development** - REQUIRED before executing any tasks
- **executing-plans** - REQUIRED before executing any tasks
- Any skill needing isolated workspace

**Pairs with:**

- **finishing-a-development-branch** - REQUIRED for cleanup after work
  complete

