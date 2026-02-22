---
name: writing-gitlab-cicd
description: Produces correct, secure, and maintainable GitLab CI/CD pipeline
  configurations. Use when the user asks about .gitlab-ci.yml, pipeline stages,
  jobs, rules, variables, environments, artifacts, caching, includes, extends,
  anchors, merge request pipelines, parent-child pipelines, multi-project
  pipelines, GitLab runners, SAST, DAST, or any GitLab CI/CD configuration.
---

# Writing GitLab CI/CD

## Overview

GitLab CI/CD pipelines are defined in `.gitlab-ci.yml` at the repository root.
Pipelines consist of stages containing jobs. Jobs run on runners and are
controlled by rules, variables, and conditions. For full procedures and
reference, read [references/overview.md](references/overview.md).

## When to Use

- Authoring or editing `.gitlab-ci.yml` or included pipeline files
- Designing stage topology, job dependencies, and execution order
- Writing job `rules`, `only`/`except`, or `workflow` conditions
- Configuring variables, environments, and deployments
- Setting up artifacts, caching, and dependency passing between jobs
- Using `include`, `extends`, and YAML anchors for reuse
- Configuring merge request pipelines and `needs` graphs
- Setting up parent-child or multi-project pipeline triggers
- Integrating GitLab-managed SAST, DAST, or security scanning templates
- Debugging runner issues, job failures, or pipeline blocking conditions

## When Not to Use

- GitHub Actions workflows (use `writing-github-actions` instead)
- Runner infrastructure provisioning (Terraform/Ansible task)
- GitLab API queries via glab CLI (use `using-gitlab-cli` instead)

## Prerequisites

- GitLab project with CI/CD enabled
- At least one configured runner with appropriate tags
- Understand target environments and deployment targets before writing jobs

## Workflow

1. Identify required stages and their order.
   See [references/overview.md](references/overview.md) for stage and job design.
2. Write jobs with minimal scope: one responsibility per job.
3. Use `rules` over `only`/`except`; prefer explicit conditions.
4. Validate locally with `gitlab-ci-lint` or the GitLab API lint endpoint.
5. Use `needs` to parallelize and reduce pipeline duration.
6. For reuse patterns (anchors, extends, includes), see
   [references/overview.md](references/overview.md).
7. For concrete `.gitlab-ci.yml` patterns, see
   [references/examples.md](references/examples.md).
8. If jobs fail unexpectedly, see
   [references/troubleshooting.md](references/troubleshooting.md).

## Hard Rules

- Never store secrets in `.gitlab-ci.yml`; use CI/CD variables (masked + protected).
- Always pin external `include` references to a specific `ref` or `sha`.
- Prefer `rules` over `only`/`except`; never mix them in the same job.
- Set `interruptible: true` on jobs that can be safely cancelled.
- Scope environment variables to the narrowest job or stage that needs them.
- Use `needs` to express true DAG dependencies, not stage ordering alone.
- Artifacts must declare explicit `expire_in` to avoid unbounded storage.

## Failure Handling

- If pipeline lint fails, fix syntax before pushing; use the lint API endpoint.
- If a job is blocked by a rule, trace the rule evaluation order top-to-bottom.
- If a runner is stuck, check runner tags match the job's `tags` list.
- If child pipeline fails, inspect the generated child `gitlab-ci.yml` artifact.

## Red Flags

- Secrets or tokens hardcoded in YAML values
- `only: [push]` combined with `rules` in the same job
- Missing `expire_in` on artifacts
- `allow_failure: true` masking real breakage in required jobs
- Un-pinned external template includes (`ref: main` instead of a SHA)
- Deeply nested `!reference` chains that are hard to trace
