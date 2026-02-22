# Using AWS CLI: Troubleshooting

## Contents

- ExpiredTokenException
- AccessDeniedException
- InvalidClientTokenId
- NoCredentialProviders
- Profile not found
- Region errors
- Throttling and TooManyRequestsException
- Pagination and truncated results
- JMESPath query returning null or empty
- CloudFormation stack stuck in ROLLBACK
- SSO token expired or browser not opening
- Unsafe command patterns to stop

---

## ExpiredTokenException

Symptoms:

- `An error occurred (ExpiredTokenException): The security token included
  in the request is expired`

Causes:

- SSO session token has expired (default 8 hours)
- Assumed role session has expired (default 1 hour)
- Static `AWS_SESSION_TOKEN` env var is stale

Fixes:

```bash
# Re-authenticate with SSO
aws sso login --profile <profile>

# Verify new token is active
aws sts get-caller-identity --profile <profile>

# If using env vars, unset stale session token
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
```

---

## AccessDeniedException

Symptoms:

- `An error occurred (AccessDeniedException): User: arn:aws:iam::... is
  not authorized to perform: <action> on resource: <arn>`

Checks:

```bash
# Confirm active identity
aws sts get-caller-identity --profile <profile> --region <region>

# Simulate the specific action
aws iam simulate-principal-policy \
  --policy-source-arn <role-or-user-arn> \
  --action-names <service:Action> \
  --resource-arns <resource-arn> \
  --profile <profile>
```

Fixes:

- Confirm you are using the correct profile and account.
- Check IAM policies attached to the role or user for the missing action.
- Check for deny statements in SCPs (Service Control Policies) at the org level.
- Check resource-based policies (S3 bucket policy, KMS key policy, etc.).
- Check permission boundaries on the IAM role.

---

## InvalidClientTokenId

Symptoms:

- `An error occurred (InvalidClientTokenId): The security token included
  in the request is invalid`

Causes:

- Access key ID is incorrect or deleted.
- Credentials are for a different partition (e.g., `aws-cn` keys used
  with `aws` endpoints).
- Environment variable credentials conflict with profile credentials.

Fixes:

```bash
# Check what credentials are resolved
aws configure list --profile <profile>

# Check for conflicting environment variables
env | grep AWS_

# Unset all env overrides and use profile directly
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_PROFILE
aws sts get-caller-identity --profile <profile>
```

---

## NoCredentialProviders

Symptoms:

- `Unable to locate credentials`
- `No credential provider found in chain`

Checks:

```bash
ls -la ~/.aws/credentials ~/.aws/config
aws configure list --profile <profile>
```

Fixes:

- Run `aws configure --profile <profile>` to set credentials.
- For SSO: run `aws sso login --profile <profile>`.
- Confirm profile name matches exactly (case-sensitive) in `~/.aws/config`.
- For CI/CD: ensure `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and
  `AWS_SESSION_TOKEN` env vars are injected correctly.

---

## Profile not found

Symptoms:

- `The config profile (<profile>) could not be found`

Checks:

```bash
# List all known profiles
aws configure list-profiles

# View config file
cat ~/.aws/config
```

Fixes:

- Correct spelling and case of the profile name.
- Ensure the profile is in `~/.aws/config` (not only `~/.aws/credentials`
  for SSO profiles).
- Re-run `aws configure sso --profile <profile>` if SSO profile is missing.

---

## Region errors

Symptoms:

- `You must specify a region`
- Commands targeting the wrong region unexpectedly

Fixes:

```bash
# Always pass region explicitly
aws ec2 describe-instances --region us-east-1 --profile <profile>

# Or set in profile config:
# [profile my-profile]
# region = us-east-1

