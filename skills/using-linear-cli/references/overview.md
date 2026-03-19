# Using Linear CLI: Full Reference

## Contents

- [Authentication](#authentication)
- [Issue Lifecycle](#issue-lifecycle)
- [Teams, Cycles, and Initiatives](#teams-cycles-and-initiatives)
- [Projects and Milestones](#projects-and-milestones)
- [Documents and Labels](#documents-and-labels)
- [Raw GraphQL and Schema](#raw-graphql-and-schema)
- [VCS Context](#vcs-context)

---

## Authentication

Verify your identity and workspace before making any changes.

```bash
linear auth whoami
linear auth list
```

- `-w <slug>`: Target a specific workspace credential.
- `linear auth login --key "$KEY"`: Non-interactive authentication.

## Issue Lifecycle

### Read Operations
- `linear issue list --all-states --limit 100`: Exhaustive listing.
- `linear issue view ENG-123`: Detailed metadata and description.
- `linear issue comment list ENG-123`: Recent discussion context.
- `linear issue relation list ENG-123`: Dependency mapping.

### Mutation Operations
- `linear issue create --team ENG --title "Task" --start --no-interactive`: Create and start.
- `linear issue start ENG-123 --from-ref main`: Branch and mark in-progress.
- `linear issue update ENG-123 --state started --assignee self`: Reassign and status update.
- `linear issue comment add ENG-123 --body-file ./comment.md`: Threaded markdown updates.
- `linear issue attach ENG-123 ./logs.txt`: Artifact linking.

## Teams, Cycles, and Initiatives

- `linear team list`: Identity and default team discovery.
- `linear cycle list --team ENG`: Timeline and current cycle discovery.
- `linear initiative list --status active`: High-level strategic context.
- `linear initiative-update list <initiativeId>`: Progress tracking.

## Projects and Milestones

- `linear project list`: Active and planned project discovery.
- `linear project-update list <projectId>`: Recent project history.
- `linear milestone list --project <projectId>`: Roadmap detail.

## Documents and Labels

- `linear document list --project <projectId>`: Related spec/doc discovery.
- `linear document view <slug> --raw`: Clean markdown extraction for analysis.
- `linear label list`: Taxonomy discovery for issue tagging.

## Raw GraphQL and Schema

Use when high-level commands are insufficient.

```bash
linear api 'query($id:String!){ issue(id:$id){ id title } }' --variable id=ENG-123
```

- `--paginate`: Automatic cursor handling for large result sets.
- `linear schema`: Complete API reference extraction.

## VCS Context

The CLI is repository-aware.

- `linear issue id`: Confirms the current issue based on the git branch or jj trailers.
- Git: Branch name containing `ENG-123`.
- Jujutsu (jj): `Linear-issue` trailer in the current commit description.
