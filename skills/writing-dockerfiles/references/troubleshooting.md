# Writing Dockerfiles: Troubleshooting

## Contents

- [Cache Invalidation Problems](#cache-invalidation-problems)
- [Signal Handling and Graceful Shutdown](#signal-handling-and-graceful-shutdown)
- [Image Size Larger Than Expected](#image-size-larger-than-expected)
- [Permission Errors at Runtime](#permission-errors-at-runtime)
- [Package Installation Failures](#package-installation-failures)
- [Secret Leakage](#secret-leakage)
- [Multi-Stage Build Mistakes](#multi-stage-build-mistakes)
- [Common Anti-Patterns](#common-anti-patterns)

---

## Cache Invalidation Problems

**Symptom:** Dependency installation runs on every build even when
`package.json` has not changed.

**Cause:** Source code is copied before dependency manifests, so any
source change invalidates the install layer.

```dockerfile
# Bad
COPY . .
RUN npm ci

# Good
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
```

**Symptom:** `apt-get install` fetches packages from the internet even
though packages have not changed.

**Cause:** `apt-get update` is in a separate `RUN` layer that was cached,
but the package list is now stale.

```dockerfile
# Bad
RUN apt-get update
RUN apt-get install -y curl

# Good — single layer keeps update and install together
RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*
```

---

## Signal Handling and Graceful Shutdown

**Symptom:** `docker stop` takes 10 seconds (the default timeout) before
the container is killed. The application does not shut down cleanly.

**Cause:** Shell form `CMD` or `ENTRYPOINT` wraps the process in
`/bin/sh -c`, making the shell PID 1. SIGTERM is sent to the shell, not
the application.

```dockerfile
# Bad — shell is PID 1; app never sees SIGTERM
CMD node server.js

# Good — node is PID 1
ENTRYPOINT ["node", "server.js"]
```

**Cause:** Application does not reap zombie processes (relevant when
spawning child processes).

**Fix:** Add `tini` as a minimal init:

```dockerfile
RUN apk add --no-cache tini
ENTRYPOINT ["/sbin/tini", "--", "node", "server.js"]
```

**Cause:** Shell-script entrypoint does not exec into the application.

```bash
# Bad — shell remains PID 1
#!/bin/sh
node server.js

# Good — exec replaces the shell
#!/bin/sh
set -e
exec node server.js
```

---

## Image Size Larger Than Expected

**Symptom:** Final image is hundreds of MB larger than expected.

**Checklist:**

1. Is there a multi-stage build? If not, build tools remain in the image.
2. Is the package cache cleaned in the same `RUN` that installed packages?
   (`/var/lib/apt/lists/*`, `/root/.cache/pip`, `/root/.npm`)
3. Is `.dockerignore` excluding `node_modules`, `dist`, test files?
4. Is the base image minimal? Switch from `ubuntu` to `debian:slim` or
   `alpine` if compatible.
5. Are dev dependencies included? Use `npm ci --only=production`,
   `pip install --no-dev`, or stage separation.

Run `docker history <image>` to see which layers consume the most space.
Use `dive` for interactive layer inspection:

```bash
dive <image>
```

---

## Permission Errors at Runtime

**Symptom:** Application fails with `Permission denied` when writing to a
directory or reading a file.

**Cause:** Files were `COPY`-ed as root, but the container runs as a
non-root user.

**Fix:** Use `--chown` flag on `COPY`:

```dockerfile
RUN addgroup -S app && adduser -S app -G app
COPY --chown=app:app . .
USER app
```

**Cause:** A mounted volume at runtime is owned by root, but the process
user does not have write access.

**Fix:** Create the directory before switching user and set ownership:

```dockerfile
RUN mkdir -p /app/data && chown -R app:app /app/data
USER app
```

---

## Package Installation Failures

**Symptom:** `apk add` or `apt-get install` fails with "package not found".

**Cause:** Package index is stale or the package name differs between
distributions.

Alpine fix:

```dockerfile
# Use --no-cache to always fetch fresh index without caching the file
RUN apk add --no-cache curl
```

Debian fix — never cache the update layer separately:

```dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*
```

**Symptom:** Build fails on ARM64 with a package not available for that
architecture.

**Fix:** Use BuildKit `--platform` to build for the native arch, or find
an architecture-agnostic alternative package.

---

## Secret Leakage

**Symptom:** `docker history` or image inspection reveals a credential.

**Cause:** `ARG` or `ENV` was used to pass a secret during the build.
Even if `unset` later, the value is captured in the layer.

```dockerfile
# Dangerous — visible in docker history
ARG NPM_TOKEN
RUN echo "//registry.npmjs.org/:_authToken=${NPM_TOKEN}" > .npmrc && \
    npm install && \
    rm .npmrc
```

**Fix:** Use BuildKit secret mounts, which are never written to any layer:

```dockerfile
# syntax=docker/dockerfile:1
RUN --mount=type=secret,id=npmrc,target=/root/.npmrc \
    npm install
```

Build:

```bash
docker build --secret id=npmrc,src=$HOME/.npmrc .
```

---

## Multi-Stage Build Mistakes

**Symptom:** Final image still contains build tools or source code.

**Cause:** `COPY . .` in the final stage copies everything instead of
only built artifacts.

```dockerfile
# Bad — copies all source into runtime stage
FROM builder AS final
COPY . .

# Good — copies only the compiled artifact
FROM gcr.io/distroless/static-debian12
COPY --from=builder /app/server /server
```

**Symptom:** `COPY --from` cannot find the file.

**Cause:** The source path is relative to the stage's `WORKDIR`, not the
host. Use the absolute path from the stage.

```dockerfile
# builder WORKDIR is /app, binary written to /app/server
COPY --from=builder /app/server /server
```

---

## Common Anti-Patterns

| Anti-pattern | Problem | Fix |
| ------------ | ------- | --- |
| `FROM ubuntu:latest` | Image changes silently | Pin to `ubuntu:24.04` |
| `RUN apt-get update` then `RUN apt-get install` | Stale cache | Combine in one `RUN` |
| `ADD https://...` | No checksum, no cache control | Use `curl` with `--fail` and checksum |
| `ENV SECRET=value` | Secret baked into image | Use runtime env or BuildKit secret mount |
| `USER root` in final stage | Container runs as root | Add `USER nonroot` |
| `COPY . .` without `.dockerignore` | Leaks `.env`, `.git`, secrets | Create `.dockerignore` |
| `CMD npm start` (shell form) | SIGTERM not forwarded | Use `ENTRYPOINT ["node", "server.js"]` |
| Package cache left in layer | Inflated image size | Clean in same `RUN` |
| No `HEALTHCHECK` for services | Orchestrator cannot detect failures | Add `HEALTHCHECK` |
| `RUN cd /path` | Does not persist | Use `WORKDIR /path` |
