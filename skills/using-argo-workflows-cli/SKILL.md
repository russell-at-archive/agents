---
name: using-argo-workflows-cli
description: Provides expert guidance for using the argo CLI to submit,
  monitor, manage, and debug Argo Workflows on Kubernetes. Use when requests
  involve argo submit, argo list, argo get, argo logs, argo retry, argo
  suspend, argo resume, argo terminate, argo stop, argo template, argo cron,
  or argo server commands.
---

# Using argo (Argo Workflows CLI)

## Overview

The `argo` CLI is the control surface for Argo Workflows — a Kubernetes-native
workflow engine. Use explicit namespace and server targeting, inspect before
acting, and prefer watch/wait flags for CI-safe execution. For full procedures,
read [references/overview.md](references/overview.md).

## When to Use

- Submitting, monitoring, or debugging Argo Workflows
- Managing workflow lifecycle: suspend, resume, retry, stop, terminate
- Listing, inspecting, or deleting workflow runs and templates
- Creating or managing cron workflows and workflow templates
- Configuring server auth tokens or local API access

## When Not to Use

- Argo CD operations — use `argocd` CLI instead
- Argo Rollouts operations — use `kubectl argo rollouts` plugin instead
- Authoring workflow YAML specs without running them

## Prerequisites

- `argo` CLI installed (matches server version)
- Argo Workflows server running and reachable
- `ARGO_SERVER` and `ARGO_TOKEN` env vars set, or `--argo-server` /
  `--token` flags supplied
- Target namespace known and accessible

## Workflow

1. Set server and auth context before any command — see
   [references/overview.md](references/overview.md).
2. Inspect before acting: use `argo list` and `argo get` first.
3. Submit workflows with explicit namespace and parameter flags.
4. Watch or wait for completion; do not poll manually.
5. On failure, use `argo logs` and `argo get` to diagnose before retrying.
6. For command templates and patterns, read
   [references/examples.md](references/examples.md).
7. For failure recovery, read
   [references/troubleshooting.md](references/troubleshooting.md).

## Hard Rules

- Always pass `-n <namespace>` explicitly on every command.
- Never use `argo delete` without first confirming the workflow name.
- Use `--wait` or `--watch` in CI; do not fire-and-forget submissions.
- Do not store tokens in shell history; use `ARGO_TOKEN` env var or a
  secret manager.
- Use `argo lint` before submitting new or modified workflow specs.
- Match CLI version to server version; version skew causes silent errors.

## Failure Handling

- Server unreachable: verify `ARGO_SERVER` value and TLS (`ARGO_SECURE`).
- Auth denied: run `argo auth token` to validate the token in use.
- Workflow stuck `Pending`: inspect pod events and node resource pressure.
- Lint failure: resolve schema errors before submitting.
- Version mismatch: install matching CLI via the server download endpoint.

## Red Flags

- Running `argo delete` with wildcards or without namespace scope.
- Submitting to the wrong namespace due to missing `-n` flag.
- Ignoring `argo lint` output before submission.
- Using `--insecure-skip-verify` in production without explicit approval.
- Retrying a workflow without diagnosing the root cause first.
