# Overview

## Overview


Use GitHub CLI (`gh`) for GitHub operations that are not better handled by
Graphite (`gt`).

`gh` is the default tool for issues, workflow status, releases,
comments, and API calls.

## Tool Boundary


- If a `gt` equivalent exists for branch and stack workflows, use `gt`.
- Use `gh` for operations without a `gt` equivalent.
- Do not use raw browser-only workflows when a clear `gh` command exists.

## Setup and Context


Before running write operations, confirm auth and target repository context.

```bash
gh auth status
gh repo view
```

If working outside the current repository, pass `--repo <owner>/<repo>`.

## Non-Interactive Defaults


Prefer non-interactive commands in automation and agent workflows.

- Always pass explicit flags instead of relying on prompts.
- Prefer machine-readable output with `--json` and `--jq`.
- Use `--confirm` only when command semantics require it.

## Common Commands


### Pull Requests

```bash
# View PR details
gh pr view <number> --json number,title,state,author,mergeStateStatus

# List open PRs
gh pr list --state open --limit 50

# Add a review comment
gh pr comment <number> --body "<comment>"

# Merge when policy allows
gh pr merge <number> --squash --delete-branch
```

### Issues

```bash
# List open issues
gh issue list --state open --limit 50

# Create issue
gh issue create --title "<title>" --body "<body>"

# Comment on issue
gh issue comment <number> --body "<comment>"

# Close issue
gh issue close <number> --comment "<resolution note>"
```

### Workflows and CI

```bash
# List recent workflow runs
gh run list --limit 20

# View a specific run
gh run view <run-id> --log

# Re-run failed jobs
gh run rerun <run-id> --failed
```

### Releases

```bash
# List releases
gh release list --limit 20

# Create release
gh release create <tag> --title "<title>" --notes "<notes>"
```

### API Access

```bash
# Query GitHub API directly
gh api repos/<owner>/<repo>/pulls --jq '.[].number'
```

## Output and Parsing


Prefer `--json` output for stable automation.

```bash
gh pr view <number> --json title,state,reviewDecision --jq '.state'
```

Avoid parsing plain text output when a JSON field is available.

## Safety Rules


- Do not run destructive commands without clear user intent.
- Confirm target repo before mutating issues, PRs, or releases.
- For bulk edits, test on one object first, then scale.

