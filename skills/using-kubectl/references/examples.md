# Using kubectl: Examples

## Contents

- Inspect failing deployment
- Trace CrashLoopBackOff quickly
- Validate service-to-pod wiring
- Preview and apply manifest safely
- Restart and monitor rollout
- Debug with ephemeral commands
- Permission troubleshooting
- Bulk operations with selectors

## Inspect failing deployment

```bash
kubectl get deploy <name> -n <namespace>
kubectl describe deploy <name> -n <namespace>
kubectl get rs -n <namespace> --sort-by=.metadata.creationTimestamp
kubectl get pods -l app=<label> -n <namespace> -o wide
```

## Trace CrashLoopBackOff quickly

```bash
kubectl get pods -n <namespace>
kubectl logs <pod> -n <namespace> --previous --tail=200
kubectl describe pod <pod> -n <namespace>
kubectl get events -n <namespace> --sort-by=.lastTimestamp
```

## Validate service-to-pod wiring

```bash
kubectl get svc <service> -n <namespace> -o yaml
kubectl get endpoints <service> -n <namespace> -o wide
kubectl get pods -l <selector> -n <namespace> --show-labels
```

If endpoints are empty, compare service selector labels with pod labels.

## Preview and apply manifest safely

```bash
kubectl --context <ctx> -n <namespace> diff -f k8s/
kubectl --context <ctx> -n <namespace> \
  apply --server-side --dry-run=server -f k8s/
kubectl --context <ctx> -n <namespace> apply -f k8s/
```

## Restart and monitor rollout

```bash
kubectl rollout restart deploy/<name> -n <namespace>
kubectl rollout status deploy/<name> -n <namespace> --timeout=5m
kubectl get pods -l app=<label> -n <namespace>
```

Rollback pattern:

```bash
kubectl rollout history deploy/<name> -n <namespace>
kubectl rollout undo deploy/<name> -n <namespace>
```

## Debug with ephemeral commands

```bash
kubectl exec -it pod/<pod> -n <namespace> -- sh
kubectl port-forward svc/<service> 8080:80 -n <namespace>
kubectl cp -n <namespace> <pod>:/tmp/report.txt ./report.txt
```

Use `exec` minimally in production and preserve auditability by recording
commands run.

## Permission troubleshooting

```bash
kubectl auth can-i list pods -n <namespace>
kubectl auth can-i patch deployment/<name> -n <namespace>
kubectl auth can-i --list -n <namespace>
```

If denied, report the missing verb and resource directly:

`Need RBAC permission: verb=patch resource=deployments namespace=<namespace>`

## Bulk operations with selectors

Safe bulk restart:

```bash
kubectl rollout restart deploy -l team=<team> -n <namespace>
```

Safe bulk inspection:

```bash
kubectl get pods -l app.kubernetes.io/part-of=<system> -n <namespace>
kubectl logs -l app=<label> -n <namespace> --all-containers --tail=100
```

Avoid broad operations without selectors or explicit resource names.
