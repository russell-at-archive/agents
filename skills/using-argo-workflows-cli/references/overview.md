# Argo Workflows CLI: Overview

## Contents

- Environment and authentication
- Global flags
- Submit workflows
- List and inspect
- Stream logs
- Workflow lifecycle (wait, watch, stop, terminate, suspend, resume)
- Retry and resubmit
- Delete workflows
- Lint and validate
- Template management
- Cron workflow management
- Cluster template management
- Archive operations
- Node operations
- Output formats
- Node field selectors

---

## Environment and Authentication

```bash
export ARGO_SERVER=argo.example.com:2746   # host:port — NO https:// prefix
export ARGO_TOKEN="Bearer <token>"          # literal "Bearer " prefix required
export ARGO_NAMESPACE=argo                  # optional default namespace
export ARGO_SECURE=true                     # false only for non-TLS local dev
export ARGO_INSECURE_SKIP_VERIFY=false      # corresponds to -k flag
```

Check what token the CLI is using: `argo auth token`

Skip TLS verification (non-production only):

```bash
argo list -n argo -k
# or
export ARGO_INSECURE_SKIP_VERIFY=true
```

---

## Global Flags

These flags work on every subcommand:

| Flag | Short | Description |
|------|-------|-------------|
| `--namespace` | `-n` | Kubernetes namespace (always pass explicitly) |
| `--argo-server` | `-s` | API server host:port (overrides ARGO_SERVER) |
| `--token` | | Bearer token (overrides ARGO_TOKEN) |
| `--secure` | `-e` | Use TLS (default: true) |
| `--insecure-skip-verify` | `-k` | Skip cert validation (non-production only) |
| `--kubeconfig` | | Path to kubeconfig |
| `--context` | | Kubeconfig context name |
| `--loglevel` | | debug\|info\|warn\|error |
| `--verbose` | `-v` | Shorthand for --loglevel debug |
| `--output` | `-o` | name\|json\|yaml\|wide (where applicable) |
| `--request-timeout` | | Per-request timeout |
| `--instanceid` | | Controller instance ID label |

---

## Submit Workflows

```bash
argo submit -n <ns> workflow.yaml
```

Key flags:

| Flag | Short | Description |
|------|-------|-------------|
| `--wait` | `-w` | Block until done; exit non-zero on failure |
| `--watch` | | Stream live node-tree until done |
| `--log` | | Stream logs until done |
| `--parameter` | `-p` | Override input parameter: `-p key=value` (repeatable) |
| `--parameter-file` | `-f` | YAML/JSON file of all input parameters |
| `--from` | | Submit from existing resource: `workflowtemplate/<name>`, `cronwf/<name>`, `clusterworkflowtemplate/<name>` |
| `--entrypoint` | | Override `spec.entrypoint` |
| `--name` | | Override `metadata.name` |
| `--generate-name` | | Override `metadata.generateName` |
| `--labels` | `-l` | Comma-separated labels to apply |
| `--serviceaccount` | | Run all pods as this service account |
| `--priority` | | Workflow priority |
| `--dry-run` | | Resolve and print spec client-side without creating |
| `--server-dry-run` | | Server validates without persisting |
| `--output` | `-o` | name\|json\|yaml\|wide |

```bash
# CI-safe: submit and wait, exit non-zero on failure
argo submit -n argo workflow.yaml --wait

# Capture workflow name for later use
NAME=$(argo submit -n argo workflow.yaml -o name)

# Submit from template with parameters
argo submit -n argo --from workflowtemplate/ci-pipeline \
  -p branch=main -p commit=abc1234 --wait

# Submit with parameter file
argo submit -n argo workflow.yaml -f params.yaml --wait

# Server-side validate without creating
argo submit -n argo workflow.yaml --server-dry-run

# Preview resolved spec client-side
argo submit -n argo workflow.yaml --dry-run -o yaml
```

---

## List and Inspect

