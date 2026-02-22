---
name: using-gitlab-cli
description: Use when instructed to run GitLab CLI (`glab`) commands for merge
  request operations, issue management, pipeline runs, releases, repository
  settings, or GitLab API queries. Invoke before running any glab command.
---

# Using GitLab CLI (glab)

## Overview

Use GitLab CLI (`glab`) for GitLab operations from the terminal.

`glab` is the default tool for merge requests, issues, pipelines,
releases, and API calls.

## Setup and Context

Before running write operations, confirm auth and target project context.

```bash
glab auth status
glab repo view
```

If working outside the current repository, pass `--repo <group>/<project>`
when supported by the subcommand.

## Non-Interactive Defaults

Prefer non-interactive commands in automation and agent workflows.

- Always pass explicit flags instead of relying on prompts.
- Prefer machine-readable output with `--output json` and `jq`.
- Use `--yes` or equivalent confirmation flags only when needed.

## Common Commands

### Merge Requests

```bash
# View MR details
glab mr view <number>

# List open MRs
glab mr list --state opened

# Add a comment
glab mr note <number> --message "<comment>"

# Merge when policy allows
glab mr merge <number> --yes
```

### Issues

```bash
# List open issues
glab issue list --state opened

# Create issue
glab issue create --title "<title>" --description "<body>"

# Add issue comment
glab issue note <number> --message "<comment>"

# Close issue
glab issue close <number>
```

### Pipelines and CI

```bash
# List recent pipelines
glab pipeline list

# View pipeline details
glab pipeline view <pipeline-id>

# Retry failed pipeline
glab pipeline retry <pipeline-id>
```

### Releases

```bash
# List releases
glab release list

# Create release
glab release create <tag> --name "<title>" --notes "<notes>"
```

### API Access

```bash
# Query GitLab API directly
glab api projects/<project-id>/merge_requests
```

## Output and Parsing

Prefer JSON output for stable automation.

```bash
glab mr list --output json | jq '.[].iid'
```

Avoid parsing plain text output when JSON is available.

## Safety Rules

- Do not run destructive commands without clear user intent.
- Confirm target project before mutating issues, MRs, or releases.
- For bulk edits, test one object first, then scale.

## Red Flags

Stop and correct if any of these appear:

- Running interactive `glab` prompts in automation context
- Mutating resources without explicit project targeting
- Parsing human text output when JSON output is available

## Common Mistakes

- **Missing auth check**: Run `glab auth status` before write operations.
- **Wrong project**: Set project context or pass explicit repo/project flags.
- **Prompt-driven commands**: Replace prompts with explicit flags.
- **Fragile parsing**: Use JSON output and `jq` instead of text scraping.
