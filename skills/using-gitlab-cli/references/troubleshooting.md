# Troubleshooting

## Common Failures

### Wrong Instance Or Repo

Symptoms:

- `404 Not Found` for a known object
- command succeeds against the wrong project

Checks:

```bash
glab auth status
glab repo view
glab mr list -R group/project --output json
```

Fix:

- pass `-R/--repo` explicitly on follow-up commands
- re-auth against the correct hostname if the wrong instance is selected

### Authentication Or Token Scope

Symptoms:

- `401 Unauthorized`
- `403 Forbidden`
- prompts to log in despite existing config

Checks:

```bash
glab auth status --all
env | rg '^(GITLAB|GLAB|OAUTH|CI_)'
```

Fix:

- remember that `GITLAB_TOKEN`, `GITLAB_ACCESS_TOKEN`, and `OAUTH_TOKEN`
  override stored credentials
- for PAT login, prefer `glab auth login --stdin`
- for CI jobs, confirm the command supports `CI_JOB_TOKEN`

### Interactive Prompt Dead-End

Symptoms:

- command hangs waiting for editor, browser, or prompt input

Fix:

- add explicit flags such as `--title`, `--description`, `--yes`, `--web=false`
  where supported
- set `NO_PROMPT=true` in automation if needed

### CI Object Confusion

Symptoms:

- wrong result from `glab ci view`
- job ID used where a pipeline ID was expected

Fix:

```bash
glab ci list
glab ci view <id>
glab ci trace <id>
```

Re-select the ID from the list before retrying writes.

### API Shape Errors

Symptoms:

- `400 Bad Request`
- missing field or invalid method

Fix:

- add explicit `-X GET|POST|PUT|DELETE`
- prefer `-F` fields over hand-built query strings
- add `--paginate` for complete list retrieval

## Recovery Pattern

1. Reproduce with a read-only command.
2. Confirm host, auth source, and repo scope.
3. Re-run with explicit flags and structured output.
4. Verify the resource state after the command.
5. Report the exact failure and next corrective action.