```bash
argo list -n <ns>
argo get -n <ns> <workflow-name>
argo get -n <ns> @latest
```

### argo list flags

| Flag | Short | Description |
|------|-------|-------------|
| `--all-namespaces` | `-A` | Show all namespaces |
| `--running` | | Show running workflows only |
| `--completed` | | Show completed workflows only |
| `--status` | | Filter: `Pending,Running,Succeeded,Failed,Error` |
| `--prefix` | | Filter by name prefix |
| `--selector` | `-l` | Label selector |
| `--field-selector` | | Field query filter |
| `--since` | | Show workflows created after duration (e.g. `1h`) |
| `--older` | | Show completed workflows finished before duration (e.g. `7d`) |
| `--output` | `-o` | name\|json\|yaml\|wide |
| `--limit` | | Maximum results |
| `--chunk-size` | | Paginate large lists |
| `--no-headers` | | Suppress column headers |

```bash
argo list -n argo --running
argo list -n argo --status Failed,Error
argo list -n argo --prefix nightly- --completed
argo list -n argo --since 1h
argo list -n argo --completed --older 7d
argo list -n argo -A -o wide
```

### argo get flags

| Flag | Description |
|------|-------------|
| `--output` / `-o` | name\|json\|yaml\|short\|wide |
| `--node-field-selector` | Filter displayed nodes |
| `--status` | Filter nodes by phase |
| `--no-color` | Suppress colored output |

```bash
argo get -n argo my-workflow -o yaml
argo get -n argo my-workflow -o json | jq '.status.phase'
argo get -n argo my-workflow --node-field-selector phase=Failed
```

---

## Stream Logs

```bash
argo logs -n <ns> <workflow-name> [pod-name]
```

Omit `pod-name` to aggregate logs across all pods. Include it to target a
specific step's pod.

| Flag | Short | Description |
|------|-------|-------------|
| `--follow` | `-f` | Stream continuously |
| `--tail` | | Return last N lines |
| `--since` | | Only logs newer than duration (e.g. `5m`) |
| `--since-time` | | Only logs after RFC3339 timestamp |
| `--grep` | | Filter lines matching pattern |
| `--timestamps` | | Prefix each line with timestamp |
| `--no-color` | | Suppress colorized output (useful for piping) |
| `--container` | `-c` | Container name (default: `main`) |
| `--previous` | `-p` | Logs from previous (terminated) container |
| `--selector` | `-l` | Pod label selector |

```bash
argo logs -n argo my-workflow --follow
argo logs -n argo my-workflow --tail=200 --timestamps
argo logs -n argo my-workflow --grep "ERROR"
argo logs -n argo my-workflow --since=10m
argo logs -n argo my-workflow <pod-name> --previous   # crashed container
argo logs -n argo my-workflow --no-color | grep WARN  # pipe-friendly
```

---

## Wait and Watch

### argo wait

Block until the workflow reaches a terminal state. Use when you submitted
without `--wait`.

```bash
argo wait -n argo my-workflow
argo wait -n argo my-workflow --ignore-not-found
```

### argo watch

Render a live-updating node-tree until completion (interactive terminal use).

```bash
argo watch -n argo my-workflow
argo watch -n argo my-workflow --node-field-selector phase=Running
```

---

## Stop and Terminate

### argo stop (graceful)

Marks the workflow as `Stopped` and allows exit handlers to run. Prefer this
over `terminate` when cleanup matters.

```bash
argo stop -n argo my-workflow
argo stop -n argo my-workflow --message "stopped: maintenance window"
argo stop -n argo -l app=myapp --dry-run
```

Flags: `--message`, `--node-field-selector`, `--selector`/`-l`,
`--field-selector`, `--dry-run`

### argo terminate (hard stop)

Immediately kills the workflow without running exit handlers. Use only when
`stop` is insufficient.

```bash
argo terminate -n argo my-workflow
argo terminate -n argo -l app=myapp --dry-run
```

