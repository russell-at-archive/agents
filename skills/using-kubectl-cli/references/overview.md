# Using kubectl: Overview

## Contents

- Command posture
- Pre-flight checks
- Read-only diagnosis flow
- Safe mutation flow
- Rollout verification flow
- Context and namespace discipline
- Output and query patterns
- Patch strategy
- High-signal command set

## Command posture

Treat `kubectl` usage as a sequence:

1. Scope: set context and namespace.
2. Observe: gather facts with read-only commands.
3. Decide: identify root cause or intended change.
4. Mutate: apply minimal, auditable change.
5. Verify: confirm health and rollback path.

Never begin with mutation unless the user explicitly requests emergency
containment.

## Pre-flight checks

Run these checks before non-trivial work:

```bash
kubectl config current-context
kubectl get ns
kubectl auth can-i get pods -n <namespace>
```

For mutation checks:

```bash
kubectl auth can-i apply deployments -n <namespace>
kubectl auth can-i patch deployments -n <namespace>
```

If permission is missing, stop and report exact verb/resource/namespace.

## Read-only diagnosis flow

Use this order for most incidents:

1. List objects and status.
2. Inspect object details.
3. Check events by recency.
4. Inspect container logs.
5. Inspect resource pressure and node placement.

Commands:

```bash
kubectl get deploy,rs,pods -n <namespace> -o wide
kubectl describe pod <pod> -n <namespace>
kubectl get events -n <namespace> --sort-by=.lastTimestamp
kubectl logs <pod> -n <namespace> --all-containers --tail=200
kubectl top pod -n <namespace>
kubectl get pod <pod> -n <namespace> -o jsonpath='{.spec.nodeName}'
```

Prefer targeted queries over cluster-wide `-A` when urgency is low.

## Safe mutation flow

For declarative resources:

1. Preview with `diff` or dry-run.
2. Apply from files tracked in source control.
3. Verify rollout and availability.

```bash
kubectl diff -f <path>
kubectl apply --server-side --dry-run=server -f <path>
kubectl apply -f <path>
kubectl rollout status deploy/<name> -n <namespace> --timeout=5m
```

For imperative emergency changes, keep them minimal and document follow-up to
backport into source-of-truth manifests.

## Rollout verification flow

After applying workload changes, check:

1. Desired vs available replicas.
2. Pod readiness and restart count.
3. Recent warnings/events.
4. Service endpoint population.

```bash
kubectl get deploy <name> -n <namespace>
kubectl get pods -l app=<label> -n <namespace>
kubectl get events -n <namespace> --sort-by=.lastTimestamp
kubectl get endpoints <service> -n <namespace>
```

Use `kubectl rollout undo deploy/<name>` only after confirming the previous
revision is healthy.

## Context and namespace discipline

Use explicit flags for any mutating command:

```bash
kubectl --context <ctx> -n <namespace> apply -f <path>
```

Set temporary defaults only when working repeatedly in one scope:

```bash
kubectl config set-context --current --namespace=<namespace>
```

Immediately re-check context after switching clusters.

## Output and query patterns

Use output modes intentionally:

- `-o wide` for placement and IP details
- `-o yaml` for full object inspection
- `-o jsonpath=...` for script-friendly extraction
- `-o custom-columns=...` for quick tabular triage

Examples:

```bash
kubectl get pods -n <namespace> \
  -o custom-columns='NAME:.metadata.name,PH:.status.phase,ND:.spec.nodeName'
kubectl get pod <pod> -n <namespace> -o jsonpath='{.status.phase}'
```

## Patch strategy

Prefer declarative apply over patch when possible. If patch is required:

- Use `--type merge` for small map-like changes.
- Use `--type json` for precise list index operations.
- Avoid ad-hoc patches for long-lived config drift.

Example:

```bash
kubectl patch deploy <name> -n <namespace> \
  --type merge -p '{"spec":{"replicas":3}}'
```

## High-signal command set

Keep these commands close:

- Discovery: `api-resources`, `api-versions`, `explain`
- State: `get`, `describe`, `events`, `logs`, `top`
- Access: `auth can-i`, `whoami` (if plugin available)
- Change: `diff`, `apply`, `patch`, `scale`, `rollout`
- Network/debug: `port-forward`, `exec`, `cp`

Use `kubectl explain <kind> --recursive` when uncertain about fields.
