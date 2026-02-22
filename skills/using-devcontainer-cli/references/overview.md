# DevContainer CLI Overview

Full procedure and configuration logic for managing development environments
using the Dev Container CLI.

## Installation

Install the CLI via npm (globally or locally):
```bash
npm install -g @devcontainers/cli
```

## Core Procedure

### 1. Provisioning (`up`)
Use `devcontainer up` to create and start a container. It follows the
`devcontainer.json` configuration found in the `--workspace-folder`.

**Primary Options:**
- `--workspace-folder <path>`: Required. Path to the folder containing
  `.devcontainer/devcontainer.json`.
- `--id-label <label>`: Assigns a unique label to the container for
  easier tracking (recommended for "Minion" orchestration).
- `--remove-existing-container`: Forces a fresh start by removing any
  previous container for that workspace.

### 2. Execution (`exec`)
Use `devcontainer exec` to run commands inside the container. This is
the primary method for the "Inner Agent" to work.

**Primary Options:**
- `--workspace-folder <path>`: Required.
- `--user <user>`: Run the command as a specific user (e.g., `root`, `vscode`, `node`).
- `--env <KEY=VAL>`: Set environment variables for the execution context.

### 3. Build & Pre-build (`build`)
Use `devcontainer build` for creating images to be reused in CI/CD.

**Primary Options:**
- `--image-name <name>`: The tag for the resulting image.
- `--push true`: Push the image to a registry after building.
- `--cache-from <image>`: Use an existing image as a build cache.

## Lifecycle Hook Logic

The Dev Container spec defines several hooks. Understanding their
execution point is critical for correct environment setup:

| Hook | Host/Container | Execution | Typical Use |
| :--- | :--- | :--- | :--- |
| `initializeCommand` | Host | Before container creation | Host setup |
| `onCreateCommand` | Container | Once after creation | Install deps |
| `updateContentCommand` | Container | On create or rebuild | Refresh caches |
| `postCreateCommand` | Container | After creation | Start background tasks |
| `postStartCommand` | Container | Every container start | Start servers |
| `postAttachCommand` | Container | Every tool connection | Welcome message |

## Constraints & Rules

1.  **Docker Dependency:** The CLI requires a running Docker daemon
    (Docker Desktop, OrbStack, or similar).
2.  **Workspace Isolation:** Each workspace folder is associated with
    one container instance by default.
3.  **Root Privileges:** Some Feature installations or lifecycle hooks
    may require `sudo` if the default container user is not root.
4.  **Pathing:** Always use absolute paths or paths relative to the
    workspace root for reliability.

## Authoring Checklist

- [ ] Command includes `--workspace-folder` flag.
- [ ] Docker daemon is verified to be running.
- [ ] Configuration (`devcontainer.json`) is validated before `up`.
- [ ] Lifecycle hooks do not require interactive input (use `-y` flags).
- [ ] Environment variables needed for execution are passed via `--env`.