# Check what region is resolved
aws configure get region --profile <profile>
```

Note: some global services (IAM, Route 53, S3 bucket listing) do not
require a region but still accept `--region`.

---

## Throttling and TooManyRequestsException

Symptoms:

- `An error occurred (ThrottlingException): Rate exceeded`
- `An error occurred (TooManyRequestsException)`

Fixes:

- Add `--cli-read-timeout` and `--cli-connect-timeout` for slow networks.
- Back off and retry after a few seconds.
- Use `--page-size` to reduce per-request load on paginated calls.
- Spread high-volume scripted calls across time or use exponential backoff.

```bash
# Reduce page size to avoid triggering throttle limits
aws ec2 describe-instances --page-size 20 --profile <profile> --region <region>
```

---

## Pagination and truncated results

Symptoms:

- Output has a `NextToken` field but fewer results than expected
- Results appear incomplete compared to the AWS Console

Checks:

```bash
# Confirm auto-pagination is not disabled
aws s3api list-objects-v2 --bucket <bucket> --profile <profile>
# (auto-paginates by default; do NOT add --no-paginate if you need all results)
```

Fixes:

- Remove `--no-paginate` if you added it accidentally.
- For very large result sets, use `--max-items` and loop with
  `--starting-token <NextToken>`.
- Pipe to `jq` to process streamed output page by page.

---

## JMESPath query returning null or empty

Symptoms:

- `--query` returns `null`, `[]`, or no output

Checks:

```bash
# First inspect the raw response structure without --query
aws ec2 describe-instances --profile <profile> --region <region>
```

Common mistakes:

- Array vs. non-array path: `Instances[*]` vs. `Instances` depends on
  the response shape; check raw output first.
- Case sensitivity: JMESPath is case-sensitive; `instanceId` != `InstanceId`.
- Nested arrays: use flatten `[]` operator for doubly-nested arrays.
- Backtick strings vs. bare strings in filters: string literals need
  backticks inside `[?Key==\`Name\`]`.

Fix by inspecting raw output, then building the query incrementally:

```bash
# Step 1: get raw shape
aws ec2 describe-instances --profile <p> --region <r>
# Step 2: navigate one level
aws ec2 describe-instances --query 'Reservations' --profile <p> --region <r>
# Step 3: add more path segments
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[*].InstanceId' \
  --profile <p> --region <r>
```

---

## CloudFormation stack stuck in ROLLBACK

Symptoms:

- Stack status is `ROLLBACK_IN_PROGRESS`, `UPDATE_ROLLBACK_FAILED`,
  or `ROLLBACK_COMPLETE`

Checks:

```bash
aws cloudformation describe-stack-events \
  --stack-name <stack> \
  --query 'StackEvents[?ResourceStatus==`CREATE_FAILED` || ResourceStatus==`UPDATE_FAILED`].[Timestamp,LogicalResourceId,ResourceStatusReason]' \
  --output table --profile <profile> --region <region>
```

Fixes:

- Fix the underlying resource error reported in the events.
- For `UPDATE_ROLLBACK_FAILED`: use `continue-update-rollback` to
  unblock the stack:

```bash
aws cloudformation continue-update-rollback \
  --stack-name <stack> --profile <profile> --region <region>
```

- For `ROLLBACK_COMPLETE` (failed create): delete the stack and redeploy.

---

## SSO token expired or browser not opening

Symptoms:

- `Error when retrieving token from sso: Token has expired`
- Browser does not open for SSO login

Fixes:

```bash
# Force re-login
aws sso login --profile <profile>

# If browser fails to open, use --no-browser and copy the URL manually
aws sso login --profile <profile> --no-browser

# Clear cached SSO tokens and retry
rm -rf ~/.aws/sso/cache/
aws sso login --profile <profile>
```

---

## Unsafe command patterns to stop

Stop and re-scope if a command includes any of the following without
explicit user confirmation:

- `aws s3 rm s3://<bucket> --recursive` — deletes all objects
- `aws s3 rb s3://<bucket> --force` — deletes bucket and all contents
- `aws ec2 terminate-instances` — permanent instance termination
- `aws iam delete-role` or `aws iam detach-role-policy` without review
- `aws cloudformation delete-stack` in production
- Any command using `--force` on destructive operations
- Any `--profile` that maps to a production account unless confirmed

Replace with targeted operations, scoped selectors, and require
explicit user review of the resource list before proceeding.
