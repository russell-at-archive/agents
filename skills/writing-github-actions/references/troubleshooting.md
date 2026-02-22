# Writing GitHub Actions: Troubleshooting

## Contents

- [Workflow not triggering](#workflow-not-triggering)
- [Job not running (skipped)](#job-not-running-skipped)
- [Step fails with exit code 1](#step-fails-with-exit-code-1)
- [Secret or variable is empty](#secret-or-variable-is-empty)
- [OIDC authentication failure](#oidc-authentication-failure)
- [Expression evaluation errors](#expression-evaluation-errors)
- [Needs context not available](#needs-context-not-available)
- [Artifact not found in downstream job](#artifact-not-found-in-downstream-job)
- [Cache miss on every run](#cache-miss-on-every-run)
- [Matrix job failing for one combination](#matrix-job-failing-for-one-combination)
- [Reusable workflow errors](#reusable-workflow-errors)
- [Composite action errors](#composite-action-errors)
- [Concurrency cancels the wrong run](#concurrency-cancels-the-wrong-run)
- [permissions: write-all still not enough](#permissions-write-all-still-not-enough)
- [workflow_dispatch inputs not working](#workflow_dispatch-inputs-not-working)
- [Anti-patterns reference](#anti-patterns-reference)

---

## Workflow not triggering

**Symptom:** Push or PR does not start the workflow.

**Checks:**

**1. YAML syntax error.** GitHub silently ignores workflows with syntax errors.
Validate locally:
```bash
actionlint .github/workflows/ci.yml
# OR use yamllint
yamllint .github/workflows/ci.yml
```

**2. Trigger branch filter doesn't match.**
```yaml
# If your default branch is "main" but filter says "master":
on:
  push:
    branches: [master]   # wrong — won't fire on main
```
Fix: match the actual branch name. Use `**` for any branch.

**3. Path filter excludes your change.**
```yaml
on:
  push:
    paths: ["src/**"]
# A change only in docs/ will not trigger this workflow
```
Fix: use `paths-ignore` instead, or remove the path filter.

**4. Workflow file is not on the default branch.**
New workflow files only trigger for events in the branch they are on.
Merge the workflow to the default branch first, then test triggers.

**5. `pull_request` events from forks are restricted.**
By default, first-time contributors require approval. Check:
Settings → Actions → Fork pull request workflows.

**6. Event type not listed.**
```yaml
on:
  pull_request:
    types: [labeled]   # will NOT fire on opened or synchronize
```
Omit `types:` to use the default set for the event.

---

## Job not running (skipped)

**Symptom:** Job shows as "skipped" without explanation.

**Common causes:**

**1. `if:` condition evaluated to false.**
```yaml
if: github.ref == 'refs/heads/main'
# This job only runs on pushes to main, not on PRs
```
Debug: temporarily remove the `if:` to confirm the job runs, then refine.

**2. `needs:` dependency was skipped or failed.**
By default, a job that `needs:` a skipped or failed job is also skipped.
```yaml
# To run even if upstream failed:
jobs:
  notify:
    needs: deploy
    if: always()
```

**3. Draft PR with condition.**
```yaml
if: github.event.pull_request.draft == false
# Skipped for draft PRs — expected behavior
```

---

## Step fails with exit code 1

**Symptom:** `Error: Process completed with exit code 1` with no clear message.

**Debug steps:**

**1. Add `set -euo pipefail` and trace output:**
```yaml
- name: Debug build
  run: |
    set -euo pipefail
    set -x          # print each command before executing
    make build
```

**2. Check the full log.** GitHub truncates long logs. The error is usually
several lines before the exit code message.

**3. Pipe failures with `pipefail`:**
```bash
# Without pipefail, this always exits 0:
failing_command | grep something

# With set -o pipefail, exits with failing_command's exit code
set -euo pipefail
failing_command | grep something
```

**4. Windows runner line endings.** Scripts cloned on Windows may have CRLF:
```yaml
- name: Fix line endings
  if: runner.os == 'Windows'
  run: git config --global core.autocrlf false
```

---

## Secret or variable is empty

**Symptom:** Step behaves as if a secret is empty; `echo $MY_SECRET` outputs nothing.

**Cause:** GitHub masks secrets in logs (shows `***`), so empty output in logs
doesn't mean the secret is empty. But it might actually be empty.

**Checks:**

**1. Verify the secret exists** in the right scope:
- Repository: Settings → Secrets and variables → Actions → Repository secrets
- Environment: Settings → Environments → `<env name>` → Secrets
- Organization: Only available if admin has enabled repo access

**2. Verify the correct name** — secret names are case-sensitive.
```yaml
env:
  API_KEY: ${{ secrets.API_KEY }}   # must match exact name in settings
```

**3. Secrets are not available in `pull_request` events from forks** by
default. Use `pull_request_target` (with caution) or restrict to internal PRs.

**4. `vars` context for non-secret variables:**
```yaml
run: echo "Region is ${{ vars.AWS_REGION }}"
# vars context requires repository/org variables, not secrets
```

---

## OIDC authentication failure

**Symptom:** `Error: Could not assume role` or `OpenIDConnect token not found`.

**Checks:**

**1. Missing `permissions: id-token: write`:**
```yaml
permissions:
  id-token: write   # REQUIRED — without this, no OIDC token is issued
  contents: read
```

**2. Trust policy mismatch.** The AWS/GCP/Azure trust policy must match the
exact OIDC claim from GitHub:
```
repo:ORG/REPO:ref:refs/heads/BRANCH
repo:ORG/REPO:environment:ENVIRONMENT_NAME
repo:ORG/REPO:pull_request
```
Verify the `sub` claim matches your trust policy's condition exactly.

**3. Token audience.** AWS expects `aud: sts.amazonaws.com`. If using a custom
audience, pass `audience:` in the action inputs.

**4. Region mismatch.** Ensure `aws-region` in the action matches the region
where the IAM role exists (roles are global, but the STS endpoint is regional).

**5. Workflow triggered from a fork.** OIDC tokens are not issued for fork PRs
by default. Use `environment:` on the job to get secrets and OIDC access
with an approval gate.

---

## Expression evaluation errors

**Symptom:** Workflow fails with `Invalid format string` or expression produces
unexpected output.

**Checks:**

**1. Missing quotes around expressions in YAML strings:**
```yaml
# WRONG: YAML parses {} as a mapping
if: ${{ github.ref == 'refs/heads/main' }}

# RIGHT: quotes required when value starts with ${{
name: "Deploy ${{ github.sha }}"
```

**2. Context not available at that scope.** `steps` context is only available
within the same job. `needs` context requires the job to be in `needs:`.

**3. `fromJSON` for dynamic values:**
```yaml
# Parse a JSON string stored in a variable
run: |
  echo "matrix=$(jq -c . matrix.json)" >> "$GITHUB_OUTPUT"

strategy:
  matrix: ${{ fromJSON(needs.setup.outputs.matrix) }}
```

**4. Ternary-style expression for optional values:**
```yaml
# Conditional expression
env:
  SUFFIX: ${{ github.ref == 'refs/heads/main' && '-prod' || '-dev' }}
# Note: if the "true" branch is empty string or 0, this pattern breaks
# Use explicit conditions via if: instead
```

---

## Needs context not available

**Symptom:** `needs.jobname.outputs.foo` is empty or throws an error.

**Checks:**

**1. Job not in `needs:` list:**
```yaml
jobs:
  deploy:
    needs: [build]   # must list build here to access needs.build
    steps:
      - run: echo ${{ needs.build.outputs.version }}
```

**2. Output not declared in the upstream job:**
```yaml
jobs:
  build:
    outputs:
      version: ${{ steps.tag.outputs.version }}   # must be declared here
```

**3. Step ID missing or mismatched:**
```yaml
steps:
  - id: tag   # must have an id to reference via steps.tag.outputs
    run: echo "version=1.0.0" >> "$GITHUB_OUTPUT"
```

---

## Artifact not found in downstream job

**Symptom:** `download-artifact` step fails with "No artifacts found".

**Checks:**

**1. Artifact name mismatch.** The `name:` in upload and download must match exactly.

**2. Upload failed silently.** Check if the upload step ran and succeeded.
Use `if: always()` on the upload step to ensure it runs even after failures.

**3. Cross-workflow artifact access.** Artifacts from one workflow run are not
directly accessible to a different workflow run. Use `actions/download-artifact`
with `run-id:` to download from a specific run:
```yaml
- uses: actions/download-artifact@fa0a91b85d4f404e444306234036836ebe37a218  # v4.1.8
  with:
    name: build-output
    run-id: ${{ github.event.workflow_run.id }}
    github-token: ${{ secrets.GITHUB_TOKEN }}
```

**4. Artifact expired.** Default retention is 90 days. Check artifact retention
settings in the repository.

---

## Cache miss on every run

**Symptom:** Cache is never restored; `cache-hit` is always `false`.

**Checks:**

**1. Key includes a value that changes every run** (e.g., `github.sha`):
```yaml
# WRONG: SHA changes every commit, so cache is never restored
key: ${{ runner.os }}-node-${{ github.sha }}

# RIGHT: key based on lock file hash (stable across commits unless deps change)
key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
```

**2. Cache saved on a different branch.** Caches are isolated by branch.
Add `restore-keys` as a fallback to the default/main branch cache:
```yaml
restore-keys: |
  ${{ runner.os }}-node-
```

**3. Cache path doesn't match what's actually being written.** Verify the
`path:` matches the actual cache directory for the package manager.

**4. Cache size limit exceeded** (10 GB per repo). Old caches are evicted.
Reduce what you cache or split into multiple smaller caches.

---

## Matrix job failing for one combination

**Symptom:** One matrix combination fails; you want to continue others.

**Fix:**
```yaml
strategy:
  fail-fast: false   # don't cancel other jobs when one fails
  matrix:
    os: [ubuntu-24.04, windows-2022]
```

**Excluding a broken combination temporarily:**
```yaml
matrix:
  os: [ubuntu-24.04, windows-2022, macos-14]
  node: ["18", "20"]
  exclude:
    - os: windows-2022
      node: "18"    # known broken, skip until fixed
```

---

## Reusable workflow errors

**Symptom:** `workflow_call` workflow fails or inputs/secrets are unavailable.

**Checks:**

**1. Caller and reusable workflow must be in the same repo OR the reusable
workflow must be in a public repo** (or an org-internal repo if org allows it).

**2. Input type mismatch.** `workflow_call` inputs are typed. Passing a number
where a string is expected (or vice versa) causes silent errors.

**3. Secret not passed through.** Secrets must be explicitly forwarded:
```yaml
# In caller:
uses: ./.github/workflows/_deploy.yml
secrets:
  MY_SECRET: ${{ secrets.MY_SECRET }}
# OR:
secrets: inherit   # passes all secrets from caller context
```

**4. Outputs not declared.** Job outputs must be declared at the job level AND
at the `workflow_call` `outputs:` level:
```yaml
on:
  workflow_call:
    outputs:
      url:
        value: ${{ jobs.deploy.outputs.url }}   # reference job output here

jobs:
  deploy:
    outputs:
      url: ${{ steps.step_id.outputs.url }}     # declare job output here
```

**5. Max nesting depth is 4.** A reusable workflow calling another reusable
workflow is allowed, but max 4 levels deep.

---

## Composite action errors

**Symptom:** Composite action steps fail or `shell:` is missing.

**Fix:** Every `run:` step in a composite action **must** specify `shell:`.
This is required (unlike in workflow steps where it defaults to `bash`):
```yaml
runs:
  using: composite
  steps:
    - name: Build
      shell: bash       # REQUIRED in composite actions
      run: make build
```

**`uses:` in composite actions.** You can call other actions from a composite
action, but you cannot call reusable workflows from a composite action.

---

## Concurrency cancels the wrong run

**Symptom:** Prod deploys are being cancelled mid-run by new commits.

**Fix:** Use `cancel-in-progress: false` for deployment jobs, and separate
concurrency groups for build vs deploy:
```yaml
jobs:
  build:
    concurrency:
      group: build-${{ github.ref }}
      cancel-in-progress: true   # cancel stale builds

  deploy:
    concurrency:
      group: deploy-production   # one deploy at a time
      cancel-in-progress: false  # never cancel a running deployment
```

---

## permissions: write-all still not enough

**Symptom:** Action fails with 403 even though `permissions: write-all` is set.

**Cause:** `GITHUB_TOKEN` cannot:
- Push to a branch protected by required status checks (chicken-and-egg)
- Trigger other workflows (to prevent infinite loops)
- Access resources in a different repository
- Bypass organization SSO SAML enforcement

**Fixes:**
- For cross-repo access: use a PAT or a GitHub App installation token.
- To trigger another workflow: use a PAT with `workflow` scope or a GitHub App.
- For protected branches: use a PAT with bypass permissions or relax the
  branch protection rule for the Actions bot.

---

## workflow_dispatch inputs not working

**Symptom:** `inputs.my_input` is empty when triggered manually.

**Checks:**

**1. Input name matches exactly** — case-sensitive.

**2. Default value used when input not provided.** If you don't fill in an
input on the manual trigger UI, the `default:` value is used (if set);
otherwise the input is an empty string (`""`).

**3. Boolean inputs are strings in expressions.** The `boolean` type renders
as the string `"true"` or `"false"`, not a YAML boolean:
```yaml
# WRONG:
if: inputs.dry_run == true

# RIGHT:
if: inputs.dry_run == 'true'
```

**4. `workflow_dispatch` inputs are not available on other trigger types.**
If the workflow fires via `push`, `inputs` is empty. Guard with:
```yaml
env:
  DRY_RUN: ${{ inputs.dry_run || 'false' }}
```

---

## Anti-patterns reference

| Anti-pattern | Problem | Fix |
|---|---|---|
| `uses: owner/action@v3` (tag) | Tags are mutable; supply chain risk | Pin to full commit SHA with version comment |
| `permissions: write-all` | Over-broad token scope | Use minimum required permissions per job |
| `${{ secrets.X }}` in `run:` string | Value appears in workflow definition; potential log exposure | Pass via `env:` and use `$ENV_VAR` in shell |
| `pull_request_target` + checkout of fork ref | Runs attacker code with elevated permissions | Never checkout untrusted fork code with `pull_request_target` |
| No `timeout-minutes` | Runaway jobs consume all minutes | Set `timeout-minutes` on every job |
| `continue-on-error: true` without comment | Silent failures hide real problems | Only use with explicit justification comment |
| `if: always()` on deploy steps | Deploys broken code after test failure | Use `if: success()` or specific conditions |
| Hard-coded runner `ubuntu-latest` | Version changes silently break workflows | Pin to `ubuntu-24.04` or specific version |
| Secrets in workflow environment matrix | Secret values appear in job names | Use opaque IDs in matrix; reference secrets in steps |
| Checking out with full PAT in public repo | PAT can be exfiltrated by malicious PR code | Use `GITHUB_TOKEN` for public repos; limit PAT scope |
| Not using `concurrency:` on deploy jobs | Multiple deploys race each other | Add concurrency group per environment |
| Giant monolithic workflow | Hard to debug; entire pipeline reruns on change | Split into focused workflows; use reusable workflows |
| `workflow_run` for sequencing within same repo | Complex and error-prone | Use `needs:` for in-workflow sequencing |
