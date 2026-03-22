# Overview

## Preflight

Run these before write operations:

```bash
glab --version
glab auth status
glab repo view
```

If the command targets another project, always pass explicit scope:

```bash
glab <group> <command> -R group/project
```

## Auth And Context

- `glab` detects the GitLab instance from git remotes, config, or explicit host
- `GITLAB_TOKEN`, `GITLAB_ACCESS_TOKEN`, and `OAUTH_TOKEN` override stored
  credentials
- CI auto-login can use `CI_JOB_TOKEN`, but only for commands that support job
  tokens
- for self-managed instances, prefer explicit `--hostname` during auth and
  explicit `-R/--repo` during operations

## Non-Interactive Defaults

- prefer explicit flags over prompts
- prefer `--output json` where supported
- use `--stdin` for secrets and tokens
- use `--yes` only when the target and side effects are already confirmed
- validate every mutation with a follow-up read command

## Command Families

### Merge Requests

Use `glab mr` for listing, viewing, creating, updating, commenting, checking
out, rebasing, and merging MRs.

- inspect: `glab mr view <iid>`
- list: `glab mr list --output json`
- create: `glab mr create ...`
- merge safely: `glab mr merge <iid> --sha <head-sha> --yes`

### Issues And Work Items

Use `glab issue` for classic issues and `glab work-items` when the project uses
GitLab work items.

### CI/CD

Use `glab ci` for pipelines and jobs.

- list or inspect: `glab ci list`, `glab ci view <id>`
- trigger: `glab ci run ...`
- retry, cancel, trace, lint, or get status through the `ci` subcommands

### Releases

Use `glab release` to list, create, upload assets, and update releases.

### Variables

Use `glab variable` for project or group CI/CD variables. Treat these as secret
or environment-impacting writes.

### Repositories

Use `glab repo` for clone, fork, view, and other repository-scoped actions.

### API Escape Hatch

Use `glab api` when:

- the needed field is missing from a high-level subcommand
- you need pagination or explicit HTTP methods
- you need stable automation around typed fields

Preferred patterns:

```bash
glab api projects/:id/merge_requests --paginate
glab api projects/:id/issues -X POST -F title='Bug' -F description='Details'
```

## Safety Notes

- confirm whether the identifier is an IID, project ID, pipeline ID, or job ID
- for bulk changes, test one target first
- for merge operations, use `--sha` when correctness depends on the reviewed
  source HEAD remaining unchanged
