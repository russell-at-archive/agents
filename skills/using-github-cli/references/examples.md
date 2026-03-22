# Examples

## Pull request triage

```bash
gh pr list --repo owner/repo --limit 20 \
  --json number,title,author,reviewDecision,mergeStateStatus \
  --jq '.[] | {number, title, author: .author.login, reviewDecision, mergeStateStatus}'
```

## Safe PR merge

```bash
pr=123
head_sha="$(gh pr view "$pr" --repo owner/repo --json headRefOid --jq '.headRefOid')"

gh pr merge "$pr" \
  --repo owner/repo \
  --squash \
  --delete-branch \
  --match-head-commit "$head_sha"
```

## Issue creation without prompts

```bash
GH_PROMPT_DISABLED=1 gh issue create \
  --repo owner/repo \
  --title "bug: startup panic in auth bootstrap" \
  --body "Observed in v1.4.2 after config migration." \
  --label bug \
  --assignee @me
```

## Watch a workflow run to completion

```bash
run_id="$(gh run list --repo owner/repo --limit 1 --json databaseId --jq '.[0].databaseId')"
gh run watch "$run_id" --repo owner/repo --exit-status
```

## Trigger workflow_dispatch with inputs

```bash
gh workflow run deploy.yml \
  --repo owner/repo \
  -f environment=staging \
  -f image_tag=2026.03.22
```

## Download artifacts from a run

```bash
gh run download 123456789 --repo owner/repo --dir /tmp/build-artifacts
```

## Search for stale bugs

```bash
gh search issues \
  --repo owner/repo \
  --state open \
  --label bug \
  --json number,title,updatedAt,url \
  --jq '.[] | select(.updatedAt < "2026-01-01T00:00:00Z")'
```

## Query the API with pagination

```bash
gh api repos/{owner}/{repo}/issues \
  --repo owner/repo \
  --paginate \
  --jq '.[] | select(.state == "open") | .number'
```

## GraphQL for compact repository data

```bash
gh api graphql \
  -F owner='owner' \
  -F repo='repo' \
  -f query='
    query($owner: String!, $repo: String!) {
      repository(owner: $owner, name: $repo) {
        defaultBranchRef { name }
        openIssues: issues(states: OPEN) { totalCount }
        openPullRequests: pullRequests(states: OPEN) { totalCount }
      }
    }'
```

## Cross-repo release inspection

```bash
gh release list --repo owner/infrastructure --limit 5
```
