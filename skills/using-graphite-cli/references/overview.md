# Overview

## Overview


**All git operations MUST use the Graphite CLI (`gt`) instead of raw
`git` commands.** All pull requests MUST use Graphite stacks
via `gt submit`.

## The Rule


**NEVER run `git` commands when a `gt` equivalent exists.**
Use `gt` for branch creation, committing, syncing, submitting PRs,
and navigation.

**Violating the letter of this rule is violating the spirit of the
rule.**

## Command Mapping


| git / gh                          | gt equivalent             |
| --------------------------------- | ------------------------- |
| `git checkout -b <name>`          | `gt create <name>`        |
| `git commit`                      | `gt create` / `gt modify` |
| `git add . && git commit --amend` | `gt modify`               |
| `git rebase origin/main`          | `gt sync`                 |
| `git push`                        | `gt submit`               |
| `git push` (full stack)           | `gt submit --stack`       |
| `gh pr create`                    | `gt submit`               |
| `git checkout <branch>`           | `gt checkout`             |
| `git log --graph`                 | `gt log`                  |
| `git checkout` (up in stack)      | `gt up`                   |
| `git checkout` (down in stack)    | `gt down`                 |
| `git rebase` (reorder stack)      | `gt restack`              |

## Core Workflow


### Creating a new branch with changes

```bash
# Stage your changes first
git add <files>
# Create a new stacked branch with a commit
gt create feature-name -m "commit message"
```

### Stacking another PR on top

```bash
# From current branch, stage changes, then:
gt create next-feature -m "commit message"
# This automatically stacks on the current branch
```

### Modifying the current branch

```bash
# Stage changes, then:
gt modify
# Automatically restacks all descendant branches
```

### Pre-Submit Gate — MANDATORY

**Before running `gt submit`, local validation checks must pass.**
Do not submit and wait for CI to catch failures.

Run the repository's standard pre-submit commands. Prefer commands
documented in `README.md`, `CONTRIBUTING.md`, or project task runners
(`package.json`, `Makefile`, `justfile`, etc.).

```bash
# Example only — use project-specific equivalents
npm run typecheck
npm run lint
npm test
```

If checks fail, fix and re-run before proceeding to `gt submit`.

### Submitting PRs (always as stacks)

A PR is not ready for review until it has:

1. **All required local validation checks passing**
2. **A description** — follow the repository PR template if one exists
3. **Published (not draft)** — use `--publish` so reviewers are
   notified
4. **A reviewer assigned** — use `--reviewer <username>`

```bash
# Submit the entire stack, published, with reviewer
gt submit --stack --no-interactive --publish --reviewer <reviewer-username>

# Submit current branch and all downstack branches
gt submit --no-interactive --publish --reviewer <reviewer-username>
```

**Note:** GitHub does not allow requesting a review from the PR author.
If the agent is running as the same user who owns the repo, omit
`--reviewer` and add reviewers manually from the GitHub UI after
submission.

**`--no-interactive` forces draft mode.** The flag to override this is
`--publish`. There is no `--no-draft` flag — it does not exist. Always
pass `--publish` when submitting in non-interactive mode. A draft PR
will not be reviewed.

After `gt submit`, update each PR's description using `gh pr edit`:

```bash
gh pr edit <number> --body "$(cat <<'EOF'

## Summary

- <what and why>

## Type of Change

- [ ] New implementation
- [ ] Design document or ADR
- [ ] Bug fix
- [ ] Test cases added
- [ ] Refactor

## Related Issues

Closes #N

## ADR

- [ ] No ADR required
- [ ] ADR written: [ADR-NNN](docs/adr/NNN-title.md)

## Test Plan

- [ ] Ran test suite
- [ ] Documentation-only — no test needed

## Definition of Done

- [ ] Tests pass
- [ ] TypeScript typechecks with no errors
- [ ] No new gaps introduced
EOF
)"
```

### Syncing with trunk

```bash
gt sync
# Pulls latest trunk, rebases all stacks, prompts to clean merged
# branches
```

## When Git Is Still Acceptable


Only use raw `git` for operations that have **no `gt` equivalent**:

- `git status` — checking working tree state
- `git diff` — viewing changes
- `git add` — staging files
- `git stash` — stashing changes
- `git log` — viewing commit history (though prefer `gt log`)
- `git clone` — cloning repositories
- `git init` — initializing repositories
- `gt init` should be run after `git init` or `git clone` to set up
  Graphite

## Non-Interactive Mode


When running `gt` in an automated/agent context, use `--no-interactive`
to avoid prompts. `--no-interactive` forces draft mode, so always add
`--publish` on submit — a draft PR will not be reviewed:

```bash
gt submit --no-interactive --publish
gt sync --no-interactive
```

## Rationalization Table


| Excuse                            | Reality                                  |
| --------------------------------- | ---------------------------------------- |
| "git is simpler for this"         | `gt` wraps git — same simplicity.        |
| "I just need a quick branch"      | `gt create` is one command.              |
| "This PR doesn't need stacking"   | `gt submit` handles single PRs too.      |
| "gh pr create gives more control" | Use `gt submit --help` for options.      |
| "I'll switch to gt later"         | No. Mixing causes stack tracking issues. |

