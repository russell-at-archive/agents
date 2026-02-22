---
name: writing-devcontainer-features
description: Produces correct, publishable Dev Container Features following
  the official devcontainers.org specification. Use when asked to write, create,
  fix, review, or publish a devcontainer feature, devcontainer-feature.json,
  install.sh entrypoint, feature test suite, or OCI feature distribution.
---

# Writing Dev Container Features

Produces a complete, spec-compliant Dev Container Feature: metadata file,
install script, test suite, and optional publish workflow. Every feature must
be installable, idempotent, multi-arch, and testable before publishing.

Full procedure: [references/overview.md](references/overview.md)

## When to Use

- Writing a new devcontainer feature from scratch
- Fixing or improving an existing `devcontainer-feature.json` or `install.sh`
- Adding tests via `devcontainer features test`
- Publishing a feature to GHCR or another OCI registry
- Reviewing a feature for spec compliance or best-practice violations

## When Not to Use

- Writing a `devcontainer.json` that only *uses* features (not authoring one)
- Authoring a Dev Container Template (different spec)
- General Dockerfile or container image work unrelated to the feature spec

## Prerequisites

- `devcontainer` CLI available (`npm install -g @devcontainers/cli`)
- Docker running locally for test builds
- Target OCI registry credentials if publishing (GHCR recommended)

## Workflow

1. Scaffold the feature directory — read
   [references/overview.md](references/overview.md) for canonical layout.
2. Write `devcontainer-feature.json` — id, version, name, options, env,
   mounts, lifecycle hooks, and container behavior flags.
3. Write `install.sh` — root-executed entrypoint with strict mode, arch
   detection, OS detection, and user-context handling.
4. Write the test suite under `test/<id>/` — at minimum `test.sh` plus
   `scenarios.json` for non-default options.
5. Run `devcontainer features test` locally against at least one base image.
6. Add GitHub Actions publish workflow if distributing via OCI.

For the full procedure, schema reference, and script patterns read
[references/overview.md](references/overview.md).
For concrete worked examples read [references/examples.md](references/examples.md).

## Hard Rules

- `id` must be lowercase, hyphens only, and match the directory name exactly.
- `version` must follow semver; bump it on every published change.
- `install.sh` must start with `#!/bin/sh` or `#!/bin/bash` and `set -e`.
- Never hardcode architecture (`amd64`/`arm64`) — detect at runtime.
- Never assume a specific base OS — detect via `/etc/os-release` or fallback.
- Use `_REMOTE_USER` and `_REMOTE_USER_HOME` (injected) for non-root setup.
- Options map to uppercase env vars in `install.sh` — never use raw strings.
- Test files must call `reportResults` or the suite will not exit cleanly.
- Do not mark features `privileged: true` unless strictly required; document why.

## Failure Handling

- If the feature id conflicts with an existing directory, stop and confirm.
- If `devcontainer features test` fails, read the build log before changing code.
- If a base image is unsupported, emit a clear error message and exit 1.
- If publish fails with a 403, check GHCR package visibility (must be public).

## Red Flags

- `install.sh` missing `set -e` — errors will be silently swallowed
- Options defined in `devcontainer-feature.json` but not consumed in `install.sh`
- Hardcoded `amd64` or `arm64` strings in download URLs
- No test file — feature is unverifiable
- `version` not bumped after a content change
- `installsAfter` used instead of `dependsOn` when a hard dependency is intended
