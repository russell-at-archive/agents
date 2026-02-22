# DevContainer CLI Examples

Common patterns and use cases for the `@devcontainers/cli`.

## Basic Lifecycle

### Provisioning and Starting
To start a development environment from the current folder:
```bash
devcontainer up --workspace-folder .
```

### Executing a Task
To run npm install inside the container:
```bash
devcontainer exec --workspace-folder . npm install
```

### Cleaning Up
To stop and remove containers for a workspace:
```bash
devcontainer down --workspace-folder .
```

---

## "Minion Orchestrator" Patterns

### Unique Feature Containers
If you're running multiple "Minions" in parallel on the same host, use
labels and unique folders:
```bash
# Feature 1
devcontainer up --workspace-folder /tmp/feature-1 --id-label "minion-job=123"

# Feature 2
devcontainer up --workspace-folder /tmp/feature-2 --id-label "minion-job=456"
```

### Injecting Secrets via --env
To pass credentials (like `GH_TOKEN`) into an active Minion:
```bash
devcontainer exec --workspace-folder . --env GH_TOKEN=$GH_TOKEN git push
```

### Pre-building an Image for Minions
Use build to pre-cache heavy dependencies (e.g., node_modules, apt packages):
```bash
devcontainer build --workspace-folder . --image-name ghcr.io/my-repo/minion-base:latest
```

---

## Troubleshooting & Debugging

### Inspecting Configuration
To see exactly how features and Docker Compose files are being merged:
```bash
devcontainer read-configuration --workspace-folder .
```

### Running Lifecycle Hooks Manually
To re-run the `postCreateCommand` after a manual fix:
```bash
devcontainer run-user-commands --workspace-folder . postCreateCommand
```

### Checking for Dev Container Status
To list all active dev containers on the host using Docker:
```bash
docker ps --filter "label=devcontainer.local_folder=*"
```
