---
name: writing-github-actions
description: Produces correct, secure, and maintainable GitHub Actions workflow
  and action YAML files. Use when the user asks about GitHub Actions, workflow
  files, .github/workflows, on triggers, jobs, steps, matrix strategy, reusable
  workflows, composite actions, secrets, OIDC, caching, artifacts, or CI/CD
  pipeline configuration for GitHub repositories.
---

# Writing GitHub Actions

## Overview

GitHub Actions automates software workflows via YAML files in `.github/workflows/`.
Workflows respond to events (triggers), run jobs on runners, and execute steps
sequentially within each job. For the full YAML schema and context reference,
read [references/overview.md](references/overview.md). For concrete patterns,
read [references/examples.md](references/examples.md).

## When to Use

- Writing or editing `.github/workflows/*.yml` files
- Writing reusable workflows (`workflow_call`)
- Writing composite actions (`action.yml`)
- Configuring triggers: `push`, `pull_request`, `schedule`, `workflow_dispatch`
- Setting up matrix builds, caching, artifacts, environments, and deployments
- Implementing OIDC-based cloud authentication (AWS, GCP, Azure)
- Debugging failed workflows and fixing common Action errors
- Reviewing workflows for security issues (script injection, excess permissions)

## When Not to Use

- GitLab CI/CD (`.gitlab-ci.yml`) — use the `using-gitlab-cli` skill instead
- General shell scripting unrelated to Actions — use `writing-bash-scripts`
- Managing GitHub repos/PRs/issues via CLI — use `using-github-cli`

## Prerequisites

- Repository hosted on GitHub
- Workflow files placed in `.github/workflows/` (or `action.yml` in repo root
  for custom actions)
- Secrets and variables configured in repository or organization settings

## Workflow

1. Read any existing workflow files to understand the current pipeline structure.
2. Identify the trigger events and the runner OS required.
3. Write the workflow YAML following [references/overview.md](references/overview.md).
4. Pin all third-party actions to a full commit SHA, not a mutable tag.
5. Set minimum `permissions` at the workflow or job level.
6. Validate with `actionlint` if available; otherwise review manually against
   the schema in [references/overview.md](references/overview.md).
7. For troubleshooting, see [references/troubleshooting.md](references/troubleshooting.md).

## Hard Rules

- **Pin third-party actions to commit SHA.** Tags are mutable and can be
  rewritten to point to malicious code. Use `@<SHA>  # v3.x.x` with a comment.
- **Set minimum permissions.** Default to `contents: read`. Never use
  `permissions: write-all` without explicit justification.
- **Never interpolate secrets into `run:` strings.** Pass secrets via `env:`
  and reference the env var in the shell script — never `${{ secrets.FOO }}`.
- **Use `environment:` for production deployments** to enforce approval gates.
- **Do not hard-code tokens.** Use `secrets.GITHUB_TOKEN` or OIDC federation.
- **Validate `workflow_dispatch` inputs.** Always set `type` and constraints.

## Failure Handling

- Workflow not triggering: check trigger syntax and branch filters; see
  [references/troubleshooting.md](references/troubleshooting.md).
- `Process completed with exit code 1`: inspect step logs; add
  `set -euo pipefail` and `echo` debug statements to the `run:` block.
- Expression errors (`${{ }}`): verify context availability at that job/step
  scope; check quoting rules in [references/overview.md](references/overview.md).
- OIDC auth failures: verify `permissions: id-token: write` and trust policy.

## Red Flags

- Third-party action pinned to a tag (`uses: owner/action@v4`) not a commit SHA
- `permissions: write-all` or no `permissions` block at workflow level
- Secret value interpolated directly in `run:` string via `${{ secrets.X }}`
- `continue-on-error: true` without a documented reason
- No `timeout-minutes` on long-running jobs
- `workflow_dispatch` inputs without `type` constraints
- Self-hosted runner used for untrusted fork PRs
