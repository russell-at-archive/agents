# Argo CD CLI Examples

## Login and Context

```bash
argocd login cd.example.com --sso
argocd context
argocd context team-staging
```

If the server is behind an ingress that does not support HTTP/2 cleanly, add
`--grpc-web`.

## Safe Application Reconcile

```bash
argocd app get payments
argocd app diff payments
argocd app sync payments --apply-out-of-sync-only
argocd app wait payments --health --sync --operation --timeout 300
```

## CI-Safe Sync

```bash
export ARGOCD_SERVER=cd.example.com
export ARGOCD_AUTH_TOKEN=<token>

argocd app get payments --server "$ARGOCD_SERVER" --auth-token "$ARGOCD_AUTH_TOKEN"
argocd app sync payments --server "$ARGOCD_SERVER" --auth-token "$ARGOCD_AUTH_TOKEN"
argocd app wait payments \
  --server "$ARGOCD_SERVER" \
  --auth-token "$ARGOCD_AUTH_TOKEN" \
  --health --sync --operation --timeout 300
```

## Diff Against Local Manifests

```bash
argocd app diff payments --local ./manifests --server-side-generate
```

Use this before committing when you want the server to render the same sources
Argo CD would render.

## Selective Sync

```bash
argocd app sync payments --resource apps:Deployment:payments-api
argocd app sync payments --resource :Service:payments
```

## Roll Back After Inspecting History

```bash
argocd app history payments
argocd app rollback payments 7
argocd app wait payments --health --sync --operation --timeout 300
```

If auto-sync would immediately move the app forward again, disable it first with
`argocd app set payments --sync-policy none`.

## Add a Private Git Repository

```bash
argocd repo add git@github.com:org/private-config.git \
  --ssh-private-key-path ~/.ssh/argocd_repo_key
```

For HTTPS repos, use the appropriate auth flags rather than embedding secrets in
shell history.

## Register a Cluster

```bash
argocd cluster add my-kube-context --name staging
argocd cluster list
```

`cluster add` operates on a kubeconfig context, not an Argo CD app name.

## Create a Project With Guardrails

```bash
argocd proj create payments \
  --src https://github.com/org/payments-config.git \
  --dest https://kubernetes.default.svc,payments
argocd proj get payments
```

## Preview an ApplicationSet

```bash
argocd appset create appset.yaml --dry-run -o json
argocd appset create appset.yaml --upsert
```
