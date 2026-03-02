# Overview

Graphite-first policy: use `gt` whenever it has a direct equivalent.
Use raw `git` only for inspection/staging and conflict-resolution steps.

Version reference: validated against local `gt 1.7.17`.

## Prerequisites

1. Repository cloned and on expected remote.
2. Graphite initialized:
   `gt init --trunk <trunk-branch>` (typically `main`).
3. Auth configured for PR operations:
   `gt auth`.
4. Clean understanding of current stack:
   `gt log` and `git status`.

## Command Mapping

| Task                             | Preferred command           |
| -------------------------------- | --------------------------- |
| Create branch + commit           | `gt create <name> -m "..."` |
| Amend current branch             | `gt modify -m "..."`        |
| New commit on current branch     | `gt modify --commit -m`     |
| Move to branch                   | `gt checkout <branch>`      |
| Move up/down stack               | `gt up` / `gt down`         |
| Visualize stack                  | `gt log`                    |
| Sync with trunk and remote state | `gt sync`                   |
| Repair branch ancestry           | `gt restack`                |
| Submit PRs                       | `gt submit`                 |
| Submit full stack including kids | `gt submit --stack`         |

## Allowed Raw Git

Use raw `git` for:

- `git status`
- `git diff`
- `git add` (or patch staging flows)
- `git stash`
- conflict resolution commands during `gt`-initiated rebase flows

Do not replace `gt create`, `gt modify`, `gt restack`, `gt sync`, or
`gt submit` with manual `git` equivalents.

## Standard Workflow

1. Inspect state:
   `git status` and `gt log --stack`.
2. Create or update branch:
   `gt create` for new branch, `gt modify` for existing branch.
3. Restack if ancestry changed:
   `gt restack` (or `gt sync` when trunk moved).
4. Run repository validation before PR submit.
5. Submit:
   `gt submit` for downstack-only, `gt submit --stack` for full stack.
6. Re-check:
   `gt log` and confirm PR links/numbers.

## Submission Guidance

Use explicit flags in automation:

```bash
gt submit --no-interactive --no-edit --reviewers alice,bob
```

If PRs should be ready for review immediately, include `--publish`.
If PRs should stay draft, include `--draft`.

Common useful submit flags:

- `--stack`: include descendants.
- `--restack`: restack before push.
- `--reviewers`: assign reviewers.
- `--rerequest-review`: re-request existing reviewers.
- `--merge-when-ready`: set MWR on submitted PRs.

## Stack Repair And Reshaping

Use Graphite-native stack mutation commands instead of manual rebases:

- `gt move <target-branch>`: move branch and descendants.
- `gt fold`: fold current branch into parent.
- `gt split`: split one branch into multiple branches.
- `gt squash`: squash commits within current branch.
- `gt reorder`: interactively reorder branches between trunk and current.

After any reshape action, run `gt log` to verify expected topology.

## Conflict Recovery

When a Graphite command stops for conflicts:

1. Resolve files.
2. Stage resolved files with `git add`.
3. Continue with `gt continue`.

If abandoning the operation, run `gt abort`.
Do not start new stack mutations until the halted operation is resolved.
