# Using argo (Argo Workflows CLI): Troubleshooting

## Contents

- Server unreachable
- Authentication denied
- Version mismatch errors
- Workflow stuck in Pending
- Step in Error state
- CrashLoopBackOff in workflow pod
- Workflow never reaches a step
- Retry does not re-run expected steps
- Cron workflow not triggering
- Unsafe command patterns to stop

## Server Unreachable

Symptoms:

- `dial tcp: connection refused`
- `transport: Error while dialing`

Checks:

```bash
echo $ARGO_SERVER
echo $ARGO_SECURE
kubectl get svc -n argo
kubectl port-forward svc/argo-server 2746:2746 -n argo
```

Fix:

- Set `ARGO_SERVER` to `<host>:<port>` without `https://` prefix.
- Set `ARGO_SECURE=false` for local port-forwarded access.
- Confirm the Argo Server pod is running in the target namespace.

## Authentication Denied

Symptoms:

- `code = Unauthenticated`
- `401 Unauthorized`

Checks:

```bash
argo auth token
echo $ARGO_TOKEN
```

Fix:

- Ensure `ARGO_TOKEN` starts with `"Bearer "` (including the space).
- Re-generate the token from the service account secret if expired.
- Confirm the service account has correct RBAC roles in the target
  namespace.

## Version Mismatch Errors

Symptoms:

- `unknown flag` errors
- Unexpected output format
- Missing commands that exist in docs

Checks:

```bash
argo version
kubectl -n argo get deploy argo-server -o jsonpath='{.spec.template.spec.containers[0].image}'
```

Fix:

- Download the CLI version matching the server from the server's
  `/assets` endpoint or GitHub releases.
- Never mix major versions between CLI and server.

## Workflow Stuck in Pending

Symptoms:

- `argo get` shows `Running` but all steps show `Pending`
- Pods never appear with `kubectl get pods`

Checks:

```bash
kubectl describe pod -n <namespace> -l workflows.argoproj.io/workflow=<name>
kubectl get events -n <namespace> --sort-by=.lastTimestamp
kubectl top nodes
```

Fix:

- Check for node resource pressure (CPU, memory, ephemeral storage).
- Resolve taints/tolerations or affinity constraints on the pod spec.
- Confirm image pull secrets are present if using a private registry.

## Step in Error State

Symptoms:

- `argo get` shows a step in `Error` (not `Failed`)
- Step errored before the container ran

Checks:

```bash
argo get -n <namespace> <workflow-name> -o yaml
argo logs -n <namespace> <workflow-name> --follow
kubectl describe pod -n <namespace> <pod-name>
```

Fix:

- `Error` usually indicates a Kubernetes-level failure (scheduling,
  image pull, init container). Read pod events, not just logs.
- Fix the underlying resource or spec issue before retrying.

## CrashLoopBackOff in Workflow Pod

Symptoms:

- Pod status shows `CrashLoopBackOff` in `kubectl get pods`
- Argo step shows `Failed`

Checks:

```bash
argo logs -n <namespace> <workflow-name> <pod-name> --previous
kubectl describe pod -n <namespace> <pod-name>
```

Fix:

- Read the previous container logs for the actual exit reason.
- Fix the script or command in the workflow template.
- Use `argo retry` only after the root cause is resolved.

## Workflow Never Reaches a Step

Symptoms:

- Workflow shows `Running` but downstream steps show `Omitted`

Checks:

```bash
argo get -n <namespace> <workflow-name>
```

Fix:

- `Omitted` steps are skipped due to `when` conditions or DAG
  dependencies not being met.
- Review the upstream step output parameters referenced by `when:` clauses.
- Use `--dry-run` to preview parameter resolution.

## Retry Does Not Re-Run Expected Steps

Symptoms:

- `argo retry` completes but skips expected failed steps

Checks:

```bash
argo get -n <namespace> <workflow-name> -o yaml | grep phase
```

Fix:

- By default, `argo retry` only resets `Failed` and `Error` nodes.
- Add `--restart-successful` with `--node-field-selector` to include
  successful upstream steps in the retry scope.

## Cron Workflow Not Triggering

Symptoms:

- Cron workflow shows no recent runs
- `argo cron get` shows `suspended: true`

Checks:

```bash
argo cron get -n <namespace> <cron-name>
kubectl get cronjob -n <namespace>
kubectl get events -n <namespace> --sort-by=.lastTimestamp
```

Fix:

- Run `argo cron resume -n <namespace> <cron-name>` if suspended.
- Validate the cron schedule syntax (`* * * * *` format).
- Check that the timezone field is set correctly if using non-UTC schedules.

## Unsafe Command Patterns to Stop

Stop and re-scope if any command includes:

- `argo delete -n <namespace> --all` — confirm scope before bulk deletes
- `argo terminate` without first running `argo get` — may terminate the
  wrong workflow
- `--insecure-skip-verify` in shared or production clusters
- Setting `ARGO_TOKEN` inline in shell scripts committed to source control

Replace with explicit names, scoped selectors, and secrets management.
