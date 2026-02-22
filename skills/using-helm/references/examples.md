# Using Helm: Examples

## Contents

- [Scaffold a new chart](#scaffold-a-new-chart)
- [Validate and render locally](#validate-and-render-locally)
- [Install with layered values](#install-with-layered-values)
- [Upgrade safely in place](#upgrade-safely-in-place)
- [Inspect live release state](#inspect-live-release-state)
- [Rollback to a prior revision](#rollback-to-a-prior-revision)
- [Manage dependencies](#manage-dependencies)
- [Pull and install from OCI](#pull-and-install-from-oci)
- [Package and publish a chart](#package-and-publish-a-chart)
- [Render then server-side validate](#render-then-server-side-validate)

---

## Scaffold a new chart

```bash
helm create payments-api
tree payments-api
```

Then immediately remove unused templates and default probes/ingress blocks you
do not plan to support yet.

---

## Validate and render locally

```bash
helm lint ./payments-api
helm template payments ./payments-api -n apps -f values-dev.yaml
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

Rightmost values file takes precedence (`values-prod.yaml` in this example).

---

## Upgrade safely in place

```bash
helm upgrade payments ./payments-api -n apps \
  -f values-common.yaml \
  -f values-prod.yaml \
  --wait --atomic --timeout 10m
```

Preview values merged for a release:

```bash
helm get values payments -n apps -a
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

## Manage dependencies

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

## Pull and install from OCI

```bash
helm registry login ghcr.io
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

## Render then server-side validate

```bash
helm template payments ./payments-api -n apps -f values-prod.yaml \
  > /tmp/payments-rendered.yaml
kubectl apply --dry-run=server -f /tmp/payments-rendered.yaml
```

This catches Kubernetes API validation errors before `helm upgrade`.
