---
name: using-aws-cli
description: Provides expert guidance for using the AWS CLI to authenticate,
  inspect, troubleshoot, and operate AWS resources safely. Use when requests
  involve aws configure, aws sso login, aws sts, aws ec2, aws s3, aws iam,
  aws ecs, aws lambda, aws cloudformation, aws ssm, aws secretsmanager, aws
  route53, aws ecr, aws rds, or any other aws service subcommands.
---

# Using AWS CLI

## Overview

The AWS CLI is the direct control plane for AWS APIs. Expert usage starts by
proving identity, fixing auth and region context, minimizing payload with
server-side filters, shaping results with JMESPath, and treating every write as
an auditable change.

For full procedures and command patterns, read
[references/overview.md](references/overview.md).

## When to Use

- Writing, reviewing, or running `aws` commands for any AWS service
- Working with AWS SSO / IAM Identity Center profiles and sessions
- Diagnosing identity, credential, permission, account, or region issues
- Inspecting resources with `--filters`, `--query`, and structured output
- Building shell workflows around paginated AWS CLI output
- Planning or executing carefully scoped AWS mutations

## When Not to Use

- AWS SDK implementation inside application code
- Terraform, OpenTofu, or CloudFormation authoring where the CLI is incidental
- Kubernetes operations better handled by `kubectl`, `helm`, or `eksctl`

## Prerequisites

- `aws` CLI v2 installed and on PATH. See
  [references/installation.md](references/installation.md).
- Named profiles configured, preferably with `sso-session` in `~/.aws/config`
- The intended AWS account, profile, and region identified before any
  non-trivial command
- Permission to pause and confirm before any destructive or high-blast-radius
  action

## Workflow

1. Confirm tooling and context: `aws --version`, intended `--profile`, and
   intended `--region`.
2. Prove identity first with `aws sts get-caller-identity --profile <p>`.
3. If auth is stale or missing, renew via `aws sso login --profile <p>` or
   `aws sso login --sso-session <session>`.
4. Observe before changing anything: start with read-only service commands and
   inspect raw output when response shape is unclear.
5. Reduce the dataset on the AWS side with service-native `--filters` or other
   server-side selectors before adding `--query`.
6. Use `--query` to shape, sort, filter, and flatten output locally with
   JMESPath. Prefer `--output json`, `text`, or `table` intentionally.
7. For scripts, add `--no-cli-pager`; capture structured fields safely instead
   of scraping human-formatted output.
8. Before mutations, identify the exact target resources, use `--dry-run` or
   `--generate-cli-skeleton` when available, and make the smallest viable
   change.
9. After mutations, verify the resulting state with fresh read-only commands.
10. For deeper procedures, examples, and recovery paths, use
   [references/overview.md](references/overview.md),
   [references/examples.md](references/examples.md), and
   [references/troubleshooting.md](references/troubleshooting.md).

## Hard Rules

- Always establish identity before cross-account, production, or privileged
  work with `aws sts get-caller-identity`.
- Always pass `--profile` and `--region` explicitly on mutating commands.
- Prefer server-side filtering first; use `--query` for shaping, not bulk
  reduction.
- Never put AWS secrets or session credentials into scripts, files, commits, or
  shell history.
- Use `--no-cli-pager` in scripts and automation.
- Do not guess response shapes. Drop `--query` and inspect raw output when the
  path is uncertain.
- Confirm with the user before any `delete`, `terminate`, `detach`, `revoke`,
  `put-*`, `update-*`, `modify-*`, or other state-changing command with real
  blast radius.
- Treat S3 sync deletions, IAM changes, KMS policy changes, Route53 updates,
  and EC2/ECS/Lambda production mutations as high-risk operations.

## Failure Handling

- `ExpiredTokenException`: re-authenticate with `aws sso login`; clear stale
  `AWS_*` environment variables if needed.
- `AccessDenied` or `UnauthorizedOperation`: verify caller identity first, then
  inspect IAM policy, SCP, permission boundary, and resource policy layers.
- `InvalidClientTokenId` or unexpected caller: check for conflicting
  environment credentials and confirm the active profile.
- Profile resolution failures: inspect `~/.aws/config` and
  `aws configure list-profiles`.
- `--query` returning `null` or `[]`: inspect the raw JSON shape, then correct
  array markers, case sensitivity, or literal quoting.
- Throttling: narrow the request with server-side filters and rely on CLI retry
  configuration where appropriate.
- For service-specific recovery steps, read
  [references/troubleshooting.md](references/troubleshooting.md).

## Red Flags

- Mutating commands without explicit `--profile` and `--region`
- Production-impacting actions proposed before proving identity
- Large list operations using only `--query` and no server-side reduction
- Shell loops over resources without a read-only preview step
- S3 `sync --delete`, IAM policy edits, or route changes proposed without
  confirmation
- Reliance on ambient `AWS_*` environment variables when named profiles are
  available
