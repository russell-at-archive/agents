# Argo Workflows CLI: Examples

## Contents

- CI pipeline: submit and wait
- Submit with parameters (inline and file)
- Submit from a workflow template
- Submit from a cluster template
- Capture workflow name for scripting
- Monitor a running workflow
- Debug a failing workflow
- Get logs from a specific step or crashed container
- Approve a suspended step
- Retry from failure
- Resubmit with memoization
- Manage cron workflows
- Clean up completed workflows
- Lint and validate before submitting
- Archive operations

---

## CI Pipeline: Submit and Wait

The most important pattern — exits non-zero if the workflow fails.

```bash
argo submit -n argo workflow.yaml --wait
```

With parameters:

```bash
argo submit -n argo workflow.yaml \
  -p branch=main \
  -p commit="${GIT_SHA}" \
  --wait
```

---

## Submit with Parameters (Inline and File)

Inline `-p` flags override individual parameters. `-f` supplies a full
parameter file — useful when many parameters need to be set.

```bash
# Inline overrides
argo submit -n argo workflow.yaml \
  -p image=myapp:v2.3.1 \
  -p replicas=5 \
  -p region=us-west-2 \
  --wait

# From a YAML parameter file
cat params.yaml
# image: myapp:v2.3.1
# replicas: 5
# region: us-west-2

argo submit -n argo workflow.yaml -f params.yaml --wait

# Both: file sets defaults, inline flags override specific keys
argo submit -n argo workflow.yaml -f base-params.yaml -p image=myapp:hotfix --wait
```

---

## Submit from a Workflow Template

Templates live in the cluster and must exist before submission.

```bash
# List available templates
argo template list -n argo

# Submit an instance from a template
argo submit -n argo \
  --from workflowtemplate/ci-pipeline \
  -p branch=main \
  -p commit=abc1234 \
  --wait
```

---

## Submit from a Cluster Template

Cluster templates are namespace-agnostic — reference them from any namespace.

```bash
argo cluster-template list

argo submit -n argo \
  --from clusterworkflowtemplate/shared-build-pipeline \
  -p image=myapp:v2.0.0 \
  --wait
```

---

## Capture Workflow Name for Scripting

Submit without blocking, then wait or poll separately.

```bash
# -o name prints: workflow.argoproj.io/my-wf-abc12
NAME=$(argo submit -n argo workflow.yaml -o name)

# Strip the resource prefix for subsequent commands
WF="${NAME#workflow.argoproj.io/}"

# Wait for it separately
argo wait -n argo "$WF"

# Or gate on phase
PHASE=$(argo get -n argo "$WF" -o json | jq -r '.status.phase')
[[ "$PHASE" == "Succeeded" ]] || { echo "Workflow failed: $PHASE"; exit 1; }
```

---

## Monitor a Running Workflow

```bash
# Quick status check
argo get -n argo @latest

# Named workflow
argo get -n argo my-workflow-abc12

# Full YAML spec + status
argo get -n argo my-workflow-abc12 -o yaml

# Interactive live view (renders updating node tree in terminal)
argo watch -n argo my-workflow-abc12

# List all running workflows
argo list -n argo --running
```

---

## Debug a Failing Workflow

Work through this sequence systematically.

```bash
# 1. See overall status and which nodes failed
argo get -n argo my-workflow

# 2. Zoom in on failed nodes only
argo get -n argo my-workflow --node-field-selector phase=Failed

# 3. Get full YAML — check node message and outputs
argo get -n argo my-workflow -o yaml

# 4. Stream logs and grep for errors
argo logs -n argo my-workflow --grep "ERROR\|FATAL\|panic"

# 5. Check the pod directly (pod events reveal scheduling/image pull failures)
kubectl describe pod -n argo <pod-name>

# 6. List recent events in the namespace
kubectl get events -n argo --sort-by=.lastTimestamp | tail -20
```

**Error vs. Failed distinction:** `Error` means Kubernetes-level failure
(scheduling, image pull, init container crash) before the container ran. `Failed`
means the container ran and exited non-zero. For `Error`, read `kubectl describe pod`
events — `argo logs` will often be empty.

---

## Get Logs from a Specific Step or Crashed Container

```bash
# Find the pod ID from workflow status
argo get -n argo my-workflow -o json \
  | jq '.status.nodes | to_entries[]
        | select(.value.type=="Pod")
        | {name: .value.displayName, podId: .value.id}'

# Stream that pod's logs
argo logs -n argo my-workflow <pod-id> -c main --follow

# Crashed container — read previous run's logs
argo logs -n argo my-workflow <pod-id> --previous

# Filter by time
argo logs -n argo my-workflow --since=10m --timestamps

# Pipe-friendly output for grep/awk
argo logs -n argo my-workflow --no-color | grep "step failed"
```

