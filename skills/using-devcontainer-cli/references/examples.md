# DevContainer CLI Examples

## Inspect Before Startup

Resolve and inspect the workspace before changing anything:

```bash
devcontainer read-configuration --workspace-folder /abs/path/to/repo
```

Include merged configuration when Features or overrides are involved:

```bash
devcontainer read-configuration \
  --workspace-folder /abs/path/to/repo \
  --include-merged-configuration \
  --include-features-configuration
```

## Start or Recreate a Workspace

Start a workspace with debug logs:

```bash
devcontainer up --workspace-folder /abs/path/to/repo --log-level debug
```

Force a clean recreate when the existing container is suspect:

```bash
devcontainer up \
  --workspace-folder /abs/path/to/repo \
  --remove-existing-container
```

Start a Git worktree and mount common Git metadata for containerized Git:

```bash
devcontainer up \
  --workspace-folder /abs/path/to/worktree \
  --mount-git-worktree-common-dir
```

## Execute Commands Inside the Container

Run tests in the active container:

```bash
devcontainer exec --workspace-folder /abs/path/to/repo npm test
```

Inject environment variables for the command:

```bash
devcontainer exec \
  --workspace-folder /abs/path/to/repo \
  --remote-env GH_TOKEN="$GH_TOKEN" \
  gh auth status
```

Target a running container by label instead of path:

```bash
devcontainer exec --id-label repo=my-service make verify
```

## Build Without Starting

Build an image for CI or cache warming:

```bash
devcontainer build \
  --workspace-folder /abs/path/to/repo \
  --image-name ghcr.io/example/service-devcontainer:latest
```

Push a multi-platform image:

```bash
devcontainer build \
  --workspace-folder /abs/path/to/repo \
  --platform linux/amd64,linux/arm64 \
  --image-name ghcr.io/example/service-devcontainer:latest \
  --push
```

## Rerun Hooks or Attach to Existing Containers

Rerun user commands after fixing a broken hook:

```bash
devcontainer run-user-commands \
  --workspace-folder /abs/path/to/repo \
  --log-level debug
```

Set up a container that already exists:

```bash
devcontainer set-up \
  --container-id <container-id> \
  --config /abs/path/to/repo/.devcontainer/devcontainer.json
```

## Maintenance

Check version drift:

```bash
devcontainer outdated --workspace-folder /abs/path/to/repo --output-format json
```

Preview lockfile updates:

```bash
devcontainer upgrade --workspace-folder /abs/path/to/repo --dry-run
```

## Features and Templates

Inspect a published Feature:

```bash
devcontainer features info manifest ghcr.io/devcontainers/features/node:1
```

Apply a published Template:

```bash
devcontainer templates apply \
  --workspace-folder /abs/path/to/repo \
  --template-id ghcr.io/devcontainers/templates/node:latest
```
