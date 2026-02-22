# Writing GitLab CI/CD: Troubleshooting

## Contents

- [Pipeline does not trigger](#pipeline-does-not-trigger)
- [Job skipped unexpectedly](#job-skipped-unexpectedly)
- [Job stuck in pending](#job-stuck-in-pending)
- [rules and only/except conflict](#rules-and-onlyexcept-conflict)
- [Artifact not available in downstream job](#artifact-not-available-in-downstream-job)
- [Cache miss on every run](#cache-miss-on-every-run)
- [needs job not found](#needs-job-not-found)
- [include file not found or invalid](#include-file-not-found-or-invalid)
- [extends key conflict](#extends-key-conflict)
- [Docker-in-Docker build fails](#docker-in-docker-build-fails)
- [Variable not available in job](#variable-not-available-in-job)
- [Deployment blocked by environment protection](#deployment-blocked-by-environment-protection)
- [Child pipeline not reflecting parent status](#child-pipeline-not-reflecting-parent-status)
- [SAST/scanning jobs missing](#sastsscanning-jobs-missing)
- [Anti-patterns to stop immediately](#anti-patterns-to-stop-immediately)

---

## Pipeline does not trigger

**Symptom**

Push or MR produces no pipeline.

**Cause**

- `workflow:rules` evaluated to `when: never` for the event.
- CI/CD is disabled for the project.
- No `.gitlab-ci.yml` found at the configured path.

**Fix**

1. Check **Settings > CI/CD > General > Custom CI configuration path**.
2. Review `workflow:rules` top-to-bottom; add a debug rule temporarily:
   ```yaml
   workflow:
     rules:
       - when: always   # temporary debug — remove before merge
   ```
3. Confirm CI/CD is enabled in **Settings > General > Visibility**.

---

## Job skipped unexpectedly

**Symptom**

Job shows as skipped in pipeline graph.

**Cause**

- No `rules` condition matched; last rule is `when: never` (explicit or implicit).
- `only`/`except` evaluated negatively for the current ref or source.

**Fix**

1. Trace `rules` top-to-bottom; the first match wins.
2. Add a catch-all at the end during debugging:
   ```yaml
   rules:
     - if: '...'
     - when: on_success   # fallback — replace with never in production
   ```
3. Check `$CI_PIPELINE_SOURCE` value for the event type in job logs.

---

## Job stuck in pending

**Symptom**

Job stays in "pending" state indefinitely; never picked up by a runner.

**Cause**

- No runner online with matching `tags`.
- Runner capacity exhausted.
- Runner is paused or locked to a different project.

**Fix**

1. Check **Settings > CI/CD > Runners** for registered, online runners.
2. Compare job `tags` against runner tags — they must be an exact subset.
3. If using shared runners, verify they are enabled for the project.
4. Remove the `tags` key temporarily to target any available runner (testing only).

---

## rules and only/except conflict

**Symptom**

```text
jobs:my-job config contains unknown keys: only
```

or job behaves unexpectedly when both are present.

**Cause**

`rules` and `only`/`except` cannot coexist in the same job. GitLab rejects the
configuration or ignores one of them.

**Fix**

Remove `only`/`except` entirely and rewrite using `rules`:

```yaml
# Before (broken)
my-job:
  only: [main]
  rules:
    - if: '$CI_COMMIT_TAG'

# After (correct)
my-job:
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'
    - if: '$CI_COMMIT_TAG'
```

---

## Artifact not available in downstream job

**Symptom**

Downstream job cannot find files produced by an upstream job.

**Cause**

- `needs` entry missing `artifacts: true` (or omitted when default is wrong).
- Job producing the artifact used `when: never` or was skipped.
- `artifacts:paths` did not match the actual output path.
- Artifact expired before the downstream job ran.

**Fix**

1. Confirm the producing job succeeded and the artifact is visible in the UI.
2. Ensure `needs` entry references the correct job name:
   ```yaml
   needs:
     - job: build-job
       artifacts: true
   ```
3. Check `artifacts:paths` globs match actual file paths.
4. Increase `expire_in` if downstream jobs are delayed (e.g., manual gates).

---

## Cache miss on every run

**Symptom**

Cache is never restored; every run reinstalls dependencies from scratch.

**Cause**

- Cache `key` changes between runs (e.g., dynamic key with `$CI_COMMIT_SHA`).
- Different runner picks up the job and does not share the cache volume.
- `policy: push` on the restoring job or `policy: pull` on the seeding job.

**Fix**

1. Use a stable `key` based on lock file content:
   ```yaml
   cache:
     key:
       files:
         - package-lock.json
     paths:
       - node_modules/
   ```
2. For distributed runners, use a distributed cache backend (S3).
3. Use `policy: pull-push` (default) on the job that seeds the cache.

---

## needs job not found

**Symptom**

```text
'needs' job 'build-job' is not defined in any stage
```

**Cause**

- Job name is misspelled.
- The referenced job is in an included file that failed to load.
- The referenced job is excluded by `rules` for this pipeline.

**Fix**

1. Check exact job name spelling including case.
2. Verify the referenced job will actually appear in this pipeline (its own
   `rules` must not evaluate to `when: never`).
3. Add `optional: true` to allow the reference to a conditionally absent job:
   ```yaml
   needs:
     - job: optional-build
       optional: true
       artifacts: true
   ```

---

## include file not found or invalid

**Symptom**

```text
Could not retrieve the pipeline configuration from the include file
```

**Cause**

- Wrong path in `local` include.
- `project` include references a non-existent file or inaccessible project.
- `ref` does not exist in the referenced project.
- Remote URL is unreachable.

**Fix**

1. Use the GitLab web editor to validate before pushing — it resolves includes.
2. Confirm the `project` include path starts with `/` and the `ref` exists.
3. Prefer `local` includes or pinned `project` includes over `remote` URLs.

---

## extends key conflict

**Symptom**

Job produces unexpected behavior after `extends` — some keys are missing or wrong.

**Cause**

`extends` performs a deep merge; conflicting scalar values in the child
override the parent, but list values are replaced entirely, not appended.

**Fix**

Understand merge semantics:
- **Scalars**: child value wins.
- **Maps**: deep-merged, child keys win on conflict.
- **Lists** (`script`, `tags`, etc.): child list replaces parent list entirely.

If you need to combine lists, duplicate the content explicitly or use YAML
anchors:

```yaml
.base:
  script:
    - setup.sh

child:
  extends: .base
  script:
    - setup.sh     # must repeat if needed
    - extra.sh
```

---

## Docker-in-Docker build fails

**Symptom**

```text
Cannot connect to the Docker daemon at unix:///var/run/docker.sock
```

**Cause**

- `docker:dind` service not declared.
- `DOCKER_HOST` not set to `tcp://docker:2376`.
- TLS configuration missing or wrong.

**Fix**

```yaml
build:
  image: docker:24
  services:
    - docker:24-dind
  variables:
    DOCKER_HOST: tcp://docker:2376
    DOCKER_TLS_CERTDIR: "/certs"
    DOCKER_BUILDKIT: "1"
  script:
    - docker info
    - docker build .
```

Ensure runner is configured with `privileged = true` in `config.toml` for
the Docker executor when using DinD.

---

## Variable not available in job

**Symptom**

Job uses `$MY_VAR` but it is empty or unset.

**Cause**

- Variable is defined as "Protected" but the branch is not protected.
- Variable is group-level but the project does not inherit group variables.
- Variable was added after the pipeline was created (not retroactive).
- Variable name has a typo.

**Fix**

1. Check **Settings > CI/CD > Variables** for scope (protected, masked, env scope).
2. Confirm the branch or tag is protected if the variable is protected.
3. Use `echo "VAR=$MY_VAR"` in a debug job to inspect runtime value (never log secrets).
4. Check if an `environment:` scope filter is restricting the variable.

---

## Deployment blocked by environment protection

**Symptom**

Deploy job hangs waiting for approval or fails immediately with a permission error.

**Cause**

- Protected environment requires approval from a specific role/user.
- The user who triggered the pipeline does not have the required role.

**Fix**

1. Check **Settings > CI/CD > Environments > Protected Environments**.
2. Add the triggering user or their group to the allowed approvers list.
3. Approve the deployment in the pipeline UI if it is pending approval.

---

## Child pipeline not reflecting parent status

**Symptom**

Parent pipeline shows green but child pipeline failed, or parent fails without
child failure information.

**Cause**

`strategy: depend` is missing on the `trigger` job.

**Fix**

```yaml
trigger-child:
  trigger:
    include:
      - artifact: generated-ci.yml
        job: generate-pipelines
    strategy: depend    # parent mirrors child status
```

Without `strategy: depend`, the trigger job succeeds as soon as the child
pipeline is created, regardless of child outcome.

---

## SAST/scanning jobs missing

**Symptom**

Expected security scan jobs (e.g., `semgrep-sast`) do not appear in the pipeline.

**Cause**

- Template not included or included after overriding `stages` without the
  required stage name.
- Language not detected by the auto-detection logic.
- GitLab tier does not support the feature (some scans require Ultimate).

**Fix**

1. Ensure the template include is at the top level of `.gitlab-ci.yml`.
2. Confirm `stages` includes `test` (the default stage for most scan jobs).
   If you renamed stages, override the `stage` in the security job:
   ```yaml
   semgrep-sast:
     stage: security   # match your custom stage name
   ```
3. Check GitLab license tier for DAST and advanced scanning features.

---

## Anti-patterns to stop immediately

- Using `only: [push]` — replace with `rules` and `$CI_PIPELINE_SOURCE`.
- Hardcoding tokens or passwords in `variables` in `.gitlab-ci.yml`.
- Floating `ref: main` on `project` includes — pin to a tag or commit SHA.
- `allow_failure: true` on jobs that gate production deployment.
- Using `when: always` on deploy jobs without gating conditions.
- Using `cache` to pass build artifacts between jobs — use `artifacts`.
- Creating one monolithic `.gitlab-ci.yml` over 300 lines — split with `include`.
- Using `shell` executor for untrusted or third-party pipeline code.
- Ignoring `expire_in` on artifacts — storage grows unboundedly.
- `retry: 2` on all jobs unconditionally — masks real failures and wastes runner time.
