---
name: using-terraform
description: Provides expert guidance for working with HashiCorp Terraform
  and OpenTofu — declarative infrastructure-as-code tools for provisioning
  and managing cloud resources. Use when the user asks about Terraform HCL,
  providers, resources, data sources, modules, state, backends, workspaces,
  variables, outputs, lifecycle rules, import blocks, moved blocks, check
  blocks, terraform init/plan/apply/destroy, or writing and structuring
  Terraform configurations.
---

# Using Terraform

## Overview

Terraform manages infrastructure declaratively: you describe desired end state
in HCL; Terraform builds a dependency graph, diffs against state, and executes
the minimum operations to converge. Every file is plain `.tf` HCL — no
templating engine. State tracks the mapping between configuration and real
resources. For full language and CLI reference, read
[references/overview.md](references/overview.md). For concrete patterns, read
[references/examples.md](references/examples.md).

## When to Use

- Writing or editing `.tf` files (resources, data sources, variables, outputs,
  locals, providers, modules, backends)
- Configuring provider `required_providers` and version constraints
- Designing module structure and interfaces
- Managing state: backends, import, moved blocks, state subcommands
- Writing lifecycle rules, dynamic blocks, for_each/count, conditionals
- Running or debugging `terraform init`, `plan`, `apply`, `destroy`, `state`
- Configuring remote backends (S3, GCS, Azure Blob, HCP Terraform)
- Writing `terraform test` files (v1.6+)
- Advising on multi-environment patterns, secrets handling, DRY structure

## When Not to Use

- Kubernetes resource management where Kustomize or Helm is the primary tool
- Atmos-specific stack orchestration (use the `using-atmos` skill instead)
- Pulumi, CDK, or CloudFormation (different tools)

## Prerequisites

- `terraform` (or `tofu`) binary installed and on PATH
- Cloud credentials configured (env vars, instance role, or provider auth block)
- Backend infrastructure exists before `terraform init` (S3 bucket, DynamoDB
  table, etc.) when using remote state

## Workflow

1. Read existing `.tf` files to understand provider, backend, and resource
   structure before making changes.
2. Run `terraform validate` after edits; run `terraform fmt -recursive` to
   normalize formatting.
3. Run `terraform plan` and inspect the diff before any `apply`.
4. For state changes (import, mv, rm), always `terraform plan` after to
   confirm the expected result.
5. For errors, check [references/troubleshooting.md](references/troubleshooting.md).
6. For pattern examples, check [references/examples.md](references/examples.md).

## Hard Rules

- **Never edit `terraform.tfstate` by hand.** Use `terraform state` subcommands.
- **Never store secrets in `.tf` files or check them into git.** Use
  environment variables, Vault, AWS Secrets Manager, or `sensitive = true`
  variables supplied at runtime.
- **Always pin provider versions** with `~>` or `=` constraints in
  `required_providers`. Unpinned providers will upgrade on `terraform init -upgrade`
  and can silently break configurations.
- **Never run `terraform apply` without reviewing `plan` output first** in prod.
- **Use `prevent_destroy = true`** on stateful resources (databases, S3 buckets).
- **Always use `ignore_changes`** for attributes managed externally (e.g., ASG
  desired capacity, ECS task definition updated by CI).
- **`terraform destroy` is irreversible** for many resource types — confirm scope.

## Failure Handling

- `Error: No valid credential sources` — configure provider authentication;
  check env vars (`AWS_PROFILE`, `GOOGLE_CREDENTIALS`, etc.).
- `Error acquiring the state lock` — run `terraform force-unlock <ID>` only
  after confirming no other process holds the lock.
- Plan shows unexpected destroy — check for `for_each` key changes, resource
  renames without `moved` blocks, or provider upgrades with breaking changes.
- `terraform init` fails on module source — check git ref, registry path, or
  local relative path.
- State drift (resource exists in cloud but not plan) — run `terraform import`
  or use an `import` block (v1.5+).

## Red Flags

- `terraform.tfstate` committed to git (even as empty placeholder).
- Provider blocks without `version` constraints.
- Hard-coded credentials, secrets, or account IDs in `.tf` files.
- `count = 0` used to disable resources instead of `enabled` variable with
  `count = var.enabled ? 1 : 0`.
- `depends_on` on a module when a specific resource reference would suffice.
- `terraform apply -auto-approve` in production without a plan review gate.
- Using `provisioners` as a first resort instead of user_data, cloud-init,
  or configuration management tools.
