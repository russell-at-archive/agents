---
name: using-devcontainer-cli
description: Provides expert guidance for using the Dev Container CLI (`devcontainer`) to inspect configuration, build images, start environments, run commands in containers, rerun lifecycle hooks, and maintain Features or Templates. Use when requests mention `devcontainer`, Dev Containers, `devcontainer up`, `exec`, `build`, `set-up`, `read-configuration`, `run-user-commands`, `outdated`, `upgrade`, Features, or Templates.
---

# Using DevContainer CLI

Expert guide for using `@devcontainers/cli` to automate development
environments defined by `devcontainer.json`. Install and verification
steps live in [references/installation.md](references/installation.md).

## When to Use

- The user wants to run or debug any `devcontainer` command.
- A workspace must be built, started, attached, or executed inside a
  dev container.
- A `devcontainer.json`, lifecycle hook, Feature, or Template needs
  inspection or troubleshooting.
- The task involves Dev Container maintenance such as `outdated` or
  `upgrade`.

## Core Workflow

1. Verify prerequisites: installed CLI, running Docker-compatible
   runtime, and a resolvable workspace path.
2. Inspect before mutating: start with
   `devcontainer read-configuration --workspace-folder <abs-path>` when
   config, Features, mounts, or lifecycle behavior is unclear.
3. Choose the right command:
   `up` for create/start, `exec` for work inside a running container,
   `build` for image-only workflows, `set-up` for an existing container,
   and `run-user-commands` to rerun lifecycle hooks.
4. Prefer explicit workspace targeting:
   always pass `--workspace-folder <abs-path>` and add
   `--mount-git-worktree-common-dir` when a Git worktree needs `.git`
   metadata inside the container.
5. Use maintenance commands deliberately:
   `outdated` to inspect versions and `upgrade` to refresh the lockfile.
6. Escalate debugging with `--log-level debug` or `trace` before making
   speculative config changes.

## Resources

- [references/installation.md](references/installation.md) for install
  and verification.
- [references/overview.md](references/overview.md) for command selection,
  lifecycle behavior, and safe defaults.
- [references/examples.md](references/examples.md) for common command
  patterns.
- [references/troubleshooting.md](references/troubleshooting.md) for
  Docker, lifecycle, mount, and lockfile failures.
