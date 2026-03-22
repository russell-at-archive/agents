# Linear CLI: Command Reference

## Contents

- [Authentication](#authentication)
- [Issues](#issues)
- [Teams](#teams)
- [Projects and milestones](#projects-and-milestones)
- [Cycles and initiatives](#cycles-and-initiatives)
- [Documents](#documents)
- [Labels](#labels)
- [Raw GraphQL](#raw-graphql)
- [VCS context](#vcs-context)

---

## Authentication

```bash
linear auth login               # Add a workspace (prompts for API key)
linear auth login --key "$KEY"  # Non-interactive
linear auth list                # List all workspaces (* = default)
linear auth default <slug>      # Change the default workspace
linear auth logout <slug>       # Remove a workspace
linear auth whoami              # Current user and workspace
linear auth token               # Print the raw API token (for curl)
```

The `-w <slug>` flag works on any command to target a specific workspace:
`linear -w side-project issue list`

---

## Issues

### Read

```bash
linear issue list                          # Your unstarted issues
linear issue list -A                       # All team issues
linear issue list --project "My Project"   # Filtered by project
linear issue list --project "P" --milestone "Phase 1"
linear issue list -s in_progress           # Filter by state
linear issue view ENG-123                  # Full details
linear issue view                          # Current issue (from VCS context)
linear issue view -w                       # Open in browser
linear issue view -a                       # Open in Linear.app
linear issue comment list ENG-123          # Comments thread
```

### VCS context helpers (single-line output, useful in scripts)

```bash
linear issue id                            # Print issue ID (e.g. ENG-42)
linear issue title                         # Print issue title
linear issue url                           # Print Linear.app URL
linear issue commits                       # Linked commits (jj VCS only)
```

### Create

```bash
linear issue create                        # Interactive
linear issue create --title "Title" --description "Body"
linear issue create --title "Title" --description-file /tmp/issue.md
linear issue create --project "My Project" --milestone "Phase 1"
```

### Start (create branch + mark In Progress)

```bash
linear issue start ENG-123                 # Branch created from current HEAD
linear issue start                         # Interactive: pick from list
linear issue start --branch custom-name    # Override branch name
```

Branch naming convention: `{team-key}-{issue-number}-{slugified-title}`
e.g. `eng-123-fix-login-bug`

### Update

```bash
linear issue update ENG-123 --title "New Title"
linear issue update ENG-123 --description-file /tmp/updated.md
linear issue update ENG-123 --milestone "Phase 2"
```

### Comments

```bash
linear issue comment add --body "text"
linear issue comment add --body-file /tmp/comment.md
linear issue comment add -p <comment-id>        # Reply to a comment
linear issue comment update <id> --body "text"
linear issue comment update <id> --body-file /tmp/updated.md
```

### PR integration

```bash
linear issue pr          # Creates a PR via `gh pr create` with issue title/body
```

Requires the `gh` CLI to be authenticated independently.

### Delete

```bash
linear issue delete ENG-123     # Always confirm with the user before running
```

---

## Teams

```bash
linear team list           # List all teams
linear team id             # Print current team ID (from config or context)
linear team members        # List team members
linear team create         # Create a new team (interactive)
linear team autolinks      # Configure GitHub autolinks for the team
```

---

## Projects and milestones

```bash
linear project list                                  # All projects
linear project view <projectId>                      # Project details
linear project-update list <projectId>               # Status updates

linear milestone list --project <projectId>          # List milestones
linear milestone view <milestoneId>                  # Milestone details
linear milestone create --project <id> --name "Q1"  # Create milestone
linear milestone create --project <id> --name "Q1" --target-date "2026-03-31"
linear milestone update <id> --name "New Name"
linear milestone update <id> --target-date "2026-04-15"
linear milestone delete <id>
linear milestone delete <id> --force                 # Skip confirmation
linear m list --project <projectId>                  # `m` is an alias for milestone
```

---

## Cycles and initiatives

```bash
linear cycle list --team ENG                        # Cycles for a team
linear initiative list --status active              # Active initiatives
linear initiative-update list <initiativeId>        # Initiative progress updates
```

---

## Documents

```bash
linear document list                               # All documents
linear document list --project <projectId>         # Filter by project
linear document list --issue ENG-123               # Filter by issue
linear document list --json                        # JSON output

linear document view <slug>                        # Render in terminal
linear document view <slug> --raw                  # Raw markdown
linear document view <slug> --web                  # Open in browser
linear document view <slug> --json                 # JSON output

linear document create --title "Spec" --content "# Hello"
linear document create --title "Spec" --content-file ./spec.md
linear document create --title "Notes" --project <projectId>
linear document create --title "Notes" --issue ENG-123
cat spec.md | linear document create --title "Spec"   # stdin

linear document update <slug> --title "New Title"
linear document update <slug> --content-file ./updated.md
linear document update <slug> --edit               # Open in $EDITOR

linear document delete <slug>                      # Soft delete
linear document delete <slug> --permanent          # Permanent delete
linear document delete --bulk <slug1> <slug2>

linear docs list                                   # `docs` is an alias for document
```

---

## Labels

```bash
linear label list          # All labels (for tagging issues)
```

---

## Raw GraphQL

Use when high-level commands are insufficient.

```bash
# Simple inline query
linear api '{ viewer { id name email } }'

# With a single variable
linear api --variable teamId=abc123 '{ team(id: $teamId) { name } }'

# Heredoc for complex queries (recommended)
linear api --variable term=login <<'GRAPHQL'
query($term: String!) {
  searchIssues(term: $term, first: 20) {
    nodes { identifier title state { name } }
  }
}
GRAPHQL

# JSON variables for multiple/typed variables
linear api --variables-json '{"teamId":"abc","first":10}' <<'GRAPHQL'
query($teamId: String!, $first: Int) {
  team(id: $teamId) { issues(first: $first) { nodes { identifier title } } }
}
GRAPHQL

# Pipe to jq
linear api '{ viewer { id name } }' | jq '.viewer.name'

# Direct curl using the stored token
curl -sX POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: $(linear auth token)" \
  -d '{"query": "{ viewer { id } }"}' | jq .
```

### Schema

```bash
linear schema                        # Print schema to stdout
linear schema -o /tmp/linear.graphql # Write to file
```

---

## VCS context

The CLI reads the current issue from:

- **Git:** branch name containing the issue identifier (e.g. `eng-123-fix-bug`)
- **Jujutsu (jj):** `Linear-issue: ENG-123` trailer in the current commit
  description

Configure which VCS to use:

```toml
# .linear.toml
vcs = "git"   # or "jj"
```

Or: `export LINEAR_VCS=jj`

Always run `linear issue id` before assuming VCS context is available. If it
fails, fall back to explicit issue IDs.
