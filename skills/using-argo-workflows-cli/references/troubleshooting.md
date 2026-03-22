# Argo Workflows CLI: Troubleshooting

## Contents

- Server unreachable
- Authentication denied
- TLS errors
- Version mismatch errors
- Workflow stuck in Pending
- Step in Error state (vs. Failed)
- CrashLoopBackOff in workflow pod
- Workflow never reaches a step (Omitted)
- Retry does not re-run expected steps
- Cron workflow not triggering
- Unsafe command patterns

---

## Server Unreachable

Symptoms: `dial tcp: connection refused`, `transport: Error while dialing`

```bash
echo $ARGO_SERVER    # must be host:port with NO https:// prefix
echo $ARGO_SECURE    # false for local dev, true for remote
kubectl get pods -n argo -l app=argo-server
kubectl get svc -n argo
```

Fix:

- `ARGO_SERVER` must be `host:port` format — no scheme prefix.
- Set `ARGO_SECURE=false` for local port-forwarded connections.
- Port-forward if you cannot reach the server directly:

```bash
kubectl port-forward svc/argo-server 2746:2746 -n argo
export ARGO_SERVER=localhost:2746
export ARGO_SECURE=false
```

---

## Authentication Denied

Symptoms: `code = Unauthenticated`, `401 Unauthorized`

```bash
argo auth token      # print what token the CLI is using
echo $ARGO_TOKEN     # must start with "Bearer " (space included)
```

Fix:

- `ARGO_TOKEN` must be exactly `"Bearer <token>"` — the literal `Bearer `
  prefix including the space is required.
- If the token is expired, re-generate from the service account secret:

```bash
TOKEN=$(kubectl get secret ci-runner.service-account-token \
  -n argo -o jsonpath='{.data.token}' | base64 -d)
export ARGO_TOKEN="Bearer $TOKEN"
```

- Confirm the service account has the required RBAC verbs in the target
  namespace.

---

## TLS Errors

Symptoms: `x509: certificate signed by unknown authority`,
`tls: failed to verify certificate`

For development / self-signed certs:

```bash
argo list -n argo -k                         # per-command
export ARGO_INSECURE_SKIP_VERIFY=true        # session-wide
```

For production, supply the CA certificate:

```bash
argo list -n argo --certificate-authority /path/to/ca.crt
```

Never use `-k` / `--insecure-skip-verify` in production without explicit
approval from the security owner.

---

## Version Mismatch Errors

Symptoms: `unknown flag`, missing subcommands, unexpected output format

```bash
# Check CLI version
argo version

# Find server version
kubectl -n argo get deploy argo-server \
  -o jsonpath='{.spec.template.spec.containers[0].image}'
```

Fix: Download the CLI matching the server version. The server exposes its own
matching binary at its `/assets` endpoint — no GitHub lookup required:

```bash
curl -sL https://<argo-server-host>/assets/argo-linux-amd64.gz \
  | gunzip > argo && chmod +x argo && sudo mv argo /usr/local/bin/argo
```

---

## Workflow Stuck in Pending

Symptoms: `argo get` shows `Running` but all steps are `Pending`; pods never
appear in `kubectl get pods`

```bash
kubectl get pods -n argo -l workflows.argoproj.io/workflow=<name>
kubectl describe pod -n argo <pod-name>
kubectl get events -n argo --sort-by=.lastTimestamp | tail -20
kubectl top nodes
```

Fix:

- **Resource pressure**: nodes are out of CPU/memory/storage. Adjust resource
  requests in the workflow template or add cluster capacity.
- **Taint/toleration mismatch**: add tolerations to the workflow pod spec or
  choose a different node pool.
- **Image pull failure**: the pod cannot pull the container image. Check
  `imagePullSecrets` and registry access.
- **PVC not bound**: if the workflow uses a volume, confirm the PVC bound to a PV.

---

## Step in Error State (vs. Failed)

This distinction matters for how you diagnose and fix the issue.

