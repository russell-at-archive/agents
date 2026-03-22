# Using AWS CLI: Troubleshooting

## Contents

- ExpiredTokenException (SSO and Sessions)
- JMESPath: null, empty, or unexpected shape
- AccessDeniedException: diagnosing the root cause
- Throttling: Rate exceeded and retry logic
- Profile not found: configuration mismatch
- S3: Access Denied vs 404
- Lambda: Invoke errors and log tailing

---

## ExpiredTokenException (SSO and Sessions)

Symptoms:

- `An error occurred (ExpiredTokenException): The security token included in the request is expired`

Expert fix:

```bash
# For modern SSO sessions:
aws sso login --sso-session <session-name>

# For specific profile:
aws sso login --profile <profile>

# If using env vars, clear them:
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
```

---

## JMESPath: null, empty, or unexpected shape

Symptoms:

- `--query` returns `null` or `[]` when data is expected.

Diagnostics:

1. **Check Case Sensitivity**: JMESPath is case-sensitive. `instanceId` != `InstanceId`.
2. **Inspect Raw Output**: Run WITHOUT `--query` to see the exact field names.
3. **Array vs. Object**: Check if the path needs `[]` or `[*]`.
4. **Literal Types**: Ensure string literals in filters use backticks: `[?Key==\`Name\`]`.

Example fix:

```bash
# WRONG: 'Reservations.Instances.InstanceId' (missing array markers)
# RIGHT: 'Reservations[].Instances[].InstanceId'
aws ec2 describe-instances --query 'Reservations[].Instances[].InstanceId'
```

---

## AccessDeniedException: diagnosing the root cause

Symptoms:

- `An error occurred (AccessDenied): User: arn:aws:iam::... is not authorized to perform: <action>`

Checklist:

1. **Identity**: `aws sts get-caller-identity --profile <p>` to confirm WHO you are.
2. **Policy Simulation**: Use `simulate-principal-policy` to test permissions locally.
3. **SCPs**: Check if an AWS Organization Service Control Policy is blocking the action.
4. **Boundaries**: Check if a Permission Boundary is restricting the role.
5. **Resource Policy**: Check S3 Bucket Policies or KMS Key Policies.

---

## Throttling: Rate exceeded and retry logic

Symptoms:

- `An error occurred (ThrottlingException): Rate exceeded`

Fixes:

- **Server-side filtering**: Use `--filters` to reduce the number of objects returned.
- **Backoff**: CLI v2 has built-in retry logic. Configure in `~/.aws/config`:

```ini
[profile dev]
retry_mode = standard
max_attempts = 10
```

---

## Profile not found: configuration mismatch

Symptoms:

- `The config profile (<name>) could not be found`

Fixes:

- Check `~/.aws/config` for `[profile <name>]`.
- If using `sso-session`, ensure the profile points to the correct session.
- Run `aws configure list-profiles` to see what the CLI recognizes.

---

## S3: Access Denied vs 404

Symptoms:

- `An error occurred (403) when calling the ListObjectsV2 operation: Access Denied`
- `An error occurred (404) when calling the GetObject operation: Not Found`

Nuance:

- S3 often returns 403 (Access Denied) instead of 404 (Not Found) if the user lacks `s3:ListBucket` permissions, to prevent resource enumeration.
- Fix: Grant `s3:ListBucket` on the bucket resource (`arn:aws:s3:::bucket`) to see 404s.

---

## Lambda: Invoke errors and log tailing

Symptoms:

- Lambda returns `200` but the function logic failed.

Diagnostics:

```bash
# Check the FunctionError field and log output
aws lambda invoke \
  --function-name my-f \
  --log-type Tail \
  --query 'LogResult' \
  --output text out.json | base64 -d
```

- Note: `LogResult` is base64 encoded; pipe to `base64 -d` to read the log tail.
