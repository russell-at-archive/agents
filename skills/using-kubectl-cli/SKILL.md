---
name: using-kubectl-cli
description: Provides expert guidance for operating Kubernetes safely with
  kubectl. Use when requests involve kubectl commands, cluster inspection,
  rollout debugging, pod logs, apply or patch workflows, port-forward, exec,
  auth can-i, contexts, namespaces, or Kubernetes incident response.
---

# Using kubectl

## Overview

Treat `kubectl` as an operational sequence: scope, observe, decide, mutate,
verify. Keep `SKILL.md` focused on command posture and route detailed
procedures to the reference files:

- Read [references/overview.md](references/overview.md) for the default
  operating model, pre-flight checks, output modes, and patch strategy.
- Read [references/examples.md](references/examples.md) when the user needs
  concrete command patterns for diagnosis, rollout, restart, `exec`, or
  `port-forward`.
- Read [references/troubleshooting.md](references/troubleshooting.md) when the
  task involves `Forbidden`, `NotFound`, rollout failures, image pull issues,
  scheduling failures, or service/endpoints mismatches.
- Read [references/installation.md](references/installation.md) if `kubectl`
  is missing or the user asks how to install or upgrade it.

## When to Use

- Writing or reviewing `kubectl` commands
- Diagnosing cluster, workload, service, RBAC, or rollout problems
- Applying, patching, scaling, deleting, or restarting Kubernetes resources
- Working with contexts, namespaces, selectors, events, logs, or `top`
- Debugging incidents where safe scoping and verification matter

## When Not to Use

- Helm, Kustomize, Argo CD, or Terraform workflows are the primary task
- The user needs Kubernetes architecture theory rather than CLI operations
- The request is cluster-specific policy design, not resource operation

## Prerequisites

- `kubectl` installed and authenticated; if not, read
  [references/installation.md](references/installation.md)
- Known target context and namespace, or an explicit plan to discover them
- RBAC permission to inspect or mutate the requested resources

## Workflow

1. Confirm scope first: cluster context, namespace, resource kind, and name or
   selector.
2. Start read-only unless the user explicitly requests emergency containment.
3. Use the smallest high-signal commands first: `get`, `describe`, `logs`,
   `events`, `top`, `auth can-i`, and `explain`.
4. Prefer targeted queries over cluster-wide commands; use `-A` only when the
   problem is genuinely cross-namespace.
5. Before mutation, check permissions and preview impact with `diff` or
   server-side dry-run when possible.
6. Prefer declarative `apply` from source-controlled files over ad-hoc live
   edits or manual drift.
7. After every change, verify rollout, pod readiness, events, and service
   wiring.
8. Pull exact command sequences from [references/examples.md](references/examples.md)
   and failure-specific recovery steps from
   [references/troubleshooting.md](references/troubleshooting.md).

## Hard Rules

- Always make the target context and namespace explicit before mutating.
- Never run broad destructive commands such as `delete all --all` without
  explicit user approval.
- Prefer names, labels, and narrow selectors over unconstrained queries.
- Use `kubectl diff` or `--dry-run=server` before `apply` in shared clusters.
- Treat `kubectl edit` and imperative hotfixes as exceptions; if used, call out
  the required follow-up to reconcile source of truth.
- Use `rollout status` or equivalent health checks after changes; do not assume
  `apply` means success.
- Do not put secrets or raw credentials into shell history or inline patches.

## Failure Handling

- Auth or connectivity failure: confirm kubeconfig, identity, and active
  context before doing anything else.
- RBAC denial: run `kubectl auth can-i` and report the exact missing
  verb/resource/namespace.
- `NotFound`: re-check namespace, kind, API group, and naming prefixes.
- Apply conflict: inspect live state and field ownership before retrying.
- Unhealthy rollout: inspect events, probes, logs, scheduling, and endpoints
  before recommending rollback.

## Red Flags

- Running in the default namespace by accident
- Mutating the wrong cluster because context was assumed, not checked
- Using cluster-wide list or delete commands when a selector would do
- Editing live objects with no plan to update GitOps or manifest sources
- Ignoring warnings from admission, diff output, rollout status, or events