---

## Approve a Suspended Step

Workflows pause at `suspend` template nodes waiting for manual approval.

```bash
# See that it is suspended
argo get -n argo my-workflow

# Resume all suspend nodes
argo resume -n argo my-workflow

# Resume a specific named approval step only
argo resume -n argo my-workflow \
  --node-field-selector displayName=await-approval

# Provide a "supplied" output parameter before resuming (e.g. approval decision)
argo node -n argo my-workflow \
  --node-field-selector displayName=await-approval \
  --output-parameter approved=true
argo resume -n argo my-workflow \
  --node-field-selector displayName=await-approval
```

---

## Retry from Failure

```bash
# Inspect before retrying — understand the root cause first
argo get -n argo my-workflow
argo logs -n argo my-workflow --grep "ERROR"

# Simple retry — resets Failed and Error nodes in place
argo retry -n argo my-workflow

# Retry from a specific step (resets it and all downstream nodes)
argo retry -n argo my-workflow \
  --node-field-selector templateName=deploy-step \
  --restart-successful

# Retry with a parameter override (e.g. different image)
argo retry -n argo my-workflow -p image=myapp:hotfix --wait

# Bulk retry all failed workflows with a label
argo retry -n argo -l app=myapp --wait
```

---

## Resubmit with Memoization

When you want a fresh workflow object (new name) but want to skip steps that
already succeeded in the previous run.

```bash
# Resubmit: new workflow, reuse completed steps from prior run
argo resubmit -n argo my-workflow --memoized --wait

# Resubmit with parameter override
argo resubmit -n argo my-workflow -p env=production --wait

# Resubmit without memoization — full re-run from scratch
argo resubmit -n argo my-workflow --wait
```

`--memoized` is the key flag here. It tells the new workflow to re-use
outputs from successfully completed steps in the prior run rather than
re-executing them.

---

## Manage Cron Workflows

```bash
# List all cron workflows
argo cron list -n argo

# Inspect schedule, last run, and active instances
argo cron get -n argo nightly-report
argo cron get -n argo nightly-report -o yaml

# Temporarily pause scheduling (e.g. during maintenance)
argo cron suspend -n argo nightly-report

# Re-enable scheduling
argo cron resume -n argo nightly-report

# Create from file
argo cron create -n argo cron.yaml

# Update schedule or parameters
argo cron update -n argo cron.yaml

# Lint before applying
argo cron lint cron.yaml

# Delete
argo cron delete -n argo nightly-report
```

---

## Clean Up Completed Workflows

Always dry-run bulk operations first.

```bash
# Preview what would be deleted
argo delete -n argo --completed --dry-run

# Delete all completed workflows in namespace
argo delete -n argo --completed

# Delete completed workflows older than 7 days
argo delete -n argo --completed --older 7d

# Delete by status
argo delete -n argo --status Failed,Error

# Delete by name prefix
argo delete -n argo --prefix nightly- --completed

# Delete a specific workflow
argo delete -n argo my-workflow-abc12
```

---

## Lint and Validate Before Submitting

```bash
# Lint a single file
argo lint workflow.yaml

# Lint an entire directory
argo lint workflows/

# Lint without a server connection (CI / offline)
argo lint --offline workflow.yaml

# Lint specific resource kinds
argo lint --kinds=workflowtemplates templates/

# Machine-readable output for CI parsing
argo lint --output=simple workflow.yaml

# Dry-run: show the fully resolved spec that would be submitted
argo submit -n argo workflow.yaml --dry-run -o yaml

# Server-side validate without persisting
argo submit -n argo workflow.yaml --server-dry-run
```

---

## Archive Operations

Archives require workflow archiving to be enabled in the controller config.
Archived workflows are addressed by **UID** (not name).

```bash
# List archived workflows
argo archive list -n argo

# Get a specific archived workflow (use UID from the list)
argo archive get <uid>

# List label keys present in the archive
argo archive list-label-keys -n argo

# List values for a specific label key
argo archive list-label-values -n argo --label-key=app

# Retry an archived workflow (creates a new run from the archive)
argo archive retry <uid> -n argo

# Resubmit an archived workflow
argo archive resubmit <uid> -n argo --memoized

# Delete from archive
argo archive delete <uid>
```
