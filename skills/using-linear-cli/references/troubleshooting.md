# Using Linear CLI: Troubleshooting

## Common Issues and Fixes

| Issue | Problem | Fix |
| ----- | ------- | --- |
| `linear: command not found` | CLI not installed or on PATH | Run `npm install -g @schpet/linear-cli` |
| `Unauthorized` | Invalid or expired token | Run `linear auth login` or check `LINEAR_API_KEY` |
| `linear issue id` fails | VCS context not detectable | Use explicit issue ID (e.g., `ENG-123`) |
| No issues found | Filter or workspace mismatch | Use `--all-states` or `-w <slug>` |
| Command hangs | Waiting for interactive input | Use `--no-interactive` or required flags |

## VCS Resolution Mistakes

- **Git:** Ensure the branch name actually contains the issue identifier.
- **JJ:** Ensure the `Linear-issue` trailer is present in the current commit.
- **Outside Repo:** The CLI cannot infer context if run outside the target directory.

## Red Flags

- Updating issues without verifying their current state first.
- Using `linear issue delete` without explicit confirmation from the user.
- Assuming `gh` auth works just because `linear` auth works (required for `linear issue pr`).
- Hardcoding team or project IDs when names/slugs are available and safer.
