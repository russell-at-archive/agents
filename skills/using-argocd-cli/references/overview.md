# Argo CD CLI Overview

Use `argocd` as the API-facing control plane for Argo CD. The default posture is
to scope first, inspect second, mutate third, and verify last.

## Contents

- Core operating model
- Authentication patterns
- High-signal parent flags
- Application commands that matter most
- Admin commands
- Decision heuristics

## Core Operating Model

1. Confirm target server and context.
2. Inspect current state.
3. Show intended change.
4. Apply the change explicitly.
5. Wait for the result and inspect failures.

This sequence usually maps to:

```bash
argocd context
argocd app get <app>
argocd app diff <app>
argocd app sync <app>
argocd app wait <app> --health --sync --operation --timeout 300
```

## Authentication Patterns

- Interactive login:

```bash
argocd login cd.example.com
argocd login cd.example.com --sso
```

- Non-interactive auth:

```bash
export ARGOCD_SERVER=cd.example.com
export ARGOCD_AUTH_TOKEN=<token>
argocd app get my-app --server "$ARGOCD_SERVER" --auth-token "$ARGOCD_AUTH_TOKEN"
```

- Direct Kubernetes API access instead of the Argo CD API server:

```bash
argocd login cd.example.com --core
```

## High-Signal Parent Flags

- `--argocd-context`: pin a saved Argo CD context
- `--grpc-web`: use when proxies or ingress break native gRPC
- `--port-forward`: connect by port-forwarding to `argocd-server`
- `--core`: talk to Kubernetes directly instead of the Argo CD API server
- `--prompts-enabled`: explicitly control interactive prompts in automation

## Application Commands That Matter Most

- Inspect:

```bash
argocd app list
argocd app get <app> -o yaml
argocd app history <app>
argocd app resources <app>
argocd app logs <app> --follow
```

- Diff:

```bash
argocd app diff <app>
argocd app diff <app> --revision <git-ref>
argocd app diff <app> --local ./manifests --server-side-generate
```

`argocd app diff` returns `1` when a diff exists, `0` when none exists, and
`2` on general errors. It honors `KUBECTL_EXTERNAL_DIFF`.

- Sync and wait:

```bash
argocd app sync <app>
argocd app sync <app> --apply-out-of-sync-only
argocd app sync <app> --resource apps:Deployment:api
argocd app wait <app> --health --sync --operation --timeout 300
```

- Recovery:

```bash
argocd app rollback <app> <history-id>
argocd app terminate-op <app>
```

## Admin Commands

- Repositories:

```bash
argocd repo list
argocd repo add <repo-url> ...
argocd repo get <repo-url>
```

- Clusters:

```bash
argocd cluster list
argocd cluster add <kube-context>
argocd cluster get <cluster>
```

- Projects:

```bash
argocd proj create <project> --src <repo> --dest <server>,<namespace>
argocd proj get <project>
```

- ApplicationSets:

```bash
argocd appset create appset.yaml --dry-run -o json
argocd appset create appset.yaml --upsert
```

## Decision Heuristics

- Use `app diff` before `app sync` unless the user is intentionally forcing a
  reconciliation with understood risk.
- Use `app wait` in CI. Do not treat a completed `sync` request as success on
  its own.
- Prefer selective sync or `--apply-out-of-sync-only` over broad force when the
  target change is narrow.
- For repo and cluster registration, inspect existing state before upserting.
