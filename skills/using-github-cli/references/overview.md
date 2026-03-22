# Overview

## Contents

- [Operating model](#operating-model)
- [Context and targeting](#context-and-targeting)
- [Command selection](#command-selection)
- [Pull requests](#pull-requests)
- [Issues](#issues)
- [Actions and workflows](#actions-and-workflows)
- [Repositories and releases](#repositories-and-releases)
- [Search](#search)
- [API usage](#api-usage)
- [Automation patterns](#automation-patterns)
- [Safety rules](#safety-rules)

## Operating model

Use `gh` as the first-choice interface for GitHub-native work. Optimize for:

- Non-interactive execution
- Explicit repository targeting
- Structured output
- Narrow commands before generic API calls

Baseline checks:

```bash
gh auth status
gh repo set-default --view
gh --version
```

Useful environment variables:

- `GH_PROMPT_DISABLED=1`: suppress prompts in automation
- `GH_REPO=owner/repo`: override repo detection
- `GH_HOST`: target GitHub Enterprise Server
- `GH_TOKEN` or `GITHUB_TOKEN`: token-based auth for automation

## Context and targeting

Prefer `--repo owner/repo` whenever any of these are true:

- The current directory is not the target repository
- The task spans multiple repositories
- The command mutates state
- The repo owner or host might be inferred incorrectly

When a task depends on a specific object, identify it first:

- Pull request: number, URL, or head branch
- Issue: number or URL
- Workflow run: run ID
- Workflow: file name or workflow name
- Release: tag name

## Command selection

Choose the narrowest command family that fits:

1. `gh pr`
2. `gh issue`
3. `gh run`
4. `gh workflow`
5. `gh release`
6. `gh repo`
7. `gh search`
8. `gh api`

Use `gh api` when:

- The dedicated subcommand cannot express the operation
- The task needs REST or GraphQL fields the subcommand does not expose
- Bulk or paginated collection reads are easier through the API

## Pull requests

Inspect first:

```bash
gh pr view 123 --repo owner/repo --json number,title,state,headRefName,baseRefName,url
gh pr checks 123 --repo owner/repo
gh pr diff 123 --repo owner/repo
```

Create non-interactively:

```bash
GH_PROMPT_DISABLED=1 gh pr create \
  --repo owner/repo \
  --base main \
  --head feature-branch \
  --title "feat: add oauth" \
  --body-file .github/pull_request_template.md
```

Review or comment:

```bash
gh pr review 123 --repo owner/repo --approve --body "Approved."
gh pr comment 123 --repo owner/repo --body "Please re-run the flaky test."
```

Merge safely:

```bash
gh pr merge 123 \
  --repo owner/repo \
  --squash \
  --delete-branch \
  --match-head-commit "$(git rev-parse HEAD)"
```

Rules:

- Read the PR before reviewing or merging
- Use `--match-head-commit` when merging from a checked-out branch
- Verify checks and mergeability before attempting a merge

## Issues

Inspect and list with JSON:

```bash
gh issue view 456 --repo owner/repo --json number,title,state,labels,assignees,url
gh issue list --repo owner/repo --limit 50 --json number,title,state,labels
```

Create or update:

```bash
GH_PROMPT_DISABLED=1 gh issue create \
  --repo owner/repo \
  --title "bug: crash on startup" \
  --body "Steps to reproduce..." \
  --label bug

gh issue edit 456 --repo owner/repo --add-label triaged --remove-label needs-info
```

Issue-to-branch flow:

```bash
gh issue develop 456 --repo owner/repo --checkout
```

## Actions and workflows

List and inspect:

```bash
gh workflow list --repo owner/repo
gh run list --repo owner/repo --limit 10
gh run view 123456789 --repo owner/repo
```

Dispatch and watch:

```bash
gh workflow run deploy.yml --repo owner/repo -f env=prod -f version=v1.2.0
gh run watch 123456789 --repo owner/repo --exit-status
```

Rerun or cancel carefully:

```bash
gh run rerun 123456789 --repo owner/repo
gh run cancel 123456789 --repo owner/repo
```

Rules:

- Identify the exact run ID before rerunning or canceling
- Use `gh run watch --exit-status` for CI gating in automation
- Distinguish workflow definition (`gh workflow`) from workflow execution (`gh run`)

## Repositories and releases

Repository inspection:

```bash
gh repo view owner/repo --json name,defaultBranchRef,isPrivate,url
gh repo list owner --limit 50 --json name,nameWithOwner,isPrivate,url
```

Release operations:

```bash
gh release list --repo owner/repo --limit 10
gh release view v1.2.0 --repo owner/repo
gh release create v1.2.1 --repo owner/repo --title "v1.2.1" --notes "Bug fixes"
```

## Search

Use GitHub search qualifiers rather than post-filtering when possible.

```bash
gh search issues --repo owner/repo --state open --label bug --json number,title,updatedAt
gh search prs --owner owner --review-requested @me --json number,title,url
gh search repos "topic:kubernetes archived:false" --json name,description,url
```

When excluding qualifiers on Unix-like shells, use `--` before the query:

```bash
gh search issues -- "is:open -label:bug"
```

## API usage

REST example:

```bash
gh api repos/{owner}/{repo}/pulls \
  --repo owner/repo \
  --paginate \
  --jq '.[].number'
```

Mutation example:

```bash
gh api repos/{owner}/{repo}/issues/456/comments \
  --repo owner/repo \
  -f body='Investigating now.'
```

GraphQL example:

```bash
gh api graphql \
  -F owner='owner' \
  -F repo='repo' \
  -f query='
    query($owner: String!, $repo: String!) {
      repository(owner: $owner, name: $repo) {
        pullRequests(last: 5, states: OPEN) {
          nodes { number title url }
        }
      }
    }'
```

API rules:

- Use `--paginate` for complete collection reads
- Use `--slurp` if downstream tooling needs a single JSON array
- Prefer `-F/--field` for typed values and `-f/--raw-field` for strings
- Use `--input` for larger JSON payloads instead of overloading shell quoting

## Automation patterns

Good patterns:

- `--json` + `--jq` for single-command extraction
- `GH_PROMPT_DISABLED=1` for any potentially interactive command
- Read-before-write and read-after-write verification
- Explicit `--repo` for scripts, cron jobs, and CI

Avoid:

- Scraping tables or prose output
- Hidden repo inference in automation
- Browser flows such as `--web` unless explicitly requested
- Manual pagination loops when `gh api --paginate` exists

## Safety rules

- Treat merge, close, delete, cancel, rerun, enable, and disable as mutations
- Verify resource identity before every mutation
- Do not use policy-bypassing or admin flags without explicit user intent
- If a command can target the wrong repo, make the repo explicit
