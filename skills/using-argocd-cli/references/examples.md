# Using argocd (Argo CD CLI): Examples

## Contents

- Authenticate and verify context
- List and inspect applications
- Diff before syncing
- Sync and wait for healthy state
- Sync only specific resources
- Roll back to a previous revision
- Stream application logs
- Manage repositories
- Add a cluster
- Manage projects
- CI/CD pipeline pattern

## Authenticate and Verify Context

```bash
# Interactive login
argocd login argocd.example.com --sso

# Non-interactive login for CI (using environment token)
argocd login "$ARGOCD_SERVER" \
  --auth-token "$ARGOCD_AUTH_TOKEN" \
  --grpc-web \
  --insecure

# Confirm active context before any mutation
argocd context
argocd account get-user-info
```

Always confirm context before running mutations in environments with multiple
servers.

## List and Inspect Applications

```bash
# List all applications in table format
argocd app list

# List with health and sync status visible
argocd app list -o wide

# Filter by label selector
argocd app list --selector team=platform,env=staging

# Inspect a single application
argocd app get my-app

# Get full YAML spec
argocd app get my-app -o yaml
```

## Diff before Syncing

```bash
# Show drift between Git target and live cluster state
argocd app diff my-app

# Diff against a specific revision
argocd app diff my-app --revision v2.1.0

# Diff against local files (useful before committing)
argocd app diff my-app --local ./manifests
```

Always run `diff` before syncing in production to understand the blast radius.

## Sync and Wait for Healthy State

```bash
# Basic sync
argocd app sync my-app

# Dry-run: show what would sync without applying
argocd app sync my-app --dry-run

# Sync and block until healthy (CI-safe)
argocd app sync my-app --wait

# Sync with prune (remove resources no longer in Git)
argocd app sync my-app --prune --wait

# Wait for health check separately
argocd app wait my-app --health --timeout 180
```

Use `--wait` or `argocd app wait` in CI so the pipeline fails on degraded state.

## Sync Only Specific Resources

```bash
# Sync a single Deployment
argocd app sync my-app \
  --resource apps:Deployment:my-deployment

# Sync multiple resources
argocd app sync my-app \
  --resource apps:Deployment:api \
  --resource v1:Service:api-svc
```

Useful for surgical updates without touching unrelated resources.

## Roll Back to a Previous Revision

```bash
# View deployment history
argocd app history my-app

# Roll back to history entry ID 3
argocd app rollback my-app 3

# Roll back and prune resources removed in later revisions
argocd app rollback my-app 3 --prune
```

After rollback, disable auto-sync if it would immediately re-sync forward:

```bash
argocd app set my-app --sync-policy none
```

## Stream Application Logs

```bash
# Stream all logs for the application
argocd app logs my-app --follow

# Tail last 100 lines from a specific container
argocd app logs my-app -c api --tail=100

# Logs for a specific resource within the app
argocd app logs my-app \
  --group apps --kind Deployment --name my-deployment \
  --follow
```

## Manage Repositories

```bash
# List registered repositories
argocd repo list

# Add a GitHub repo with a personal access token
argocd repo add https://github.com/org/repo \
  --username git \
  --password "$GITHUB_TOKEN"

# Add a private repo via SSH key
argocd repo add git@github.com:org/repo.git \
  --ssh-private-key-path ~/.ssh/argocd_deploy_key

# Remove a repository
argocd repo rm https://github.com/org/repo
```

## Add a Cluster

```bash
# Add the cluster from a specific kubeconfig context
argocd cluster add staging-context --name staging

# Verify cluster was registered
argocd cluster list

# Remove a cluster by server URL
argocd cluster rm https://staging.k8s.example.com
```

## Manage Projects

```bash
# Create a project with description
argocd proj create platform \
  --description "Platform team workloads"

# Allow a source repository
argocd proj add-source platform https://github.com/org/infra

# Allow deployment to a namespace in a cluster
argocd proj add-destination platform \
  https://kubernetes.default.svc platform-system

# Inspect the project
argocd proj get platform
```

## CI/CD Pipeline Pattern

```bash
#!/usr/bin/env bash
set -euo pipefail

# Authenticate non-interactively
argocd login "$ARGOCD_SERVER" \
  --auth-token "$ARGOCD_AUTH_TOKEN" \
  --grpc-web

# Confirm the app exists and is reachable
argocd app get "$APP_NAME"

# Diff to surface any unexpected drift
argocd app diff "$APP_NAME"

# Sync and wait for healthy state; pipeline fails on error
argocd app sync "$APP_NAME" --prune --wait

# Final health check with timeout
argocd app wait "$APP_NAME" --health --timeout 300
```

Store `ARGOCD_SERVER` and `ARGOCD_AUTH_TOKEN` in CI secret storage, never
in source code.
