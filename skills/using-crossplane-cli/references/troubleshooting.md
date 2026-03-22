# Crossplane CLI Troubleshooting

## Contents

- Fast diagnosis order
- Render failures
- Validate failures
- Package failures
- Runtime failures
- Red flags

## Fast diagnosis order

Use this order unless the user already proved a later step:

1. Separate offline from cluster-backed commands.
2. For live issues, run `crossplane beta trace <kind>/<name>` first.
3. Inspect the failing object with `kubectl describe`.
4. Inspect package revision objects if install or health is involved.
5. Check controller logs in `crossplane-system`.

## Render failures

Symptom: `crossplane render` fails before producing YAML.

Checks:

- Confirm the composition uses functions, not legacy `mode: Resources`.
- Confirm Docker is running and reachable.
- Confirm all YAML inputs are present and in the right order:
  XR, Composition, Functions.
- If a function expects context or observed resources, provide them explicitly.

Useful command:

```bash
crossplane render xr.yaml composition.yaml functions.yaml --include-function-results
```

## Validate failures

Symptom: `crossplane beta validate` reports missing schemas or schema errors.

Checks:

- If validating against a provider, confirm the provider package reference is
  correct and reachable.
- Clear stale downloads with `--clean-cache`.
- Confirm the correct schema source is being used: provider manifest, XRD, or a
  schema directory.
- When piping from `render`, include `--include-full-xr` if the XR schema
  expects fields outside `status`.

Useful commands:

```bash
crossplane beta validate --clean-cache provider.yaml resource.yaml
crossplane render xr.yaml composition.yaml functions.yaml --include-full-xr \
  | crossplane beta validate schemas.yaml -
```

## Package failures

Symptom: `xpkg install` or `xpkg update` completes, but the package is not
healthy.

Checks:

- Inspect the top-level package object:

```bash
kubectl get providers
kubectl get functions
kubectl get configurations
```

- Then inspect revision objects for the real cause:

```bash
kubectl get providerrevisions
kubectl get functionrevisions
kubectl get configurationrevisions
kubectl describe providerrevision <name>
```

Common causes:

- Incompatible Crossplane version
- Registry pull failures
- Dependency install failures
- Runtime image issues
- Misconfigured `DeploymentRuntimeConfig`

## Runtime failures

Symptom: XR, managed resource, provider, or function is unhealthy in cluster.

Checks:

- Use `crossplane beta trace <kind>/<name> --output=wide`.
- For package trees, add `--show-package-dependencies all` or
  `--show-package-revisions all`.
- For secret wiring, add `--show-connection-secrets`.
- Check controller logs:

```bash
kubectl -n crossplane-system logs deploy/crossplane
kubectl -n crossplane-system logs <provider-pod>
kubectl -n crossplane-system logs <function-pod>
```

- If `crossplane beta top` fails, verify metrics-server before blaming
  Crossplane.

## Red flags

- Debugging package health without looking at revision objects
- Using `beta render` examples copied from old docs
- Treating `trace` output as enough without `kubectl describe`
- Assuming `beta validate` is network-free when provider schemas must be fetched
