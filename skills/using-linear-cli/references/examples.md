# Using Linear CLI: Examples

## Bootstrap A Repo

```bash
linear auth login --key "$LINEAR_API_KEY"
linear config
```

## Triage Assigned Work

```bash
linear issue list --mine --all-states --limit 100
linear issue view ENG-123
linear issue comment list ENG-123
```

## Start Work on a Specific Issue

```bash
linear issue start ENG-123 --from-ref main
linear issue view ENG-123
```

## Create A Rich Markdown Issue

```bash
cat >/tmp/issue.md <<'EOF'
# Problem
Masked upstream timeouts cause flakiness.

# Acceptance Criteria
- Expose timeout in logs
- Add regression coverage
EOF

linear issue create \
  --team ENG \
  --title "Expose timeout" \
  --description-file /tmp/issue.md \
  --start \
  --no-interactive
```

## Update and Attach Logs

```bash
linear issue update ENG-123 --state started --assignee self
linear issue attach ENG-123 ./reproduction_logs.txt
```

## Threaded Comments

```bash
linear issue comment list ENG-123
linear issue comment add ENG-123 --body "Initial analysis"
linear issue comment add ENG-123 --parent <commentId> --body "Replying with fix info"
```

## Multi-Workspace Targeting

```bash
linear auth list
linear issue list -w personal
linear issue list -w work --team ENG
```
