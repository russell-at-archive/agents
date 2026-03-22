# Linear CLI: Troubleshooting

## Common issues

| Symptom | Likely cause | Fix |
|---|---|---|
| `linear: command not found` | Not installed or not on PATH | `brew install schpet/tap/linear` or `npm install -g @schpet/linear-cli` |
| `Unauthorized` / `401` | Invalid or expired API key | `linear auth login` or set `LINEAR_API_KEY` |
| `linear issue id` returns nothing | VCS context not detectable | Use explicit issue ID (e.g. `ENG-123`) |
| No issues listed | Filter or workspace mismatch | Try `-A` flag or `-w <slug>` |
| Command hangs | Waiting for interactive input | Add required flags (`--title`, `--team`, etc.) |
| `linear issue pr` fails | `gh` not authenticated | Run `gh auth login` separately |
| Wrong workspace used | Wrong default set | `linear auth list`, then `linear auth default <slug>` |

## VCS context resolution

- **Git:** the branch name must contain the issue identifier, e.g.
  `eng-123-fix-bug`. Branches without an issue key return nothing.
- **Jujutsu (jj):** requires a `Linear-issue: ENG-123` trailer in the current
  commit description. Set `vcs = "jj"` in `.linear.toml` or
  `LINEAR_VCS=jj`.
- **Outside a repo:** context detection always fails. Pass issue IDs explicitly.

## Auth precedence (highest to lowest)

1. `--api-key` flag on the command
2. `LINEAR_API_KEY` environment variable
3. `api_key` in `.linear.toml`
4. `-w <slug>` with stored workspace credentials
5. `workspace` field in `.linear.toml` with stored credentials
6. Default workspace in `~/.config/linear/credentials.toml`

## Keyring issues (Linux)

The CLI stores API keys in the native OS keyring. On Linux, `libsecret` is
required:

```bash
# Debian/Ubuntu
sudo apt install libsecret-tools
# Arch
sudo pacman -S libsecret
```

If keyring access is unavailable, fall back to the `LINEAR_API_KEY` env var or
`api_key` in `.linear.toml`.

## Red flags

- Running `linear issue delete` without explicit user confirmation.
- Assuming `gh` is authenticated just because `linear` is.
- Using inline `--description` strings for multi-line markdown (use
  `--description-file` instead).
- Hardcoding workspace-specific IDs in scripts when names or slugs work.
- Assuming VCS context without first running `linear issue id`.
