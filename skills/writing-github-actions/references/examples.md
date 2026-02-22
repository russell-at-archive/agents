# Writing GitHub Actions: Examples

## Contents

- [Node.js CI with caching and test reporting](#nodejs-ci-with-caching-and-test-reporting)
- [Go multi-platform matrix build](#go-multi-platform-matrix-build)
- [Docker build and push to GHCR](#docker-build-and-push-to-ghcr)
- [Release workflow with semantic versioning](#release-workflow-with-semantic-versioning)
- [Deploy to AWS with OIDC](#deploy-to-aws-with-oidc)
- [Terraform plan and apply with approval gate](#terraform-plan-and-apply-with-approval-gate)
- [Reusable deploy workflow](#reusable-deploy-workflow)
- [PR validation workflow](#pr-validation-workflow)
- [Dependabot auto-merge](#dependabot-auto-merge)
- [Scheduled stale issue closer](#scheduled-stale-issue-closer)

---

## Node.js CI with caching and test reporting

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

permissions:
  contents: read
  checks: write        # for publishing test results

concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true

jobs:
  test:
    name: Test (Node ${{ matrix.node }})
    runs-on: ubuntu-24.04
    timeout-minutes: 15

    strategy:
      fail-fast: false
      matrix:
        node: ["18", "20", "22"]

    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683  # v4.2.2

      - uses: actions/setup-node@cdca7365b2dadb8aad0a33bc7601856ffabcc48e  # v4.3.0
        with:
          node-version: ${{ matrix.node }}
          cache: npm

      - name: Install dependencies
        run: npm ci

      - name: Lint
        run: npm run lint

      - name: Type check
        run: npm run typecheck

      - name: Test
        run: npm test -- --reporter=junit --outputFile=test-results/junit.xml

      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@65462800fd760344b1a7b4382951275a0abb4808  # v4.3.3
        with:
          name: test-results-node${{ matrix.node }}
          path: test-results/
          retention-days: 7
```

---

## Go multi-platform matrix build

```yaml
# .github/workflows/build.yml
name: Build

on:
  push:
    branches: [main]
    tags: ["v*"]

permissions:
  contents: write      # needed to create releases

jobs:
  build:
    name: Build ${{ matrix.goos }}/${{ matrix.goarch }}
    runs-on: ubuntu-24.04
    timeout-minutes: 20

    strategy:
      matrix:
        include:
          - goos: linux
            goarch: amd64
          - goos: linux
            goarch: arm64
          - goos: darwin
            goarch: amd64
          - goos: darwin
            goarch: arm64
          - goos: windows
            goarch: amd64
            ext: .exe

    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683  # v4.2.2

      - uses: actions/setup-go@0aaccfd150d50ccaeb58ebd88d36e91967a5f35b  # v5.4.0
        with:
          go-version-file: go.mod
          cache: true

      - name: Build
        env:
          GOOS: ${{ matrix.goos }}
          GOARCH: ${{ matrix.goarch }}
          CGO_ENABLED: "0"
        run: |
          go build -ldflags="-s -w" -o dist/myapp-${{ matrix.goos }}-${{ matrix.goarch }}${{ matrix.ext || '' }} ./cmd/myapp

      - name: Upload binary
        uses: actions/upload-artifact@65462800fd760344b1a7b4382951275a0abb4808  # v4.3.3
        with:
          name: myapp-${{ matrix.goos }}-${{ matrix.goarch }}
          path: dist/

  release:
    if: startsWith(github.ref, 'refs/tags/v')
    needs: build
    runs-on: ubuntu-24.04
    steps:
      - name: Download all artifacts
        uses: actions/download-artifact@fa0a91b85d4f404e444306234036836ebe37a218  # v4.1.8
        with:
          path: dist/
          merge-multiple: true

      - name: Create release
        uses: softprops/action-gh-release@c062e08bd532815e2082a85e87e3ef29c3e6d191  # v2.0.8
        with:
          files: dist/*
          generate_release_notes: true
```

---

## Docker build and push to GHCR

```yaml
# .github/workflows/docker.yml
name: Docker

on:
  push:
    branches: [main]
    tags: ["v*"]

permissions:
  contents: read
  packages: write

jobs:
  build-push:
    runs-on: ubuntu-24.04
    timeout-minutes: 30

    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683  # v4.2.2

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@b5ca514318bd6ebac0fb2aedd5d36ec1b5c8011e  # v3.10.0

      - name: Log in to GHCR
        uses: docker/login-action@74a5d142397b4f367a81961eba4e8cd7edddf772  # v3.4.0
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@902fa8ec7d6ecbea8a7dc0e3d2e8a4f9d8c6e9f0  # v5.7.0
        with:
          images: ghcr.io/${{ github.repository }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=sha,prefix=sha-

      - name: Build and push
        uses: docker/build-push-action@14487ce63c6f9f8936ce79a0a2f95fc1d49ca7e4  # v6.16.0
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
          platforms: linux/amd64,linux/arm64
          provenance: true
          sbom: true
```

---

## Release workflow with semantic versioning

```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    branches: [main]

permissions:
  contents: write
  pull-requests: write

jobs:
  release:
    runs-on: ubuntu-24.04
    timeout-minutes: 15
    outputs:
      version: ${{ steps.release.outputs.version }}
      released: ${{ steps.release.outputs.released }}

    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683  # v4.2.2
        with:
          fetch-depth: 0   # full history needed for semantic-release

      - name: Semantic release
        id: release
        uses: cycjimmy/semantic-release-action@b1b432f13acb7768e0c8efdec416d363a57546f2  # v4.1.1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

  publish:
    needs: release
    if: needs.release.outputs.released == 'true'
    runs-on: ubuntu-24.04
    steps:
      - run: echo "Publishing version ${{ needs.release.outputs.version }}"
```

---

## Deploy to AWS with OIDC

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main]

permissions:
  contents: read
  id-token: write   # required for OIDC

jobs:
  deploy-staging:
    runs-on: ubuntu-24.04
    timeout-minutes: 20
    environment: staging

    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683  # v4.2.2

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@e3dd6a429d7300a6a4c196c26e071d42e0343502  # v4.0.2
        with:
          role-to-assume: ${{ vars.AWS_ROLE_ARN_STAGING }}
          aws-region: ${{ vars.AWS_REGION }}
          role-session-name: github-deploy-${{ github.run_id }}

      - name: Deploy to ECS
        run: |
          aws ecs update-service \
            --cluster staging-cluster \
            --service my-app \
            --force-new-deployment

      - name: Wait for service stability
        run: |
          aws ecs wait services-stable \
            --cluster staging-cluster \
            --services my-app

  deploy-prod:
    needs: deploy-staging
    runs-on: ubuntu-24.04
    timeout-minutes: 20
    environment: production   # requires approval

    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683  # v4.2.2

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@e3dd6a429d7300a6a4c196c26e071d42e0343502  # v4.0.2
        with:
          role-to-assume: ${{ vars.AWS_ROLE_ARN_PROD }}
          aws-region: ${{ vars.AWS_REGION }}
          role-session-name: github-deploy-${{ github.run_id }}

      - name: Deploy to ECS
        run: |
          aws ecs update-service \
            --cluster prod-cluster \
            --service my-app \
            --force-new-deployment
```

---

## Terraform plan and apply with approval gate

```yaml
# .github/workflows/terraform.yml
name: Terraform

on:
  pull_request:
    paths: ["infra/**"]
  push:
    branches: [main]
    paths: ["infra/**"]

permissions:
  contents: read
  id-token: write
  pull-requests: write

jobs:
  plan:
    runs-on: ubuntu-24.04
    timeout-minutes: 20
    defaults:
      run:
        working-directory: infra/

    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683  # v4.2.2

      - uses: hashicorp/setup-terraform@b9cd54a3c349d3f38e8881555d616ced269ef065  # v3.1.2
        with:
          terraform_version: "1.10.0"

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@e3dd6a429d7300a6a4c196c26e071d42e0343502  # v4.0.2
        with:
          role-to-assume: ${{ vars.AWS_ROLE_ARN }}
          aws-region: us-east-1

      - name: Terraform Init
        run: terraform init

      - name: Terraform Format Check
        run: terraform fmt -check -recursive

      - name: Terraform Validate
        run: terraform validate

      - name: Terraform Plan
        id: plan
        run: terraform plan -no-color -out=tfplan 2>&1 | tee plan.txt

      - name: Comment PR with plan
        if: github.event_name == 'pull_request'
        uses: actions/github-script@60a0d83039c74a4aee543508d2ffcb1c3799cdea  # v7.0.1
        with:
          script: |
            const fs = require('fs');
            const plan = fs.readFileSync('infra/plan.txt', 'utf8');
            const truncated = plan.length > 60000
              ? plan.substring(0, 60000) + '\n... truncated'
              : plan;
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `## Terraform Plan\n\`\`\`\n${truncated}\n\`\`\``
            });

      - name: Upload plan
        uses: actions/upload-artifact@65462800fd760344b1a7b4382951275a0abb4808  # v4.3.3
        with:
          name: tfplan
          path: infra/tfplan

  apply:
    needs: plan
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    runs-on: ubuntu-24.04
    timeout-minutes: 30
    environment: production
    defaults:
      run:
        working-directory: infra/

    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683  # v4.2.2

      - uses: hashicorp/setup-terraform@b9cd54a3c349d3f38e8881555d616ced269ef065  # v3.1.2
        with:
          terraform_version: "1.10.0"

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@e3dd6a429d7300a6a4c196c26e071d42e0343502  # v4.0.2
        with:
          role-to-assume: ${{ vars.AWS_ROLE_ARN }}
          aws-region: us-east-1

      - name: Download plan
        uses: actions/download-artifact@fa0a91b85d4f404e444306234036836ebe37a218  # v4.1.8
        with:
          name: tfplan
          path: infra/

      - name: Terraform Init
        run: terraform init

      - name: Terraform Apply
        run: terraform apply -auto-approve tfplan
```

---

## Reusable deploy workflow

```yaml
# .github/workflows/_deploy.yml  (leading underscore = convention for reusable)
name: Deploy (reusable)

on:
  workflow_call:
    inputs:
      environment:
        type: string
        required: true
      image_tag:
        type: string
        required: true
      aws_region:
        type: string
        default: us-east-1
    secrets:
      AWS_ROLE_ARN:
        required: true
    outputs:
      deploy_url:
        value: ${{ jobs.deploy.outputs.url }}

permissions:
  contents: read
  id-token: write

jobs:
  deploy:
    runs-on: ubuntu-24.04
    timeout-minutes: 20
    environment:
      name: ${{ inputs.environment }}
      url: ${{ steps.get_url.outputs.url }}
    outputs:
      url: ${{ steps.get_url.outputs.url }}

    steps:
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@e3dd6a429d7300a6a4c196c26e071d42e0343502  # v4.0.2
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: ${{ inputs.aws_region }}

      - name: Deploy
        id: get_url
        env:
          ENVIRONMENT: ${{ inputs.environment }}
          IMAGE_TAG: ${{ inputs.image_tag }}
        run: |
          # deployment logic here
          echo "url=https://$ENVIRONMENT.example.com" >> "$GITHUB_OUTPUT"
```

```yaml
# .github/workflows/cd.yml — calls the reusable workflow
name: CD

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-24.04
    outputs:
      image_tag: ${{ steps.tag.outputs.tag }}
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683  # v4.2.2
      - id: tag
        run: echo "tag=sha-${{ github.sha }}" >> "$GITHUB_OUTPUT"

  deploy-staging:
    needs: build
    uses: ./.github/workflows/_deploy.yml
    with:
      environment: staging
      image_tag: ${{ needs.build.outputs.image_tag }}
    secrets:
      AWS_ROLE_ARN: ${{ secrets.STAGING_AWS_ROLE_ARN }}

  deploy-prod:
    needs: [build, deploy-staging]
    uses: ./.github/workflows/_deploy.yml
    with:
      environment: production
      image_tag: ${{ needs.build.outputs.image_tag }}
    secrets:
      AWS_ROLE_ARN: ${{ secrets.PROD_AWS_ROLE_ARN }}
```

---

## PR validation workflow

```yaml
# .github/workflows/pr.yml
name: PR Validation

on:
  pull_request:
    types: [opened, synchronize, reopened, ready_for_review]

permissions:
  contents: read
  pull-requests: write
  statuses: write

concurrency:
  group: pr-${{ github.event.pull_request.number }}
  cancel-in-progress: true

jobs:
  # Fast checks run in parallel
  lint:
    if: github.event.pull_request.draft == false
    runs-on: ubuntu-24.04
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683  # v4.2.2
      - uses: actions/setup-node@cdca7365b2dadb8aad0a33bc7601856ffabcc48e  # v4.3.0
        with:
          node-version: "20"
          cache: npm
      - run: npm ci
      - run: npm run lint

  validate-commits:
    runs-on: ubuntu-24.04
    timeout-minutes: 5
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683  # v4.2.2
        with:
          fetch-depth: 0
      - name: Validate conventional commits
        env:
          BASE_SHA: ${{ github.event.pull_request.base.sha }}
          HEAD_SHA: ${{ github.event.pull_request.head.sha }}
        run: |
          git log --oneline "$BASE_SHA..$HEAD_SHA" | while read -r line; do
            echo "Checking: $line"
          done

  test:
    if: github.event.pull_request.draft == false
    needs: lint
    runs-on: ubuntu-24.04
    timeout-minutes: 20
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683  # v4.2.2
      - uses: actions/setup-node@cdca7365b2dadb8aad0a33bc7601856ffabcc48e  # v4.3.0
        with:
          node-version: "20"
          cache: npm
      - run: npm ci
      - run: npm test

  # Required status check aggregator
  all-checks:
    if: always()
    needs: [lint, test]
    runs-on: ubuntu-24.04
    steps:
      - name: Check all jobs passed
        run: |
          if [[ "${{ needs.lint.result }}" != "success" ]] || \
             [[ "${{ needs.test.result }}" != "success" ]]; then
            echo "One or more required checks failed"
            exit 1
          fi
```

---

## Dependabot auto-merge

```yaml
# .github/workflows/dependabot-auto-merge.yml
name: Dependabot Auto-merge

on:
  pull_request:

permissions:
  contents: write
  pull-requests: write

jobs:
  auto-merge:
    runs-on: ubuntu-24.04
    if: github.actor == 'dependabot[bot]'
    steps:
      - name: Fetch Dependabot metadata
        id: meta
        uses: dependabot/fetch-metadata@08eff52bf64351f401fb50d4972fa95b9f2c2d1d  # v2.3.0
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}

      - name: Auto-merge patch and minor updates
        if: |
          steps.meta.outputs.update-type == 'version-update:semver-patch' ||
          steps.meta.outputs.update-type == 'version-update:semver-minor'
        run: gh pr merge --auto --squash "$PR_URL"
        env:
          PR_URL: ${{ github.event.pull_request.html_url }}
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

## Scheduled stale issue closer

```yaml
# .github/workflows/stale.yml
name: Mark stale issues and PRs

on:
  schedule:
    - cron: "0 8 * * 1"   # every Monday at 08:00 UTC
  workflow_dispatch:

permissions:
  issues: write
  pull-requests: write

jobs:
  stale:
    runs-on: ubuntu-24.04
    timeout-minutes: 10
    steps:
      - uses: actions/stale@5bef64f19d7facfb25b37b3d0be5f5070d5ede4f  # v9.0.0
        with:
          stale-issue-message: >
            This issue has been automatically marked as stale because it has
            not had recent activity. It will be closed in 14 days if no further
            activity occurs.
          stale-pr-message: >
            This PR has been automatically marked as stale. Please update it
            or it will be closed in 7 days.
          stale-issue-label: stale
          stale-pr-label: stale
          days-before-stale: 60
          days-before-close: 14
          days-before-pr-close: 7
          exempt-issue-labels: "pinned,security,bug"
          exempt-pr-labels: "pinned,do-not-close"
```
