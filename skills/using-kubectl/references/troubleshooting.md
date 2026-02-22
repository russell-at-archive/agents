# Using kubectl: Troubleshooting

## Contents

- Authentication and context issues
- RBAC denied operations
- Resource not found errors
- Apply conflicts and field ownership
- Pods not ready after rollout
- Image pull failures
- Scheduling failures
- Service reachable but no endpoints
- Unsafe command patterns to stop

## Authentication and context issues

Symptoms:

- `The connection to the server ... was refused`
- `You must be logged in to the server`
- Unexpected cluster data appears

Checks:

```bash
kubectl config current-context
kubectl config get-contexts
kubectl cluster-info
```

Fix:

- Re-authenticate for the target cluster.
- Switch context explicitly.
- Re-run a read-only command before any mutation.

## RBAC denied operations

Symptoms:

- `Error from server (Forbidden)`

Checks:

```bash
kubectl auth can-i <verb> <resource> -n <namespace>
```

Fix:

- Confirm verb, API resource, and namespace are correct.
- Request least-privilege role updates with exact missing permission.

## Resource not found errors

Symptoms:

- `Error from server (NotFound)` for known object

Checks:

```bash
kubectl get <kind> -A | rg <name>
kubectl api-resources | rg -i <kind>
```

Fix:

- Correct namespace.
- Use fully qualified resource kind if needed.
- Check whether object was renamed by Helm/Kustomize prefixes.

## Apply conflicts and field ownership

Symptoms:

- `Apply failed with conflicts`

Checks:

```bash
kubectl diff -f <path>
kubectl get <kind>/<name> -n <namespace> -o yaml
```

Fix:

- Align source manifest with live object ownership.
- Prefer server-side apply for managed field tracking.
- Avoid force-conflicts unless user explicitly accepts overwrite risk.

## Pods not ready after rollout

Symptoms:

- Deployment hangs with unavailable replicas

Checks:

```bash
kubectl rollout status deploy/<name> -n <namespace>
kubectl get pods -l app=<label> -n <namespace>
kubectl describe pod <pod> -n <namespace>
kubectl logs <pod> -n <namespace> --all-containers --tail=200
```

Fix:

- Resolve probe failures, config errors, or dependency timeouts.
- Check resource limits and node capacity.
- Roll back if blast radius grows and prior revision is healthy.

## Image pull failures

Symptoms:

- `ImagePullBackOff`, `ErrImagePull`

Checks:

```bash
kubectl describe pod <pod> -n <namespace>
```

Fix:

- Verify image tag exists.
- Validate imagePullSecrets and registry access.
- Confirm node egress to registry endpoints.

## Scheduling failures

Symptoms:

- Pod stays `Pending`

Checks:

```bash
kubectl describe pod <pod> -n <namespace>
kubectl get nodes
kubectl top nodes
```

Fix:

- Address taints/tolerations mismatch.
- Relax strict affinity or resource requests.
- Resolve quota or limit range constraints.

## Service reachable but no endpoints

Symptoms:

- Service exists but traffic fails

Checks:

```bash
kubectl get svc <service> -n <namespace> -o yaml
kubectl get endpoints <service> -n <namespace>
kubectl get pods -n <namespace> --show-labels
```

Fix:

- Align service selector labels to pod labels.
- Confirm pods are Ready and not excluded by readiness gates.

## Unsafe command patterns to stop

Stop and re-scope if any command includes:

- `kubectl delete all --all`
- Cluster-wide mutation without explicit context
- Ad-hoc `edit` on production objects with no source update plan
- Unbounded log streaming across namespaces during incidents

Replace with targeted selectors, explicit scope flags, and auditable commands.
