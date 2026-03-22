# Using Helm: Troubleshooting

## Contents

- [Template render error](#template-render-error)
- [Lint passes but Kubernetes rejects the manifests](#lint-passes-but-kubernetes-rejects-the-manifests)
- [Install or upgrade times out](#install-or-upgrade-times-out)
- [Upgrade fails with immutable field error](#upgrade-fails-with-immutable-field-error)
- [Release stuck in a pending state](#release-stuck-in-a-pending-state)
- [Wrong values applied](#wrong-values-applied)
- [Dependency mismatch or lock drift](#dependency-mismatch-or-lock-drift)
- [OCI or repository auth failure](#oci-or-repository-auth-failure)
- [Resource already exists but is not managed by the release](#resource-already-exists-but-is-not-managed-by-the-release)
- [Rollback fails or reintroduces bad state](#rollback-fails-or-reintroduces-bad-state)
- [Stop-these-patterns](#stop-these-patterns)

---

## Template render error

**Symptom**

```text
Error: template: ...: executing "...": nil pointer evaluating ...
```

**Cause**

- Missing optional value path without guard
- Incorrect function pipeline or indentation

**Fix**

1. Re-run with debug:
   `helm template <release> <chart> -f <values> --debug`
2. Guard lookups with `with`, `if`, `default`, or `required`
3. Confirm YAML indentation around `toYaml` + `nindent`

---

## Lint passes but Kubernetes rejects the manifests

**Symptom**

`helm lint` is clean, but `install` or `upgrade` fails with Kubernetes API
validation errors.

**Cause**

- Helm template syntax is valid, but the rendered manifests violate the cluster
  API schema
- Rendered resources target a deprecated or unsupported apiVersion

**Fix**

1. Render the exact inputs with `helm template`
2. Run `kubectl apply --dry-run=server -f <rendered-file>`
3. Inspect the rejected resource and apiVersion
4. Fix the chart instead of retrying the same release command

---

## Install or upgrade times out

**Symptom**

```text
Error: UPGRADE FAILED: timed out waiting for the condition
```

**Cause**

- Pods fail readiness/liveness checks
- Hook jobs do not complete
- Quota/image pull/scheduling constraints

**Fix**

1. `helm status <release> -n <ns>`
2. `kubectl get pods -n <ns>`
3. `kubectl describe pod <pod> -n <ns>`
4. Increase timeout only after root-cause validation

---

## Upgrade fails with immutable field error

**Symptom**

```text
... field is immutable
```

**Cause**

- Attempted change to immutable selectors/service fields

**Fix**

1. Keep selectors stable across chart versions
2. If unavoidable, plan controlled recreate strategy
3. Avoid one-off manual kubectl edits on Helm-managed resources

---

## Release stuck in a pending state

**Symptom**

`helm list` shows `pending-install`, `pending-upgrade`, or `pending-rollback`.

**Fix**

1. Inspect status/history:
   `helm status <release> -n <ns>` and `helm history <release> -n <ns>`
2. If last revision is known good, rollback to it
3. Check hook jobs and Kubernetes events before retrying
4. If state is corrupted, coordinate manual intervention before retrying

---

## Wrong values applied

**Symptom**

Release behaves differently than expected after upgrade.

**Cause**

- Values precedence misunderstood
- `--reuse-values` merged stale data with new files

**Fix**

1. Inspect effective values:
   `helm get values <release> -n <ns> -a`
2. Re-run with explicit values files, no `--reuse-values`
3. Render manifests with the same value inputs before applying

---

## Dependency mismatch or lock drift

**Symptom**

```text
found in Chart.yaml, but missing in charts/ directory
```

**Fix**

```bash
helm dependency update ./chart
```

Commit `Chart.lock` with the dependency declaration changes. If `Chart.lock`
changed unexpectedly, review the resolved versions before proceeding.

---

## OCI or repository auth failure

**Symptom**

```text
unauthorized: authentication required
```

**Fix**

1. Re-authenticate: `helm registry login <registry>`
2. Confirm repository path and chart name spelling
3. Confirm token scope allows read or write as required
4. For repo-based workflows, confirm `helm repo add` used the correct URL

---

## Resource already exists but is not managed by the release

**Symptom**

Install fails due to pre-existing resource name conflict.

**Cause**

- Resource created outside Helm or by another release/namespace

**Fix**

1. Identify owner labels/annotations on existing resource
2. Rename resource or release to avoid collision
3. Do not forcibly adopt resources unless ownership model is explicit

---

## Rollback fails or reintroduces bad state

**Symptom**

Rollback to known revision fails or reintroduces bad state.

**Fix**

1. Inspect differences between revisions in `helm history`
2. Verify external dependencies (CRDs, secrets, DB migrations)
3. If chart hooks are non-idempotent, patch hooks before next deploy cycle

---

## Stop-these-patterns

- Running `helm upgrade` in production without render/lint validation
- Storing secrets in plaintext `values*.yaml` committed to git
- Using large unreviewed `--set` chains as environment configuration
- Leaving dependency versions unpinned
- Using one release name across multiple namespaces/environments
