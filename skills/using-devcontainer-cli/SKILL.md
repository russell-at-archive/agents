---
name: using-devcontainer-cli
description: Provides expert guidance for using the DevContainer CLI (`devcontainer`) to build, run, and manage isolated development environments. Use when requests involve `devcontainer` commands such as `up`, `exec`, `build`, `run-user-commands`, or lifecycle hooks.
---

# Using DevContainer CLI

Expert guide for using the `@devcontainers/cli` to automate and manage
development environments as specified in the Development Containers
Specification.

## When to Use

- Building or pre-building container images for CI/CD or local use.
- Starting and stopping isolated development environments (`up`, `down`).
- Executing commands inside a running dev container (`exec`).
- Managing and troubleshooting `devcontainer.json` lifecycle hooks
  (`postCreateCommand`, `postStartCommand`, etc.).
- Inspecting resolved configurations and features.

## Core Commands

| Command | Purpose |
| :--- | :--- |
| `devcontainer up` | Create and start a container for a workspace. |
| `devcontainer exec` | Run a command inside an active container. |
| `devcontainer build` | Build a container image from configuration. |
| `devcontainer read-configuration` | Output the resolved configuration for a workspace. |
| `devcontainer run-user-commands` | Manually trigger lifecycle scripts. |

## Workflow

1.  **Preparation:** Ensure Docker is running and a `devcontainer.json`
    exists in the target workspace.
2.  **Environment Setup:** Use `devcontainer up --workspace-folder <path>`
    to provision the environment.
3.  **Command Execution:** Use `devcontainer exec --workspace-folder <path> <command>`
    for all implementation, testing, and validation tasks.
4.  **Verification:** Confirm that environment-specific dependencies
    and lifecycle scripts have executed correctly.
5.  **Teardown:** Use `devcontainer down --workspace-folder <path>` to
    cleanup resources when the task is complete.

## Resources

- [references/overview.md](references/overview.md) — Detailed procedure,
  options, and lifecycle hook logic.
- [references/examples.md](references/examples.md) — Common command patterns
  and complex configuration examples.
- [references/troubleshooting.md](references/troubleshooting.md) — Error codes,
  Docker connection issues, and hook failures.