- **`Failed`**: the container ran and exited with a non-zero exit code. Read
  `argo logs` to see what the script/process output.
- **`Error`**: the pod never successfully ran the container — this is a
  Kubernetes-level failure (scheduling, image pull, init container,
  config map not found, etc.). `argo logs` will often be empty.

```bash
# For Error: read pod events, not logs
argo get -n argo my-workflow -o yaml   # check node message field
kubectl describe pod -n argo <pod-name>

# For Failed: read logs
argo logs -n argo my-workflow <pod-id>
argo logs -n argo my-workflow <pod-id> --previous  # if container restarted
```

---

## CrashLoopBackOff in Workflow Pod

Symptoms: pod status shows `CrashLoopBackOff`; Argo step shows `Failed`

```bash
argo logs -n argo my-workflow <pod-name> --previous
kubectl describe pod -n argo <pod-name>
```

Fix:

- The previous container's logs contain the actual crash reason — read them
  with `--previous`.
- Fix the script, command, or entrypoint in the workflow template.
- Only use `argo retry` after the root cause is resolved; retrying a broken
  template just reproduces the crash.

---

## Workflow Never Reaches a Step (Omitted)

Symptoms: workflow shows `Running` but downstream steps show `Omitted`

```bash
argo get -n argo my-workflow
argo get -n argo my-workflow -o yaml
```

Fix:

- `Omitted` means the step was skipped because a `when:` condition evaluated
  to false, or a DAG dependency was not satisfied.
- Inspect the upstream step's output parameters that drive the `when:` expression.
- Use `--dry-run` to preview parameter resolution before submitting.
- For DAG: check the `dependencies` list — any dependency that failed or was
  omitted propagates to dependents.

---

## Retry Does Not Re-Run Expected Steps

Symptoms: `argo retry` completes quickly but skips expected steps

```bash
argo get -n argo my-workflow -o json | jq '.status.nodes | to_entries[]
  | {name: .value.displayName, phase: .value.phase}'
```

Fix:

- By default, `argo retry` only resets `Failed` and `Error` nodes. Steps in
  `Succeeded` state are left as-is.
- Add `--restart-successful` together with `--node-field-selector` to include
  successful steps in the retry scope:

```bash
argo retry -n argo my-workflow \
  --node-field-selector templateName=flaky-step \
  --restart-successful
```

- If you want a full re-run, use `argo resubmit` instead of `argo retry`.

---

## Cron Workflow Not Triggering

Symptoms: no recent runs; `argo cron get` shows no activity

```bash
argo cron get -n argo <cron-name>
kubectl get events -n argo --sort-by=.lastTimestamp
```

Fix:

- **Suspended**: if `suspended: true`, run `argo cron resume -n argo <cron-name>`.
- **Bad schedule**: verify the cron syntax is 5-field (`* * * * *`). The
  `timezone` field uses IANA format (e.g. `America/New_York`).
- **Controller unhealthy**: check workflow-controller pod logs for errors.
- **Concurrent policy**: if `concurrencyPolicy: Forbid` and a previous run is
  still active, the new run is skipped.

```bash
kubectl logs -n argo -l app=workflow-controller --tail=50
```

---

## Unsafe Command Patterns

Stop and re-scope before running any of these:

| Pattern | Risk | Safer alternative |
|---------|------|-------------------|
| `argo delete -n <ns> --all` | Deletes every workflow in namespace | Use `--status`, `--prefix`, or `--older` to scope |
| `argo terminate` without prior `argo get` | May terminate the wrong workflow | Always `argo get` first to confirm the target |
| `--insecure-skip-verify` in production | Disables cert validation | Supply `--certificate-authority` with the CA cert |
| `ARGO_TOKEN=...` inline in scripts committed to source control | Token leak | Use a secret manager or CI secret injection |
| `argo delete -n <ns> --all-namespaces` | Cluster-wide deletion | Confirm scope with `argo list -A` first |
