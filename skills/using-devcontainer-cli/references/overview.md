# DevContainer CLI Overview

## Table of Contents

1. Command selection
2. Safe operating defaults
3. Lifecycle model
4. Day-2 maintenance
5. Features and Templates
6. Checklist

## Command Selection

Use the narrowest command that matches the task:

| Command | Use it when |
| :--- | :--- |
| `devcontainer read-configuration` | You need to inspect resolved config, Features, mounts, or merged settings before changing anything. |
| `devcontainer up` | You need to create or start the workspace dev container. |
| `devcontainer exec` | The container is already running and you need to run tests, builds, or one-off commands inside it. |
| `devcontainer build` | You need an image build without starting the workspace environment. |
| `devcontainer set-up` | A container already exists and must be initialized as a dev container. |
| `devcontainer run-user-commands` | You need to rerun lifecycle hooks or dotfiles logic without rebuilding everything. |
| `devcontainer outdated` | You need to inspect current versus available versions from the workspace config. |
| `devcontainer upgrade` | You need to refresh the generated lockfile. |

## Safe Operating Defaults

- Prefer `--workspace-folder <abs-path>` over implicit current-directory
  behavior.
- Inspect with `read-configuration` before using `--remove-existing-container`
  or changing mount behavior.
- Use `--log-level debug` first, then `trace` only when debug output is
  insufficient.
- Prefer `--remote-env name=value` for runtime command environment
  injection.
- Use `--mount-git-worktree-common-dir` when the workspace is a Git
  worktree and containerized Git commands need access to shared `.git`
  metadata.
- Use `--expect-existing-container` when automation should fail fast
  instead of silently creating a new container.

## Lifecycle Model

These hooks do not all run in the same place or at the same time:

| Hook | Runs on | Typical purpose |
| :--- | :--- | :--- |
| `initializeCommand` | Host | Host-side prep before container creation |
| `onCreateCommand` | Container | One-time setup after creation |
| `updateContentCommand` | Container | Sync work after content or rebuild updates |
| `postCreateCommand` | Container | Final creation-time initialization |
| `postStartCommand` | Container | Work that must happen on every start |
| `postAttachCommand` | Container | Work that should happen when a tool attaches |

Operational consequences:

- `devcontainer up` runs the create and start flow unless suppressed with
  flags such as `--skip-post-create` or `--skip-post-attach`.
- `devcontainer run-user-commands` is the right tool for rerunning hook
  logic after a manual fix.
- `--prebuild` stops after create-phase user commands and is useful for
  preparing caches without attaching a full interactive session.

## Day-2 Maintenance

- Use `devcontainer outdated --workspace-folder <abs-path>` to inspect
  current and available versions.
- Use `devcontainer upgrade --workspace-folder <abs-path>` to update the
  lockfile.
- Use `devcontainer upgrade --dry-run` before writing when you need to
  review proposed lockfile changes.

## Features and Templates

The CLI also has management surfaces beyond workspace startup:

- `devcontainer features test`, `package`, `publish`, `info`,
  `resolve-dependencies`, and `generate-docs`
- `devcontainer templates apply`, `publish`, `metadata`, and
  `generate-docs`

Reach for these when the user is authoring or maintaining reusable Dev
Container components rather than only consuming a workspace config.

## Checklist

- [ ] Resolve the target workspace to an absolute path.
- [ ] Verify Docker connectivity before blaming the config.
- [ ] Inspect with `read-configuration` when behavior is surprising.
- [ ] Choose `up`, `exec`, `build`, `set-up`, or `run-user-commands`
  based on the current container state.
- [ ] Use debug logging before editing `devcontainer.json`.
- [ ] Use `outdated` or `upgrade` for maintenance instead of manual
  lockfile edits.
