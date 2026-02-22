# Writing Dev Container Features: Full Procedure

## Contents

- [Directory layout](#directory-layout)
- [devcontainer-feature.json schema](#devcontainer-featurejson-schema)
- [install.sh patterns](#installsh-patterns)
- [Injected variables](#injected-variables)
- [Options and environment variables](#options-and-environment-variables)
- [Lifecycle hooks](#lifecycle-hooks)
- [Container behavior flags](#container-behavior-flags)
- [Test suite structure](#test-suite-structure)
- [Publishing and distribution](#publishing-and-distribution)
- [Authoring checklist](#authoring-checklist)

---

## Directory layout

```text
<repo-root>/
├── src/
│   └── <feature-id>/
│       ├── devcontainer-feature.json   # required
│       ├── install.sh                  # required
│       └── <supporting files>          # optional, packaged with feature
└── test/
    ├── _global/
    │   ├── scenarios.json              # cross-feature scenario tests
    │   └── <scenario>.sh
    └── <feature-id>/
        ├── test.sh                     # default (auto-generated) test
        ├── scenarios.json              # optional named scenarios
        ├── <scenario>.sh               # one per scenarios.json entry
        └── <scenario>/                 # optional: extra build context files
            └── Dockerfile
```

---

## devcontainer-feature.json schema

### Required fields

| Field     | Type   | Notes                                        |
|-----------|--------|----------------------------------------------|
| `id`      | string | Lowercase, hyphens only. Matches directory.  |
| `version` | string | Semver (e.g. `1.0.0`). Bump on every change. |
| `name`    | string | Human-readable display name.                 |

### Metadata fields (optional)

```json
{
  "description": "Installs the Foo CLI tool.",
  "documentationURL": "https://example.com/docs",
  "licenseURL": "https://example.com/license",
  "keywords": ["foo", "cli", "tool"]
}
```

### options

Options are declared as a map. Each key becomes an uppercased env var in
`install.sh`. Values support `string` or `boolean` types.

```json
{
  "options": {
    "version": {
      "type": "string",
      "default": "latest",
      "description": "Version to install.",
      "proposals": ["latest", "1.0", "2.0"]
    },
    "installGlobalPackage": {
      "type": "boolean",
      "default": true,
      "description": "Also install the global companion package."
    }
  }
}
```

Use `enum` (strict) or `proposals` (suggestive). The key `version` → env var
`VERSION`; `installGlobalPackage` → `INSTALLGLOBALPACKAGE`.

### Environment variables

`containerEnv` — set during image build; persists for the container's lifetime:

```json
{
  "containerEnv": {
    "PATH": "${PATH}:/usr/local/foo/bin",
    "FOO_HOME": "/usr/local/foo"
  }
}
```

`remoteEnv` — set at runtime by the supporting tool; may change after
container startup. Use for user-session variables, not PATH modifications.

### Dependency ordering

`installsAfter` — **soft** ordering. Only affects features already queued.
Does not force the listed feature to be installed.

```json
{ "installsAfter": ["ghcr.io/devcontainers/features/common-utils:1"] }
```

`dependsOn` — **hard** dependency. Forces the listed feature to be installed
first. Resolved recursively.

```json
{ "dependsOn": { "ghcr.io/devcontainers/features/node:1": {} } }
```

### Mounts

```json
{
  "mounts": [
    {
      "source": "myvolume-${devcontainerId}",
      "target": "/var/lib/mydata",
      "type": "volume"
    }
  ]
}
```

Supports `${devcontainerId}` variable substitution for unique volume names.

### customizations

Merge tool-specific config into the container:

```json
{
  "customizations": {
    "vscode": {
      "extensions": ["foo.bar-extension"],
      "settings": { "foo.enable": true }
    }
  }
}
```

---

## install.sh patterns

### Minimal template

```bash
#!/bin/bash
set -e

VERSION="${VERSION:-"latest"}"

echo "Installing foo version: ${VERSION}"

# Detect architecture
ARCH="$(uname -m)"
case "${ARCH}" in
  x86_64)  ARCH="amd64" ;;
  aarch64) ARCH="arm64" ;;
  *) echo "Unsupported architecture: ${ARCH}"; exit 1 ;;
esac

# Detect OS
. /etc/os-release
case "${ID}" in
  ubuntu|debian)
    apt-get update -y
    apt-get install -y --no-install-recommends foo
    ;;
  alpine)
    apk add --no-cache foo
    ;;
  *)
    echo "Unsupported OS: ${ID}"
    exit 1
    ;;
esac

echo "Done. foo installed."
```

### Alpine bootstrap (no bash)

If targeting Alpine, create a `/bin/sh` entrypoint that installs bash then
delegates:

```sh
#!/bin/sh
set -e
apk add --no-cache bash
exec bash "$(dirname "$0")/main.sh" "$@"
```

### Downloading binaries

```bash
curl -fsSL "https://example.com/releases/${VERSION}/foo_${VERSION}_linux_${ARCH}.tar.gz" \
  | tar -xz -C /usr/local/bin foo
chmod +x /usr/local/bin/foo
```

Always use `curl -fsSL` (fail-fast, silent, follow redirects).

### Non-root user setup

```bash
# Install to system location
install -o root -g root -m 0755 foo /usr/local/bin/foo

# Configure for remote user
if [ -n "${_REMOTE_USER}" ] && [ "${_REMOTE_USER}" != "root" ]; then
    mkdir -p "${_REMOTE_USER_HOME}/.local/share/foo"
    chown -R "${_REMOTE_USER}:${_REMOTE_USER}" "${_REMOTE_USER_HOME}/.local"
fi
```

---

## Injected variables

These are automatically available in `install.sh` (no declaration needed):

| Variable             | Value                                          |
|----------------------|------------------------------------------------|
| `_REMOTE_USER`       | Value of `remoteUser` in devcontainer.json     |
| `_REMOTE_USER_HOME`  | Home directory of `_REMOTE_USER`               |
| `_CONTAINER_USER`    | Value of `containerUser` in devcontainer.json  |
| `_CONTAINER_USER_HOME` | Home directory of `_CONTAINER_USER`          |

---

## Options and environment variables

Options are injected as env vars with the key uppercased. The mapping is
exact: `camelCase` keys become `CAMELCASE` (all caps, no separator change).
Always provide a default in the script to handle edge cases:

```bash
VERSION="${VERSION:-"latest"}"
ENABLE_EXTRAS="${ENABLEEXTRAS:-"false"}"
```

---

## Lifecycle hooks

Declare as properties of `devcontainer-feature.json`. Mirror the behavior of
the same properties in `devcontainer.json`. Feature lifecycle commands always
execute **before** user-provided commands of the same type.

```json
{
  "onCreateCommand": "echo Feature installed",
  "postCreateCommand": "/usr/local/bin/foo --init",
  "postStartCommand": "foo daemon start",
  "postAttachCommand": "foo status"
}
```

Hooks run as `remoteUser` with `remoteEnv` applied.

---

## Container behavior flags

| Property      | Type            | Purpose                                      |
|---------------|-----------------|----------------------------------------------|
| `privileged`  | boolean         | Full privileged mode (e.g. docker-in-docker) |
| `init`        | boolean         | Add `--init` (tini) to container             |
| `capAdd`      | string[]        | Linux capabilities (e.g. `SYS_PTRACE`)       |
| `securityOpt` | string[]        | Security options (e.g. `seccomp=unconfined`) |
| `entrypoint`  | string          | Custom startup script path                   |

Only set `privileged: true` when unavoidable; document the reason in
`description` or `documentationURL`.

---

## Test suite structure

### test.sh (default test)

```bash
#!/bin/bash
set -e

# Optional: source test helpers
source dev-container-features-test-lib

check "foo is installed" foo --version
check "foo is on PATH" which foo
check "foo version matches" bash -c "foo --version | grep -q '${VERSION}'"

reportResults
```

### scenarios.json

```json
{
  "install_version_2": {
    "image": "ubuntu:22.04",
    "features": {
      "./src/foo": { "version": "2.0.0" }
    }
  },
  "install_on_debian": {
    "image": "debian:bullseye",
    "features": {
      "./src/foo": {}
    }
  }
}
```

Each key maps to a `<key>.sh` test file in the same directory.

### Running tests

```bash
# Default test (auto-generated) against default base image
devcontainer features test -f foo --base-image ubuntu:22.04

# All scenarios
devcontainer features test -f foo

# Multiple base images
devcontainer features test -f foo \
  --base-image ubuntu:22.04 \
  --base-image debian:bookworm

# Global scenarios only
devcontainer features test --global-scenarios-only
```

### Test modes

| Mode             | What it does                               | Skip flag                |
|------------------|--------------------------------------------|--------------------------|
| Auto-generated   | Builds with defaults, runs `test.sh`       | `--skip-autogenerated`   |
| Scenarios        | Builds each scenario, runs matching `.sh`  | `--skip-scenarios`       |
| Duplicate        | Installs same feature twice                | `--skip-duplicated`      |

---

## Publishing and distribution

### OCI naming convention

```
<registry>/<namespace>/<id>:<version>
ghcr.io/myorg/myrepo/foo:1.2.3
```

The `devcontainer-collection.json` is auto-generated and pushed at `latest`.

### GitHub Actions publish workflow

Use the official `devcontainers/action` publish action:

```yaml
- uses: devcontainers/action@v1
  with:
    publish-features: true
    base-path-to-features: ./src
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### GHCR visibility

GHCR packages are private by default. After first publish, navigate to the
package settings and set visibility to **public** to stay in the free tier
and allow unauthenticated pulls.

### Local reference for development

```json
{
  "features": {
    "./src/foo": { "version": "latest" }
  }
}
```

Reference the local path relative to the `.devcontainer/` directory.

---

## Authoring checklist

- [ ] `id` matches directory name exactly (lowercase, hyphens only)
- [ ] `version` is valid semver
- [ ] `install.sh` starts with a shebang and `set -e`
- [ ] All options have `default` values
- [ ] Option env vars consumed in `install.sh` with fallback defaults
- [ ] Architecture detection uses `uname -m` and maps to `amd64`/`arm64`
- [ ] OS detection uses `/etc/os-release`
- [ ] Unsupported arch/OS exits with code 1 and a clear message
- [ ] Non-root user handled via `_REMOTE_USER`/`_REMOTE_USER_HOME`
- [ ] `test.sh` exists and calls `reportResults`
- [ ] `scenarios.json` covers non-default option combinations
- [ ] Tests pass locally with `devcontainer features test`
- [ ] `version` bumped before publish
