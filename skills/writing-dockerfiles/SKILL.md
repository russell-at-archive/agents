---
name: writing-dockerfiles
description: Produces correct, secure, and efficient Dockerfiles following
  established best practices for base image selection, layer caching, multi-stage
  builds, security hardening, and signal handling. Use when asked to write, fix,
  review, or improve a Dockerfile, container image, or Docker build configuration.
---

# Writing Dockerfiles

## Overview

Produces secure, minimal, and cache-efficient Dockerfiles using established
best practices: pinned base images, multi-stage builds, non-root users, proper
signal handling, and layer ordering optimized for build caching. Covers image
selection, package installation, secrets hygiene, `.dockerignore`, and
language-specific patterns. For the full reference, read
[references/overview.md](references/overview.md).

## When to Use

- Writing or creating a new `Dockerfile`
- Reviewing or fixing an existing `Dockerfile` for correctness or security
- Reducing image size or improving build cache hit rates
- Converting a single-stage build to a multi-stage build
- Debugging build failures or unexpected runtime behavior
- Choosing between `CMD`, `ENTRYPOINT`, `ARG`, `ENV`, `COPY`, or `ADD`

## When Not to Use

- Writing `docker-compose.yml` or Compose files (different concern)
- Kubernetes manifest or Helm chart authoring
- General shell scripting not related to a container build

## Prerequisites

- Docker Engine 20.10+ (for BuildKit features like `--mount=type=cache`)
- A `.dockerignore` file alongside every `Dockerfile`
- The target runtime environment and language version are known

## Workflow

1. Identify the language, runtime version, and target environment (dev/prod).
2. Select a pinned, minimal base image — see
   [references/overview.md](references/overview.md) for the selection guide.
3. Design the stage layout: separate build-time dependencies from runtime using
   multi-stage builds.
4. Order instructions for maximum cache reuse: install dependencies before
   copying source code.
5. Apply security hardening: non-root user, dropped capabilities, no secrets
   in layers.
6. Write or update `.dockerignore` to keep the build context minimal.
7. For language-specific patterns and complete examples, read
   [references/examples.md](references/examples.md).
8. For common mistakes and how to fix them, read
   [references/troubleshooting.md](references/troubleshooting.md).

## Hard Rules

- **Pin base image versions.** Never use `latest` or a mutable tag.
- **Use exec form for `ENTRYPOINT` and `CMD`.** JSON array syntax only:
  `["executable", "arg"]` — shell form prevents signal propagation.
- **Never store secrets in image layers.** Do not use `ENV` or `ARG` for
  passwords, tokens, or keys baked into the image.
- **Always run as a non-root user.** Create a dedicated user and set `USER`
  before the final `CMD`/`ENTRYPOINT`.
- **Combine related `RUN` steps.** Each `RUN` creates a layer; split only
  when cache granularity justifies it.
- **Clean package caches in the same `RUN` layer** that installs packages.
- **Never split `apt-get update` from `apt-get install`.** They must be one
  `RUN` command to prevent stale cache bugs.
- **Prefer `COPY` over `ADD`** unless tar auto-extraction is explicitly needed.

## Failure Handling

- If the base image tag is not pinnable to a digest or exact version, flag it
  and ask the user to confirm the target version before proceeding.
- If secrets are required at build time, stop and recommend BuildKit secret
  mounts (`--mount=type=secret`) instead of `ARG`/`ENV`.
- If the final image is larger than expected, check for missing multi-stage
  split or package cache not cleaned in the same layer.

## Red Flags

- `FROM node:latest` or any mutable tag — images will silently change
- `RUN apt-get update` on one line, `RUN apt-get install` on the next
- `ENV SECRET_KEY=...` or `ARG PASSWORD=...` baked into the image
- `CMD npm start` (shell form) — SIGTERM is not forwarded to the process
- `COPY . .` without a `.dockerignore` — secrets and `.git` leak into context
- `USER root` in the final stage
- Package caches (`/var/lib/apt/lists/*`, `/root/.cache`) left in the image
