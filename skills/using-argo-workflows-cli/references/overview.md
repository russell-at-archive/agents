# Using argo (Argo Workflows CLI): Overview

## Contents

- Environment and authentication
- Command posture
- Submitting workflows
- Monitoring and inspection
- Workflow lifecycle management
- Template management
- Cron workflow management
- Output formats
- High-signal command set

## Environment and Authentication

Set these environment variables before running any command:

```bash
export ARGO_SERVER=<host>:<port>        # e.g. localhost:2746
export ARGO_TOKEN="Bearer <token>"      # must include "Bearer " prefix
export ARGO_NAMESPACE=<namespace>       # optional namespace default
export ARGO_SECURE=true                 # set false only for local dev
```

Generate a token for automation:

```bash
argo auth token
```

To run against a local port-forwarded server without TLS:

```bash
export ARGO_SERVER=localhost:2746
export ARGO_SECURE=false
export ARGO_TOKEN=""
```

To skip TLS verification (non-production only):

```bash
argo list -n <namespace> --insecure-skip-verify
```

## Command Posture

Treat every `argo` session as a sequence:

1. Scope: set namespace and server.
2. Observe: inspect state with read-only commands.
3. Decide: identify the required action.
4. Act: execute with explicit flags.
5. Verify: confirm outcome with `argo get` or `argo list`.

Never begin with destructive commands (`delete`, `stop`, `terminate`)
without first running `argo get` to confirm the target.

## Submitting Workflows

Basic submission:

```bash
argo submit -n <namespace> workflow.yaml
```

Submit with parameter overrides:

```bash
argo submit -n <namespace> workflow.yaml \
  -p message="hello world" \
  -p env="production"
```

Submit and wait for completion (CI-safe):

```bash
argo submit -n <namespace> workflow.yaml --wait
```

Submit and stream logs while watching:

```bash
argo submit -n <namespace> workflow.yaml --watch
```

Submit from a workflow template:

```bash
argo submit -n <namespace> --from workflowtemplate/<template-name>
```

Override entrypoint:

```bash
argo submit -n <namespace> workflow.yaml \
  --entrypoint <template-name>
```

Dry-run validation (prints resolved spec without submitting):

```bash
argo submit -n <namespace> workflow.yaml --dry-run
```

## Monitoring and Inspection

List workflows (defaults to running):

```bash
argo list -n <namespace>
argo list -n <namespace> --all-namespaces
argo list -n <namespace> --running
argo list -n <namespace> --completed
argo list -n <namespace> --failed
```

Get full workflow status:

```bash
argo get -n <namespace> <workflow-name>
argo get -n <namespace> @latest
```

Stream logs for a workflow:

```bash
argo logs -n <namespace> <workflow-name>
argo logs -n <namespace> <workflow-name> --follow
argo logs -n <namespace> <workflow-name> -c main --tail=200
```

Stream logs for a specific pod/step:

```bash
argo logs -n <namespace> <workflow-name> <pod-name>
```

## Workflow Lifecycle Management

### Stop

Gracefully stop a running workflow (marks as stopped, allows cleanup):

```bash
argo stop -n <namespace> <workflow-name>
```

### Terminate

Immediately terminate a workflow without cleanup:

```bash
argo terminate -n <namespace> <workflow-name>
```

### Suspend and Resume

Pause a running workflow at the next suspend node:

```bash
argo suspend -n <namespace> <workflow-name>
```

Resume a suspended workflow:

```bash
argo resume -n <namespace> <workflow-name>
```

### Retry

Retry a failed workflow from the point of failure:

```bash
argo retry -n <namespace> <workflow-name>
```

Retry only failed nodes:

```bash
argo retry -n <namespace> <workflow-name> \
  --node-field-selector phase=Failed
```

Retry and restart successful steps too:

```bash
argo retry -n <namespace> <workflow-name> \
  --restart-successful \
  --node-field-selector templateName=<step-name>
```

### Delete

Delete a completed or failed workflow:

```bash
argo delete -n <namespace> <workflow-name>
```

Delete completed workflows older than a duration:

```bash
argo delete -n <namespace> --completed
```

## Template Management

Lint a workflow spec before submission:

```bash
argo lint workflow.yaml
argo lint workflows/
```

List, get, and delete workflow templates:

```bash
argo template list -n <namespace>
argo template get -n <namespace> <template-name>
argo template delete -n <namespace> <template-name>
```

Create or update a workflow template:

```bash
argo template create -n <namespace> template.yaml
```

## Cron Workflow Management

List cron workflows:

```bash
argo cron list -n <namespace>
```

Get a cron workflow:

```bash
argo cron get -n <namespace> <cron-name>
```

Create a cron workflow:

```bash
argo cron create -n <namespace> cron.yaml
```

Suspend and resume a cron workflow:

```bash
argo cron suspend -n <namespace> <cron-name>
argo cron resume -n <namespace> <cron-name>
```

Delete a cron workflow:

```bash
argo cron delete -n <namespace> <cron-name>
```

## Output Formats

Control output verbosity:

```bash
argo get -n <namespace> <workflow-name> -o yaml   # full YAML spec
argo get -n <namespace> <workflow-name> -o json   # JSON
argo list -n <namespace> -o wide                  # wide table
```

## High-Signal Command Set

Keep these commands close:

- Auth: `auth token`
- Discovery: `list`, `get @latest`
- Submission: `submit`, `submit --from`, `submit --wait`
- Lifecycle: `suspend`, `resume`, `retry`, `stop`, `terminate`, `delete`
- Logs: `logs --follow`, `logs --tail`
- Templates: `lint`, `template list`, `template get`
- Cron: `cron list`, `cron suspend`, `cron resume`

Use `argo <command> --help` when uncertain about available flags.
