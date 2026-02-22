# Writing Dockerfiles: Full Reference

## Contents

- [Base Image Selection](#base-image-selection)
- [Layer Ordering and Cache Optimization](#layer-ordering-and-cache-optimization)
- [Multi-Stage Builds](#multi-stage-builds)
- [ARG vs ENV](#arg-vs-env)
- [COPY vs ADD](#copy-vs-add)
- [CMD vs ENTRYPOINT](#cmd-vs-entrypoint)
- [WORKDIR](#workdir)
- [Security Hardening](#security-hardening)
- [Package Installation Patterns](#package-installation-patterns)
- [Build Context and .dockerignore](#build-context-and-dockerignore)
- [Health Checks](#health-checks)
- [Labels](#labels)
- [BuildKit Features](#buildkit-features)
- [Language-Specific Guidance](#language-specific-guidance)
- [Image Size Reduction Checklist](#image-size-reduction-checklist)

---

## Base Image Selection

Choose the smallest image that satisfies runtime requirements.

| Tier | Base | Use case |
| ---- | ---- | -------- |
| Minimal | `scratch` | Statically compiled binaries (Go, Rust) |
| Distroless | `gcr.io/distroless/base` | No shell, minimal CVE surface |
| Alpine | `alpine:3.x` | Small footprint with `apk`, musl libc |
| Slim | `debian:bookworm-slim` | Debian ecosystem without extras |
| Full | `ubuntu:24.04` | Max compatibility, largest size |

**Always pin to an exact version tag:**

```dockerfile
# Good
FROM node:20.11-alpine3.19
FROM python:3.12.2-slim-bookworm
FROM golang:1.22.1-alpine3.19 AS builder

# Bad
FROM node:latest
FROM python:3
```

Pin by digest for maximum reproducibility in production:

```dockerfile
FROM node:20.11-alpine3.19@sha256:<digest>
```

---

## Layer Ordering and Cache Optimization

Docker caches each layer. A cache miss on one instruction invalidates all
subsequent layers. Order instructions from **least** to **most frequently
changing**.

Canonical order:

```dockerfile
FROM base-image

# 1. System packages (rarely change)
RUN apk add --no-cache curl ca-certificates

# 2. Dependency manifests (change less than source)
COPY package.json package-lock.json ./

# 3. Dependency installation (cached until manifests change)
RUN npm ci --only=production

# 4. Application source (changes most frequently)
COPY . .
```

Never copy all source before installing dependencies:

```dockerfile
# Bad — source change busts dependency cache
COPY . .
RUN npm install
```

---

## Multi-Stage Builds

Use named stages to isolate build tools from the runtime image.

```dockerfile
# Stage 1: build
FROM golang:1.22.1-alpine3.19 AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o /app/server ./cmd/server

# Stage 2: runtime
FROM gcr.io/distroless/static-debian12
COPY --from=builder /app/server /server
ENTRYPOINT ["/server"]
```

Rules:

- Name every non-trivial stage with `AS <name>`.
- Copy only artifacts, not source or toolchains, into the final stage.
- Use `COPY --from=<stage>` to pull files across stages.
- The final stage should have no build tools, compilers, or package managers.

---

## ARG vs ENV

| Instruction | Scope | Persisted in image | Use for |
| ----------- | ----- | ------------------ | ------- |
| `ARG` | Build time only | No | Build variants, parameterizing base image |
| `ENV` | Build + runtime | Yes | App configuration, PATH additions |

`ARG` before `FROM` parameterizes the base image:

```dockerfile
ARG NODE_VERSION=20.11
FROM node:${NODE_VERSION}-alpine3.19
```

`ARG` inside the build does not persist in the final image — but its value
is visible in `docker history`. **Never use `ARG` for secrets.**

Use `ENV` only for values the running container genuinely needs:

```dockerfile
ENV NODE_ENV=production \
    PORT=8080
```

Do not use `ENV` for secrets. Pass secrets at runtime via `docker run -e` or
orchestrator secret injection.

---

## COPY vs ADD

Prefer `COPY` in almost every case.

| Instruction | Behavior |
| ----------- | -------- |
| `COPY` | Copies files/dirs from the build context or a stage |
| `ADD` | Same as COPY, plus: auto-extracts local tarballs, fetches remote URLs |

`ADD` with a URL fetches at build time with no cache invalidation control
and no checksum verification — use `curl` with a pinned checksum instead.

`ADD` for tarballs is acceptable but must be documented:

```dockerfile
# Acceptable: ADD extracts the tarball
ADD rootfs.tar.gz /

# Better: be explicit
COPY rootfs.tar.gz /tmp/
RUN tar -xzf /tmp/rootfs.tar.gz -C / && rm /tmp/rootfs.tar.gz
```

---

## CMD vs ENTRYPOINT

| Instruction | Purpose | Overridable |
| ----------- | ------- | ----------- |
| `ENTRYPOINT` | The main executable; defines the container's identity | With `--entrypoint` |
| `CMD` | Default arguments to `ENTRYPOINT`, or the full command if no `ENTRYPOINT` | With positional args |

**Always use exec (JSON array) form** to avoid shell wrapping, which prevents
the process from receiving SIGTERM:

```dockerfile
# Good — process is PID 1, receives signals directly
ENTRYPOINT ["node", "server.js"]
CMD ["--port", "8080"]

# Bad — /bin/sh -c is PID 1; node never gets SIGTERM
CMD node server.js
ENTRYPOINT node server.js
```

Use `tini` or `dumb-init` as PID 1 when the application does not handle
zombie reaping:

```dockerfile
RUN apk add --no-cache tini
ENTRYPOINT ["/sbin/tini", "--", "node", "server.js"]
```

If using a shell-script entrypoint, end with `exec "$@"` to replace the shell:

```bash
#!/bin/sh
set -e
# setup steps
exec "$@"
```

---

## WORKDIR

Always set `WORKDIR` explicitly. Use absolute paths.

```dockerfile
WORKDIR /app
```

Do not use `RUN cd /some/path` — it does not persist across `RUN` layers.
`WORKDIR` creates the directory if it does not exist.

---

## Security Hardening

### Non-root user

Create a dedicated user and switch to it before `CMD`/`ENTRYPOINT`:

```dockerfile
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser
```

For Debian-based images:

```dockerfile
RUN groupadd --system appgroup && \
    useradd --system --gid appgroup --no-create-home appuser
USER appuser
```

For distroless images, use the built-in nonroot user:

```dockerfile
FROM gcr.io/distroless/base-debian12:nonroot
```

### Read-only filesystem

Run containers with `--read-only` and mount writable tmpfs only where needed.
Signal this intent in the Dockerfile by not writing to the image filesystem
at runtime.

### Secrets at build time

Use BuildKit secret mounts (never `ARG` or `ENV`):

```dockerfile
# syntax=docker/dockerfile:1
RUN --mount=type=secret,id=npmrc,target=/root/.npmrc \
    npm install
```

Build with: `docker build --secret id=npmrc,src=$HOME/.npmrc .`

### Vulnerability scanning

After building, scan with:

```bash
docker scout cves <image>
# or
trivy image <image>
```

---

## Package Installation Patterns

### Alpine (apk)

```dockerfile
RUN apk add --no-cache \
    curl \
    ca-certificates \
    tzdata
```

`--no-cache` skips the package index cache file — no separate cleanup needed.

### Debian / Ubuntu (apt-get)

```dockerfile
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*
```

Rules:

- `apt-get update` and `apt-get install` must be in a single `RUN`.
- `--no-install-recommends` reduces installed packages significantly.
- `rm -rf /var/lib/apt/lists/*` must be in the same `RUN` layer.

---

## Build Context and .dockerignore

Always create a `.dockerignore` file. Every file in the build context is
sent to the Docker daemon — leaking `.env`, `.git`, `node_modules`, or
build artifacts slows builds and risks secret exposure.

Minimal `.dockerignore`:

```text
.git
.gitignore
.env
*.env
node_modules
__pycache__
*.pyc
.pytest_cache
dist
build
coverage
*.log
.DS_Store
README.md
docs/
tests/
```

Use `COPY --link` (BuildKit) for improved cache behavior when the base image
changes independently of the copied files.

---

## Health Checks

Add a `HEALTHCHECK` for any long-running service:

```dockerfile
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1
```

For images without `curl`, use a compiled health binary or TCP check:

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s \
    CMD wget -qO- http://localhost:8080/health || exit 1
```

---

## Labels

Follow the OCI image spec for standard labels:

```dockerfile
LABEL org.opencontainers.image.title="My App" \
      org.opencontainers.image.version="1.2.3" \
      org.opencontainers.image.source="https://github.com/org/repo" \
      org.opencontainers.image.licenses="MIT"
```

Set dynamic labels at build time with `ARG`:

```dockerfile
ARG BUILD_DATE
ARG GIT_SHA
LABEL org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${GIT_SHA}"
```

---

## BuildKit Features

Enable with `DOCKER_BUILDKIT=1` or `docker buildx build`.

| Feature | Syntax | Use |
| ------- | ------ | --- |
| Secret mounts | `--mount=type=secret` | Credentials at build time |
| Cache mounts | `--mount=type=cache` | Package manager caches |
| SSH mounts | `--mount=type=ssh` | Git SSH access |
| Bind mounts | `--mount=type=bind` | Read host files without COPY |

Cache mount example for pip:

```dockerfile
# syntax=docker/dockerfile:1
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt
```

Cache mount for apk:

```dockerfile
RUN --mount=type=cache,target=/var/cache/apk \
    apk add --update curl ca-certificates
```

---

## Language-Specific Guidance

### Node.js

```dockerfile
FROM node:20.11-alpine3.19 AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --only=production

FROM node:20.11-alpine3.19
WORKDIR /app
ENV NODE_ENV=production
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN addgroup -S app && adduser -S app -G app
USER app
EXPOSE 8080
ENTRYPOINT ["node", "server.js"]
```

- Use `npm ci` (reproducible) not `npm install`.
- Set `NODE_ENV=production` to skip dev dependencies.

### Python

```dockerfile
FROM python:3.12.2-slim-bookworm AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.12.2-slim-bookworm
WORKDIR /app
ENV PYTHONUNBUFFERED=1 PYTHONDONTWRITEBYTECODE=1
COPY --from=builder /install /usr/local
COPY . .
RUN useradd --system --no-create-home appuser
USER appuser
ENTRYPOINT ["python", "app.py"]
```

- `PYTHONUNBUFFERED=1` ensures stdout/stderr are not buffered.
- `PYTHONDONTWRITEBYTECODE=1` skips `.pyc` files.
- `--no-cache-dir` avoids writing the pip cache into the layer.

### Go

```dockerfile
FROM golang:1.22.1-alpine3.19 AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /server ./cmd/server

FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=builder /server /server
EXPOSE 8080
ENTRYPOINT ["/server"]
```

- `CGO_ENABLED=0` produces a fully static binary.
- `-ldflags="-s -w"` strips debug info and DWARF, reducing binary size.
- `distroless/static` has no shell — zero attack surface.

---

## Image Size Reduction Checklist

- [ ] Multi-stage build separates build and runtime layers
- [ ] Minimal base image selected for the runtime tier
- [ ] Package caches cleaned in the same `RUN` layer that installs them
- [ ] `--no-install-recommends` or `--no-cache` used for package installs
- [ ] Dev dependencies excluded from the final stage
- [ ] `.dockerignore` excludes all non-essential files
- [ ] Build tools, compilers, and SDKs not present in the final stage
- [ ] Binary stripped of debug symbols where applicable
