# Using argocd (Argo CD CLI): Troubleshooting

## Contents

- Server unreachable
- Authentication denied
- Version mismatch errors
- Application stuck in Progressing
- Application health Degraded after sync
- OutOfSync status not resolving
- Sync stuck due to an existing operation
- Prune removes unexpected resources
- Rollback immediately re-synced by auto-sync
- Repo not found or permission denied
- Cluster not reachable
- Unsafe command patterns to stop

## Server Unreachable

Symptoms:

- `dial tcp: connection refused`
- `rpc error: code = Unavailable`

Checks:

```bash
echo $ARGOCD_SERVER
curl -k https://$ARGOCD_SERVER/healthz
kubectl get svc -n argocd argocd-server
kubectl port-forward svc/argocd-server 8080:443 -n argocd
```

Fix:

- Set `ARGOCD_SERVER` to `<host>:<port>` without the `https://` prefix.
- If behind an HTTP/HTTPS ingress, add `--grpc-web` to CLI commands or set
  `ARGOCD_OPTS="--grpc-web"`.
- For local access, port-forward the `argocd-server` service and connect to
  `localhost:8080`.

## Authentication Denied

Symptoms:

- `rpc error: code = Unauthenticated`
- `401 Unauthorized`
- `permission denied`

Checks:

```bash
argocd account get-user-info
echo $ARGOCD_AUTH_TOKEN
argocd account list
```

Fix:

- Re-run `argocd login <server>` to refresh the session.
- If using a token, verify `ARGOCD_AUTH_TOKEN` is set and not expired.
- Confirm the account has the required RBAC roles for the target application
  and project in Argo CD settings.

## Version Mismatch Errors

Symptoms:

- `unknown flag` errors for documented flags
- Missing subcommands that appear in docs
- Unexpected output format or schema

Checks:

```bash
argocd version
# Compare client and server versions in the output
```

Fix:

- Download the CLI version that matches the server from the Argo CD GitHub
  releases page.
- Never mix major versions between client and server.
- Pin the CLI version in CI using a checksum-verified download.

## Application Stuck in Progressing

Symptoms:

- `argocd app get` shows `Health: Progressing` for an extended period
- Pods are not becoming Ready

Checks:

```bash
argocd app get <app-name>
argocd app resources <app-name>
argocd app logs <app-name> --follow
kubectl get pods -n <dest-namespace>
kubectl describe pod -n <dest-namespace> <pod-name>
```

Fix:

- Check pod events for image pull errors, OOMKill, or CrashLoopBackOff.
- Confirm resource requests/limits and node capacity.
- Verify image tag exists in the registry.
- If a previous sync left orphaned resources, use `argocd app terminate-op`
  then re-sync.

## Application Health Degraded after Sync

Symptoms:

- `argocd app get` shows `Health: Degraded`
- `argocd app wait --health` exits non-zero

Checks:

```bash
argocd app get <app-name> -o yaml
argocd app resources <app-name>
argocd app logs <app-name> --follow
kubectl get events -n <dest-namespace> --sort-by=.lastTimestamp
```

Fix:

- Identify the specific resource marked `Degraded` in `argocd app resources`.
- Inspect that resource directly with `kubectl describe`.
- Fix the root cause in Git, then re-sync rather than forcing healthy status.

## OutOfSync Status Not Resolving

Symptoms:

- App shows `OutOfSync` even after a successful sync
- Diff output is empty but status remains OutOfSync

Checks:

```bash
argocd app diff <app-name>
argocd app get <app-name> -o yaml | grep -A5 operationState
```

Fix:

- Server-side apply may report drift from annotation mutations. Enable
  `--server-side-apply` on the sync or configure it in the app spec.
- Ignorable fields (e.g., `kubectl.kubernetes.io/last-applied-configuration`)
  can be excluded with `ignoreDifferences` in the Application spec.
- Confirm the Git revision the app is tracking matches the target branch HEAD.

## Sync Stuck Due to an Existing Operation

Symptoms:

- `argocd app sync` returns `another operation is already in progress`

Fix:

```bash
# Terminate the stuck operation
argocd app terminate-op <app-name>

# Wait for termination to complete, then retry
argocd app sync <app-name>
```

## Prune Removes Unexpected Resources

Symptoms:

- Resources disappear from the cluster after `--prune` sync
- Resources not in Git were managed manually or by another tool

Fix:

- Always run `argocd app diff <app-name>` before syncing with `--prune`.
- Mark resources that should be retained with the annotation:
  `argocd.argoproj.io/managed-by: <app-name>` only if they are tracked by
  Argo CD, or exclude them with `ignoreDifferences` or resource exclusions.
- Use `--dry-run` to preview the effect of `--prune` before applying.

## Rollback Immediately Re-Synced by Auto-Sync

Symptoms:

- `argocd app rollback` completes but the app immediately syncs forward again

Fix:

```bash
# Disable auto-sync before rolling back
argocd app set <app-name> --sync-policy none

# Roll back to the desired history ID
argocd app rollback <app-name> <history-id>

# Re-enable auto-sync when ready to resume GitOps
argocd app set <app-name> --sync-policy automated
```

## Repo Not Found or Permission Denied

Symptoms:

- `rpc error: code = NotFound` when syncing
- `repository not found` in sync output

Checks:

```bash
argocd repo list
argocd repo get <repo-url>
```

Fix:

- Confirm the repository is registered: `argocd repo add <url> ...`.
- Verify credentials are valid and have read access to the repository.
- If using SSH, confirm the deploy key is added to the repository and the
  private key path or secret is correct.

## Cluster Not Reachable

Symptoms:

- `rpc error: code = Unknown` when syncing to a remote cluster
- Cluster shows `Unknown` status in `argocd cluster list`

Checks:

```bash
argocd cluster list
argocd cluster get <server-url>
kubectl --context <context> get nodes
```

Fix:

- Confirm the cluster API server is reachable from the Argo CD controller pod.
- Re-run `argocd cluster add <context>` to refresh the kubeconfig secret in
  the `argocd` namespace.
- Verify network policies and firewall rules allow traffic from Argo CD to the
  target cluster API.

## Unsafe Command Patterns to Stop

Stop and re-scope if any command includes:

- `argocd app delete --cascade` without first running `argocd app get` —
  this deletes all cluster resources managed by the app
- `argocd app sync --force` without reviewing the diff — force replaces
  resources even if they are unchanged and can disrupt live traffic
- `argocd app sync --prune` without `--dry-run` first — may delete resources
  not tracked in Git
- `--insecure` in shared or production clusters without explicit approval
- Storing `ARGOCD_AUTH_TOKEN` in plain text in CI environment files or
  committed scripts — use secret storage

Replace with explicit names, dry-run validation, and secrets management.
