---
name: using-argo-workflows-cli
description: >
  Provides expert guidance for using the argo CLI to submit, monitor, manage,
  and debug Argo Workflows on Kubernetes. Use when requests involve argo submit,
  argo list, argo get, argo logs, argo retry, argo resubmit, argo suspend,
  argo resume, argo terminate, argo stop, argo wait, argo watch, argo template,
  argo cron, argo cluster-template, argo archive, argo node, argo lint, or
  argo server commands. Also invoke when the user asks how to run a workflow,
  debug a failing step, retry from failure, approve a suspended node, manage
  cron schedules, or clean up completed workflow runs.
---

# Using argo (Argo Workflows CLI)

The `argo` CLI is the control surface for Argo Workflows — a Kubernetes-native
workflow engine. Work with an inspect-before-act posture: always scope to a
namespace, observe current state, then execute.

## Quick orientation

- If `argo` is not installed, read [references/installation.md](references/installation.md).
- For auth setup, environment variables, and the full command reference, read
  [references/overview.md](references/overview.md).
- For practical patterns (CI submission, debug, retry, cleanup), read
  [references/examples.md](references/examples.md).
- For diagnosing errors, stuck workflows, and broken cron schedules, read
  [references/troubleshooting.md](references/troubleshooting.md).

## Scope boundaries

- Argo CD operations → use `argocd` CLI
- Argo Rollouts → use `kubectl argo rollouts` plugin
- Writing workflow YAML specs from scratch → no special skill needed

## Standing rules

- Always pass `-n <namespace>` explicitly — omitting it targets the wrong scope.
- Always run `argo lint` before submitting new or modified workflow specs.
- Use `--wait` or `--watch` in CI; never fire-and-forget.
- Never delete without first confirming the target with `argo get`.
- Keep tokens in `ARGO_TOKEN` env var or a secret manager — not in shell history.
- CLI version must match server version; version skew causes silent failures.
