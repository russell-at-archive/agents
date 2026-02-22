# Examples

## Preflight

```bash
glab auth status
glab repo view
```

For cross-repo work:

```bash
glab mr list -R my-group/my-project --state opened --output json
```

## Merge Requests

List open MRs as JSON:

```bash
glab mr list --state opened --output json
```

View one MR:

```bash
glab mr view 123
```

Create a draft MR with explicit branches:

```bash
glab mr create \
  --source-branch feature/my-change \
  --target-branch main \
  --title "feat: add my change" \
  --description "Implements X and includes tests." \
  --draft
```

Add a note:

```bash
glab mr note 123 -m "Please review the retry logic in commit abc123."
```

Merge non-interactively when policy allows:

```bash
glab mr merge 123 --yes
```

## Issues

List open issues:

```bash
glab issue list --state opened --output json
```

Create issue:

```bash
glab issue create \
  --title "Bug: timeout in worker" \
  --description "Timeout occurs when processing jobs over 10MB." \
  --label bug \
  --assignee "@me"
```

Comment and close:

```bash
glab issue note 456 -m "Root cause identified; fix is in !123."
glab issue close 456
```

## CI

List CI entries:

```bash
glab ci list
```

Inspect one entry:

```bash
glab ci view 789
```

## Releases

List releases:

```bash
glab release list
```

Create a release:

```bash
glab release create v1.4.0 \
  --name "v1.4.0" \
  --notes "Includes performance fixes and CI stability improvements."
```

## API Queries

List MRs via API:

```bash
glab api projects/:id/merge_requests --paginate
```

Create an issue via API fields:

```bash
glab api projects/:id/issues \
  -X POST \
  -F title='Bug: cache miss loop' \
  -F description='Observed in production after deploy 2026-03-01.'
```
