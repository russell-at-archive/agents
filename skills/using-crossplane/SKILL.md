---
name: using-crossplane
description: Provides expert guidance for working with Crossplane — the
  Kubernetes-native control plane framework for infrastructure as code. Use
  when the user asks about Crossplane providers, ProviderConfig, managed
  resources, Composite Resource Definitions (XRDs), Compositions, composite
  resources (XR), claims (XRC), composition functions, crossplane xpkg
  commands, crossplane beta render, crossplane beta trace, crossplane beta
  validate, or debugging Crossplane resource reconciliation.
---

# Using Crossplane

## Overview

Crossplane extends Kubernetes to provision and manage external infrastructure
declaratively. Platform teams define APIs (XRDs + Compositions); developers
consume them via namespaced Claims. Every resource reconciles continuously —
it is not a one-shot apply. For the full object model, CLI reference, and
composition authoring guide, read [references/overview.md](references/overview.md).

## When to Use

- Authoring or reviewing Crossplane manifests: Providers, ProviderConfigs,
  managed resources, XRDs, Compositions, Claims, Functions
- Writing or debugging Composition pipelines with `function-patch-and-transform`
  or custom Functions
- Running `crossplane xpkg`, `crossplane beta render`, `crossplane beta trace`,
  or `crossplane beta validate`
- Diagnosing `Synced: False` or `Ready: False` conditions on any Crossplane
  resource
- Installing Crossplane or a provider package via Helm or `crossplane xpkg`
- Designing a platform API (XRD + Composition) for a team

## When Not to Use

- Pure `kubectl` operations on non-Crossplane resources (use `using-kubectl`)
- Helm chart authoring not involving Crossplane packages
- Terraform/OpenTofu workflows (use `using-terraform`)
- Argo CD deployment tasks (use `using-argocd-cli`)

## Prerequisites

- `kubectl` authenticated to a cluster with Crossplane installed, **or**
- `crossplane` CLI installed (for offline render/validate)
- Target provider installed and `ProviderConfig` created with valid credentials
- Required RBAC to create XRDs, Compositions, and managed resources

## Workflow

1. Identify the Crossplane resource layer involved: managed resource, XR,
   Claim, XRD, Composition, or Provider package.
2. For debugging, run `crossplane beta trace <Kind>/<name>` first to see the
   full resource tree and conditions.
3. For Composition authoring, preview offline with `crossplane beta render`.
4. Validate schemas before applying with `crossplane beta validate`.
5. For full authoring patterns and YAML examples, read
   [references/examples.md](references/examples.md).
6. For error diagnosis, read
   [references/troubleshooting.md](references/troubleshooting.md).

## Hard Rules

- Never edit managed resource status or finalizers by hand.
- Always create a `ProviderConfig` before creating managed resources; a
  missing `ProviderConfig` is the most common first-time failure.
- Pin provider package versions explicitly — avoid `latest` in production.
- Use `crossplane beta render` to preview Composition output before applying
  to a live cluster.
- Delete Claims, not XRs directly; deleting the XR orphans the Claim.
- Prefer Composition `mode: Pipeline` with Functions over legacy
  `mode: Resources` for new Compositions.

## Failure Handling

- `Synced: False` on a managed resource: inspect `kubectl describe` message
  and provider pod logs in `crossplane-system`.
- Provider pod not starting: check `ProviderRevision` status and image pull
  errors.
- `crossplane beta render` fails: confirm all three YAML arguments are
  supplied and Functions are resolvable.
- XRD not generating a CRD: check `kubectl get xrd <name>` status for
  validation errors in the schema.

## Red Flags

- Creating managed resources without a matching `ProviderConfig`.
- Using `mode: Resources` in new Compositions instead of `mode: Pipeline`.
- Deleting XRs directly instead of deleting the Claim.
- Ignoring `Synced: False` and applying more resources on top of a broken
  reconciliation loop.
- Storing cloud credentials in plain Kubernetes Secrets without RBAC controls.
