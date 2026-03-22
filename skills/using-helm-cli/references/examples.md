# Using Helm: Examples

## Contents

- [Scaffold and trim a new chart](#scaffold-and-trim-a-new-chart)
- [Validate and render with exact values](#validate-and-render-with-exact-values)
- [Install with layered values](#install-with-layered-values)
- [Upgrade with safe rollout flags](#upgrade-with-safe-rollout-flags)
- [Inspect live release state](#inspect-live-release-state)
- [Inspect effective values](#inspect-effective-values)
- [Rollback to a prior revision](#rollback-to-a-prior-revision)
- [Resolve dependencies](#resolve-dependencies)
- [Work with OCI charts](#work-with-oci-charts)
- [Package and publish a chart](#package-and-publish-a-chart)
- [Validate against the cluster API](#validate-against-the-cluster-api)

---

## Scaffold and trim a new chart

```bash
helm create payments-api
tree payments-api
```

Then delete or simplify default templates you do not plan to support yet.

---

## Validate and render with exact values

```bash
helm lint ./payments-api
helm template payments ./payments-api -n apps \
  -f values-common.yaml \
  -f values-dev.yaml
```

Use `--debug` while developing templates:

```bash
helm template payments ./payments-api -n apps -f values-dev.yaml --debug
```

---

## Install with layered values

```bash
helm install payments ./payments-api -n apps --create-namespace \
  -f values-common.yaml \
  -f values-prod.yaml \
  --wait --atomic --timeout 10m
```

The rightmost values file wins on conflicts.

---

## Upgrade with safe rollout flags

```bash
helm upgrade payments ./payments-api -n apps \
  -f values-common.yaml \
  -f values-prod.yaml \
  --wait --atomic --timeout 10m
```

Render the same inputs before running the upgrade:

```bash
helm template payments ./payments-api -n apps \
  -f values-common.yaml \
  -f values-prod.yaml
```

---

## Inspect live release state

```bash
helm list -n apps
helm status payments -n apps
helm get manifest payments -n apps
helm history payments -n apps
```

---

## Inspect effective values

Show user-supplied values only:

```bash
helm get values payments -n apps
```

Show computed values after merges:

```bash
helm get values payments -n apps -a
```

---

## Rollback to a prior revision

```bash
helm history payments -n apps
helm rollback payments 4 -n apps --wait --timeout 10m
```

Always verify post-rollback status:

```bash
helm status payments -n apps
kubectl get pods -n apps
```

---

## Resolve dependencies

`Chart.yaml` snippet:

```yaml
dependencies:
  - name: postgresql
    version: "13.4.4"
    repository: "https://charts.bitnami.com/bitnami"
```

Resolve and lock:

```bash
helm dependency update ./payments-api
git add payments-api/Chart.yaml payments-api/Chart.lock
```

---

## Work with OCI charts

```bash
helm registry login ghcr.io
helm show chart oci://ghcr.io/acme/charts/payments-api --version 1.7.2
helm pull oci://ghcr.io/acme/charts/payments-api --version 1.7.2
helm install payments oci://ghcr.io/acme/charts/payments-api \
  --version 1.7.2 -n apps --create-namespace -f values-prod.yaml
```

---

## Package and publish a chart

```bash
helm package ./payments-api --destination ./dist
helm push ./dist/payments-api-1.7.2.tgz oci://ghcr.io/acme/charts
```

Ensure `Chart.yaml` `version` increments for each published package.

---

## Validate against the cluster API

```bash
helm template payments ./payments-api -n apps -f values-prod.yaml \
  > /tmp/payments-rendered.yaml
kubectl apply --dry-run=server -f /tmp/payments-rendered.yaml
```

This catches API validation problems before `helm upgrade`.
