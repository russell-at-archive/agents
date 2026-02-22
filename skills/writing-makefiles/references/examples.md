# Writing Makefiles: Examples

## Contents

- [Task Runner (universal starting point)](#task-runner-universal-starting-point)
- [C Project with Pattern Rules](#c-project-with-pattern-rules)
- [Go Project](#go-project)
- [Docker Image Build](#docker-image-build)
- [Multi-Environment Deploy](#multi-environment-deploy)
- [Generated Dependency Tracking](#generated-dependency-tracking)

---

## Task Runner (universal starting point)

A Makefile that acts as a task runner for any project. No build artifacts produced.

```makefile
SHELL := /bin/bash
.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
.SUFFIXES:

MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

# ── Targets ───────────────────────────────────────────────────────────────────

.PHONY: help install lint test build clean

help: ## Show available targets
	@grep -E '^[a-zA-Z_/-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	  | sort \
	  | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

install: ## Install dependencies
	npm ci

lint: ## Run linter
	npx eslint src/

test: ## Run tests
	npx jest --coverage

build: ## Build for production
	npx tsc --project tsconfig.prod.json

clean: ## Remove build artifacts
	rm -rf dist/ coverage/
```

---

## C Project with Pattern Rules

Compiles `.c` source files to `.o` objects and links a binary. Handles
dependency tracking with `-MMD -MP`.

```makefile
SHELL := /bin/bash
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

# ── Configuration ─────────────────────────────────────────────────────────────

CC      := gcc
CFLAGS  := -Wall -Wextra -std=c11
LDFLAGS :=
LDLIBS  :=

SRC_DIR   := src
BUILD_DIR := build
BIN_DIR   := $(BUILD_DIR)/bin
OBJ_DIR   := $(BUILD_DIR)/obj

TARGET  := $(BIN_DIR)/app
SRCS    := $(wildcard $(SRC_DIR)/*.c)
OBJECTS := $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(SRCS))
DEPS    := $(OBJECTS:.o=.d)

# ── Directory targets ─────────────────────────────────────────────────────────

$(OBJ_DIR) $(BIN_DIR):
	mkdir -p $@

# ── Build rules ───────────────────────────────────────────────────────────────

.PHONY: all clean

all: $(TARGET) ## Build the application

$(TARGET): $(OBJECTS) | $(BIN_DIR)
	$(CC) $(LDFLAGS) $^ $(LDLIBS) -o $@

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c | $(OBJ_DIR)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

-include $(DEPS)

clean: ## Remove build artifacts
	rm -rf $(BUILD_DIR)
```

---

## Go Project

Builds, tests, lints, and packages a Go binary. Uses `go env` to determine
module name and architecture.

```makefile
SHELL := /bin/bash
.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
.SUFFIXES:

MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

# ── Configuration ─────────────────────────────────────────────────────────────

MODULE  := $(shell go env GOMODULE 2>/dev/null || head -1 go.mod | awk '{print $$2}')
VERSION := $(shell git describe --tags --always --dirty 2>/dev/null || echo dev)
GOOS    := $(shell go env GOOS)
GOARCH  := $(shell go env GOARCH)

BUILD_DIR := dist
BINARY    := $(BUILD_DIR)/$(notdir $(MODULE))

LDFLAGS := -ldflags "-X main.version=$(VERSION)"

# ── Targets ───────────────────────────────────────────────────────────────────

.PHONY: help build test lint vet fmt clean

help: ## Show available targets
	@grep -E '^[a-zA-Z_/-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	  | sort \
	  | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: $(BINARY) ## Compile the binary

$(BINARY): $(shell find . -name '*.go' -not -path './vendor/*') | $(BUILD_DIR)
	go build $(LDFLAGS) -o $@ ./cmd/...

$(BUILD_DIR):
	mkdir -p $@

test: ## Run tests with coverage
	go test -race -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html

lint: ## Run golangci-lint
	golangci-lint run ./...

vet: ## Run go vet
	go vet ./...

fmt: ## Format source code
	gofmt -w .

clean: ## Remove build artifacts
	rm -rf $(BUILD_DIR) coverage.out coverage.html
```

---

## Docker Image Build

Builds, tags, and pushes Docker images. Uses guard pattern for required
environment variables.

```makefile
SHELL := /bin/bash
.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
.SUFFIXES:

MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

# ── Configuration ─────────────────────────────────────────────────────────────

REGISTRY   ?= ghcr.io
REPO       ?= myorg/myapp
VERSION    := $(shell git describe --tags --always --dirty 2>/dev/null || echo dev)
IMAGE      := $(REGISTRY)/$(REPO)
DOCKERFILE := Dockerfile
PLATFORM   := linux/amd64,linux/arm64

# ── Guards ────────────────────────────────────────────────────────────────────

guard-%:
	@if [ -z "${$*}" ]; then \
	  echo "Variable $* is required but not set"; \
	  exit 1; \
	fi

# ── Targets ───────────────────────────────────────────────────────────────────

.PHONY: help build push release clean

help: ## Show available targets
	@grep -E '^[a-zA-Z_/-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	  | sort \
	  | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: ## Build image for local platform
	docker build \
	  --tag $(IMAGE):$(VERSION) \
	  --tag $(IMAGE):latest \
	  --file $(DOCKERFILE) \
	  .

push: guard-REGISTRY ## Push image to registry
	docker push $(IMAGE):$(VERSION)
	docker push $(IMAGE):latest

release: guard-REGISTRY ## Build and push multi-platform image
	docker buildx build \
	  --platform $(PLATFORM) \
	  --tag $(IMAGE):$(VERSION) \
	  --tag $(IMAGE):latest \
	  --file $(DOCKERFILE) \
	  --push \
	  .

clean: ## Remove local image
	docker rmi $(IMAGE):$(VERSION) $(IMAGE):latest 2>/dev/null || true
```

---

## Multi-Environment Deploy

Deploys to different environments using a parameterized pattern. Validates
required variables before running destructive operations.

```makefile
SHELL := /bin/bash
.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
.SUFFIXES:

MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

# ── Configuration ─────────────────────────────────────────────────────────────

ENVS       := dev staging prod
DEPLOY_CMD := ./scripts/deploy.sh

# ── Guards ────────────────────────────────────────────────────────────────────

guard-%:
	@if [ -z "${$*}" ]; then \
	  echo "Variable $* is required but not set"; \
	  exit 1; \
	fi

# ── Per-environment targets ───────────────────────────────────────────────────

.PHONY: help $(foreach e,$(ENVS),deploy/$(e) plan/$(e))

help: ## Show available targets
	@grep -E '^[a-zA-Z_/-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	  | sort \
	  | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

deploy/dev: ## Deploy to dev
	$(DEPLOY_CMD) dev

deploy/staging: guard-VERSION ## Deploy to staging (requires VERSION)
	$(DEPLOY_CMD) staging $(VERSION)

deploy/prod: guard-VERSION guard-APPROVAL ## Deploy to prod (requires VERSION and APPROVAL)
	$(DEPLOY_CMD) prod $(VERSION)

plan/%: ## Dry-run deploy for the given environment
	$(DEPLOY_CMD) $* --dry-run
```

---

## Generated Dependency Tracking

Pattern for C/C++ projects that auto-generates `.d` files so header changes
trigger recompilation.

```makefile
SHELL := /bin/bash
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

CC     := gcc
CFLAGS := -Wall -std=c11

SRC_DIR   := src
BUILD_DIR := build

SRCS    := $(wildcard $(SRC_DIR)/*.c)
OBJECTS := $(patsubst $(SRC_DIR)/%.c,$(BUILD_DIR)/%.o,$(SRCS))
DEPS    := $(OBJECTS:.o=.d)
TARGET  := $(BUILD_DIR)/app

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CC) $^ -o $@

# -MMD: generate .d file alongside .o
# -MP:  add phony targets for each header (prevents errors on header deletion)
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

$(BUILD_DIR):
	mkdir -p $@

# Include generated dependency files silently (missing on first build is OK)
-include $(DEPS)

clean:
	rm -rf $(BUILD_DIR)
```