---

## Suspend and Resume

### argo suspend

Pauses the workflow at the next `suspend` template node; does not kill running
pods.

```bash
argo suspend -n argo my-workflow
```

### argo resume

Releases a suspended workflow. Target a specific node with
`--node-field-selector` to approve a named approval step.

```bash
argo resume -n argo my-workflow
argo resume -n argo my-workflow --node-field-selector displayName=await-approval
```

---

## Retry and Resubmit

**Key distinction:**
- `argo retry` — resets failed/error nodes in-place on the same workflow object
- `argo resubmit` — creates a new workflow object (new name, fresh state)

### argo retry

```bash
argo retry -n argo my-workflow
```

| Flag | Short | Description |
|------|-------|-------------|
| `--node-field-selector` | | Scope retry to matching nodes |
| `--restart-successful` | | Also restart successful nodes in the selector scope |
| `--parameter` | `-p` | Override input parameters |
| `--wait` | `-w` | Wait for completion |
| `--watch` | | Watch until completion |
| `--selector` | `-l` | Label selector for bulk retry |
| `--field-selector` | | Field selector for bulk retry |

```bash
# Retry from a specific step (resets it and all downstream)
argo retry -n argo my-workflow \
  --node-field-selector templateName=build-step \
  --restart-successful

# Retry all failed workflows with a label
argo retry -n argo -l app=myapp

# Retry with parameter override
argo retry -n argo my-workflow -p env=production --wait
```

### argo resubmit

```bash
argo resubmit -n argo my-workflow
```

| Flag | Short | Description |
|------|-------|-------------|
| `--memoized` | | Re-use successful steps and outputs from the previous run |
| `--parameter` | `-p` | Override input parameters |
| `--priority` | | Set workflow priority |
| `--wait` | `-w` | Wait for completion |
| `--watch` | | Watch until completion |

```bash
# Resubmit reusing cached successful steps (most common recovery pattern)
argo resubmit -n argo my-workflow --memoized --wait

# Resubmit with new parameters
argo resubmit -n argo my-workflow -p env=production --wait
```

---

## Delete Workflows

Always dry-run first for bulk operations.

```bash
argo delete -n argo my-workflow
argo delete -n argo --completed --dry-run
argo delete -n argo --completed
argo delete -n argo --completed --older 7d
argo delete -n argo --status Failed,Error
argo delete -n argo --prefix nightly- --completed
```

| Flag | Short | Description |
|------|-------|-------------|
| `--all` | | Delete all workflows in namespace |
| `--completed` | | Delete completed workflows |
| `--older` | | Delete completed workflows finished before duration |
| `--status` | | Delete by status (comma-separated) |
| `--prefix` | | Delete by name prefix |
| `--selector` | `-l` | Label selector |
| `--field-selector` | | Field selector |
| `--force` | | Force delete by removing finalizers |
| `--dry-run` | | Print what would be deleted without deleting |

---

## Lint and Validate

```bash
argo lint workflow.yaml
argo lint workflows/               # entire directory
argo lint --offline workflow.yaml  # no server connection needed
argo lint --kinds=workflowtemplates templates/
argo lint --output=simple workflow.yaml  # machine-parseable
```

Flags: `--kinds` (workflows\|workflowtemplates\|cronworkflows\|clusterworkflowtemplates),
`--offline`, `--output` (pretty\|simple), `--strict`

---

## Template Management

```bash
argo template list -n argo
argo template get -n argo my-template
argo template get -n argo my-template -o yaml
argo template create -n argo template.yaml
argo template update -n argo template.yaml
argo template lint template.yaml
argo template delete -n argo my-template
```

---

## Cron Workflow Management

```bash
argo cron list -n argo
argo cron get -n argo nightly-report
argo cron get -n argo nightly-report -o yaml
argo cron create -n argo cron.yaml
argo cron update -n argo cron.yaml
argo cron lint cron.yaml
argo cron suspend -n argo nightly-report
argo cron resume -n argo nightly-report
argo cron delete -n argo nightly-report
```

