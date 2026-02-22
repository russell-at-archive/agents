# Using Crossplane: Troubleshooting

## Contents

- [Diagnostic Workflow](#diagnostic-workflow)
- [Provider Issues](#provider-issues)
- [ProviderConfig Issues](#providerconfig-issues)
- [Managed Resource Issues](#managed-resource-issues)
- [XRD and Composition Issues](#xrd-and-composition-issues)
- [Claim and XR Issues](#claim-and-xr-issues)
- [crossplane beta render Failures](#crossplane-beta-render-failures)
- [Common Error Messages](#common-error-messages)
- [Anti-patterns](#anti-patterns)

---

## Diagnostic Workflow

Follow this order for any `Synced: False` or `Ready: False` condition:

1. Run `crossplane beta trace <Kind>/<name> [-n namespace]` — shows the
   full resource tree with conditions highlighted.
2. Run `kubectl describe <kind> <name>` on the failing resource — the
   `Status.Conditions[].Message` field contains the root cause.
3. If the MR is stuck, check the provider pod logs:

   ```bash
   kubectl -n crossplane-system logs \
     -l pkg.crossplane.io/provider=<provider-name> \
     --tail=100
   ```

4. Check Crossplane core logs for package install or XRD issues:

   ```bash
   kubectl -n crossplane-system logs -lapp=crossplane --tail=100
   ```

5. Check events for the resource and its namespace:

   ```bash
   kubectl get events --field-selector involvedObject.name=<name>
   kubectl get events -n crossplane-system --sort-by=.lastTimestamp
   ```

---

## Provider Issues

### Provider stuck at `HEALTHY: False`

```bash
kubectl describe provider <name>
kubectl get providerrevision
kubectl describe providerrevision <name>-<hash>
```

Common causes:

| Symptom | Cause | Fix |
| ------- | ----- | --- |
| `ImagePullBackOff` on provider pod | Image tag not found or registry auth missing | Verify package reference and `imagePullSecrets` |
| `Installed: True, Healthy: False` | CRD install failed or RBAC missing | Check provider revision status and events |
| Provider pod in `CrashLoopBackOff` | Invalid ProviderConfig or missing secret | Check provider pod logs |

### Provider pod logs

```bash
# Find the provider pod
kubectl get pods -n crossplane-system -l pkg.crossplane.io/provider=<provider-name>

# Tail logs
kubectl -n crossplane-system logs \
  -l pkg.crossplane.io/provider=<provider-name> \
  --follow
```

---

## ProviderConfig Issues

### `cannot get referenced ProviderConfig: ... not found`

The managed resource references a ProviderConfig name that does not exist.

```bash
# List existing ProviderConfigs
kubectl get providerconfig -A

# The MR's spec.providerConfigRef.name must match exactly
kubectl get bucket my-bucket -o jsonpath='{.spec.providerConfigRef.name}'
```

Fix: create the missing ProviderConfig or correct the `providerConfigRef.name`
in the managed resource.

### Authentication failures in provider logs

```bash
kubectl -n crossplane-system logs \
  -l pkg.crossplane.io/provider=provider-aws-s3 | grep -i "auth\|cred\|denied"
```

Common causes:

- Secret does not exist in `crossplane-system`
- Secret key name does not match `secretRef.key`
- Credentials expired or lack required IAM permissions
- IRSA annotation missing from the provider service account

---

## Managed Resource Issues

### `Synced: False` — reconciliation errors

```bash
kubectl describe <kind> <name>
# Look at: Status > Conditions > Message
```

Typical messages and fixes:

| Message | Fix |
| ------- | --- |
| `cannot get credentials` | Check ProviderConfig and referenced Secret |
| `AccessDenied` | Add required IAM/GCP/Azure permissions to the credential |
| `AlreadyExists` | Set `crossplane.io/external-name` to match the existing resource name |
| `ResourceNotFoundException` | External resource was deleted outside Crossplane; re-create or import |
| `cannot resolve references` | Referenced resource (e.g., VPC) not yet ready; wait or fix selector |

### Resource created externally — importing

Set `managementPolicies: [Observe]` first, wait for `Synced: True`, then
switch to `["*"]`. See [examples.md](examples.md) for the full flow.

### `deletionPolicy: Delete` accidentally deleting cloud resources

If a managed resource was deleted from Kubernetes, Crossplane will delete
the external resource. To prevent:

```bash
# Patch to Orphan before deleting from Kubernetes
kubectl patch <kind> <name> --type merge \
  -p '{"spec":{"deletionPolicy":"Orphan"}}'
kubectl delete <kind> <name>
```

---

## XRD and Composition Issues

### XRD not generating a CRD

```bash
kubectl get xrd <name>
kubectl describe xrd <name>
# Check: Status > Conditions > Established
```

Common cause: schema validation error in the XRD's `openAPIV3Schema`.
The condition message will identify the offending field.

### Composition not being selected for an XR

```bash
kubectl get composition
kubectl describe xr <name>
# Look for: No matching Composition found
```

Fix: the `compositeTypeRef.apiVersion` and `compositeTypeRef.kind` in the
Composition must exactly match the XRD's `spec.group/version` and
`spec.names.kind`. Use `compositionRef.name` on the XR to pin explicitly.

### Function error in pipeline step

```bash
kubectl describe xr <name>
# Status > Conditions > Message will contain function error

# Also check function pod logs
kubectl -n crossplane-system logs \
  -l pkg.crossplane.io/function=<function-name>
```

Common causes:

- Invalid input structure for the function (mismatched API version / kind)
- Missing required fields in the `input` block
- Function not yet `Healthy`

### Legacy `mode: Resources` composition

Compositions using `mode: Resources` (no pipeline) are deprecated.
Convert to pipeline mode:

```bash
crossplane beta convert pipeline-composition composition.yaml \
  -f function-patch-and-transform \
  -o converted-composition.yaml
```

---

## Claim and XR Issues

### Claim stuck: `Composite resource claim is waiting for composite resource to become Ready`

The Claim is waiting for the XR, which is waiting for all MRs. Use trace:

```bash
crossplane beta trace <ClaimKind>/<name> -n <namespace>
```

This shows which MR is `Ready: False`. Inspect that MR directly.

### Claim not finding an XR after creation

Check that the Composition's `compositeTypeRef` matches the XRD's group,
version, and kind. Also check that the XRD's `claimNames` is set.

### Deleting an XR directly (without deleting the Claim first)

The Claim will be left in an orphaned state with no backing XR.
Crossplane will re-create the XR to satisfy the Claim.

Always delete the **Claim** to trigger cascade deletion of the XR and MRs.

```bash
kubectl delete <claimKind> <name> -n <namespace>
# NOT: kubectl delete xr <name>
```

---

## crossplane beta render Failures

### Missing arguments

```text
Error: must specify composite resource, composition, and functions files
```

All three positional arguments are required:

```bash
crossplane beta render xr.yaml composition.yaml functions.yaml
```

### Function not found during render

The `functions.yaml` must list every Function referenced in the Composition
pipeline. Render resolves functions from the file, not from a cluster.

### Output differs from live cluster behavior

`crossplane beta render` is an offline preview. It does not call cloud APIs.
Conditions set by the provider (e.g., `status.atProvider`) will be empty in
render output. Use the render to validate patching logic, not cloud outcomes.

---

## Common Error Messages

| Error | Location | Fix |
| ----- | -------- | --- |
| `cannot get referenced ProviderConfig` | MR condition | Create the ProviderConfig |
| `the server could not find the requested resource` | kubectl apply | Provider CRDs not yet installed; wait for provider `HEALTHY: True` |
| `invalid Function input` | XR condition | Check function input `apiVersion`/`kind` match the function's expected schema |
| `no composition found` | XR condition | Composition `compositeTypeRef` does not match the XRD |
| `XRD ... is not established` | Composition status | Wait for XRD to finish installing its CRD |
| `cannot resolve selector` | MR condition | The referenced resource (e.g., VPC, Subnet) does not exist or label selector has no matches |

---

## Anti-patterns

- **Applying managed resources before the provider is `HEALTHY`**: the CRDs
  do not exist yet; kubectl will reject the resource.
- **Hardcoding cloud resource names**: use `crossplane.io/external-name`
  annotation; let Crossplane generate names by default.
- **Skipping `crossplane beta render` in CI**: catch composition patching
  errors before they reach a live cluster.
- **Using `mode: Resources` in new Compositions**: pipeline mode with
  Functions is the current standard and the legacy mode will be removed.
- **Deleting XRs directly**: always delete via the Claim to avoid orphaned
  Claims and broken reconciliation loops.
- **Storing long-lived cloud credentials without rotation**: prefer IRSA,
  Workload Identity, or short-lived tokens over static key pairs.
- **Using `latest` or floating version tags for packages in production**:
  pin exact versions to prevent uncontrolled provider upgrades.
