# Argo CD CLI Troubleshooting

## Contents

- `argocd: command not found`
- Connection or gRPC errors
- Authentication failures
- Version skew
- App stuck or another operation in progress
- `OutOfSync` or unexpected diff
- Sync completed but app is not healthy
- Repo or cluster registration problems

## `argocd: command not found`

Install the CLI first with
[installation.md](installation.md), then verify with:

```bash
argocd version --client
```

## Connection or gRPC Errors

Typical symptoms:

- `rpc error: code = Unavailable`
- TLS handshake failures
- commands hanging during login or app inspection

Checks:

```bash
argocd context
argocd app get <app> --grpc-web
argocd app get <app> --port-forward
```

If the server is behind an ingress or proxy, `--grpc-web` is often required.
If the service is only reachable inside the cluster, `--port-forward` can be
the simplest safe path.

## Authentication Failures

Typical symptoms:

- `Unauthenticated`
- `PermissionDenied`
- expired session behavior

Checks:

```bash
argocd account get-user-info
argocd relogin
argocd context
```

For automation, confirm `ARGOCD_AUTH_TOKEN` is present and valid. For local
sessions, refresh with `argocd relogin` or `argocd login`.

## Version Skew

Typical symptoms:

- documented flags are missing
- output shape differs from expectations
- commands behave differently across environments

Check:

```bash
argocd version
```

Align the CLI version to the server version before assuming operator error.

## App Stuck or Another Operation In Progress

Checks:

```bash
argocd app get <app>
argocd app resources <app>
argocd app terminate-op <app>
```

Terminate a stale operation only after confirming that an active deployment is
not still progressing intentionally.

## `OutOfSync` or Unexpected Diff

Checks:

```bash
argocd app diff <app>
argocd app diff <app> --local ./manifests --server-side-generate
```

Remember that `argocd app diff` exits with `1` when a diff exists. That is not
the same as command failure in automation.

## Sync Completed but App Is Not Healthy

Checks:

```bash
argocd app wait <app> --health --sync --operation --timeout 300
argocd app logs <app> --follow
argocd app resources <app>
```

A successful sync request does not prove the workload became healthy. Wait on
health explicitly and inspect the degraded resource.

## Repo or Cluster Registration Problems

Checks:

```bash
argocd repo list
argocd cluster list
```

Re-check auth material, TLS options, and whether you are upserting an existing
object with a different spec.
