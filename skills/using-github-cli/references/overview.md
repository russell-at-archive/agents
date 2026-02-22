# Overview

## Purpose

Use GitHub CLI (`gh`) for GitHub-native operations that do not have a better
Graphite (`gt`) equivalent.

Use `gh` first for:

- issue lifecycle work
- Actions workflow and run operations
- release lifecycle work
- direct GitHub API calls (`gh api`)
- cross-repo metadata queries

If the operation is stack or branch-flow management, use `gt` first.

## Context Setup

Validate tool, auth, host, and repository before write operations.

```bash
gh --version
gh auth status
gh repo set-default --view
```

Context controls:

- `--repo [HOST/]OWNER/REPO` targets a specific repository.
- `GH_REPO` sets default repo context.
- `GH_HOST` targets GitHub Enterprise hosts.
- `GH_PROMPT_DISABLED=1` disables interactive prompts.

## Non-Interactive Standard

For deterministic execution:

- pass explicit flags instead of prompt-driven flows
- pass `--title`, `--body`, `--label`, and similar fields directly
- prefer `--json` and parse with `--jq` where available
- use `--template` only when output must be formatted for humans

Formatting pattern:

```bash
gh pr list --state open \
  --json number,title,author,updatedAt \
  --jq '.[] | {number, title, author: .author.login, updatedAt}'
```

## Command Selection

### Pull Requests

Common read operations:

```bash
gh pr list --state open --limit 50
gh pr view <number> --json number,title,state,reviewDecision,mergeStateStatus
gh pr checks <number> --required --watch
```

Common write operations:

```bash
gh pr create --title "<title>" --body "<body>" --base <base>
gh pr review <number> --approve --body "<note>"
gh pr merge <number> --squash --delete-branch
```

Notes:

- `gh pr checks` has additional exit code `8` for pending checks.
- On merge-queue protected branches, `gh pr merge` may enqueue instead of
  directly merging.

### Issues

```bash
gh issue list --state open --limit 100
gh issue create --title "<title>" --body "<body>" --label bug
gh issue comment <number> --body "<comment>"
gh issue close <number> --comment "<resolution>"
```

### Actions

```bash
gh run list --limit 20
gh run view <run-id> --log
gh run rerun <run-id> --failed
gh workflow run <workflow.yml> -f key=value -f key2=value2
```

For JSON workflow inputs:

```bash
echo '{"name":"value"}' | gh workflow run <workflow.yml> --json
```

### Releases

```bash
gh release list --limit 20
gh release create <tag> --generate-notes
gh release create <tag> --notes-file <file> --verify-tag
```

Safety notes:

- use `--verify-tag` when automatic tag creation is not desired
- use `--fail-on-no-commits` to avoid duplicate empty releases

### API

Use `gh api` for endpoints not covered by high-level commands.

```bash
gh api repos/{owner}/{repo}/pulls --jq '.[].number'
gh api graphql -f query='<graphql>'
gh api repos/{owner}/{repo}/issues --paginate --slurp
```

Important `gh api` patterns:

- `-f` for string fields
- `-F` for typed fields and `@file` payload injection
- `--method GET` when fields must become query params
- `--paginate` with `--slurp` for complete result sets

## Safety

Before every mutating command:

1. confirm target host and repository
2. confirm object identity (issue number, PR number, tag)
3. confirm mutation intent from the user

Never run these without explicit user intent:

- `gh pr merge`
- `gh pr close`
- `gh issue delete`
- `gh release delete`

## Reporting Standard

Return concise, auditable output:

- commands executed
- changed resources (PR/issue/run/release identifiers)
- verification command and result
- unresolved blockers and next action
