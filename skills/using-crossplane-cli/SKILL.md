---
name: using-crossplane-cli
description: Provides expert guidance for using the Crossplane CLI for package workflows, composition rendering, offline validation, and live-cluster debugging. Use when requests mention crossplane render, crossplane beta trace, crossplane beta validate, crossplane xpkg, providers, functions, compositions, or package revisions.
---

# Using Crossplane CLI

## Overview

Use this skill for Crossplane CLI work. Treat the CLI as four lanes: install
and version checks, offline composition authoring, package lifecycle, and
live-cluster debugging. For current command behavior read
[references/overview.md](references/overview.md). If the binary is missing or
setup matters, read
[references/installation.md](references/installation.md).

## When to Use

- Requests involving `crossplane render`
- Requests involving `crossplane beta trace`, `crossplane beta validate`,
  `crossplane beta top`, or `crossplane beta convert`
- Requests involving `crossplane xpkg build`, `init`, `install`, `login`,
  `push`, or `update`
- Troubleshooting Crossplane providers, functions, package revisions, XRs, or
  managed resources with CLI-assisted workflows

## When Not to Use

- Pure `kubectl` tasks with no Crossplane-specific diagnosis
- Helm-only work that does not involve Crossplane packages
- Terraform/OpenTofu workflows
- Argo CD operations unrelated to Crossplane behavior

## Prerequisites

- `crossplane` on `PATH`, or installation permission to add it
- `kubectl` and kubeconfig for live-cluster commands
- Docker for `crossplane render`
- Network access for `xpkg` registry operations and for `beta validate` when it
  must download provider schemas

## Workflow

1. Classify the task: offline render/validate, package lifecycle, or
   live-cluster debugging.
2. Verify the CLI surface with `crossplane version`; if missing, read
   [references/installation.md](references/installation.md).
3. For composition authoring, use `crossplane render` first, then
   `crossplane beta validate`. Read
   [references/overview.md](references/overview.md) for the render and validate
   patterns.
4. For package work, use the `xpkg` subcommands appropriate to the task. Read
   [references/overview.md](references/overview.md) for build, install, login,
   push, and update behavior.
5. For cluster debugging, start with `crossplane beta trace`, then inspect the
   failing object with `kubectl describe` and controller logs. Read
   [references/troubleshooting.md](references/troubleshooting.md) for the
   diagnosis order.
6. Use examples only when the user needs a concrete command or manifest shape:
   [references/examples.md](references/examples.md).

## Hard Rules

- Use `crossplane render`, not `crossplane beta render`. In current docs,
  `render` is stable while `trace`, `validate`, `top`, and `convert` remain
  under `beta`.
- Distinguish the CLI binary from the container image: manual downloads are
  published as `crank`, even though the CLI command is typically installed as
  `crossplane`.
- Do not recommend `crossplane render` for legacy `mode: Resources`
  compositions. It supports composition functions and requires Docker.
- Treat `crossplane beta validate` as offline validation, but note that it may
  download provider schemas into `.crossplane/cache`.
- Treat `crossplane beta trace` as a read-only cluster inspection tool. It can
  print connection secret names, not secret values.
- Pin package versions explicitly for `Provider`, `Function`, and
  `Configuration` examples. Prefer digests when deterministic installs matter.
- When package health is bad, inspect `ProviderRevision`, `FunctionRevision`,
  or `ConfigurationRevision` and related events, not only the top-level package.

## Failure Handling

- If `crossplane` is unavailable, use
  [references/installation.md](references/installation.md) and continue with
  offline reasoning only where necessary.
- If `render` fails, confirm Docker is running and the composition uses
  functions.
- If `beta validate` fails due to missing schemas or downloads, check cache
  location, network access, and provider package references.
- If package installation is stuck, move from `xpkg install --wait` to
  `kubectl describe` on the package and revision objects.

## Red Flags

- Advising `crossplane beta render`
- Treating `trace` or `validate` as stable GA commands
- Forgetting Docker for `render`
- Ignoring package revision objects during package install failures
- Recommending `latest` tags for provider or function packages
