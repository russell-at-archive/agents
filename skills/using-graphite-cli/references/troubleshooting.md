# Troubleshooting

## Red Flags — STOP and Fix


- About to run `git checkout -b` — use `gt create` instead
- About to run `git push` — use `gt submit` instead
- About to run `gh pr create` — use `gt submit` instead
- About to run `git rebase origin/main` — use `gt sync` instead
- Creating a PR without stacking — always use `gt submit`
- Submitting without `--publish` — `--no-interactive` forces draft
- Submitting without `--reviewer` — PRs with no reviewer sit unreviewed
- Skipping PR description — an empty PR body is never ready for review

## Common Mistakes


| Mistake                          | Fix                                    |
| -------------------------------- | -------------------------------------- |
| Using `gh pr create`             | Use `gt submit` — creates PRs too      |
| Using `git push`                 | Use `gt submit` — pushes and creates   |
| Using `git checkout -b`          | Use `gt create` — stack-aware          |
| Manual `git rebase`              | Use `gt sync` or `gt restack`          |
| Missing `--no-interactive`       | Always pass when non-interactive       |
| Missing `--publish` on submit    | `--no-interactive` forces draft        |

