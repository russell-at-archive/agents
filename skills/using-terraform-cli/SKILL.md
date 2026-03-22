---
name: using-terraform-cli
description: Uses the Terraform CLI for safe infrastructure planning,
  validation, state operations, imports, and configuration work. Use when
  the user asks about `terraform` commands, HCL modules, providers,
  backends, state, workspaces, `terraform init`, `plan`, `apply`,
  `destroy`, `import`, `fmt`, `validate`, or debugging Terraform runs.
---

# Using Terraform CLI
## Overview

Uses `terraform` for formatting, validation, plans, apply flows, state
operations, and refactors that must preserve resource addresses. Read
[references/overview.md](references/overview.md) for full command and
language behavior, [references/examples.md](references/examples.md) for
concrete patterns, [references/troubleshooting.md](references/troubleshooting.md)
for failure modes, and [references/installation.md](references/installation.md)
when the binary or first-time setup is missing.

## When to Use
- The user asks to run or explain `terraform` CLI commands
- The task involves `.tf` files, modules, providers, variables, outputs, or backends
- The task involves `terraform init`, `fmt`, `validate`, `plan`, `apply`,
  `destroy`, `import`, `state`, `workspace`, `output`, `console`, or `test`
- A Terraform refactor needs `moved` blocks, import blocks, or state-safe
  migration guidance
- A Terraform run failed and needs targeted diagnosis

## When Not to Use
- The task is primarily Helm, Kustomize, Pulumi, CDK, or CloudFormation
- Atmos is the main orchestration layer and the question is about stack
  wiring rather than raw Terraform usage
- The user only needs cloud-provider CLI help with no Terraform component

## Prerequisites
- `terraform` available on `PATH`; if not, read
  [references/installation.md](references/installation.md)
- Provider credentials and any remote backend dependencies already available
- Access to the correct root module before write operations

## Workflow
1. Identify the root module, the expected binary (`terraform` vs `tofu`), and
   whether the task is inspect-only, config-editing, planning, apply, import,
   or state repair.
2. Read the existing Terraform files before changing anything. If the task is
   unfamiliar or spans modules, backends, lifecycle rules, or advanced HCL,
   load [references/overview.md](references/overview.md).
3. Use the narrowest safe command for the job:
   `terraform fmt -recursive`, `terraform validate`, `terraform plan`,
   `terraform show`, `terraform output`, `terraform state ...`,
   `terraform import`, `terraform workspace ...`, or `terraform test`.
4. After config edits, run formatting and validation before any plan.
5. Before any apply or destroy, produce and review a plan that matches the
   intended scope.
6. After imports, moved blocks, or state operations, run another plan to
   confirm zero unexpected drift.
7. If the user needs implementation patterns, load
   [references/examples.md](references/examples.md). If the run fails or the
   plan is suspicious, load
   [references/troubleshooting.md](references/troubleshooting.md).

## Hard Rules
- Never edit `terraform.tfstate` by hand.
- Never put secrets or cloud credentials in tracked `.tf` or `.tfvars` files.
- Always pin provider versions in `required_providers`.
- Run `terraform fmt` and `terraform validate` after Terraform edits.
- Do not run `terraform apply` or `terraform destroy` without a reviewed plan,
  especially for shared or production environments.
- Treat `-target` as an exception for recovery work, not a normal workflow.
- Prefer `moved` blocks and import blocks over destructive rename-and-recreate
  behavior.
- Treat `terraform force-unlock` as a last resort after confirming no active run owns the lock.

## Failure Handling
- If the binary is missing or the repo standard is unclear, stop and use
  [references/installation.md](references/installation.md).
- If a plan shows unexpected destroy or replace actions, stop and check
  `moved` blocks, `for_each` keys, immutable attributes, and provider version
  changes in [references/troubleshooting.md](references/troubleshooting.md).
- If state is locked, credentials fail, imports collide, or drift appears,
  use [references/troubleshooting.md](references/troubleshooting.md) before
  suggesting forceful recovery.
- If examples are needed for modules, backends, lifecycle rules, tests, or
  import patterns, load [references/examples.md](references/examples.md).

## Red Flags
- `terraform.tfstate` or secret-bearing `.tfvars` files are tracked in git
- Provider versions are unpinned
- The workflow jumps to `apply`, `destroy`, `state rm`, or `force-unlock`
  without a fresh plan and explicit justification
- A rename or module move is proposed without `moved` blocks or import mapping
- `-target` is being used to paper over dependency or design issues
- Provisioners are used as a first resort instead of provider features, user data, or configuration management
