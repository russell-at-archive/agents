---
name: using-atmos-cli
description: >-
  Provides expert guidance for working with Atmos by CloudPosse — a
  config-first IaC orchestration CLI for multi-environment Terraform,
  OpenTofu, Helmfile, and related toolchains. Invoke whenever the user
  mentions Atmos, CloudPosse infrastructure, or asks about atmos CLI
  commands (plan, apply, deploy, destroy, shell, clean, output, init,
  workspace, generate), stack YAML authoring, catalog patterns, component
  inheritance, deep merge behavior, vendoring with vendor.yaml, workflow
  files, describe (component, stacks, affected, config, locals, workflows),
  list (stacks, components), validate stacks, OPA/JSON Schema policies,
  atmos.yaml configuration, CI/CD with describe-affected, GitHub Actions
  gitops integration, Atlantis or Spacelift wiring, or remote state between
  components. Also invoke when the user is debugging unexpected variable
  values, list-merge surprises, abstract component errors, or base_path
  resolution failures.
---

# Using Atmos

## Overview

Atmos is a config-first IaC orchestration CLI. Infrastructure lives in
generic Terraform/Helmfile **components**; environment configuration lives
in YAML **stacks**. Atmos deep-merges both at runtime and drives Terraform
or Helmfile on behalf of the operator.

Core reference files:

- [references/overview.md](references/overview.md) — full schema, merge
  rules, templating, YAML functions, commands, vendoring, workflows,
  validation, CI/CD, remote state
- [references/examples.md](references/examples.md) — step-by-step
  walkthroughs for common tasks
- [references/troubleshooting.md](references/troubleshooting.md) — error
  patterns and fixes
- [references/installation.md](references/installation.md) — install and
  upgrade paths

## Workflow

1. Verify `atmos` is available; if not, read
   [references/installation.md](references/installation.md).
2. Read `atmos.yaml` to understand `base_path`, stack patterns, and
   component paths. See overview for schema.
3. Identify the target stack name from `name_pattern` / `name_template`.
   Run `atmos list stacks` when uncertain.
4. Before editing, run `atmos describe component <c> --stack <s>` to see
   the fully merged config. Add `--provenance` to trace value origins.
5. Make changes; re-run describe to verify.
6. Run `atmos terraform plan <component> --stack <stack>`.
7. For CI/CD, use `atmos describe affected --ref main` to scope work.
8. Errors → [references/troubleshooting.md](references/troubleshooting.md).

## Hard Rules

- **Never edit auto-generated files** (`backend.tf.json`,
  `providers_override.tf.json`, `*.tfvars.json`) — overwritten on every
  run; must be in `.gitignore`.
- **Lists replace, maps merge** by default. Re-state all items when
  overriding an inherited list, or set `settings.list_merge_strategy:
  append` in `atmos.yaml` to change the default.
- **Abstract components cannot be deployed.** `metadata.type: abstract`
  means the component exists only for inheritance.
- **Pin all vendored versions.** Never use `ref=main` or mutable tags in
  `vendor.yaml`.
- **Exclude `providers.tf` from vendor pulls.** Atmos generates
  `providers_override.tf.json` from the stack's `providers:` section.
- **Never put credentials in stacks.** Use `role_arn` and IAM assume-role.
- **`locals` are file-scoped.** They never cross import boundaries and are
  never passed to Terraform as variables.
- **`overrides` take highest priority within a file** and never leak into
  other imported files.
