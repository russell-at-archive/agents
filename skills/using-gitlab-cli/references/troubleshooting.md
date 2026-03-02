# Troubleshooting

## Red Flags


Stop and correct if any of these appear:

- Interactive prompts in automation context
- Mutations without explicit project confirmation
- Wrong object type or ID (issue vs MR IID, job vs pipeline ID)
- Parsing table output when JSON output exists

## Common Failures and Fixes

### Authentication failures

Symptoms:

- `401 Unauthorized`
- `authentication required`

Fix:

```bash
glab auth status
glab auth login --hostname gitlab.com
```

If token-based auth is required, re-run with a valid token input path.

### Wrong repository scope

Symptoms:

- command succeeds but data is from a different project
- `404 Not Found` for known objects

Fix:

```bash
glab repo view
glab mr list -R <group>/<project> --state opened --output json
```

Use `-R/--repo` explicitly for all follow-up writes.

### Permission denied on write operations

Symptoms:

- `403 Forbidden`
- cannot merge, close, or create resources

Fix:

- Verify GitLab role for target project/group.
- Confirm branch protection and merge permissions.
- Fall back to read-only commands and report the blocked action.

### CI inspection confusion

Symptoms:

- wrong ID passed to `glab ci view`
- command output does not match intended pipeline/job

Fix:

```bash
glab ci list
glab ci view <id>
```

Select the ID directly from the list output before rerunning.

### API request shape errors

Symptoms:

- `400 Bad Request`
- missing required parameters

Fix:

- Add explicit method with `-X`.
- Pass typed fields with `-F` instead of string concatenation.
- Use `--paginate` for complete list retrieval.

## Recovery Pattern

1. Reproduce with a read-only command first.
2. Confirm auth and repository scope.
3. Re-run with explicit flags and JSON output if supported.
4. Verify the result with a second read command.
5. Report exact command, error text, and next action.
