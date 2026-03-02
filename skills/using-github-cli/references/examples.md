# Examples

## List PRs Requiring Review

```bash
gh pr list --search "review:required state:open" \
  --json number,title,author,url \
  --jq '.[] | {number, title, author: .author.login, url}'
```

## Create PR Non-Interactively

```bash
gh pr create \
  --base main \
  --head <branch> \
  --title "feat(api): add bulk import endpoint" \
  --body "## Summary\n- add endpoint\n- add tests\n\nCloses #123"
```

## Gate Merge On Required Checks

```bash
gh pr checks <pr-number> --required --watch
# exit code 0: checks passed
# exit code 8: checks still pending
# exit code 1: failed
```

## Merge With Head Commit Guard

```bash
gh pr merge <pr-number> \
  --squash \
  --delete-branch \
  --match-head-commit <sha>
```

## Create And Route An Issue

```bash
gh issue create \
  --title "Bug: cache invalidation fails on tenant switch" \
  --body "## Steps\n1. ...\n\n## Expected\n..." \
  --label bug \
  --assignee @me
```

## Bulk-Query Issues With Search Syntax

```bash
gh issue list \
  --search "label:bug no:assignee state:open sort:created-asc" \
  --json number,title,createdAt,url \
  --jq '.[] | {number, title, createdAt, url}'
```

## Trigger Workflow Dispatch With Inputs

```bash
gh workflow run deploy.yml \
  --ref main \
  -f environment=staging \
  -f image_tag=sha-abc123
```

## Watch A Workflow Run

```bash
gh run watch <run-id> --exit-status
gh run view <run-id> --log
```

## Create Release With Generated Notes

```bash
gh release create v1.8.0 \
  --generate-notes \
  --verify-tag \
  --latest
```

## Use REST API For Missing CLI Coverage

```bash
gh api repos/{owner}/{repo}/rulesets \
  --paginate \
  --slurp \
  --jq '.[].name'
```

## Use GraphQL Pagination

```bash
gh api graphql --paginate -f query='query($endCursor: String) {
  viewer {
    repositories(first: 100, after: $endCursor) {
      nodes { nameWithOwner }
      pageInfo { hasNextPage endCursor }
    }
  }
}' --jq '.data.viewer.repositories.nodes[].nameWithOwner'
```

## Cross-Repo Operation Pattern

```bash
gh issue comment 123 \
  --repo octo-org/platform \
  --body "Investigating now; status update in 30 minutes."
```
