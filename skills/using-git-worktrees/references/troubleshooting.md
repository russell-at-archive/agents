# Troubleshooting

## Common Mistakes


### Skipping ignore verification

- **Problem:** Worktree contents get tracked, pollute git status
- **Fix:** Always use `git check-ignore` before creating project-local worktree

### Assuming directory location

- **Problem:** Creates inconsistency, violates project conventions
- **Fix:** Follow priority: existing > CLAUDE.md > ask

### Proceeding with failing tests

- **Problem:** Can't distinguish new bugs from pre-existing issues
- **Fix:** Report failures, get explicit permission to proceed

### Hardcoding setup commands

- **Problem:** Breaks on projects using different tools
- **Fix:** Auto-detect from project files (package.json, etc.)

### Submitting the empty base branch

- **Problem:** `gt submit --stack` errors with "GitHub does not allow empty PRs"
  because the branch created by `git worktree add` has zero commits
- **Fix:** Before submitting, `gt checkout <first-work-branch>` and run
  `gt track --parent main --no-interactive` to re-parent it directly onto
  main, bypassing the empty base branch entirely

### Proceeding without a verified baseline

- **Problem:** New failures are mixed with pre-existing failures,
  making regressions hard to identify.
- **Fix:** Identify and run project-specific validation commands
  before implementation. If unknown, ask the user first.

### Forgetting to delete local branches after merge

- **Problem:** Local branches linger after `gt sync` because GitHub squash/rebase
  merges are not detected as "fully merged" by git — `gt sync` warns but does not
  force-delete them
- **Fix:** After removing the worktree, always run `git branch -D <branch>` for
  every branch in the stack. This is Step 4 in the teardown — it is mandatory,
  not optional

### Forgetting to tear down the worktree

- **Problem:** Stale worktrees accumulate, merged branches linger locally
- **Fix:** Follow the Teardown After Merge checklist every time a stack merges

## Red Flags


**Never:**

- Create worktree without verifying it's ignored (project-local)
- Skip validation-command discovery before implementation
- Skip baseline test verification
- Proceed with failing tests without asking
- Assume directory location when ambiguous
- Skip CLAUDE.md check

**Always:**

- Follow directory priority: existing > CLAUDE.md > ask
- Verify directory is ignored for project-local
- Auto-detect and run project setup
- Discover and run baseline validation commands before implementation
- Verify clean test baseline

