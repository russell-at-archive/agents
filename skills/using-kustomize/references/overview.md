# Using Kustomize: Full Reference

## Contents

- [Core Concepts](#core-concepts)
- [kustomization.yaml Schema](#kustomizationyaml-schema)
- [Resources, Bases, and Components](#resources-bases-and-components)
- [Patch Types](#patch-types)
- [Generators](#generators)
- [Transformers](#transformers)
- [Replacements](#replacements)
- [Components](#components)
- [Helm Chart Integration](#helm-chart-integration)
- [Directory Structure Patterns](#directory-structure-patterns)
- [CLI Commands](#cli-commands)
- [Plugin System](#plugin-system)
- [GitOps and CI/CD Patterns](#gitops-and-cicd-patterns)
- [Kustomize vs Helm](#kustomize-vs-helm)

---

## Core Concepts

Kustomize is **template-free, declarative Kubernetes configuration management**.
Every file it reads or writes is valid Kubernetes YAML. It works by:

1. Reading a `kustomization.yaml` (the "root") which declares resources,
   patches, and transformers.
2. Recursively loading all referenced resources and sub-kustomizations.
3. Applying patches and transformers in memory.
4. Emitting the final YAML to stdout.

The base is never modified. Overlays sit on top and express only the delta.

**Two integration paths:**
- `kustomize build <dir>` — standalone binary (latest version)
- `kubectl apply -k <dir>` — embedded in kubectl (lags by 1–2 releases)

---

## kustomization.yaml Schema

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
```

### Operand Fields

```yaml
# Primary way to include resources: files, directories, or URLs
resources:
- deployment.yaml
- service.yaml
- ../base                                    # local sub-kustomization
- github.com/org/app//config?ref=v2.1.0      # remote (pinned ref required)

# Reusable partial kustomizations (kind: Component)
components:
- ../../components/monitoring
- ../../components/ingress

# CRD schemas so name-reference transformers understand custom resources
crds:
- crds/my-custom-resource.yaml

# DEPRECATED — move entries to resources:
bases:
- ../base
```

### Transformer Fields

```yaml
# Safe label addition (does NOT touch selectors by default)
labels:
- pairs:
    app.kubernetes.io/part-of: my-platform
  includeSelectors: false   # do not modify matchLabels (default)
  includeTemplates: false   # do not modify pod template labels (default)

# UNSAFE on live resources — also modifies immutable matchLabels selectors
commonLabels:
  app: my-app

commonAnnotations:
  team: platform-engineering

# Sets/overrides metadata.namespace on all namespace-scoped resources
namespace: my-namespace

# Prepended/appended to metadata.name and all internal cross-references
namePrefix: "prod-"
nameSuffix: "-v2"

# Modify container image references across all resources
images:
- name: nginx
  newTag: "1.25.3"
- name: gcr.io/my-project/api
  newName: registry.company.com/api
  newTag: "v2.1.0"
- name: gcr.io/my-project/worker
  digest: sha256:24a0c4b4a4...   # immutable pin

# Set replica counts by resource name
replicas:
- name: my-deployment
  count: 5

# Unified patch field (preferred)
patches:
- path: patches/my-patch.yaml
  target:
    kind: Deployment
    name: my-app
- patch: |-
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: my-app
    spec:
      replicas: 3

# DEPRECATED — use patches:
patchesStrategicMerge:
- increase-replicas.yaml

# DEPRECATED — use patches:
patchesJson6902:
- target:
    group: apps
    version: v1
    kind: Deployment
    name: my-app
  path: replica-patch.yaml

# Modern cross-resource value propagation (replaces vars:)
replacements:
- source:
    kind: Secret
    name: db-secret
    fieldPath: metadata.name
  targets:
  - select:
      kind: Deployment
      name: my-app
    fieldPaths:
    - spec.template.spec.containers.[name=app].env.[name=DB_SECRET].valueFrom.secretKeyRef.name

# DEPRECATED — use replacements:
vars:
- name: MY_SERVICE_NAME
  objref:
    kind: Service
    name: my-service
    apiVersion: v1
```

### Generator Fields

```yaml
configMapGenerator:
- name: app-config
  files:
  - config/app.properties
  - logback.xml=config/logging.xml   # key=filepath renames the key
  literals:
  - ENV=production
  - LOG_LEVEL=warn
  envs:
  - config/.env.production
  behavior: create                   # create | merge | replace
  options:
    disableNameSuffixHash: false     # keep hash (default) for rolling updates
    labels:
      generated-by: kustomize

secretGenerator:
- name: tls-secret
  type: kubernetes.io/tls
  files:
  - tls.crt=certs/server.crt
  - tls.key=certs/server.key
- name: db-credentials
  type: Opaque
  literals:
  - username=admin
  - password=s3cr3t

# Controls all generators in this file
generatorOptions:
  disableNameSuffixHash: false
  labels:
    managed-by: kustomize
  annotations:
    config.kubernetes.io/managed: "true"
  immutable: false
```

### Helm Fields

```yaml
helmCharts:
- name: prometheus
  repo: https://prometheus-community.github.io/helm-charts
  version: "25.8.0"
  releaseName: prometheus
  namespace: monitoring
  valuesFile: prometheus-values.yaml
  valuesInline:
    alertmanager:
      enabled: false
  valuesMerge: override    # merge | override | replace
  includeCRDs: true
  skipTests: true

helmGlobals:
  chartHome: ./charts      # local directory for pre-downloaded charts
```

### Build and Plugin Fields

```yaml
# Provenance annotations on output resources
buildMetadata:
- managedByLabel
- originAnnotations

# Output ordering: legacy (priority-based) or fifo (declaration order)
sortOptions:
  order: legacy

# KRM function generators and transformers
generators:
- my-generator-config.yaml
transformers:
- my-transformer-config.yaml
validators:
- my-validator-config.yaml

# Customize built-in transformer behavior (name references, merge keys)
configurations:
- transformer-config.yaml
```

---

## Resources, Bases, and Components

### `resources` — Primary inclusion mechanism

```yaml
resources:
- deployment.yaml                              # single file
- service.yaml
- ../base                                      # local kustomization dir
- ./subapp                                     # local kustomization dir
- github.com/org/repo//path?ref=v1.0.0         # remote kustomization
- https://raw.githubusercontent.com/.../file.yaml  # raw remote file
```

Always pin remote refs. `?ref=main` is a floating pointer.

### `components` — Opt-in reusable bundles

See [Components section](#components). Unlike `resources`, components use
`apiVersion: kustomize.config.k8s.io/v1alpha1` and `kind: Component`.

---

## Patch Types

### Strategic Merge Patch

Matches Kubernetes's native merge strategy (uses merge keys like container
`name`). Specify a partial object YAML; Kustomize merges it into the matching
resource.

**Inline:**
```yaml
patches:
- patch: |-
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: my-app
    spec:
      template:
        spec:
          containers:
          - name: app
            resources:
              limits:
                cpu: "500m"
                memory: "512Mi"
```

**File + target selector:**
```yaml
patches:
- path: patches/resource-limits.yaml
  target:
    kind: Deployment
    name: my-app
```

**Target selector fields:** `group`, `version`, `kind`, `name`, `namespace`,
`labelSelector`, `annotationSelector`. `name` is a regex pattern anchored at
start/end.

**Delete a list item** with the strategic merge directive:
```yaml
spec:
  template:
    spec:
      containers:
      - name: sidecar
        $patch: delete
```

### JSON 6902 Patch

RFC 6902 operation list. More precise than strategic merge; required for CRDs
that lack strategic merge key annotations.

**Operations:** `add`, `replace`, `remove`, `copy`, `move`, `test`

**Inline:**
```yaml
patches:
- patch: |-
    - op: replace
      path: /spec/replicas
      value: 5
    - op: add
      path: /spec/template/spec/containers/0/env/-
      value:
        name: LOG_LEVEL
        value: debug
    - op: remove
      path: /spec/template/spec/containers/1
  target:
    kind: Deployment
    name: my-app
```

**Strategic merge vs JSON 6902:**

| | Strategic Merge | JSON 6902 |
|---|---|---|
| Syntax | Partial object YAML | Operation list |
| Container list matching | By `name` key (smart) | By array index |
| CRD support | Needs `openapi` config | Works natively |
| Delete item | `$patch: delete` | `remove` op |
| Best for | Most changes | Precise path edits, CRDs |

---

## Generators

### configMapGenerator

Produces a ConfigMap. By default appends a content hash suffix to the name
and propagates the new name to all Deployment/StatefulSet volume and env refs —
ensuring rolling updates when config changes.

```yaml
configMapGenerator:
- name: app-config
  namespace: my-app
  literals:
  - KEY=value
  files:
  - config.properties                 # key = filename
  - custom-key=path/to/file.conf      # key = custom-key
  envs:
  - .env.production                   # key=value per line
  behavior: create                    # create | merge | replace
  options:
    disableNameSuffixHash: true       # stable name (disables rolling update benefit)
```

### secretGenerator

Same as configMapGenerator, plus `type` field. Values are base64-encoded
automatically.

```yaml
secretGenerator:
- name: tls-cert
  type: kubernetes.io/tls
  files:
  - tls.crt
  - tls.key
- name: registry-secret
  type: kubernetes.io/dockerconfigjson
  files:
  - .dockerconfigjson=docker-config.json
```

**Never store real credentials as `literals` in git.** Use:
- External Secrets Operator (pulls from AWS SM, GCP SM, Vault, etc.)
- Sealed Secrets (encrypt before commit)
- SOPS (encrypt YAML values)

---

## Transformers

### `images` — Image name/tag management

```yaml
images:
- name: nginx                         # matches image name anywhere in resources
  newTag: "1.25.3"
- name: gcr.io/my-project/api
  newName: registry.internal/api      # change registry/name
  newTag: "v2.1.0"
- name: gcr.io/my-project/worker
  digest: sha256:abc123...            # fully immutable — overrides newTag
```

**CI/CD image update:**
```bash
kustomize edit set image gcr.io/my-project/api:${GIT_SHA}
git commit -am "chore: deploy ${GIT_SHA}"
```

### `replicas`

```yaml
replicas:
- name: my-deployment    # matches metadata.name
  count: 10
```

Applies to: Deployment, ReplicationController, ReplicaSet, StatefulSet, HPA.

### `namePrefix` / `nameSuffix`

Propagates through all internal cross-references (ConfigMap volumes, Secret
mounts, ServiceAccount refs, etc.).

```yaml
namePrefix: "prod-"
nameSuffix: "-us-east-1"
```

### `namespace`

```yaml
namespace: production
```

Only sets namespace-scoped resources. Cluster-scoped resources (ClusterRole,
Namespace itself) are not modified.

### `labels` (preferred over `commonLabels`)

```yaml
labels:
- pairs:
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/part-of: my-platform
  includeSelectors: false    # safe default — don't touch matchLabels
  includeTemplates: true     # also add to pod template metadata
```

**Do not use `commonLabels` on live resources** — it mutates `spec.selector`
which is immutable after creation on Deployments and StatefulSets.

---

## Replacements

Copies a value from one resource field into one or more target fields.
Replaces deprecated `vars`.

```yaml
replacements:
- source:
    kind: ConfigMap
    name: cluster-config
    fieldPath: data.CLUSTER_NAME
  targets:
  - select:
      kind: Deployment
    fieldPaths:
    - spec.template.spec.containers.[name=app].env.[name=CLUSTER].value

- source:
    kind: Secret
    name: db-secret
    fieldPath: metadata.name    # default fieldPath
  targets:
  - select:
      kind: Deployment
      name: my-app
    fieldPaths:
    - spec.template.spec.containers.[name=app].env.[name=DB_SECRET_NAME].valueFrom.secretKeyRef.name
    reject:
    - name: excluded-deployment   # skip this resource

- sourceValue: "production"       # inline scalar source (no resource lookup)
  targets:
  - select:
      kind: ConfigMap
      name: app-config
    fieldPaths:
    - data.ENVIRONMENT
```

**Path syntax:**
- Dot notation: `spec.template.spec.containers.[name=app].image`
- Array index: `spec.containers.0.image`
- Wildcard: `spec.containers.*.image`
- Escaped dots: `metadata.annotations.[app\.kubernetes\.io/name]`

---

## Components

`kind: Component` — reusable, opt-in configuration bundles. Unlike bases,
components are only included when explicitly listed in `components:`.

```yaml
# components/monitoring/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1alpha1
kind: Component

resources:
- servicemonitor.yaml

patches:
- patch: |-
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: placeholder
    spec:
      template:
        metadata:
          annotations:
            prometheus.io/scrape: "true"
            prometheus.io/port: "8080"
  target:
    kind: Deployment
```

```yaml
# overlays/prod/kustomization.yaml
resources:
- ../../base
components:
- ../../components/monitoring      # opt-in
- ../../components/ingress         # opt-in
```

**Use components for:** monitoring integration, LDAP/auth, TLS configuration,
resource limits policies, per-cloud annotations — anything that some overlays
need and others don't.

---

## Helm Chart Integration

Requires `kustomize build --enable-helm` (standalone) or
`kustomize.buildOptions: --enable-helm` in ArgoCD's `argocd-cm`.

```yaml
helmCharts:
- name: cert-manager
  repo: https://charts.jetstack.io
  version: "v1.14.2"
  releaseName: cert-manager
  namespace: cert-manager
  valuesFile: values/cert-manager.yaml
  valuesInline:
    installCRDs: true
  includeCRDs: true

helmGlobals:
  chartHome: ./charts    # pre-downloaded charts go here

# Post-render patching — apply org standards after Helm renders
patches:
- patch: |-
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: cert-manager
    spec:
      template:
        spec:
          tolerations:
          - key: CriticalAddonsOnly
            operator: Exists
  target:
    kind: Deployment
    name: cert-manager
```

**Pre-download for air-gapped environments:**
```bash
helm pull prometheus-community/prometheus --version 25.8.0 --untar --untardir charts/
```
Then reference with `repo:` omitted — Kustomize looks in `chartHome`.

---

## Directory Structure Patterns

### Pattern A: Base + Overlays (most common)

```
app/
├── base/
│   ├── kustomization.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   └── configmap.yaml
└── overlays/
    ├── dev/
    │   ├── kustomization.yaml   # resources: [../../base], small deltas
    │   └── patches/
    ├── staging/
    │   └── kustomization.yaml
    └── prod/
        ├── kustomization.yaml
        └── patches/
```

### Pattern B: Multi-Cluster

```
infra/
├── base/
├── components/
│   ├── monitoring/              # kind: Component
│   └── ingress/                 # kind: Component
└── clusters/
    ├── us-east-1/
    │   └── kustomization.yaml   # resources: [../../base], components: [...]
    └── eu-west-1/
        └── kustomization.yaml
```

### Pattern C: Components for Feature Variants

```
app/
├── base/
├── components/
│   ├── external-db/             # kind: Component — external DB config
│   ├── ldap/                    # kind: Component — LDAP auth
│   └── recaptcha/               # kind: Component — reCAPTCHA
└── overlays/
    ├── community/               # resources: [base], components: [external-db, recaptcha]
    ├── enterprise/              # resources: [base], components: [external-db, ldap]
    └── dev/                     # resources: [base], components: [external-db]
```

### Pattern D: GitOps Config Repo Layout

```
gitops-config/
├── apps/
│   ├── my-api/
│   │   ├── base/
│   │   └── overlays/
│   │       ├── dev/             # newTag: latest-dev (auto-updated by CI)
│   │       └── prod/            # newTag: v2.1.0 (promoted via PR)
│   └── my-worker/
└── infra/
    └── clusters/
```

---

## CLI Commands

```bash
# ── Build (preview output) ────────────────────────────────────────────────
kustomize build overlays/prod
kustomize build overlays/prod | kubectl apply -f -
kustomize build --enable-helm overlays/prod
kustomize build --enable-alpha-plugins overlays/prod
kustomize build --load-restrictor LoadRestrictionsNone overlays/prod

# ── Apply / Delete / Diff via kubectl ─────────────────────────────────────
kubectl apply -k overlays/prod
kubectl delete -k overlays/prod
kubectl diff -k overlays/prod
kubectl kustomize overlays/prod    # preview without applying

# ── Edit helpers ──────────────────────────────────────────────────────────
kustomize edit set image gcr.io/my-project/api:v2.1.0
kustomize edit set image gcr.io/my-project/api:$(git rev-parse --short HEAD)
kustomize edit set namespace my-namespace
kustomize edit set nameprefix prod-
kustomize edit add resource deployment.yaml
kustomize edit add patch --path patch.yaml
kustomize edit fix               # migrate deprecated fields to current equivalents
kustomize edit fix --vars        # migrate vars: to replacements:
```

---

## Plugin System

Plugins implement the KRM Functions Specification (reads a `ResourceList`
from stdin, writes a `ResourceList` to stdout).

**Containerized KRM function (recommended):**
```yaml
# my-generator-config.yaml
apiVersion: my.org/v1
kind: MyGenerator
metadata:
  name: instance
  annotations:
    config.kubernetes.io/function: |
      container:
        image: registry.io/my-plugin:v1.0.0
spec:
  someField: someValue
```

```yaml
# kustomization.yaml
generators:
- my-generator-config.yaml
```

```bash
kustomize build --enable-alpha-plugins \
  --mount type=bind,src=$(pwd),dst=/workspace \
  overlays/prod
```

**Exec KRM function (trusted local code only):**
```yaml
metadata:
  annotations:
    config.kubernetes.io/function: |
      exec:
        path: ./my-local-plugin
```
Requires `--enable-exec` flag. No sandbox — only use for local tooling.

---

## GitOps and CI/CD Patterns

### Image Promotion Pipeline

```bash
# CI: build and push image, then update the overlay
cd gitops-config/apps/my-api/overlays/staging
kustomize edit set image gcr.io/my-project/api:${GIT_SHA}
git commit -am "chore: promote my-api ${GIT_SHA} to staging"
git push
# ArgoCD/Flux reconciles automatically
```

### Pull-Based GitOps with ArgoCD

```yaml
# ArgoCD Application resource
apiVersion: argoproj.io/v1alpha1
kind: Application
spec:
  source:
    repoURL: https://github.com/org/gitops-config
    targetRevision: HEAD
    path: apps/my-api/overlays/prod
    kustomize:
      images:
      - gcr.io/my-project/api:v2.1.0
      buildOptions: --enable-helm
```

### ConfigMap Rolling Update

```yaml
configMapGenerator:
- name: app-config
  literals:
  - DATABASE_URL=postgres://prod-db:5432/myapp
  # Hash suffix (default enabled) means changing any value creates a new
  # ConfigMap name → Deployment reference auto-updates → rolling update fires
```

### Digest Pinning for Production

```yaml
images:
- name: gcr.io/my-project/api
  digest: sha256:24a0c4b4...   # completely immutable — never changes
```

---

## Kustomize vs Helm

| Dimension | Kustomize | Helm |
|---|---|---|
| Paradigm | Overlay patches (transforms YAML) | Template rendering (generates YAML) |
| Templating | None (by design) | Full Go templates |
| Install | Embedded in kubectl | Separate binary |
| Output | Always valid YAML | Rendered YAML |
| Release tracking | None (stateless) | Full history, `helm rollback` |
| CRD lifecycle | Manual `crds:` field | Chart CRD hooks |
| GitOps alignment | Excellent | Good (extra cluster state) |
| Distributing apps | Not designed for it | First-class (charts) |
| Complex conditionals | Workaround via components | Native via templates |

**Hybrid pattern (most mature teams):**
1. Install community software via Helm (`helmCharts` or `helm install`)
2. Post-process with Kustomize patches for org standards
3. Manage all internal apps with Kustomize overlays
4. Reconcile with ArgoCD or Flux (both support both tools natively)
