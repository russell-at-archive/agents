---
name: using-helm
description: Provides expert guidance for working with Helm, the Kubernetes
  package manager for templating, packaging, installing, and operating
  Kubernetes applications as charts and releases. Use when the user asks about
  Helm charts, Chart.yaml, values.yaml, templates, helm lint/template/install/
  upgrade/rollback, dependencies, OCI registries, or Helm release debugging.
---

# Using Helm

## Overview

Helm manages Kubernetes applications as versioned chart packages rendered into
manifest YAML and tracked as releases per namespace. It enables reusable app
packaging, values-driven configuration, and repeatable upgrades/rollbacks. For
full procedures and guardrails, read
[references/overview.md](references/overview.md).

## When to Use

- Authoring or editing `Chart.yaml`, `values.yaml`, or `templates/*.yaml`
- Creating, packaging, or publishing charts
- Running `helm lint`, `helm template`, `helm install`, `helm upgrade`
- Managing release lifecycle: `helm history`, `helm rollback`, `helm uninstall`
- Handling chart dependencies and repository/OCI workflows
- Debugging rendered manifests, failed releases, and value merge behavior

## When Not to Use

- Raw Kubernetes YAML workflows with no chart abstraction required
- Kustomize-first customization tasks without Helm release management
- Terraform/Atmos orchestration tasks where Helm is only incidental

## Prerequisites

- `helm` v3 installed and on PATH
- Cluster context configured (`kubectl config current-context` is valid)
- Access to required chart repos or OCI registries

## Workflow

1. Inspect chart structure and release context before editing.
   See [references/overview.md](references/overview.md) for the full process.
2. Validate chart syntax and rendered output locally:
   `helm lint` then `helm template`.
3. For installs/upgrades, use explicit values files and review output diff.
4. Use safe rollout flags for changes with cluster impact (`--wait --atomic`).
5. If deployment fails or behavior diverges, use
   [references/troubleshooting.md](references/troubleshooting.md).
6. For concrete command patterns, use
   [references/examples.md](references/examples.md).

## Hard Rules

- Always run `helm lint` and `helm template` before `install` or `upgrade`.
- Never put plaintext secrets in chart values tracked in git.
- Prefer values files over long `--set` chains for non-trivial configuration.
- Do not use `--reuse-values` blindly; confirm merged results first.
- Pin dependency versions; avoid floating chart tags in production.
- Use `--namespace` explicitly on release commands to avoid wrong-target deploys.

## Failure Handling

- If `helm lint` fails, fix chart schema/template issues before cluster changes.
- If rendering fails, isolate with `helm template --debug` and minimal values.
- If upgrade fails, inspect release history and rollback path before retrying.
- If repository/OCI auth fails, report exact command error and auth prerequisite.

## Red Flags

- Editing generated release manifests instead of chart sources
- `helm upgrade --install` in production without rendering/review
- Secrets passed via CLI flags that may leak to shell history
- Multiple environments sharing one mutable values file
- Dependency updates without lockfile or version review
