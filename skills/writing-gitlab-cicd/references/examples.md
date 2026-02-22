# Writing GitLab CI/CD: Examples

## Contents

- [Minimal pipeline](#minimal-pipeline)
- [Node.js build, test, and publish](#nodejs-build-test-and-publish)
- [Docker image build and push](#docker-image-build-and-push)
- [DAG pipeline with needs](#dag-pipeline-with-needs)
- [Merge request pipeline with workflow rules](#merge-request-pipeline-with-workflow-rules)
- [Multi-environment deployment with manual gate](#multi-environment-deployment-with-manual-gate)
- [Reusable job templates with extends](#reusable-job-templates-with-extends)
- [Modular includes](#modular-includes)
- [Parent-child pipeline](#parent-child-pipeline)
- [OIDC authentication with Vault](#oidc-authentication-with-vault)
- [Security scanning](#security-scanning)
- [Matrix jobs](#matrix-jobs)

---

## Minimal pipeline

```yaml
# .gitlab-ci.yml
stages:
  - build
  - test

build:
  stage: build
  image: alpine
  script:
    - echo "Building..."

test:
  stage: test
  image: alpine
  script:
    - echo "Testing..."
```

---

## Node.js build, test, and publish

```yaml
stages:
  - install
  - test
  - build
  - publish

default:
  image: node:20-alpine
  cache:
    key:
      files:
        - package-lock.json
    paths:
      - node_modules/

install:
  stage: install
  script:
    - npm ci
  artifacts:
    paths:
      - node_modules/
    expire_in: 1 hour

lint:
  stage: test
  needs: [install]
  script:
    - npm run lint

unit-test:
  stage: test
  needs: [install]
  script:
    - npm test -- --coverage
  artifacts:
    reports:
      junit: junit.xml
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml
    expire_in: 7 days

build:
  stage: build
  needs: [lint, unit-test]
  script:
    - npm run build
  artifacts:
    paths:
      - dist/
    expire_in: 7 days

publish-npm:
  stage: publish
  needs: [build]
  script:
    - echo "//registry.npmjs.org/:_authToken=$NPM_TOKEN" > ~/.npmrc
    - npm publish --access public
  rules:
    - if: '$CI_COMMIT_TAG =~ /^v\d+\.\d+\.\d+$/'
```

---

## Docker image build and push

```yaml
build-image:
  stage: build
  image: docker:24
  services:
    - docker:24-dind
  variables:
    DOCKER_BUILDKIT: "1"
    IMAGE_TAG: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA
  before_script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
  script:
    - docker build --tag $IMAGE_TAG .
    - docker push $IMAGE_TAG
    - |
      if [ "$CI_COMMIT_BRANCH" = "$CI_DEFAULT_BRANCH" ]; then
        docker tag $IMAGE_TAG $CI_REGISTRY_IMAGE:latest
        docker push $CI_REGISTRY_IMAGE:latest
      fi
  tags:
    - docker
  rules:
    - if: '$CI_COMMIT_BRANCH'
    - if: '$CI_COMMIT_TAG'
```

---

## DAG pipeline with needs

```yaml
stages:
  - build
  - test
  - deploy

build-frontend:
  stage: build
  script: make build-frontend
  artifacts:
    paths: [dist/frontend/]
    expire_in: 1 hour

build-backend:
  stage: build
  script: make build-backend
  artifacts:
    paths: [dist/backend/]
    expire_in: 1 hour

test-frontend:
  stage: test
  needs:
    - job: build-frontend
      artifacts: true
  script: make test-frontend

test-backend:
  stage: test
  needs:
    - job: build-backend
      artifacts: true
  script: make test-backend

deploy-staging:
  stage: deploy
  needs: [test-frontend, test-backend]
  script: make deploy staging
  environment:
    name: staging
```

Both test jobs start as soon as their respective build job finishes, without
waiting for the other build job.

---

## Merge request pipeline with workflow rules

```yaml
workflow:
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
    - if: '$CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH'
    - if: '$CI_COMMIT_TAG'
    - when: never

lint:
  script: make lint

test:
  script: make test
  coverage: '/TOTAL.+?(\d+\%)/'
  artifacts:
    reports:
      junit: junit.xml
    expire_in: 7 days

deploy:
  script: make deploy
  environment:
    name: production
  rules:
    - if: '$CI_COMMIT_TAG =~ /^v\d+\.\d+\.\d+$/'
      when: manual
    - when: never
```

---

## Multi-environment deployment with manual gate

```yaml
.deploy-template:
  script:
    - ./scripts/deploy.sh $DEPLOY_ENV
  environment:
    url: https://$DEPLOY_ENV.example.com

deploy-staging:
  extends: .deploy-template
  variables:
    DEPLOY_ENV: staging
  environment:
    name: staging
  rules:
    - if: '$CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH'
      when: on_success

deploy-production:
  extends: .deploy-template
  variables:
    DEPLOY_ENV: production
  environment:
    name: production
    deployment_tier: production
  rules:
    - if: '$CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH'
      when: manual
  needs: [deploy-staging]
  resource_group: production
```

`resource_group: production` serializes concurrent deploys to the same
environment — only one deploy runs at a time.

---

## Reusable job templates with extends

```yaml
# Hidden jobs used as templates
.docker-base:
  image: docker:24
  services:
    - docker:24-dind
  tags:
    - docker
  before_script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY

.test-base:
  image: python:3.12-slim
  before_script:
    - pip install -r requirements-dev.txt
  artifacts:
    reports:
      junit: reports/junit.xml
    expire_in: 7 days

unit-tests:
  extends: .test-base
  script: pytest tests/unit -v

integration-tests:
  extends: .test-base
  script: pytest tests/integration -v
  services:
    - postgres:15

build-app-image:
  extends: .docker-base
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA
```

---

## Modular includes

```yaml
# .gitlab-ci.yml (root file)
stages:
  - lint
  - test
  - build
  - release
  - deploy

include:
  - local: .gitlab/ci/lint.yml
  - local: .gitlab/ci/test.yml
  - local: .gitlab/ci/build.yml
  - local: .gitlab/ci/deploy.yml
  - project: 'platform/ci-templates'
    ref: 'v3.1.0'            # pinned tag, not a branch
    file: '/templates/notify.yml'
```

```yaml
# .gitlab/ci/test.yml
unit-test:
  stage: test
  image: node:20-alpine
  script:
    - npm ci
    - npm test
```

---

## Parent-child pipeline

```yaml
# Parent .gitlab-ci.yml
stages:
  - generate
  - trigger

generate-pipelines:
  stage: generate
  image: python:3.12-slim
  script:
    - python scripts/generate_pipelines.py > generated-ci.yml
  artifacts:
    paths:
      - generated-ci.yml
    expire_in: 1 hour

run-generated:
  stage: trigger
  trigger:
    include:
      - artifact: generated-ci.yml
        job: generate-pipelines
    strategy: depend
```

---

## OIDC authentication with Vault

```yaml
deploy:
  stage: deploy
  image: alpine
  id_tokens:
    VAULT_ID_TOKEN:
      aud: https://vault.example.com
  script:
    - apk add --no-cache vault
    - export VAULT_ADDR=https://vault.example.com
    - vault write auth/jwt/login role=ci-deploy jwt=$VAULT_ID_TOKEN > /tmp/vault.json
    - export VAULT_TOKEN=$(cat /tmp/vault.json | vault kv get -field=token -)
    - export DB_PASSWORD=$(vault kv get -field=password secret/prod/db)
    - ./deploy.sh
  rules:
    - if: '$CI_COMMIT_TAG'
```

No static credentials stored in GitLab variables — Vault validates the
GitLab-issued JWT and issues a short-lived token.

---

## Security scanning

```yaml
include:
  - template: Security/SAST.gitlab-ci.yml
  - template: Security/Dependency-Scanning.gitlab-ci.yml
  - template: Security/Secret-Detection.gitlab-ci.yml
  - template: Security/Container-Scanning.gitlab-ci.yml

variables:
  SAST_EXCLUDED_PATHS: "spec, test, tests, tmp, node_modules"
  CS_IMAGE: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA

# Container scanning needs the image built first
container_scanning:
  needs:
    - job: build-image
      artifacts: false
```

Security jobs appear in the **Security** tab of merge requests automatically
when using GitLab Ultimate.

---

## Matrix jobs

```yaml
test:
  stage: test
  image: python:$PYTHON_VERSION
  script:
    - pip install tox
    - tox -e py
  parallel:
    matrix:
      - PYTHON_VERSION: ["3.10", "3.11", "3.12"]
        DATABASE: ["postgres", "sqlite"]
```

This creates 6 parallel jobs covering all combinations. Each job name includes
the matrix values for easy identification in the pipeline UI.