Key status fields on `cron get`: `suspended`, `lastScheduledTime`, `active`
(currently running instances).

---

## Cluster Template Management

Cluster workflow templates are cluster-scoped (no namespace). They can be
referenced by workflows in any namespace.

```bash
argo cluster-template list
argo cluster-template get my-cluster-template
argo cluster-template get my-cluster-template -o yaml
argo cluster-template create cluster-template.yaml
argo cluster-template update cluster-template.yaml
argo cluster-template lint cluster-template.yaml
argo cluster-template delete my-cluster-template
```

Submit a workflow from a cluster template:

```bash
argo submit -n argo --from clusterworkflowtemplate/my-cluster-template \
  -p param1=value1 --wait
```

---

## Archive Operations

Archived workflows are identified by **UID** (not name). Archiving must be
enabled in the workflow-controller-configmap.

```bash
argo archive list -n argo
argo archive list -n argo -o wide
argo archive get <uid>
argo archive list-label-keys -n argo
argo archive list-label-values -n argo --label-key=app
argo archive retry <uid> -n argo
argo archive resubmit <uid> -n argo
argo archive delete <uid>
```

---

## Node Operations

Used to inject output parameters into a waiting node or manually set node
phase for testing. The `supplied` output parameter type must be declared in
the workflow template.

```bash
# Provide a "supplied" output parameter to unblock a waiting node
argo node -n argo my-workflow \
  --node-field-selector displayName=await-approval \
  --output-parameter approved=true

# Set a message on a node
argo node -n argo my-workflow \
  --node-field-selector displayName=await-approval \
  --message "approved by operator"

# Manually complete a node (testing/debug only)
argo node -n argo my-workflow \
  --node-field-selector displayName=manual-step \
  --phase Succeeded
```

---

## Output Formats

| Value | Description |
|-------|-------------|
| `name` | Workflow name only — scriptable |
| `json` | Full JSON — pipe to `jq` |
| `yaml` | Full YAML |
| `wide` | Extended table with extra columns |
| `short` | Compact summary (argo get only) |

```bash
# Extract phase for CI gate
argo get -n argo my-workflow -o json | jq -r '.status.phase'

# Get failed node names
argo get -n argo my-workflow -o json \
  | jq '.status.nodes | to_entries[]
        | select(.value.phase=="Failed")
        | .value.displayName'

# Capture name at submit time
NAME=$(argo submit -n argo workflow.yaml -o name)
# NAME is: workflow.argoproj.io/my-wf-abc12
# Strip prefix for use in subsequent commands:
WF=${NAME#workflow.argoproj.io/}
```

---

## Node Field Selectors

Used with `--node-field-selector` in: `retry`, `resume`, `stop`, `watch`,
`get`, `submit`, `node`. Syntax: `FIELD=VALUE` or `FIELD!=VALUE`. Multiple
selectors are AND-ed (comma-separated).

| Field | Example |
|-------|---------|
| `displayName` | `displayName=build` |
| `name` | `name=my-wf.step1.substep` |
| `templateName` | `templateName=build-image` |
| `phase` | `phase=Failed` |
| `id` | `id=my-wf-1234567890` |
| `templateRef.name` | `templateRef.name=ci-templates` |
| `templateRef.template` | `templateRef.template=build-step` |
| `inputs.parameters.<NAME>.value` | `inputs.parameters.env.value=production` |

```bash
# Retry only the failed nodes in a specific template
argo retry -n argo my-workflow --node-field-selector templateName=deploy,phase=Failed

# Resume a named approval step
argo resume -n argo my-workflow --node-field-selector displayName=manual-approval

# Inspect only failed nodes
argo get -n argo my-workflow --node-field-selector phase=Failed
```
