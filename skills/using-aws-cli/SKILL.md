---
name: using-aws-cli
description: Provides expert guidance for using the AWS CLI to authenticate,
  inspect, and operate AWS resources safely. Use when requests involve aws
  configure, aws sso login, aws ec2, aws s3, aws iam, aws ecs, aws lambda,
  aws cloudformation, aws secretsmanager, aws ssm, aws sts, aws rds, aws
  route53, aws ecr, or any other aws service subcommands.
---

# Using AWS CLI

## Overview

The AWS CLI is the primary control surface for AWS API operations. Always
target a specific profile and region explicitly, start with read-only
inspection before mutation, and preview destructive changes before execution.
For full procedures and command patterns, read
[references/overview.md](references/overview.md).

## When to Use

- Writing or reviewing `aws` commands for any AWS service
- Authenticating via AWS SSO, IAM credentials, or instance roles
- Inspecting, creating, updating, or deleting AWS resources
- Querying resource state with `--query` and JMESPath filters
- Scripting AWS operations with paginated JSON output
- Diagnosing permission, credential, or region configuration issues

## When Not to Use

- Terraform or CloudFormation authoring where CLI execution is incidental
- AWS SDK usage inside application code
- Kubernetes cluster operations handled by `kubectl` or `eksctl`

## Prerequisites

- `aws` CLI v2 installed and on PATH (`aws --version`)
- Credentials configured: SSO profile, env vars, or `~/.aws/credentials`
- Target AWS account, profile, and region known before running commands

## Workflow

1. Verify identity with `aws sts get-caller-identity --profile <p> --region <r>`.
2. Confirm the active profile and region before running service commands.
3. Start with read-only operations: `list-*`, `describe-*`, `get-*`.
4. For mutations, use `--dry-run` (EC2) or `--generate-cli-skeleton` to
   preview before applying.
5. Use `--query` to filter output; use `--output json` for scripting.
6. Always paginate: use `aws ... --no-paginate` or handle `NextToken`.
7. For full command and auth patterns, read
   [references/overview.md](references/overview.md).
8. For concrete service examples, read
   [references/examples.md](references/examples.md).

## Hard Rules

- Always pass `--profile` and `--region` explicitly on mutating commands.
- Never store credentials in scripts, shell history, or committed files.
- Run `aws sts get-caller-identity` before any cross-account operation.
- Use `--dry-run` (EC2) or `--no-execute-change-set` (CloudFormation)
  before applying destructive operations where supported.
- Confirm with the user before running `aws s3 rm --recursive`,
  `aws s3 rb --force`, or any delete/purge command.
- Use `--no-cli-pager` in scripts to prevent interactive blocking.

## Failure Handling

- `ExpiredTokenException`: re-authenticate with `aws sso login --profile <p>`
  or refresh STS credentials; check token expiry in `~/.aws/cli/cache/`.
- `AccessDeniedException`: verify identity with `sts get-caller-identity`;
  check IAM policies, permission boundaries, and SCPs.
- `InvalidClientTokenId`: credentials are malformed or region-mismatched;
  recheck `~/.aws/credentials` and env vars.
- Profile not found: verify `~/.aws/config` contains the named profile.
- Unexpected account output: always pass `--profile` explicitly and confirm.

## Red Flags

- Mutating commands run without `--profile` or `--region` flags.
- Credentials present in environment variables during unrelated sessions.
- Deleting S3 buckets, IAM roles, or VPCs without prior `list`/`ls` review.
- Using `--recursive` or `--force` on delete without explicit confirmation.
- Skipping `sts get-caller-identity` before cross-account operations.
