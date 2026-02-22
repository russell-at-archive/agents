# Using Kustomize: Troubleshooting

## Contents

- [Build fails: resource or patch file not found](#build-fails-resource-or-patch-file-not-found)
- [commonLabels breaks kubectl apply on live resources](#commonlabels-breaks-kubectl-apply-on-live-resources)
- [Unexpected field value in rendered output](#unexpected-field-value-in-rendered-output)
- [List items missing after overlay merge](#list-items-missing-after-overlay-merge)
- [namePrefix not propagating to cross-references](#nameprefix-not-propagating-to-cross-references)
- [ConfigMap hash suffix causes unexpected rollout](#configmap-hash-suffix-causes-unexpected-rollout)
- [ConfigMap reference in Deployment not updated after generator rename](#configmap-reference-in-deployment-not-updated-after-generator-rename)
- [Helm chart not rendering](#helm-chart-not-rendering)
- [vars still present after migration attempt](#vars-still-present-after-migration-attempt)
- [Remote base not updating to new ref](#remote-base-not-updating-to-new-ref)
- [kubectl apply -k uses wrong kustomize version](#kubectl-apply--k-uses-wrong-kustomize-version)
- [load-restrictor error on patch file path](#load-restrictor-error-on-patch-file-path)
- [Strategic merge patch not matching container by name](#strategic-merge-patch-not-matching-container-by-name)
- [JSON patch path wrong for annotation with slash in key](#json-patch-path-wrong-for-annotation-with-slash-in-key)
- [Component patches applying to wrong resources](#component-patches-applying-to-wrong-resources)
- [Anti-patterns reference](#anti-patterns-reference)

---

## Build fails: resource or patch file not found

**Symptom:**
```
accumulating resources: accumulation err='...': no such file or directory
```

**Cause:** All paths in `resources`, `patches.path`, `components`, and
`bases` are relative to the `kustomization.yaml` that declares them — not
to the working directory where you run `kustomize build`.

**Fix:**
```yaml
# If kustomization.yaml is at overlays/prod/kustomization.yaml,
# patch paths are relative to overlays/prod/:
patches:
- path: patches/resource-limits.yaml    # overlays/prod/patches/resource-limits.yaml
- path: ../../shared/patches/common.yaml # valid relative path up the tree

# Remote resources:
resources:
- github.com/org/repo//path/to/dir?ref=v1.0.0   # ref= is required
```

---

## commonLabels breaks kubectl apply on live resources

**Symptom:**
```
The Deployment "my-app" is invalid: spec.selector: Invalid value: ...
selector does not match template labels
```

**Cause:** `commonLabels` modifies `spec.selector.matchLabels` and pod
template labels. `spec.selector` is **immutable** after a Deployment is
created. Adding a new label via `commonLabels` changes the selector and
kubectl apply rejects it.

**Fix:** Replace `commonLabels` with `labels` and set `includeSelectors: false`:

```yaml
# BEFORE (dangerous):
commonLabels:
  app.kubernetes.io/managed-by: kustomize

# AFTER (safe):
labels:
- pairs:
    app.kubernetes.io/managed-by: kustomize
  includeSelectors: false   # do NOT touch matchLabels
  includeTemplates: false   # do NOT touch pod template labels
```

If you need to add a label to pod template metadata (for metrics/logging):
```yaml
labels:
- pairs:
    my-label: value
  includeSelectors: false
  includeTemplates: true    # adds to pod template but NOT to matchLabels
```

---

## Unexpected field value in rendered output

**Symptom:** A field has the wrong value but you can't tell where it's
coming from.

**Diagnosis approach — build each layer independently:**

```bash
# Check what the base produces
kustomize build base/

# Check what the overlay adds
kustomize build overlays/staging/

# Check what a component contributes (build component as a standalone kustomization)
# Components can't be built standalone, but you can inspect them directly

# For remote bases, check the pinned ref content:
# kustomize build github.com/org/repo//path?ref=v1.0.0
```

**Common causes:**
- A component patch targets all resources of a `kind` (no `name` in `target`),
  clobbering resources you didn't intend to modify.
- An earlier import in `resources` sets a value; a later import overrides it
  back. Reorder or add a more specific patch.
- A `namePrefix` is prepended but the patch references the original name,
  creating a mismatch (patch targets `my-app`, actual resource is `prod-my-app`).

---

## List items missing after overlay merge

**Symptom:** An overlay that adds items to an inherited list ends up with only
the overlay's items — the base items are gone.

**Cause:** Kustomize uses **replacement semantics for lists** in strategic merge
patches. A list in an overlay replaces the entire list from the base. There is
no append operator.

**Fix:** Always re-state all items you want to keep:

```yaml
# base/deployment.yaml
spec:
  template:
    spec:
      containers:
      - name: app
        env:
        - name: BASE_VAR
          value: base-value

# overlays/prod/kustomization.yaml — WRONG (drops BASE_VAR):
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
            env:
            - name: PROD_VAR
              value: prod-value

# overlays/prod/kustomization.yaml — CORRECT (keeps BASE_VAR):
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
            env:
            - name: BASE_VAR    # re-state to keep
              value: base-value
            - name: PROD_VAR    # add new
              value: prod-value
```

Alternatively, use a JSON 6902 `add` operation to append without restating:
```yaml
patches:
- patch: |-
    - op: add
      path: /spec/template/spec/containers/0/env/-
      value:
        name: PROD_VAR
        value: prod-value
  target:
    kind: Deployment
    name: my-app
```

---

## namePrefix not propagating to cross-references

**Symptom:** After setting `namePrefix: "prod-"`, a Deployment's volume still
references the old ConfigMap name (without prefix), causing pod start failures.

**Cause:** Kustomize only propagates name changes for resource types and
reference fields it knows about. For custom resources or unusual reference
fields, it doesn't know to update them.

**Fix:**
- For standard Kubernetes resources, this should work automatically. Check that
  `apiVersion` and `kind` in your resources are spelled correctly.
- For CRDs with name references, register the CRD schema:
  ```yaml
  crds:
  - crds/my-custom-resource.yaml
  ```
- For remaining unknown references, use `replacements:` to explicitly copy
  the renamed value into the target field.

---

## ConfigMap hash suffix causes unexpected rollout

**Symptom:** Deploying what you thought was an unrelated change triggers a
Deployment rollout because a ConfigMap's hash-suffixed name changed.

**Cause:** Correct behavior — the ConfigMap content changed (someone edited
it), so its hash changed, so the Deployment reference changed, so the
Deployment rolls out.

**Diagnosis:**
```bash
# Compare the ConfigMap content between two builds:
kustomize build overlays/prod | grep -A 20 "kind: ConfigMap"
```

**Fix if unintentional:** Find and revert the accidental ConfigMap data change.

**Fix if stable name truly needed** (e.g., external system references the name):
```yaml
configMapGenerator:
- name: cluster-info
  literals:
  - CLUSTER_NAME=prod-us-east-1
  options:
    disableNameSuffixHash: true    # stable name — no rolling update on change
```

---

## ConfigMap reference in Deployment not updated after generator rename

**Symptom:** You renamed a `configMapGenerator` entry but the Deployment's
`volumes.configMap.name` still references the old name.

**Cause:** Kustomize updates references using the original `name` field as a
lookup key. If you changed the `name`, it can no longer find what to update.

**Fix:** The `name` field in `configMapGenerator` is the stable identifier —
do not change it to rename the resource. Use `namePrefix`/`nameSuffix` at
the kustomization level to differentiate environments.

---

## Helm chart not rendering

**Symptom:** `kustomize build` ignores `helmCharts` or errors with
`helm not enabled`.

**Fix:**
```bash
# Must pass --enable-helm flag
kustomize build --enable-helm overlays/prod

# For ArgoCD, add to argocd-cm ConfigMap:
# kustomize.buildOptions: --enable-helm

# Helm binary must be installed and on PATH
which helm
helm version
```

If using pre-downloaded charts (air-gapped):
```yaml
helmGlobals:
  chartHome: ./charts    # directory containing unpacked chart folders

helmCharts:
- name: my-chart
  # omit repo: — looks in chartHome
  version: "1.0.0"
```

```bash
# Pre-download charts:
helm pull my-repo/my-chart --version 1.0.0 --untar --untardir charts/
```

---

## vars still present after migration attempt

**Symptom:** Running `kustomize edit fix --vars` didn't fully migrate, or
`vars` still appears in old files.

**Manual migration pattern:**

```yaml
# BEFORE (deprecated vars):
vars:
- name: SERVICE_NAME
  objref:
    kind: Service
    name: my-service
    apiVersion: v1
  fieldref:
    fieldpath: metadata.name

# AFTER (replacements):
replacements:
- source:
    kind: Service
    name: my-service
    fieldPath: metadata.name
  targets:
  - select:
      kind: Deployment
      name: my-app
    fieldPaths:
    - spec.template.spec.containers.[name=app].env.[name=SERVICE_NAME].value
```

Also remove any `$(SERVICE_NAME)` substitution syntax from resource YAML —
replacements work by direct field path assignment, not string interpolation.

---

## Remote base not updating to new ref

**Symptom:** After changing `?ref=v1.2.3` to `?ref=v2.0.0` in `resources`,
the old content is still rendered.

**Cause:** Kustomize caches remote bases in `~/.cache/kustomize/` (or
`$XDG_CACHE_HOME/kustomize/`).

**Fix:**
```bash
# Clear the kustomize cache
rm -rf ~/.cache/kustomize/

# Or set KUSTOMIZE_PLUGIN_HOME to a temp dir
# Then retry the build
kustomize build overlays/prod
```

---

## kubectl apply -k uses wrong kustomize version

**Symptom:** Features available in standalone `kustomize` (like `replacements`,
new `patches` fields, Helm support) fail or are ignored with `kubectl apply -k`.

**Cause:** The kustomize embedded in `kubectl` is typically 1–2 major versions
behind the standalone binary.

**Fix:** Use the standalone binary instead:
```bash
# Install latest standalone kustomize
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
sudo mv kustomize /usr/local/bin/

# Use instead of kubectl apply -k:
kustomize build overlays/prod | kubectl apply -f -
```

Check versions:
```bash
kustomize version
kubectl version --client
```

---

## load-restrictor error on patch file path

**Symptom:**
```
security; file '/path/outside/root/patch.yaml' is not in or below '/path/to/kustomization/root'
```

**Cause:** By default, Kustomize prevents patches from referencing files
outside the kustomization root directory.

**Fix (preferred):** Restructure so patch files live within the kustomization
root, or symlink if needed.

**Fix (override):** Use `--load-restrictor LoadRestrictionsNone` for monorepo
layouts where cross-directory patches are intentional:
```bash
kustomize build --load-restrictor LoadRestrictionsNone overlays/prod
```
Use with caution — it allows path traversal. Acceptable in controlled
CI environments, risky in untrusted input scenarios.

---

## Strategic merge patch not matching container by name

**Symptom:** A patch targeting a specific container by `name` isn't applying,
or applies to the wrong container.

**Cause:** Strategic merge patches on container lists use the `name` field as
the merge key. If the `name` in your patch doesn't exactly match the container
name in the base, it adds a new container instead of merging.

**Diagnosis:**
```bash
kustomize build overlays/prod | grep -A 5 "containers:"
# Verify exact container names in the rendered base
```

**Fix:** Ensure the `name` in your patch exactly matches the container name:
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
          - name: api          # must match exactly — case sensitive
            env:
            - name: NEW_VAR
              value: new-value
```

---

## JSON patch path wrong for annotation with slash in key

**Symptom:** JSON 6902 patch fails with an invalid path error when the
annotation key contains a slash (common with Kubernetes annotations like
`app.kubernetes.io/name`).

**Cause:** JSON Pointer (RFC 6901) uses `/` as a path separator and `~` as
an escape character. Slashes in keys must be encoded as `~1`, and `~` must
be encoded as `~0`.

**Fix:**
```yaml
patches:
- patch: |-
    - op: add
      path: /metadata/annotations/app.kubernetes.io~1managed-by
      value: kustomize
    - op: add
      path: /metadata/annotations/iam.amazonaws.com~1role
      value: arn:aws:iam::123456789012:role/my-role
  target:
    kind: Deployment
```

`app.kubernetes.io/managed-by` → `app.kubernetes.io~1managed-by`
`iam.amazonaws.com/role` → `iam.amazonaws.com~1role`

---

## Component patches applying to wrong resources

**Symptom:** A component patch intended for one resource is applying to all
resources of that `kind`.

**Cause:** The patch `target` in the component has only `kind` and no `name`,
so it matches every resource of that kind in the parent kustomization.

**Fix:** Add a `name`, `labelSelector`, or `annotationSelector` to narrow the target:

```yaml
# BEFORE (too broad — applies to all Deployments):
patches:
- patch: |-
    ...
  target:
    kind: Deployment

# AFTER (scoped to a specific app):
patches:
- patch: |-
    ...
  target:
    kind: Deployment
    labelSelector: "app.kubernetes.io/name=my-app"
```

Or use `annotationSelector` to opt specific resources in:
```yaml
target:
  kind: Deployment
  annotationSelector: "monitoring.enabled=true"
```

---

## Anti-patterns reference

| Anti-pattern | Problem | Fix |
|---|---|---|
| `commonLabels` on live resources | Mutates immutable `spec.selector` → apply fails | Use `labels` with `includeSelectors: false` |
| Floating remote base ref (`?ref=main`) | Non-deterministic builds | Pin to `?ref=v1.2.3` or commit SHA |
| Real credentials in `secretGenerator.literals` | Plaintext in git history | External Secrets Operator, Sealed Secrets, SOPS |
| `vars:` in new code | Deprecated in v5.0.0, removed in v1 API | Migrate to `replacements:` |
| `patchesStrategicMerge` / `patchesJson6902` | Deprecated in v5.0.0 | Move to unified `patches:` field |
| `disableNameSuffixHash: true` globally | Breaks rolling updates on ConfigMap change | Only disable per-generator when a stable name is required |
| Overlay re-declares full resource YAML | Loses DRY — defeats purpose of base | Write patches for only the delta |
| Overlay chain 3+ levels deep | Hard to reason about merge order | Flatten to base + single overlay level |
| Component with no `name` in target selector | Applies patch to all resources of that `kind` | Add `name`, `labelSelector`, or `annotationSelector` |
| Using `kubectl apply -k` for v5+ features | Embedded kustomize lags by 1–2 releases | Use `kustomize build | kubectl apply -f -` |
