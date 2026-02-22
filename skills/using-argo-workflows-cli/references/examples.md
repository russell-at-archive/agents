# Using argo (Argo Workflows CLI): Examples

## Contents

- Submit and wait for a workflow
- Submit with parameter overrides
- Monitor a running workflow
- Tail logs from a specific step
- Retry a failed workflow at the failed node
- Suspend and resume mid-flight
- Run from a workflow template
- Manage cron workflows
- Clean up completed workflows
- Validate before submitting

## Submit and Wait for a Workflow

```bash
argo submit -n argo workflow.yaml --wait
```

Use `--wait` in CI pipelines so the command exits non-zero on failure.

## Submit with Parameter Overrides

```bash
argo submit -n argo workflow.yaml \
  -p message="deployment complete" \
  -p environment="staging" \
  --wait
```

Parameters map to `arguments.parameters` in the workflow spec.

## Monitor a Running Workflow

```bash
# Check current status
argo get -n argo @latest

# Watch live progress
argo submit -n argo workflow.yaml --watch
```

`@latest` is shorthand for the most recently submitted workflow in the
namespace.

## Tail Logs from a Specific Step

```bash
# All containers, last 200 lines
argo logs -n argo <workflow-name> --follow --tail=200

# Single container for a specific pod
argo logs -n argo <workflow-name> <pod-name> -c main --follow
```

## Retry a Failed Workflow at the Failed Node

```bash
# Inspect first
argo get -n argo <workflow-name>

# Retry from failure
argo retry -n argo <workflow-name>

# Retry only a named step and all after it
argo retry -n argo <workflow-name> \
  --node-field-selector templateName=build-step \
  --restart-successful
```

## Suspend and Resume Mid-Flight

```bash
# Pause at next suspend node
argo suspend -n argo <workflow-name>

# Confirm suspended state
argo get -n argo <workflow-name>

# Resume when ready
argo resume -n argo <workflow-name>
```

## Run from a Workflow Template

```bash
# List available templates
argo template list -n argo

# Submit an instance from a template with parameters
argo submit -n argo \
  --from workflowtemplate/ci-pipeline \
  -p branch="main" \
  -p commit="abc1234" \
  --wait
```

## Manage Cron Workflows

```bash
# List all scheduled cron workflows
argo cron list -n argo

# Inspect schedule and last run
argo cron get -n argo nightly-report

# Temporarily pause scheduling
argo cron suspend -n argo nightly-report

# Re-enable scheduling
argo cron resume -n argo nightly-report
```

## Clean Up Completed Workflows

```bash
# Delete a single completed workflow
argo delete -n argo <workflow-name>

# Delete all completed workflows in namespace
argo delete -n argo --completed
```

Prefer deleting only after confirming the workflow is no longer needed
for debugging or audit.

## Validate before Submitting

```bash
# Lint a single file
argo lint workflow.yaml

# Lint all files in a directory
argo lint workflows/

# Dry-run shows resolved spec without submitting
argo submit -n argo workflow.yaml --dry-run
```

Always pass lint before submitting to production namespaces.
