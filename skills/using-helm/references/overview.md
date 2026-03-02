# Using Helm: Full Reference

## Contents

- [Core Concepts](#core-concepts)
- [Chart Structure](#chart-structure)
- [Values and Merge Semantics](#values-and-merge-semantics)
- [Template Best Practices](#template-best-practices)
- [Dependency Management](#dependency-management)
- [Repository and OCI Workflows](#repository-and-oci-workflows)
- [Release Lifecycle](#release-lifecycle)
- [Validation and Preflight Checks](#validation-and-preflight-checks)
- [Upgrade and Rollback Strategy](#upgrade-and-rollback-strategy)
- [Security and Secrets](#security-and-secrets)
- [Operational Guardrails](#operational-guardrails)

---

## Core Concepts

- **Chart**: Versioned package containing Kubernetes templates and defaults.
- **Release**: Installed chart instance tracked by Helm in one namespace.
- **Values**: User-provided config merged with chart defaults before render.
- **Template engine**: Go templates with Sprig functions and Helm helpers.

Use Helm as a packaging/deployment layer; keep business logic out of templates.

---

## Chart Structure

```text
my-chart/
├── Chart.yaml
├── values.yaml
├── templates/
│   ├── _helpers.tpl
│   ├── deployment.yaml
│   └── service.yaml
├── charts/                 # vendored dependency tgz files (optional)
└── Chart.lock              # resolved dependency versions
```

Key files:

- `Chart.yaml`: metadata, app/chart versions, dependencies
- `values.yaml`: safe defaults and documented knobs
- `templates/_helpers.tpl`: shared naming/labels helpers

---

## Values and Merge Semantics

Merge precedence (last wins):

1. Chart `values.yaml`
2. Parent chart values (for subcharts)
3. `-f values-a.yaml -f values-b.yaml` (rightmost wins)
4. `--set`, `--set-string`, `--set-json`, `--set-file`

Guidelines:

- Use layered values files per environment (`values-dev.yaml`, `values-prod.yaml`)
- Use `--set-string` for values that look numeric but must stay strings
- Avoid deep ad hoc `--set` usage for reproducibility

---

## Template Best Practices

- Prefer named helpers for labels/selectors to keep resources consistent
- Keep templates idempotent and deterministic
- Guard optional blocks with `with` or `if`; avoid empty map/list output
- Use `required` for mandatory user inputs that must fail fast
- Use `nindent` correctly when rendering nested YAML blocks
- Quote strings likely to contain special YAML characters

---

## Dependency Management

In `Chart.yaml`:

```yaml
dependencies:
  - name: redis
    version: "18.4.0"
    repository: "https://charts.bitnami.com/bitnami"
```

Workflow:

1. Update dependency declarations in `Chart.yaml`
2. Run `helm dependency update` to resolve and write `Chart.lock`
3. Commit both `Chart.yaml` and `Chart.lock`
4. Re-render and test charts after dependency changes

Never rely on floating versions for production charts.

---

## Repository and OCI Workflows

Classic repo:

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm search repo bitnami/nginx
```

OCI workflow:

```bash
helm registry login ghcr.io
helm pull oci://ghcr.io/acme/charts/my-app --version 1.2.3
helm push my-app-1.2.3.tgz oci://ghcr.io/acme/charts
```

Prefer OCI for immutable artifact distribution and registry policy controls.

---

## Release Lifecycle

Install:

```bash
helm install my-app ./chart -n apps --create-namespace -f values-prod.yaml \
  --wait --atomic --timeout 10m
```

Upgrade:

```bash
helm upgrade my-app ./chart -n apps -f values-prod.yaml \
  --wait --atomic --timeout 10m
```

Inspect and operate:

```bash
helm list -n apps
helm status my-app -n apps
helm get values my-app -n apps -a
helm history my-app -n apps
helm rollback my-app 3 -n apps --wait --timeout 10m
helm uninstall my-app -n apps
```

---

## Validation and Preflight Checks

Run before changing cluster state:

```bash
helm lint ./chart
helm template my-app ./chart -n apps -f values-prod.yaml > rendered.yaml
kubectl apply --dry-run=server -f rendered.yaml
```

For diffs, use a Helm diff plugin or render-and-diff workflow in CI.

---

## Upgrade and Rollback Strategy

- Treat each upgrade as a migration with explicit timeout and rollback path
- Use `--atomic` so Helm rolls back automatically on failed upgrade
- Check `helm history` before retrying repeated failures
- Avoid manual edits to live resources managed by Helm
- If hooks are used, verify hook jobs are idempotent and timeout-bounded

---

## Security and Secrets

- Keep secrets out of plain values files committed to git
- Use encrypted values workflows (for example SOPS-based pipelines)
- Prefer external secret managers and operators for runtime secret delivery
- Avoid passing secrets via plain `--set` in shell history

---

## Operational Guardrails

- Keep chart `version` and `appVersion` semantics explicit and documented
- Use one release name per app/environment/namespace tuple
- Standardize labels and selectors via helpers; never drift selectors
- Pin chart and dependency versions in production
- Validate rendered manifests against cluster API before deploy
