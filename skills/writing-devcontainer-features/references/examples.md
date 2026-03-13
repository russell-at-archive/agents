# Writing Dev Container Features: Examples

## Contents

- [Minimal feature (tool installer)](#minimal-feature-tool-installer)
- [Feature with typed options](#feature-with-typed-options)
- [Feature with privileged mode and entrypoint](#feature-with-privileged-mode-and-entrypoint)
- [Feature with lifecycle hooks and PATH extension](#feature-with-lifecycle-hooks-and-path-extension)
- [Test file patterns](#test-file-patterns)
- [scenarios.json patterns](#scenariosjson-patterns)
- [GitHub Actions publish workflow](#github-actions-publish-workflow)

---

## Minimal feature (tool installer)

**`src/mytool/devcontainer-feature.json`**

```json
{
  "id": "mytool",
  "version": "1.0.0",
  "name": "My Tool",
  "description": "Installs mytool CLI.",
  "options": {
    "version": {
      "type": "string",
      "default": "latest",
      "description": "Tool version to install.",
      "proposals": ["latest", "2.0.0", "1.9.0"]
    }
  }
}
```

**`src/mytool/install.sh`**

```bash
#!/bin/bash
set -e

VERSION="${VERSION:-"latest"}"

echo "Activating feature 'mytool' version=${VERSION}"

ARCH="$(uname -m)"
case "${ARCH}" in
  x86_64)  ARCH="amd64" ;;
  aarch64) ARCH="arm64" ;;
  *) echo "(!) Unsupported architecture: ${ARCH}"; exit 1 ;;
esac

if [ "${VERSION}" = "latest" ]; then
  VERSION="$(curl -fsSL https://api.github.com/repos/example/mytool/releases/latest \
    | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/')"
fi

curl -fsSL "https://github.com/example/mytool/releases/download/v${VERSION}/mytool_${VERSION}_linux_${ARCH}.tar.gz" \
  | tar -xz -C /tmp mytool
install -o root -g root -m 0755 /tmp/mytool /usr/local/bin/mytool
rm -f /tmp/mytool

echo "Done. mytool ${VERSION} installed."
```

---

## Feature with typed options

Options of both `string` and `boolean` types, with non-root user setup.

**`src/sdktool/devcontainer-feature.json`**

```json
{
  "id": "sdktool",
  "version": "1.2.0",
  "name": "SDK Tool",
  "description": "Installs SDK Tool with optional shell integration.",
  "options": {
    "version": {
      "type": "string",
      "default": "latest",
      "description": "SDK Tool version.",
      "enum": ["latest", "3.0", "2.9", "2.8"]
    },
    "installShellIntegration": {
      "type": "boolean",
      "default": true,
      "description": "Add shell completion and PATH entry."
    }
  },
  "containerEnv": {
    "SDKTOOL_HOME": "/usr/local/sdktool",
    "PATH": "${PATH}:/usr/local/sdktool/bin"
  }
}
```

**`src/sdktool/install.sh`**

```bash
#!/bin/bash
set -e

VERSION="${VERSION:-"latest"}"
INSTALLSHELLINTEGRATION="${INSTALLSHELLINTEGRATION:-"true"}"

ARCH="$(uname -m)"
case "${ARCH}" in
  x86_64)  ARCH="amd64" ;;
  aarch64) ARCH="arm64" ;;
  *) echo "(!) Unsupported architecture: ${ARCH}"; exit 1 ;;
esac

. /etc/os-release
case "${ID}" in
  ubuntu|debian)
    apt-get update -y
    apt-get install -y --no-install-recommends curl ca-certificates
    ;;
  alpine)
    apk add --no-cache curl ca-certificates
    ;;
  *)
    echo "(!) Unsupported OS: ${ID}"; exit 1
    ;;
esac

curl -fsSL "https://example.com/sdktool/${VERSION}/linux_${ARCH}.tar.gz" \
  | tar -xz -C /usr/local/sdktool

if [ "${INSTALLSHELLINTEGRATION}" = "true" ] \
    && [ -n "${_REMOTE_USER}" ] \
    && [ "${_REMOTE_USER}" != "root" ]; then
  echo 'eval "$(sdktool shell-init)"' >> "${_REMOTE_USER_HOME}/.bashrc"
  chown "${_REMOTE_USER}:${_REMOTE_USER}" "${_REMOTE_USER_HOME}/.bashrc"
fi

echo "Done."
```

---

## Feature with privileged mode and entrypoint

Used for docker-in-docker style features.

**`src/docker-in-docker/devcontainer-feature.json`** (abbreviated)

```json
{
  "id": "docker-in-docker",
  "version": "2.0.0",
  "name": "Docker (Docker-in-Docker)",
  "description": "Installs Docker inside the container. Requires privileged mode.",
  "privileged": true,
  "init": true,
  "entrypoint": "/usr/local/share/docker-init.sh",
  "capAdd": ["SYS_PTRACE"],
  "securityOpt": ["seccomp=unconfined"],
  "options": {
    "version": {
      "type": "string",
      "default": "latest",
      "description": "Docker Engine version."
    }
  }
}
```

---

## Feature with lifecycle hooks and PATH extension

**`src/nvm/devcontainer-feature.json`**

```json
{
  "id": "nvm",
  "version": "1.0.0",
  "name": "Node Version Manager (nvm)",
  "description": "Installs nvm and a default Node version.",
  "options": {
    "nodeVersion": {
      "type": "string",
      "default": "lts",
      "description": "Initial Node.js version to install via nvm."
    }
  },
  "containerEnv": {
    "NVM_DIR": "/usr/local/share/nvm",
    "PATH": "${PATH}:/usr/local/share/nvm/versions/node/current/bin"
  },
  "postCreateCommand": "nvm install --lts && nvm alias default lts",
  "installsAfter": ["ghcr.io/devcontainers/features/common-utils:2"]
}
```

---

## Test file patterns

**`test/mytool/test.sh`**

```bash
#!/bin/bash
set -e

source dev-container-features-test-lib

check "mytool is on PATH" which mytool
check "mytool --version runs" mytool --version
check "mytool exits 0" mytool --help

reportResults
```

**`test/mytool/install_specific_version.sh`**

```bash
#!/bin/bash
set -e

source dev-container-features-test-lib

check "mytool is installed" which mytool
check "mytool is version 2.0.0" bash -c "mytool --version | grep -q '2.0.0'"

reportResults
```

---

## scenarios.json patterns

**`test/mytool/scenarios.json`**

```json
{
  "install_specific_version": {
    "image": "ubuntu:22.04",
    "features": {
      "./src/mytool": {
        "version": "2.0.0"
      }
    }
  },
  "install_on_debian": {
    "image": "debian:bookworm",
    "features": {
      "./src/mytool": {}
    }
  },
  "install_on_alpine": {
    "image": "alpine:3.19",
    "features": {
      "./src/mytool": {}
    }
  }
}
```

**`test/_global/scenarios.json`** (cross-feature integration)

```json
{
  "mytool_with_node": {
    "image": "ubuntu:22.04",
    "features": {
      "./src/mytool": {},
      "./src/node": { "version": "20" }
    }
  }
}
```

---

## GitHub Actions publish workflow

**`.github/workflows/release.yaml`**

```yaml
name: Release Dev Container Features

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      packages: write
    steps:
      - uses: actions/checkout@v6

      - name: Publish Features
        uses: devcontainers/action@v1
        with:
          publish-features: true
          base-path-to-features: ./src
          generate-docs: true
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

After first publish, set each GHCR package to **public** in package settings.
