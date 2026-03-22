---
name: using-kustomize-cli
description: Uses the Kustomize CLI correctly for authoring, editing,
  rendering, localizing, and debugging Kubernetes configuration overlays.
  Use whenever the user mentions kustomize, kubectl -k, kustomization.yaml,
  overlays, bases, components, patches, replacements, generators,
  helmCharts, or commands such as kustomize build, edit, create, localize,
  cfg, or fn.
---

# Using Kustomize CLI

## Overview

Treat Kustomize as a CLI workflow, not just a YAML schema. Start by figuring
out whether the user needs to author a kustomization, mutate one in place,
render output, apply it to a cluster, or debug an unexpected render. Use the
standalone `kustomize` binary when exact feature behavior matters; `kubectl -k`
may embed an older Kustomize release. For setup, read
[references/installation.md](references/installation.md). For syntax,
commands, and examples, read [references/overview.md](references/overview.md),
[references/examples.md](references/examples.md), and
[references/troubleshooting.md](references/troubleshooting.md) as needed.

## When to Use

- Creating or fixing `kustomization.yaml`
- Choosing between `build`, `edit`, `create`, `localize`, `cfg`, `fn`, and
  `kubectl -k`
- Structuring `base/`, `overlays/`, and `components/`
- Using `patches`, `replacements`, generators, images, replicas, labels,
  namespaces, or name transforms
- Debugging why rendered output differs from source YAML
- Explaining version skew between standalone `kustomize` and `kubectl`
- Integrating Helm charts or KRM functions into a Kustomize pipeline

## When Not to Use

- Pure Helm workflows with no Kustomize layer
- Raw `kubectl` questions unrelated to `-k`
- Non-Kubernetes configuration management
- Template-language questions; Kustomize is template-free

## Prerequisites

- Verify which binary is in play with `kustomize version` and
  `kubectl version --client`.
- If installation or upgrade is needed, read
  [references/installation.md](references/installation.md).
- For `helmCharts`, ensure `helm` is installed and use `--enable-helm`.
- For KRM function plugins, ensure the required runtime is available.

## Workflow

1. Identify the execution path first: authoring, in-place mutation, rendering,
   applying, or debugging.
2. Verify versions before reasoning about behavior. If standalone and embedded
   versions differ, treat standalone `kustomize` as authoritative unless the
   user explicitly deploys through `kubectl -k`.
3. Read the target `kustomization.yaml` and the directory layout before making
   changes. Use [references/overview.md](references/overview.md) for field and
   command selection.
4. Prefer the highest-level primitive that solves the problem:
   `images`/`replicas`/`labels`/`namespace` before `replacements`, and
   `replacements` before custom patches or plugins.
5. Use unified `patches` for partial-object or JSON 6902 operations. Reserve
   `helmCharts`, `fn`, and alpha features for cases that truly need them.
6. Preview with `kustomize build <dir>` before apply. If a cluster is involved,
   prefer `kubectl diff -k <dir>` before `kubectl apply -k <dir>`.
7. When changing files mechanically, prefer `kustomize edit ...`; remember it
   mutates files in place.
8. For unexpected output, build layer by layer and use
   [references/troubleshooting.md](references/troubleshooting.md).

## Hard Rules

- Always render before apply. Do not reason from source YAML alone.
- Prefer standalone `kustomize build` when feature parity matters; `kubectl -k`
  can lag.
- Prefer `labels` over `commonLabels`. On live resources, keep
  `includeSelectors: false` unless the selector change is intentional.
- Use `patches`, not `patchesStrategicMerge` or `patchesJson6902`, in new
  work. Migrate old files with `kustomize edit fix` when appropriate.
- Use `replacements`, not `vars`, in new work.
- Pin all remote refs to a tag or commit SHA.
- Do not commit real secrets through `secretGenerator.literals`.
- Do not disable generator hash suffixes globally unless the stability tradeoff
  is explicit.
- Treat `--enable-helm`, `--enable-alpha-plugins`, and `localize` as explicit
  feature choices, not defaults.

## Failure Handling

- Missing-file errors: check every relative path from the declaring
  `kustomization.yaml`, not from the shell working directory.
- Wrong rendered value: build each layer separately to isolate the change.
- Version-skew issues: compare `kustomize version` with `kubectl version
  --client` and switch to standalone render if needed.
- Load-restrictor failures: restructure the tree first; relax restrictions only
  deliberately.

## Red Flags

- `commonLabels` on already-deployed workloads
- Floating remote refs such as `?ref=main`
- New uses of `vars`, `bases`, `patchesStrategicMerge`, or `patchesJson6902`
- Real secrets in generator literals
- An overlay copying full resource YAML instead of patching the base
- Reaching for plugins, Helm, or `LoadRestrictionsNone` before simpler
  built-in features
