# Writing GitLab CI/CD: Full Reference

## Contents

- [Core Concepts](#core-concepts)
- [Pipeline Structure](#pipeline-structure)
- [Stages and Jobs](#stages-and-jobs)
- [Rules and Conditions](#rules-and-conditions)
- [Variables](#variables)
- [Artifacts and Caching](#artifacts-and-caching)
- [Needs and DAG Pipelines](#needs-and-dag-pipelines)
- [Reuse: Extends, Anchors, and Includes](#reuse-extends-anchors-and-includes)
- [Environments and Deployments](#environments-and-deployments)
- [Merge Request Pipelines](#merge-request-pipelines)
- [Parent-Child and Multi-Project Pipelines](#parent-child-and-multi-project-pipelines)
- [Security Scanning Templates](#security-scanning-templates)
- [Runners](#runners)
- [Secrets and Security](#secrets-and-security)
- [Validation](#validation)
- [Operational Guardrails](#operational-guardrails)

---

## Core Concepts

- **Pipeline**: Set of stages and jobs triggered by an event (push, tag, MR, schedule).
- **Stage**: Named group of jobs that run in parallel before the next stage starts.
- **Job**: Atomic unit of work; runs a `script` on a runner.
- **Runner**: Agent that executes jobs; matched by tags and scope (shared/group/project).
- **Artifact**: Files produced by a job, passed to downstream jobs or downloadable.
- **Cache**: Files reused across pipeline runs to speed up jobs (e.g., node_modules).

---

## Pipeline Structure

Minimal `.gitlab-ci.yml`:

```yaml
stages:
  - build
  - test
  - deploy

build-job:
  stage: build
  script:
    - make build

test-job:
  stage: test
  script:
    - make test

deploy-job:
  stage: deploy
  script:
    - make deploy
  environment:
    name: production
```

Key top-level keywords:

| Keyword | Purpose |
|---------|---------|
| `stages` | Define and order stage names |
| `variables` | Global CI/CD variables |
| `workflow` | Control when a pipeline runs |
| `include` | Import external YAML files |
| `default` | Default values for all jobs |
| `image` | Default Docker image |

---

## Stages and Jobs

Define stages explicitly to control order. Jobs in the same stage run in
parallel (subject to runner availability).

```yaml
stages:
  - lint
  - build
  - test
  - release
  - deploy
```

Job anatomy:

```yaml
my-job:
  stage: test
  image: node:20-alpine
  tags:
    - docker
  before_script:
    - npm ci
  script:
    - npm test
  after_script:
    - echo "done"
  timeout: 10 minutes
  retry:
    max: 2
    when:
      - runner_system_failure
  interruptible: true
```

Use `timeout` and `retry` on long-running or flaky jobs. Set
`interruptible: true` on any job that can be safely cancelled when a newer
pipeline starts for the same ref.

---

## Rules and Conditions

`rules` replaces the deprecated `only`/`except` keywords. Rules are evaluated
top-to-bottom; the first match wins.

```yaml
deploy-production:
  script: ./deploy.sh
  rules:
    - if: '$CI_COMMIT_TAG =~ /^v\d+\.\d+\.\d+$/'
      when: manual
    - if: '$CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH'
      when: on_success
    - when: never
```

Common predicates:

| Variable | Meaning |
|----------|---------|
| `$CI_PIPELINE_SOURCE == "merge_request_event"` | MR pipeline |
| `$CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH` | Default branch push |
| `$CI_COMMIT_TAG` | Tag pipeline |
| `$CI_PIPELINE_SOURCE == "schedule"` | Scheduled pipeline |
| `$CI_PIPELINE_SOURCE == "web"` | Manual trigger |

`workflow` rules control whether a pipeline starts at all:

```yaml
workflow:
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
    - if: '$CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH'
    - if: '$CI_COMMIT_TAG'
    - when: never
```

---

## Variables

Define at global, job, or `environment` scope. Use group/project CI/CD
settings for secrets.

```yaml
variables:
  APP_ENV: staging          # global default
  DOCKER_BUILDKIT: "1"

build-image:
  variables:
    PLATFORM: linux/amd64   # job-scoped override
  script:
    - docker build --platform $PLATFORM .
```

Variable types:

- **File variables**: Mounted as a temp file; path injected into the variable.
- **Masked variables**: Redacted from job logs (cannot contain newlines).
- **Protected variables**: Only available on protected branches/tags.

Predefined variables worth knowing:

| Variable | Value |
|----------|-------|
| `$CI_PROJECT_PATH` | `namespace/project` |
| `$CI_COMMIT_SHA` | Full commit SHA |
| `$CI_COMMIT_SHORT_SHA` | 8-char SHA |
| `$CI_REGISTRY_IMAGE` | Project container registry path |
| `$CI_ENVIRONMENT_SLUG` | URL-safe environment name |
| `$CI_MERGE_REQUEST_IID` | MR internal ID |

---

## Artifacts and Caching

**Artifacts** — pass files between jobs or expose for download:

```yaml
build-job:
  script:
    - make build
  artifacts:
    paths:
      - dist/
    expire_in: 7 days
    when: always          # upload even on failure
    reports:
      junit: reports/junit.xml
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml
```

Always set `expire_in`. Use `artifacts:reports` for test/coverage data to
surface results in the GitLab UI.

**Cache** — reuse build dependencies across runs:

```yaml
default:
  cache:
    key:
      files:
        - package-lock.json
    paths:
      - node_modules/

build-job:
  cache:
    policy: pull          # read-only; skip upload
```

Cache is not a reliable artifact transport — use `artifacts` for inter-job
dependencies and `cache` for package manager directories.

---

## Needs and DAG Pipelines

`needs` creates job-level dependencies regardless of stage, enabling a
directed acyclic graph (DAG) instead of strictly sequential stages.

```yaml
build-frontend:
  stage: build
  script: make frontend

build-backend:
  stage: build
  script: make backend

test-frontend:
  stage: test
  needs: [build-frontend]   # starts as soon as build-frontend finishes
  script: make test-frontend

test-backend:
  stage: test
  needs: [build-backend]
  script: make test-backend

deploy:
  stage: deploy
  needs: [test-frontend, test-backend]
  script: make deploy
```

Rules for `needs`:
- Jobs listed in `needs` must exist in the same pipeline or be cross-project.
- `needs` can reference jobs in earlier or same-stage jobs.
- Add `artifacts: true` (default) in `needs` entries to download artifacts.

---

## Reuse: Extends, Anchors, and Includes

### `extends` — inherit job configuration

```yaml
.base-test:
  image: python:3.12
  before_script:
    - pip install -r requirements.txt
  retry:
    max: 1

unit-tests:
  extends: .base-test
  script: pytest tests/unit

integration-tests:
  extends: .base-test
  script: pytest tests/integration
```

Hidden jobs (name starts with `.`) are templates; they never run directly.

### YAML anchors — inline reuse

```yaml
.default-rules: &default-rules
  rules:
    - if: '$CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH'
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'

lint:
  <<: *default-rules
  script: make lint
```

Prefer `extends` over anchors for cross-file reuse; anchors only work within
the same file.

### `include` — modular pipeline files

```yaml
include:
  - local: .gitlab/ci/build.yml
  - local: .gitlab/ci/test.yml
  - project: 'my-group/ci-templates'
    ref: 'v2.3.1'                   # pin to tag or SHA, never floating branch
    file: '/templates/docker.yml'
  - template: Security/SAST.gitlab-ci.yml
```

Include types:

| Type | Source |
|------|--------|
| `local` | Same repository |
| `project` | Another GitLab project |
| `remote` | Raw HTTP URL (avoid; use `project` instead) |
| `template` | GitLab-bundled templates |

Use `local` includes to split large pipelines into topic files under
`.gitlab/ci/`. Pin all `project` includes to an immutable ref.

---

## Environments and Deployments

```yaml
deploy-staging:
  script: ./deploy.sh staging
  environment:
    name: staging
    url: https://staging.example.com
    on_stop: stop-staging

stop-staging:
  script: ./teardown.sh staging
  environment:
    name: staging
    action: stop
  rules:
    - when: manual
```

Use `environment:deployment_tier` (`production`, `staging`, `testing`,
`development`, `other`) for GitLab DORA metrics.

Protected environments enforce approval gates before deployment jobs run.
Configure them in **Settings > CI/CD > Environments**.

---

## Merge Request Pipelines

MR pipelines run against the merge result, not just the source branch.

```yaml
workflow:
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
    - if: '$CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH'

mr-lint:
  script: make lint
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
```

Use `only: [merge_requests]` is deprecated; use `rules` with
`$CI_PIPELINE_SOURCE == "merge_request_event"` instead.

For merge trains, jobs must be `interruptible: false` if their side effects
cannot be rolled back.

---

## Parent-Child and Multi-Project Pipelines

### Parent-child

```yaml
generate-child:
  stage: build
  script:
    - ./generate-pipeline.sh > generated-pipeline.yml
  artifacts:
    paths:
      - generated-pipeline.yml

trigger-child:
  stage: test
  trigger:
    include:
      - artifact: generated-pipeline.yml
        job: generate-child
    strategy: depend     # parent waits and mirrors child status
```

### Multi-project

```yaml
trigger-downstream:
  trigger:
    project: my-group/downstream-repo
    branch: main
    strategy: depend
```

Use `strategy: depend` when the parent pipeline must reflect child/downstream
status. Without it, the trigger job always succeeds immediately.

---

## Security Scanning Templates

GitLab provides managed templates for common scans. Include them and they
auto-configure based on detected languages.

```yaml
include:
  - template: Security/SAST.gitlab-ci.yml
  - template: Security/Dependency-Scanning.gitlab-ci.yml
  - template: Security/Container-Scanning.gitlab-ci.yml
  - template: Security/Secret-Detection.gitlab-ci.yml
  - template: DAST.gitlab-ci.yml

variables:
  SAST_EXCLUDED_PATHS: "spec, test, tests, tmp"
  DS_EXCLUDED_PATHS: "spec, test, tests, tmp"

dast:
  variables:
    DAST_WEBSITE: https://staging.example.com
  rules:
    - if: '$CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH'
```

Security jobs run in the `test` stage by default. Do not rename stages without
also overriding the `stage` in included jobs.

---

## Runners

Runners are matched by `tags`. Always use specific tags to target the right
executor type.

```yaml
build-image:
  tags:
    - docker
    - linux-amd64
  script:
    - docker build .
```

Runner executors:

| Executor | Use case |
|----------|---------|
| `docker` | Isolated container per job (most common) |
| `shell` | Runs on runner host (avoid for untrusted code) |
| `kubernetes` | Job pod per job; scales horizontally |
| `docker-autoscaler` | Cloud auto-scaling (AWS/GCP) |

For the `docker` executor, always specify `image` per job or in `default`.
Never rely on the runner's pre-installed software.

---

## Secrets and Security

- Store secrets in **CI/CD Variables** (Settings > CI/CD > Variables), not in YAML.
- Mark variables `Masked` to redact from logs.
- Mark variables `Protected` to restrict to protected branches/tags.
- Use `id_tokens` for OIDC-based authentication (Vault, AWS, GCP):

```yaml
deploy:
  id_tokens:
    VAULT_ID_TOKEN:
      aud: https://vault.example.com
  script:
    - vault login -method=jwt jwt=$VAULT_ID_TOKEN
```

- Prefer OIDC/JWT over static credentials wherever the target supports it.
- Rotate static tokens stored as CI variables on a regular schedule.

---

## Validation

Lint before pushing:

```bash
# Using glab CLI
glab ci lint

# Using curl against GitLab API
curl --header "PRIVATE-TOKEN: $TOKEN" \
  --form "content=@.gitlab-ci.yml" \
  "https://gitlab.example.com/api/v4/ci/lint"
```

The GitLab web editor also provides real-time lint feedback and a pipeline
visualization before committing.

---

## Operational Guardrails

- Use `default` to set shared `image`, `retry`, and `interruptible` across all jobs.
- Keep pipeline files under `.gitlab/ci/` and include them; avoid one 500-line file.
- Use `resource_group` to serialize deployments to the same environment.
- Set `CI_DEFAULT_BRANCH` and `CI_COMMIT_BEFORE_SHA` guards on destructive jobs.
- Use `allow_failure: false` (the default) for jobs that gate deployment.
- Audit `allow_failure: true` usage; it should be intentional and documented.
- Pin GitLab-bundled template versions in `.gitlab-ci.yml` comments for audit trail.
