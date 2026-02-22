# Troubleshooting

## Fast Triage

1. confirm auth: `gh auth status`
2. confirm repo context: `gh repo set-default --view`
3. rerun with debug logs: `GH_DEBUG=api <command>`
4. inspect exit code and command-specific docs

## Auth Failures

Symptom:

- `gh auth status` reports invalid token
- command exits with code `4`

Fix:

```bash
gh auth login -h github.com
gh auth refresh -s repo,read:org,workflow
```

If running in CI/automation, set `GH_TOKEN` explicitly.

## Wrong Repository Target

Symptom:

- operations affect or query unexpected repository

Fix:

```bash
gh repo set-default --view
gh repo set-default <owner>/<repo>
```

Or pass `--repo <owner>/<repo>` on every command.

## Interactive Prompt In Automation

Symptom:

- command hangs waiting for input

Fix:

- replace prompt path with explicit flags
- set `GH_PROMPT_DISABLED=1`
- provide `--title`, `--body`, `--base`, `--head`, etc.

## Merge Queue Or Policy Blocks

Symptom:

- `gh pr merge` does not merge immediately

Fix:

- inspect PR policy state:
  `gh pr view <pr> --json mergeStateStatus,reviewDecision,statusCheckRollup`
- if checks are pending, wait or enable auto-merge with `--auto`
- use `--admin` only with explicit authorization

## Failing Or Stuck Checks

Symptom:

- required checks never complete or fail intermittently

Fix:

```bash
gh pr checks <pr> --required --watch
gh run list --limit 20
gh run view <run-id> --log
gh run rerun <run-id> --failed
```

## API Request Errors

Symptom:

- `gh api` returns `404`, `422`, or malformed payload errors

Fix:

- confirm endpoint and method
- use `-F` for typed fields and nested payloads
- send body with `--input` for complex JSON
- include previews when required: `--preview <name>`

Diagnostic command:

```bash
gh api <endpoint> --verbose --include
```

## Rate Limiting

Symptom:

- API responses indicate primary or secondary rate limits

Fix:

- reduce polling frequency
- add caching for repeated reads: `--cache 300s`
- avoid unnecessary pagination or wide queries

## Red Flags

Stop and correct immediately if any of these occur:

- mutating command without explicit repository targeting in multi-repo context
- plain-text scraping when `--json` fields exist
- running `gh` for branch/stack flows where `gt` should be primary
- destructive operation attempted without explicit user approval
