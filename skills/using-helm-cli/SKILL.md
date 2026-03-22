---
name: using-helm-cli
description: Provides expert guidance for using the Helm CLI to author,
  validate, package, install, upgrade, and debug Kubernetes charts and
  releases. Use when the user asks about Helm charts, `Chart.yaml`,
  `values.yaml`, templates, `helm lint`, `helm template`, `helm install`,
  `helm upgrade`, `helm rollback`, dependencies, OCI registries, or Helm
  release troubleshooting.
---

# Using Helm

## Overview

Uses Helm as a chart packaging and release-management interface, not as a
substitute for understanding rendered Kubernetes manifests. For deeper workflow
and command selection, read [references/overview.md](references/overview.md).
If Helm is missing or first-time setup matters, read
[references/installation.md](references/installation.md).

## When to Use

- Authoring or editing `Chart.yaml`, `values.yaml`, or `templates/*.yaml`
- Running chart validation, rendering, packaging, or publishing workflows
- Managing a release with `install`, `upgrade`, `history`, `rollback`, or `get`
- Working with dependencies, chart repositories, or OCI registries
- Debugging bad renders, failed upgrades, hook problems, or wrong merged values

## When Not to Use

- Pure `kubectl` tasks where Helm does not own the resources
- Kustomize-only customization with no chart or release lifecycle
- Higher-level deployment tooling where Helm is incidental and not the control
  surface the user asked for

## Prerequisites

- `helm` available on `PATH`. If missing, read
  [references/installation.md](references/installation.md).
- The relevant kube context, namespace, and registry or repo access are known
- The chart path or release name is identified before mutating cluster state

## Workflow

1. Confirm the task type: chart authoring, render validation, package publishing,
   release operation, or troubleshooting.
2. Inspect current inputs before acting: chart files, values files, release
   status, and effective namespace.
3. Read [references/overview.md](references/overview.md) for the detailed
   workflow and choose the narrowest Helm command that matches the task.
4. Before `install` or `upgrade`, run `helm lint` and `helm template` with the
   same values inputs intended for deployment.
5. Use explicit values files and explicit namespace flags; prefer reviewable
   files over ad hoc CLI overrides.
6. For concrete command patterns, read
   [references/examples.md](references/examples.md).
7. If the operation fails or output does not match expectations, read
   [references/troubleshooting.md](references/troubleshooting.md).

## Hard Rules

- Always run `helm lint` and `helm template` before `install` or `upgrade`.
- Treat rendered manifests as the source of truth for behavioral review.
- Never put plaintext secrets in values tracked in git.
- Prefer values files over long `--set` chains for any repeatable workflow.
- Do not use `--reuse-values` unless the merged result is explicitly desired and
  reviewed.
- Use `--namespace` explicitly on release commands.
- Do not mutate Helm-managed resources manually unless the user explicitly asks
  for break-glass recovery.

## Failure Handling

- If chart validation fails, stop and fix the chart before touching the cluster.
- If rendering fails, reduce inputs and re-run with `helm template --debug`.
- If a release operation fails, inspect `status`, `history`, and effective
  values before retrying.
- If repo or registry auth fails, surface the exact failing command and missing
  prerequisite.

## Red Flags

- Editing generated manifests instead of chart sources
- `helm upgrade --install` used as a shortcut before render review
- Secrets passed on the command line or committed in values files
- Shared mutable values files across environments
- Dependency changes without `Chart.lock` review
- Namespace or release name inferred instead of stated
