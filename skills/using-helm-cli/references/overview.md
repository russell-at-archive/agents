# Using Helm: Full Reference

## Contents

- [Mental Model](#mental-model)
- [Task Routing](#task-routing)
- [Chart Structure](#chart-structure)
- [Values and Merge Rules](#values-and-merge-rules)
- [Authoring Guidance](#authoring-guidance)
- [Validation Workflow](#validation-workflow)
- [Release Operations](#release-operations)
- [Dependencies and Packaging](#dependencies-and-packaging)
- [Repositories and OCI Registries](#repositories-and-oci-registries)
- [Safety Rules](#safety-rules)

---

## Mental Model

- **Chart**: A versioned package containing metadata, defaults, and templates.
- **Release**: One installed revision history of a chart in a namespace.
- **Values**: Inputs merged into templates before Helm renders manifests.
- **Rendered manifests**: The real Kubernetes objects Helm will submit.

Use Helm to package and operate Kubernetes resources predictably. Do not reason
from template intent alone; reason from rendered manifests and release state.

---

## Task Routing

Choose commands by task:

- Author or inspect chart structure: `helm show`, file edits, `helm lint`
- Preview manifests: `helm template`
- Install first release: `helm install`
- Update existing release: `helm upgrade`
- Inspect current or past release state: `helm status`, `helm get`, `helm history`
- Revert a bad revision: `helm rollback`
- Resolve chart dependencies: `helm dependency update`
- Package or publish a chart: `helm package`, `helm push`, `helm pull`

Do not default to `helm upgrade --install` unless the ambiguity is acceptable
for the specific workflow.

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
├── charts/                # fetched dependency packages
└── Chart.lock             # resolved dependency versions
```

- `Chart.yaml`: metadata, app/chart versions, dependencies
- `values.yaml`: safe defaults and documented knobs
- `templates/_helpers.tpl`: shared names, labels, and helper snippets
- `Chart.lock`: lock the exact dependency resolution that was tested

---

## Values and Merge Rules

Merge order is deterministic; later inputs win:

1. Chart `values.yaml`
2. Parent chart values (for subcharts)
3. `-f values-a.yaml -f values-b.yaml`
4. `--set`, `--set-string`, `--set-json`, `--set-file`

Use these rules deliberately:

- Keep environment overlays in files such as `values-dev.yaml` and
  `values-prod.yaml`
- Use `--set-string` for values that must stay strings
- Use `--set-file` for generated file payloads, not for normal configuration
- Avoid large `--set` chains; they are hard to review and easy to misquote
- Verify the effective values of a live release with `helm get values -a`

---

## Authoring Guidance

- Prefer helpers for names, labels, and selector fragments
- Keep selectors stable across revisions; changing selectors often breaks
  upgrades
- Guard optional values with `with`, `if`, `default`, or `required`
- Use `toYaml` and `nindent` carefully to avoid malformed YAML
- Keep templates deterministic; avoid hidden randomness or time dependence
- Keep business logic out of templates when possible

---

## Validation Workflow

Run before changing cluster state:

```bash
helm lint ./chart
helm template my-app ./chart -n apps -f values-prod.yaml > rendered.yaml
kubectl apply --dry-run=server -f rendered.yaml
```

Recommended order:

1. Lint chart structure and template syntax with `helm lint`
2. Render the exact deployment inputs with `helm template`
3. If a cluster is available, validate against the API with server-side dry run
4. Only then run `helm install` or `helm upgrade`

If a diff is needed, use the existing project workflow or a render-and-diff
approach. Do not assume a Helm plugin is installed.

---

## Release Operations

Typical safe release commands:

```bash
helm install my-app ./chart -n apps --create-namespace -f values-prod.yaml \
  --wait --atomic --timeout 10m

helm upgrade my-app ./chart -n apps -f values-prod.yaml \
  --wait --atomic --timeout 10m

helm status my-app -n apps
helm get values my-app -n apps -a
helm get manifest my-app -n apps
helm history my-app -n apps
helm rollback my-app 3 -n apps --wait --timeout 10m
```

Operational guidance:

- Treat every upgrade as a migration with a rollback plan
- Use explicit namespace and timeout flags
- Inspect `history` before retrying repeated failures
- Check hook behavior when upgrades hang or partially fail
- Avoid manual edits to Helm-managed resources unless doing explicit recovery

---

## Dependencies and Packaging

Dependency workflow:

1. Edit dependency declarations in `Chart.yaml`
2. Run `helm dependency update ./chart`
3. Review and commit both `Chart.yaml` and `Chart.lock`
4. Re-run lint and render after dependency changes

Packaging workflow:

```bash
helm package ./chart --destination ./dist
helm pull oci://registry.example.com/charts/my-app --version 1.2.3
helm push ./dist/my-app-1.2.3.tgz oci://registry.example.com/charts
```

Pin versions. Do not treat dependency upgrades as harmless maintenance.

---

## Repositories and OCI Registries

Repository workflow:

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm search repo bitnami/nginx
```

OCI workflow:

```bash
helm registry login ghcr.io
helm pull oci://ghcr.io/acme/charts/my-app --version 1.2.3
helm show chart oci://ghcr.io/acme/charts/my-app --version 1.2.3
```

Use repo or OCI commands that match the artifact source the user is actually
using. Do not mix the two models casually.

---

## Safety Rules

- Keep chart `version` and `appVersion` intentional and documented
- Use one release name per app, environment, and namespace tuple
- Keep secrets out of plain git-tracked values files
- Prefer external secret delivery or encrypted values workflows
- Validate the rendered output before mutating the cluster
