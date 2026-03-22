# Crossplane CLI Overview

## Contents

- Command map
- Task routing
- Render workflow
- Validate workflow
- Package workflow
- Debug workflow
- Decision rules

## Command map

| Task | Command | Cluster required | Key constraint |
| ---- | ------- | ---------------- | -------------- |
| Check versions | `crossplane version` | Optional | Server version only appears with cluster access |
| Render a composition pipeline | `crossplane render` | No | Requires Docker and composition functions |
| Validate manifests offline | `crossplane beta validate` | No | May download provider schemas into cache |
| Visualize object relationships | `crossplane beta trace` | Yes | Uses kubeconfig and reads cluster state |
| View Crossplane pod resource usage | `crossplane beta top` | Yes | Requires metrics-server |
| Convert legacy resources | `crossplane beta convert` | No | Experimental command surface |
| Build a package | `crossplane xpkg build` | No | Packages `.yaml` and `.yml` under the root |
| Scaffold a package | `crossplane xpkg init` | No | Template-driven |
| Install or update a package in cluster | `crossplane xpkg install` / `update` | Yes | Uses kubeconfig |
| Authenticate and publish packages | `crossplane xpkg login` / `push` | No | Registry credentials required |

## Task routing

Use this routing first:

1. If the user is authoring a composition pipeline, start with `render`.
2. If the user is validating manifests or schemas, use `beta validate`.
3. If the user is troubleshooting runtime behavior in a cluster, start with
   `beta trace`.
4. If the user is building or publishing Crossplane packages, use `xpkg`.
5. If the user is dealing with provider or function install health, pair `xpkg`
   commands with `kubectl describe` on revision objects.

## Render workflow

Current docs describe `render` as stable. The old `beta render` guidance is
stale.

Core pattern:

```bash
crossplane render xr.yaml composition.yaml functions.yaml
```

Useful flags:

- `--include-full-xr` to retain full XR fields in output
- `--include-function-results` to print function events/results
- `--observed-resources` to mock composed resource state
- `--extra-resources` to mock non-composed resources requested by functions
- `--context-files` and `--context-values` to populate function context

Use `render` only for compositions that use composition functions. It does not
support legacy `mode: Resources` compositions. It also requires a local Docker
Engine because the CLI runs functions locally.

## Validate workflow

`crossplane beta validate` is the main offline validation entry point.

Validate resources against provider or XRD schemas:

```bash
crossplane beta validate provider.yaml resource.yaml
```

Validate a rendered pipeline:

```bash
crossplane render xr.yaml composition.yaml functions.yaml --include-full-xr \
  | crossplane beta validate schemas.yaml -
```

Useful flags:

- `--cache-dir` to control where provider schemas are downloaded
- `--clean-cache` to refresh stale schema downloads
- `--skip-success-results` for quieter output

Validation is offline, but provider-backed validation still needs network access
to download package schemas unless they are already cached.

## Package workflow

Build a package from a directory tree:

```bash
crossplane xpkg build --package-root=. --package-file=package.xpkg
```

Scaffold from a template:

```bash
crossplane xpkg init my-function function-template-go
```

Install a package into a cluster:

```bash
crossplane xpkg install Provider xpkg.crossplane.io/crossplane-contrib/provider-aws-s3:v2.0.0
crossplane xpkg install Function xpkg.crossplane.io/crossplane-contrib/function-patch-and-transform:v0.8.2
```

Use `--wait` when you want synchronous package installation behavior. If install
fails, inspect the resulting `ProviderRevision`, `FunctionRevision`, or
`ConfigurationRevision`.

Login and push:

```bash
crossplane xpkg login --username="$USER" --password -
crossplane xpkg push -f package.xpkg index.docker.io/org/package:v0.1.0
```

Package advice:

- Pin versions explicitly
- Prefer digests for deterministic installs
- Use `--manual-activation` when you need revision control during upgrades
- Use `--revision-history-limit` when inactive revisions matter

## Debug workflow

Start runtime diagnosis with `trace`:

```bash
crossplane beta trace <kind>/<name>
crossplane beta trace <kind>/<name> --output=wide
crossplane beta trace <kind>/<name> --output=json
crossplane beta trace <kind>/<name> --output=dot
```

Important flags:

- `--namespace` for namespaced resources
- `--show-connection-secrets` to display secret names only
- `--show-package-dependencies` and `--show-package-revisions` for package trees
- `--show-package-runtime-configs` when package runtime wiring matters

Then move to:

```bash
kubectl describe <kind> <name>
kubectl describe providerrevision <name>
kubectl describe functionrevision <name>
kubectl -n crossplane-system logs <controller-pod>
```

Use `crossplane beta top` only when the cluster has metrics-server.

## Decision rules

- Prefer `render` plus `beta validate` for authoring feedback before touching a
  cluster.
- Prefer `beta trace` before raw `kubectl` when the issue is relationship or
  dependency oriented.
- Prefer revision objects over top-level package objects when package health is
  unclear.
- Prefer concrete package versions over floating tags.
