---
name: using-kubectl
description: Provides expert guidance for using kubectl to inspect,
  troubleshoot, and operate Kubernetes clusters safely. Use when requests
  involve kubectl commands such as get, describe, logs, exec, apply, diff,
  delete, rollout, port-forward, top, auth can-i, or context and namespace
  management.
---

# Using kubectl

## Overview

kubectl is the control surface for Kubernetes API operations. Use explicit
context and namespace targeting, favor read-only inspection before mutation,
and apply changes with preview and rollback awareness. For full procedures,
read [references/overview.md](references/overview.md).

## When to Use

- Writing or reviewing `kubectl` commands
- Diagnosing workload failures, crash loops, scheduling issues, or service
  connectivity
- Applying, patching, deleting, or rolling out Kubernetes resources
- Managing contexts, namespaces, and RBAC permission checks
- Inspecting events, logs, metrics, and object state drift

## When Not to Use

- Helm chart authoring and release lifecycle tasks
- Kustomize design tasks where `kubectl` execution is only incidental
- Terraform or Atmos orchestration as the primary workflow

## Prerequisites

- `kubectl` installed and authenticated
- Reachable cluster and known target context
- Required RBAC permissions for requested operations

## Workflow

1. Identify target cluster, namespace, and resource scope before running
   commands.
2. Start with read-only inspection: `get`, `describe`, `logs`, and `events`.
3. Validate permissions and impact before mutating resources.
4. For changes, preview with `kubectl diff` or dry-run, then apply with
   explicit files and selectors.
5. Verify rollout and runtime health after changes.
6. For command templates and troubleshooting patterns, use
   [references/examples.md](references/examples.md) and
   [references/troubleshooting.md](references/troubleshooting.md).

## Hard Rules

- Always set context and namespace explicitly for mutating commands.
- Never run broad deletes (`delete all --all`) without explicit approval.
- Prefer label selectors and resource names over unconstrained list queries.
- Run `kubectl diff` or server dry-run before `apply` in shared clusters.
- Use `rollout status` after deploy changes; do not assume success on apply.
- Do not place secrets in shell history; use files, sealed secrets, or secret
  managers.

## Failure Handling

- Authentication failure: confirm kubeconfig, identity, and context.
- Authorization failure: run `kubectl auth can-i` and report missing verbs.
- NotFound errors: re-check namespace, API group, and resource kind.
- Apply conflicts: inspect managed fields, ownership, and drift before retry.
- Unhealthy rollout: inspect events, pod status, probes, and recent logs.

## Red Flags

- Running commands in the wrong context or default namespace.
- Editing live objects imperatively without source-of-truth updates.
- Deleting or scaling resources without rollout and dependency checks.
- Ignoring warnings from `kubectl diff`, admission webhooks, or policies.
