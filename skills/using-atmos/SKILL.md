---
name: using-atmos
description: Provides expert guidance for working with Atmos by CloudPosse —
  an IaC orchestration CLI for multi-environment Terraform, Helmfile, and
  related toolchains. Use when the user asks about Atmos stacks, components,
  vendoring, workflows, or running atmos CLI commands such as plan, apply,
  describe, list, vendor pull, or validate.
---

# Using Atmos

## Overview

Atmos is a config-first IaC orchestration CLI by CloudPosse. Infrastructure
code lives in generic Terraform components; environment configuration lives
in YAML stacks. Atmos merges both at runtime and drives Terraform/Helmfile
on behalf of the operator. Full reference:
[references/overview.md](references/overview.md).

## When to Use

- Running or debugging `atmos terraform plan/apply/deploy/destroy`
- Authoring or modifying stack YAML files or catalog entries
- Diagnosing unexpected variable values via `atmos describe component`
- Setting up or updating `atmos.yaml` CLI configuration
- Vendoring external components via `vendor.yaml`
- Writing or running Atmos workflow files
- Configuring CI/CD with `atmos describe affected`
- Validating stacks with JSON Schema or OPA policies

## When Not to Use

- Pure Terraform work with no Atmos configuration present
- Terragrunt projects (different tool with different config model)
- Questions about Helm or Kubernetes that do not involve Atmos orchestration

## Prerequisites

- `atmos` CLI installed (`brew install cloudposse/tap/atmos` or GitHub releases)
- `atmos.yaml` present at repo root or discoverable via git root search
- `base_path` in `atmos.yaml` must resolve to the repo root; override with
  `ATMOS_BASE_PATH=$(pwd)` when running locally if set to a container path
- AWS credentials or role available when running Terraform commands

## Workflow

1. Read `atmos.yaml` to understand `base_path`, stack patterns, and component
   paths. See [references/overview.md](references/overview.md) for schema.
2. Identify the target stack name from the `name_pattern` or `name_template`.
3. Before editing, run `atmos describe component <c> --stack <s>` to see the
   fully merged config. See [references/examples.md](references/examples.md).
4. Make stack or component changes, then re-run describe to verify.
5. Run `atmos terraform plan <component> --stack <stack>` to validate.
6. For CI/CD, use `atmos describe affected --ref main` to scope work.
7. If errors arise, consult [references/troubleshooting.md](references/troubleshooting.md).

## Hard Rules

- **Never edit auto-generated files** (`backend.tf.json`,
  `providers_override.tf.json`, `*.tfvars.json`) — they are overwritten on
  every run and must be in `.gitignore`.
- **Lists replace, maps merge** during deep merge. Appending to an inherited
  list requires re-stating all items.
- **Abstract components cannot be deployed.** `metadata.type: abstract` means
  the component exists only for inheritance.
- **Pin all vendored versions.** Never use `ref=main` or mutable tags in
  `vendor.yaml`.
- **Exclude `providers.tf` from vendor pulls.** Atmos generates
  `providers_override.tf.json` from the stack's `providers:` section.
- **Never put credentials in stacks.** Use role ARNs and IAM assume-role.

## Failure Handling

- `atmos.yaml` not found: search from CWD up to git root; check
  `ATMOS_BASE_PATH` env var; verify `base_path` is not set to a container path.
- Stack name not resolving: run `atmos list stacks` and cross-check with the
  `name_pattern` in `atmos.yaml`.
- Unexpected variable values: run `atmos describe component` with
  `--provenance` to trace where each value originated.
- `atmos vendor pull` network failure: retry with `--dry-run` first; check
  source URL and version tag.

## Red Flags

- `base_path` pointing to `/workspaces/...` — set `ATMOS_BASE_PATH=$(pwd)`.
- Stack file appears in `atmos list stacks` but should not — it is likely
  missing from `excluded_paths` in `atmos.yaml`.
- Inherited list value has unexpected items — a list override silently
  replaced the parent list rather than appending to it.
- Component deployed from an abstract base — `metadata.type: abstract` is
  missing or misspelled.
