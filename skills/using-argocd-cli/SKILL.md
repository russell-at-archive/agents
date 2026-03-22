---
name: using-argocd-cli
description: >
  Use this skill for Argo CD or argocd CLI tasks: logging in,
  switching context, inspecting or diffing apps, syncing apps and waiting for
  health, explaining argocd CI behavior such as `app diff` exit codes,
  `--grpc-web`, or `ARGOCD_AUTH_TOKEN`, and administering Argo CD repos,
  clusters, AppProjects, rollbacks, and ApplicationSets. Not for Argo
  Workflows, kubectl-only, Helm, Kustomize, or Crossplane tasks.
---

# Using argocd

## Overview

Use this skill for Argo CD CLI work. Treat `argocd` as a high-leverage control
plane: confirm server context first, inspect before mutating, and prefer
commands that make convergence visible (`app diff`, `app sync`, `app wait`).

Read [references/overview.md](references/overview.md) for the operator model,
[references/examples.md](references/examples.md) for copy-paste patterns,
[references/troubleshooting.md](references/troubleshooting.md) for failure
recovery, and [references/installation.md](references/installation.md) if the
CLI is missing.

## When to Use

- The user asks to log into Argo CD or switch Argo CD contexts
- The task involves application inspection, diff, sync, wait, rollback, or logs
- The task involves repository, cluster, project, or ApplicationSet management
- The task needs CI-safe, non-interactive `argocd` command patterns

## When Not to Use

- Argo Workflows tasks: use the `argo` CLI skill
- Raw Kubernetes object inspection or editing: use `kubectl`
- Git changes to app manifests without Argo CD operations: use Git tooling

## Prerequisites

- `argocd` CLI installed; if not, follow
  [references/installation.md](references/installation.md)
- Reachable Argo CD API server or a deliberate `--core` / `--port-forward`
  approach
- Valid auth via `argocd login`, `ARGOCD_AUTH_TOKEN`, or an existing local
  context
- The target app, repo, cluster, or project name is known before mutating it

## Workflow

1. Check whether `argocd` is installed. If not, use
   [references/installation.md](references/installation.md).
2. Establish scope before action: confirm server and context with `argocd
   context`, `--argocd-context`, or explicit login.
3. Prefer read-only inspection first: `argocd app get`, `argocd app diff`,
   `argocd app history`, `argocd repo list`, `argocd cluster list`, `argocd
   proj get`.
4. For application changes, follow this sequence unless the user asks
   otherwise:
   `app get` -> `app diff` -> `app sync` -> `app wait`.
5. In CI or automation, prefer token auth, explicit timeouts, and waiting for
   a terminal state. Do not rely on interactive prompts.
6. For admin operations, scope tightly and review existing state before add,
   update, or remove commands.
7. When commands fail, use
   [references/troubleshooting.md](references/troubleshooting.md) before
   suggesting retries or forceful mutations.

## Hard Rules

- Always identify the active server context before any mutating command.
- Do not recommend `argocd app sync --force`, `--prune`, `app delete`, or
  `cluster rm` without first inspecting the target and explaining the blast
  radius.
- Use `argocd app wait` or `argocd app sync --wait` for automation; do not
  fire-and-forget syncs.
- When behind an ingress or proxy that breaks HTTP/2, account for `--grpc-web`.
- Keep `argocd` client and server versions aligned closely enough to avoid
  command and flag skew.
- Prefer `ARGOCD_AUTH_TOKEN` or existing context over embedding credentials in
  scripts.
- Use `--core` only when direct Kubernetes API access is intentional and the
  user actually wants to bypass the Argo CD API server.

## Failure Handling

- CLI missing: use [references/installation.md](references/installation.md)
- Auth or connectivity issues: inspect
  [references/troubleshooting.md](references/troubleshooting.md)
- Unclear blast radius or ambiguous target: stop and ask the user before
  destructive actions

## Red Flags

- Mutating commands issued before `argocd context` or equivalent scoping
- Habitual use of `--insecure`, `--plaintext`, `--force`, or `--prune`
- Recommending retries without first checking `app get`, `app diff`, or logs
- Confusing `argocd` responsibilities with `kubectl`, `argo`, or Git operations
