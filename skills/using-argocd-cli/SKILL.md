---
name: using-argocd-cli
description: Provides expert guidance for using the argocd CLI to manage
  applications, repositories, clusters, and projects in Argo CD. Use when
  requests involve argocd login, argocd app sync, argocd app get, argocd app
  diff, argocd app rollback, argocd app wait, argocd repo add, argocd cluster
  add, argocd proj, or argocd appset commands.
---

# Using argocd (Argo CD CLI)

## Overview

The `argocd` CLI is the control surface for Argo CD — a declarative,
GitOps-based continuous delivery tool for Kubernetes. Authenticate first,
inspect before acting, and always confirm the target application and server
context before running mutations. For full procedures, read
[references/overview.md](references/overview.md).

## When to Use

- Syncing, diffing, or rolling back Argo CD applications
- Inspecting application health, sync status, and resource trees
- Managing repositories, clusters, and projects
- Creating or managing ApplicationSets
- Automating GitOps operations in CI/CD pipelines

## When Not to Use

- Argo Workflows operations — use the `argo` CLI instead
- Argo Rollouts operations — use `kubectl argo rollouts` plugin instead
- Editing raw Kubernetes resources directly — use `kubectl` instead

## Prerequisites

- `argocd` CLI installed and matching server version
- Argo CD server running and reachable
- `ARGOCD_SERVER` and `ARGOCD_AUTH_TOKEN` env vars set, or `--server` /
  `--auth-token` flags supplied, or active login session via `argocd login`
- Target application name and namespace known

## Workflow

1. Authenticate and set server context — see
   [references/overview.md](references/overview.md).
2. Inspect before acting: use `argocd app get` and `argocd app diff` first.
3. Sync with explicit app name; use `--prune` and `--force` only when certain.
4. Use `argocd app wait` in CI; never fire-and-forget sync operations.
5. On failure, inspect with `argocd app get`, `argocd app logs`, and
   `argocd app resources` before retrying.
6. For full command reference, read
   [references/examples.md](references/examples.md).
7. For failure recovery, read
   [references/troubleshooting.md](references/troubleshooting.md).

## Hard Rules

- Always confirm `argocd context` before running any mutation.
- Never run `argocd app delete` without first inspecting the app with
  `argocd app get`.
- Use `--dry-run` on sync operations when uncertain about drift scope.
- Do not store auth tokens in shell scripts; use `ARGOCD_AUTH_TOKEN` env var
  or a secret manager.
- Use `argocd app wait --health` in CI; do not poll manually.
- Match CLI version to server version; version skew causes silent failures.

## Failure Handling

- Server unreachable: verify `ARGOCD_SERVER` value and TLS settings.
- Auth denied: re-run `argocd login` or validate `ARGOCD_AUTH_TOKEN`.
- App OutOfSync: run `argocd app diff` to identify drift before syncing.
- Sync degraded: use `argocd app get` and `argocd app logs` to identify the
  failing resource.
- Version mismatch: install matching CLI from server's `/download` page.

## Red Flags

- Running `argocd app delete` without a prior `argocd app get`.
- Using `--force` on sync without understanding the resource impact.
- Ignoring `argocd app diff` output before a production sync.
- Using `--insecure` in shared or production clusters without approval.
- Syncing with `--prune` without reviewing what would be pruned.
