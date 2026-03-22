# Installation

## Overview

The `devcontainer` CLI depends on a working Docker-compatible runtime.
Installation is complete only when both the CLI and container runtime
respond successfully.

## Install Paths

Homebrew:

```bash
brew install devcontainer
```

npm:

```bash
npm install -g @devcontainers/cli
```

## Verify

```bash
devcontainer --version
devcontainer --help
docker version
docker info
```

## Host Requirements

- macOS and Windows usually use Docker Desktop or OrbStack.
- Linux needs a working Docker Engine or compatible daemon before
  `devcontainer up` or `build` can succeed.
- If Docker is remote, confirm `DOCKER_HOST` and related auth settings
  before debugging the Dev Container config itself.

## Minimum Readiness Check

Run these before diagnosing a workspace:

```bash
devcontainer read-configuration --workspace-folder <abs-path>
devcontainer up --workspace-folder <abs-path> --log-level debug
```
