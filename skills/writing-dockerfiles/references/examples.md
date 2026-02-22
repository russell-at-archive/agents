# Writing Dockerfiles: Examples

## Contents

- [Node.js Production Service](#nodejs-production-service)
- [Python FastAPI Service](#python-fastapi-service)
- [Go Binary with Distroless](#go-binary-with-distroless)
- [Static Site with Nginx](#static-site-with-nginx)
- [Multi-Platform Build with BuildKit](#multi-platform-build-with-buildkit)
- [Minimal .dockerignore](#minimal-dockerignore)

---

## Node.js Production Service

A two-stage build: install production dependencies in one stage, copy them
to a clean runtime stage.

```dockerfile
# syntax=docker/dockerfile:1
FROM node:20.11-alpine3.19 AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --only=production

FROM node:20.11-alpine3.19
WORKDIR /app
ENV NODE_ENV=production \
    PORT=8080
RUN addgroup -S app && adduser -S app -G app
COPY --from=deps /app/node_modules ./node_modules
COPY --chown=app:app . .
USER app
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget -qO- http://localhost:${PORT}/health || exit 1
ENTRYPOINT ["node", "server.js"]
```

---

## Python FastAPI Service

```dockerfile
# syntax=docker/dockerfile:1
FROM python:3.12.2-slim-bookworm AS builder
WORKDIR /build
COPY requirements.txt .
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --prefix=/install -r requirements.txt

FROM python:3.12.2-slim-bookworm
WORKDIR /app
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PORT=8080
RUN useradd --system --no-create-home --uid 1001 appuser
COPY --from=builder /install /usr/local
COPY --chown=appuser:appuser . .
USER appuser
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:${PORT}/health')"
ENTRYPOINT ["python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
```

---

## Go Binary with Distroless

Produces the smallest possible image: a statically compiled binary in a
distroless container with no shell and no package manager.

```dockerfile
# syntax=docker/dockerfile:1
FROM golang:1.22.1-alpine3.19 AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download
COPY . .
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOOS=linux go build \
        -ldflags="-s -w" \
        -o /server \
        ./cmd/server

FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=builder /server /server
EXPOSE 8080
ENTRYPOINT ["/server"]
```

---

## Static Site with Nginx

Build the site, then serve with a minimal nginx image.

```dockerfile
# syntax=docker/dockerfile:1
FROM node:20.11-alpine3.19 AS builder
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:1.25.3-alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
RUN addgroup -S nginx && adduser -S nginx -G nginx || true
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s \
    CMD wget -qO- http://localhost/health || exit 1
CMD ["nginx", "-g", "daemon off;"]
```

`nginx.conf` for a single-page app:

```nginx
server {
    listen 80;
    root /usr/share/nginx/html;
    index index.html;

    location /health {
        return 200 "ok\n";
        add_header Content-Type text/plain;
    }

    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

---

## Multi-Platform Build with BuildKit

Build for `linux/amd64` and `linux/arm64` simultaneously:

```bash
docker buildx create --use --name multiarch
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --tag registry.example.com/myapp:1.0.0 \
  --push \
  .
```

Use `TARGETARCH` and `TARGETOS` build args (automatically set by BuildKit)
for platform-specific steps:

```dockerfile
FROM golang:1.22.1-alpine3.19 AS builder
ARG TARGETOS TARGETARCH
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    go build -o /server ./cmd/server
```

---

## Minimal .dockerignore

```text
# Version control
.git
.gitignore
.gitattributes

# Secrets and environment
.env
*.env
.env.*

# Language-specific build artifacts
node_modules
__pycache__
*.pyc
*.pyo
.pytest_cache
.mypy_cache
dist
build
target
*.class

# IDE and OS
.vscode
.idea
*.swp
.DS_Store
Thumbs.db

# Test and documentation
tests/
test/
spec/
coverage/
*.log
docs/
README.md
CHANGELOG.md

# Docker itself (avoid circular inclusion)
Dockerfile*
.dockerignore
docker-compose*.yml
```
