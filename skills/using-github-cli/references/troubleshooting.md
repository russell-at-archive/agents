# Troubleshooting

## Contents

- [Fast triage](#fast-triage)
- [Authentication failures](#authentication-failures)
- [Missing scopes](#missing-scopes)
- [Wrong repository context](#wrong-repository-context)
- [Non-interactive hangs](#non-interactive-hangs)
- [API and rate limiting](#api-and-rate-limiting)
- [GraphQL errors](#graphql-errors)
- [Extensions and version drift](#extensions-and-version-drift)
- [Mutation safety failures](#mutation-safety-failures)
- [Red flags](#red-flags)

## Fast triage

Run these first:

```bash
gh auth status
gh --version
gh repo set-default --view
GH_DEBUG=api gh <command>
```

## Authentication failures

Symptoms:

- `401 Unauthorized`
- `403 Forbidden`
- prompts to log in unexpectedly

Checks and fixes:

```bash
gh auth status
gh auth login
gh auth refresh -h github.com -s repo,read:org,workflow
```

For automation:

- Ensure `GH_TOKEN` or `GITHUB_TOKEN` is set
- Ensure the token scopes match the operation
- Use enterprise-specific token variables for GitHub Enterprise Server

## Missing scopes

Typical mismatch:

- `gh workflow` or `gh run` fails because `workflow` scope is missing
- org-level operations fail because admin scopes are absent

Refresh scopes explicitly:

```bash
gh auth refresh -s workflow
```

## Wrong repository context

Symptoms:

- The command targets the wrong repository
- `fatal: not a git repository`
- The same command works in one directory and fails in another

Fix:

```bash
gh repo set-default owner/repo
gh pr view 123 --repo owner/repo
```

Rule:

- In scripts and CI, prefer `--repo` or `GH_REPO` instead of relying on cwd

## Non-interactive hangs

Symptoms:

- Command stalls waiting for input
- CI job hangs with no clear error

Fixes:

```bash
GH_PROMPT_DISABLED=1 gh pr create --title "..." --body "..." --base main --head branch
GH_PROMPT_DISABLED=1 gh issue create --title "..." --body "..."
```

Also:

- Provide `--title`, `--body`, `--body-file`, `--base`, and `--head` when needed
- Use `--yes` where supported for explicit confirmation
- Avoid `--web` unless the user asked for browser interaction

## API and rate limiting

Symptoms:

- `403` with rate limit language
- slow loops over large collections
- partial result sets

Fixes:

```bash
gh api repos/{owner}/{repo}/pulls --paginate --cache 10m
```

Rules:

- Use `--paginate` instead of manual page loops
- Use `--cache` for repeated read-heavy requests
- Reduce request concurrency outside `gh` if secondary rate limits appear

## GraphQL errors

Symptoms:

- malformed query errors
- empty fields due to incorrect schema assumptions

Fixes:

- Verify variable names and types
- Include pagination fields when using `--paginate`
- Fall back to REST if the GraphQL shape is not worth the complexity

## Extensions and version drift

Symptoms:

- `unknown command` for an extension
- extension crashes after a `gh` upgrade

Fixes:

```bash
gh extension list
gh extension upgrade --all
gh extension install owner/extension-name
```

## Mutation safety failures

Symptoms:

- Merge rejected due to changed head SHA
- Cancel or rerun affects the wrong workflow run
- Close, delete, or release actions hit the wrong target

Fixes:

- Re-read the target resource immediately before mutating
- Use `--match-head-commit` for PR merges
- Resolve by concrete identifiers such as PR number, run ID, or tag name

## Red flags

- Scraping formatted CLI tables instead of asking `gh` for JSON
- Running mutating commands without `--repo` in ambiguous contexts
- Embedding tokens directly in commands, scripts, or committed files
- Using policy-bypassing flags without explicit user approval
