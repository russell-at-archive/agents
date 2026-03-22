# Using Kustomize: Examples

## Contents

- [Preview and apply a kustomization](#preview-and-apply-a-kustomization)
- [Base + overlay for multi-environment](#base--overlay-for-multi-environment)
- [Add a strategic merge patch](#add-a-strategic-merge-patch)
- [Add a JSON 6902 patch](#add-a-json-6902-patch)
- [Update an image tag across all environments](#update-an-image-tag-across-all-environments)
- [Generate a ConfigMap with hash suffix](#generate-a-configmap-with-hash-suffix)
- [Add a namespace and name prefix](#add-a-namespace-and-name-prefix)
- [Create a reusable component](#create-a-reusable-component)
- [Integrate a Helm chart with post-render patches](#integrate-a-helm-chart-with-post-render-patches)
- [Propagate a generated name with replacements](#propagate-a-generated-name-with-replacements)
- [CI/CD image promotion](#cicd-image-promotion)

---

## Preview and apply a kustomization

```bash
# Preview what will be applied (standalone binary — latest version)
kustomize build overlays/prod

# Preview via kubectl (embedded version — may be older)
kubectl kustomize overlays/prod

# Apply
kustomize build overlays/prod | kubectl apply -f -
kubectl apply -k overlays/prod

# Diff against live cluster
kubectl diff -k overlays/prod

# Delete
kubectl delete -k overlays/prod
```

---

## Base + overlay for multi-environment

```
app/
├── base/
│   ├── kustomization.yaml
│   ├── deployment.yaml
│   └── service.yaml
└── overlays/
    ├── dev/
    │   └── kustomization.yaml
    └── prod/
        ├── kustomization.yaml
        └── patches/
            └── resource-limits.yaml
```

```yaml
# base/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- deployment.yaml
- service.yaml
```

```yaml
# overlays/dev/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../../base
namespace: dev
replicas:
- name: my-app
  count: 1
images:
- name: gcr.io/my-project/api
  newTag: latest-dev
```

```yaml
# overlays/prod/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../../base
namespace: production
namePrefix: "prod-"
replicas:
- name: my-app
  count: 10
images:
- name: gcr.io/my-project/api
  newTag: "v2.1.0"
patches:
- path: patches/resource-limits.yaml
  target:
    kind: Deployment
    name: my-app
```

```yaml
# overlays/prod/patches/resource-limits.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  template:
    spec:
      containers:
      - name: api
        resources:
          requests:
            cpu: "500m"
            memory: "512Mi"
          limits:
            cpu: "1"
            memory: "1Gi"
```

---

## Add a strategic merge patch

Merge a partial object — Kubernetes-aware (uses merge keys like container `name`):

```yaml
# overlays/prod/kustomization.yaml
patches:
# Inline patch — no separate file needed
- patch: |-
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: my-app
    spec:
      template:
        spec:
          nodeSelector:
            node-pool: production
          tolerations:
          - key: dedicated
            value: production
            effect: NoSchedule
          containers:
          - name: api
            env:
            - name: LOG_LEVEL
              value: warn

# File patch with target selector (target overrides what's in the file's metadata)
- path: patches/add-sidecar.yaml
  target:
    kind: Deployment
    labelSelector: "app.kubernetes.io/component=api"
```

**Delete a container from a list:**
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
          - name: debug-sidecar
            $patch: delete
```

---

## Add a JSON 6902 patch

Precise path-based operations. Required when strategic merge keys aren't defined
(common with CRDs):

```yaml
patches:
- patch: |-
    - op: replace
      path: /spec/replicas
      value: 5
    - op: add
      path: /spec/template/spec/containers/0/env/-
      value:
        name: NEW_VAR
        value: new-value
    - op: remove
      path: /spec/template/spec/initContainers/0
    - op: test
      path: /spec/template/spec/containers/0/name
      value: api
  target:
    kind: Deployment
    name: my-app
```

**Add an annotation to all Deployments:**
```yaml
patches:
- patch: |-
    - op: add
      path: /metadata/annotations/iam.amazonaws.com~1role
      value: arn:aws:iam::123456789012:role/my-app
  target:
    kind: Deployment
```

Note: `/` in annotation keys is encoded as `~1`.

---

## Update an image tag across all environments

```yaml
# overlays/prod/kustomization.yaml
images:
- name: gcr.io/my-project/api      # matches across all resources
  newTag: "v2.1.0"

# Pin to digest for complete immutability
images:
- name: gcr.io/my-project/api
  digest: sha256:24a0c4b4a4c0eb97...

# Change registry AND tag (useful for registry mirrors)
images:
- name: nginx
  newName: registry.company.com/mirror/nginx
  newTag: "1.25.3"
```

**Automated update from CI:**
```bash
cd overlays/prod
kustomize edit set image gcr.io/my-project/api:${GIT_SHA}
# This modifies kustomization.yaml in place
git add kustomization.yaml
git commit -m "chore: deploy api ${GIT_SHA}"
```

---

## Generate a ConfigMap with hash suffix

```yaml
# kustomization.yaml
configMapGenerator:
- name: app-config
  literals:
  - DATABASE_HOST=prod-db.internal
  - LOG_LEVEL=warn
  - FEATURE_X=enabled
  # Hash suffix enabled by default → name becomes app-config-5f7g8h9j
  # Any change to data → new hash → new ConfigMap name
  # → Deployment's volumeMount reference auto-updated → rolling update triggered

# To keep a stable name (loses rolling update benefit):
- name: cluster-info
  literals:
  - CLUSTER_NAME=prod-us-east-1
  options:
    disableNameSuffixHash: true
```

**In overlay, add keys to a base-generated ConfigMap:**
```yaml
# overlay kustomization.yaml
configMapGenerator:
- name: app-config
  behavior: merge        # merge with the base ConfigMap generator
  literals:
  - EXTRA_KEY=overlay-value
```

---

## Add a namespace and name prefix

```yaml
# kustomization.yaml
namespace: production
namePrefix: "prod-"
nameSuffix: "-v2"
```

Kustomize propagates `namePrefix`/`nameSuffix` through all internal
cross-references — ConfigMap volume names, Secret mounts, ServiceAccount refs,
etc. A Deployment that references a ConfigMap named `app-config` will
automatically reference `prod-app-config-v2` after transformation.

---

## Create a reusable component

```yaml
# components/monitoring/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1alpha1
kind: Component

resources:
- servicemonitor.yaml
- alertrules.yaml

patches:
- patch: |-
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: placeholder   # overridden by target selector
    spec:
      template:
        metadata:
          annotations:
            prometheus.io/scrape: "true"
            prometheus.io/port: "8080"
  target:
    kind: Deployment     # applies to ALL Deployments in the parent kustomization
```

```yaml
# overlays/prod/kustomization.yaml
resources:
- ../../base
components:
- ../../components/monitoring    # opt-in
- ../../components/tls           # opt-in
# overlays/dev/kustomization.yaml does NOT include these components
```

---

## Integrate a Helm chart with post-render patches

```yaml
# kustomization.yaml
helmCharts:
- name: ingress-nginx
  repo: https://kubernetes.github.io/ingress-nginx
  version: "4.9.0"
  releaseName: ingress-nginx
  namespace: ingress-nginx
  valuesInline:
    controller:
      replicaCount: 2
      metrics:
        enabled: true

# Enforce org standards after Helm renders
patches:
- patch: |-
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: ingress-nginx-controller
    spec:
      template:
        spec:
          nodeSelector:
            node-role: ingress
          tolerations:
          - key: dedicated
            value: ingress
            effect: NoSchedule
  target:
    kind: Deployment
    labelSelector: "app.kubernetes.io/component=controller"

labels:
- pairs:
    managed-by: platform-team
  includeSelectors: false
```

```bash
# Build with Helm enabled
kustomize build --enable-helm overlays/prod
```

---

## Propagate a generated name with replacements

When a `secretGenerator` adds a hash suffix, Kustomize updates known
cross-references (Deployment env/volume refs) automatically. For resources
Kustomize doesn't know about (CronJobs, custom controllers), use `replacements`:

```yaml
secretGenerator:
- name: db-credentials
  literals:
  - password=s3cr3t
  # Generated name: db-credentials-abc123

replacements:
- source:
    kind: Secret
    name: db-credentials
    fieldPath: metadata.name        # db-credentials-abc123
  targets:
  - select:
      kind: CronJob
      name: db-backup
    fieldPaths:
    - spec.jobTemplate.spec.template.spec.containers.[name=backup].env.[name=DB_SECRET_NAME].value
  - select:
      kind: Job
      name: db-migrate
    fieldPaths:
    - spec.template.spec.containers.[name=migrate].env.[name=DB_SECRET_NAME].value
```

---

## CI/CD image promotion

**Dev pipeline (runs on every commit):**
```bash
cd gitops-config/apps/my-api/overlays/dev
kustomize edit set image gcr.io/my-project/api:${GIT_SHA}
git commit -am "ci: deploy my-api ${GIT_SHA} to dev"
git push
```

**Production promotion (runs on release tag):**
```bash
# Verify staging is healthy first, then promote to prod
cd gitops-config/apps/my-api/overlays/prod
kustomize edit set image gcr.io/my-project/api:${RELEASE_TAG}
git commit -am "release: promote my-api ${RELEASE_TAG} to prod"
git push
# ArgoCD/Flux reconciles the change automatically
```

**Preview what will change:**
```bash
# Before committing, compare rendered output
kustomize build overlays/prod > /tmp/new.yaml
git stash
kustomize build overlays/prod > /tmp/old.yaml
git stash pop
diff /tmp/old.yaml /tmp/new.yaml
```
