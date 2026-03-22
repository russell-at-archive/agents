# Linear CLI: Examples

## Bootstrap a repo

```bash
linear auth login --key "$LINEAR_API_KEY"
linear config                            # generates .linear.toml interactively
linear auth whoami                       # verify identity
```

## Triage your work

```bash
linear issue list                        # your unstarted issues
linear issue list -A                     # all team issues
linear issue view ENG-123
linear issue comment list ENG-123
```

## Start work on an issue

```bash
linear issue start ENG-123              # creates branch, marks In Progress
# branch name: eng-123-slugified-title
linear issue id                         # confirm VCS context resolves
linear issue url                        # grab the issue URL
```

## Create an issue with rich markdown

```bash
cat > /tmp/issue.md <<'EOF'
## Problem
Upstream timeouts are masked and cause flakiness.

## Acceptance criteria
- Expose timeout in logs
- Add regression test
EOF

linear issue create \
  --title "Expose upstream timeout" \
  --description-file /tmp/issue.md
```

## Create PR after finishing work

```bash
linear issue pr          # runs `gh pr create` with title/body from the issue
```

## Update an issue

```bash
linear issue update ENG-123 --title "New Title"
linear issue update ENG-123 --description-file /tmp/updated.md
linear issue update ENG-123 --milestone "Phase 2"
```

## Threaded comments

```bash
linear issue comment list ENG-123
linear issue comment add --body "Initial analysis"
# reply to a specific comment:
linear issue comment add -p <comment-id> --body-file /tmp/reply.md
```

## Query via raw GraphQL

```bash
# Search issues across the workspace
linear api --variable term=login <<'GRAPHQL' | jq '.searchIssues.nodes[]'
query($term: String!) {
  searchIssues(term: $term, first: 20) {
    nodes { identifier title state { name } assignee { name } }
  }
}
GRAPHQL
```

## Direct curl using the stored token

```bash
curl -sX POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: $(linear auth token)" \
  -d '{"query":"{ viewer { id name email } }"}' | jq .
```

## Manage milestones

```bash
linear milestone list --project <projectId>
linear milestone create --project <projectId> --name "Q2 Goals" --target-date "2026-06-30"
linear milestone update <milestoneId> --target-date "2026-07-15"
```

## Work with documents

```bash
# Write a spec
cat spec.md | linear document create --title "Auth Redesign Spec" --project <projectId>

# Read it back
linear document list --project <projectId>
linear document view <slug> --raw

# Update in-place
linear document update <slug> --content-file ./spec-v2.md
```

## Multi-workspace targeting

```bash
linear auth list
linear -w personal issue list
linear -w work issue list --project "Platform"
```
