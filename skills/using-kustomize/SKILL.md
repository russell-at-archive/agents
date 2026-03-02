---
name: using-kustomize
description: Provides expert guidance for working with Kustomize — a
  template-free, declarative Kubernetes configuration management tool that
  uses overlays and patches to customize YAML without forking. Use when the
  user asks about kustomization.yaml, kustomize build, overlays, bases,
  patches, configMapGenerator, secretGenerator, images transformer, components,
  helmCharts, replacements, or kubectl apply -k.
---

# Using Kustomize

## Overview

Kustomize manages Kubernetes configurations through non-destructive layering:
a base of generic YAML is never modified; overlays apply patches and
transformations in memory and emit the result. Every file Kustomize reads or
writes is valid Kubernetes YAML — no templating syntax. It ships embedded in
`kubectl` (`kubectl apply -k`) and as a standalone binary. Full reference:
[references/overview.md](references/overview.md).

## When to Use

- Authoring or editing `kustomization.yaml` files
- Structuring base / overlay / component directory layouts
- Writing strategic merge patches or JSON 6902 patches
- Configuring `configMapGenerator` or `secretGenerator`
- Using `images`, `replicas`, `namePrefix`, `nameSuffix`, or `namespace`
  transformer fields
- Setting up `replacements` to propagate values across resources
- Creating reusable `kind: Component` bundles
- Integrating Helm charts via `helmCharts` with post-render patching
- Running `kustomize build`, `kustomize edit`, or `kubectl apply -k`
- Debugging unexpected output from `kustomize build`
- Designing GitOps image promotion pipelines

## When Not to Use

- Pure Helm workflows with no Kustomize involvement
- Non-Kubernetes configuration management
- Writing Go template logic (Kustomize has none by design)

## Prerequisites

- Standalone `kustomize` binary **or** `kubectl` v1.14+ (embedded, older version)
- For Helm integration: `helm` binary installed, use `--enable-helm` flag
- For containerized KRM function plugins: container runtime available

## Workflow

1. Read `kustomization.yaml` to understand the resource pipeline.
   See [references/overview.md](references/overview.md) for the full schema.
2. Run `kustomize build <dir>` (or `kubectl kustomize <dir>`) to see the
   rendered output before applying. Debug unexpected values from there.
3. For patches, choose the right type:
   - Targeted single-field changes → `images`, `replicas` transformer fields
   - Partial object changes → strategic merge patch in `patches`
   - Precise path operations (add/remove/replace) → JSON 6902 in `patches`
4. For multi-environment, structure as `base/` + `overlays/<env>/`.
   For opt-in cross-cutting features, use `kind: Component`.
5. After editing, re-run `kustomize build` and pipe to `kubectl apply -f -`.
6. For troubleshooting, consult
   [references/troubleshooting.md](references/troubleshooting.md).
   For examples, consult [references/examples.md](references/examples.md).

## Hard Rules

- **Never use `commonLabels` on resources already deployed to a cluster.**
  It modifies `spec.selector.matchLabels`, which is immutable; use `labels`
  with `includeSelectors: false` instead.
- **Always pin remote base refs.** `?ref=main` is a floating pointer; use
  `?ref=v1.2.3` or a commit SHA.
- **Do not store real secret values in `kustomization.yaml` literals.**
  They commit to git in plaintext. Use External Secrets Operator, Sealed
  Secrets, or SOPS.
- **Do not use `vars` in new code.** Deprecated in v5.0.0. Use
  `replacements` instead.
- **Do not use `patchesStrategicMerge` or `patchesJson6902` in new code.**
  Both are deprecated in v5.0.0. Use the unified `patches` field. Run
  `kustomize edit fix` to migrate existing files.
- **Do not disable hash suffixes globally** (`generatorOptions:
  disableNameSuffixHash: true`) — it breaks automatic rolling updates when
  ConfigMap data changes. Only disable per-generator when required.
- **Lists in strategic merge patches replace, not append.** Re-state all
  items when overriding an inherited list.

## Failure Handling

- `kustomize build` errors about missing files: check all paths in
  `resources`, `patches`, and `components` are relative to the
  `kustomization.yaml` that declares them.
- Unexpected field values in output: run `kustomize build` at each layer
  (`base`, then `overlay`) to isolate which layer introduces the value.
- `--load-restrictor` errors: patches may not reference files outside the
  kustomization root by default; restructure paths or use
  `--load-restrictor LoadRestrictionsNone` with caution.
- `kubectl apply -k` applies an older kustomize version than standalone;
  use `kustomize build | kubectl apply -f -` for latest features.

## Red Flags

- `commonLabels` used on any production-deployed resource.
- Remote `resources` without a pinned `?ref=` — update will be unpredictable.
- `vars:` present in a new kustomization — migrate to `replacements`.
- Real secret values stored as `literals` in `secretGenerator`.
- Overlay re-declaring the full base resource YAML instead of patching it.
- Deeply nested overlay chains (overlay of overlay of overlay) — flatten.
