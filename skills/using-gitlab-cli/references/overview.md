# Overview

## Overview

Use GitLab CLI (`glab`) for GitLab operations from the terminal.

`glab` is the default tool for merge requests, issues, pipelines,
releases, and API calls.

Use non-interactive commands with explicit scope and parseable output.

## Preflight Checks

Run these before write operations:

```bash
glab auth status
glab repo view || glab repo list
```

If working outside the current repository, pass:

```bash
-R <group>/<project>
```

or:

```bash
--repo <group>/<project>
```

depending on the command.

## Non-Interactive Defaults


Prefer non-interactive commands in automation and agent workflows.

- Always pass explicit flags instead of relying on prompts.
- Prefer machine-readable output with `--output json`.
- Use `--yes` or equivalent confirmation flags only when needed.
- Confirm repo and object IDs before running mutations.

## Command Families

Load command-specific help before less common operations:

```bash
glab <group> <subcommand> --help
```

### Merge Requests (`glab mr`)

- inspect: `glab mr view <iid>`
- list: `glab mr list --state opened --output json`
- create: `glab mr create ...`
- merge: `glab mr merge <iid> --yes`
- comment: `glab mr note <iid> -m "<message>"`

### Issues (`glab issue`)

- list: `glab issue list --state opened --output json`
- create: `glab issue create ...`
- comment: `glab issue note <iid> -m "<message>"`
- close: `glab issue close <iid>`

### CI (`glab ci`)

- list pipelines/jobs view: `glab ci list`
- inspect pipeline/job: `glab ci view <id>`
- use `--output json` where supported for automation

### Releases (`glab release`)

- list: `glab release list`
- create: `glab release create <tag> --name "<title>" --notes "<notes>"`

### API (`glab api`)

- direct API query:
  `glab api projects/:id/merge_requests --paginate`
- use `-F/--field` for typed parameters
- use `-X` for explicit HTTP method when mutating

## JSON-First Output Strategy

Prefer JSON output for stable automation. Avoid parsing table output.

```bash
glab mr list --output json | jq '.[].iid'
```

Avoid parsing plain text output when JSON is available.

## Mutation Safety Rules


- Do not run destructive commands without clear user intent.
- Confirm target project before mutating issues, MRs, or releases.
- Check IDs before action: MR IID, issue IID, pipeline/job ID, release tag.
- For bulk edits, test one object first, then scale.
