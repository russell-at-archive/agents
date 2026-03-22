# Using AWS CLI: Overview

## Contents

- Installation and verification: [references/installation.md](installation.md)
- Command posture
- Pre-flight checks
- Authentication: modern SSO and sessions
- Performance: server-side filtering vs. client-side querying
- JMESPath expert patterns
- Pagination and scripting
- Safe mutation patterns
- High-signal service command reference

---

## Command posture

Treat every AWS CLI session as a sequence:

1. **Identify**: confirm account, profile, and region.
2. **Observe**: gather facts with read-only commands.
3. **Decide**: identify root cause or intended change.
4. **Mutate**: apply the minimal, auditable change.
5. **Verify**: confirm the resource reached the expected state.

---

## Pre-flight checks

Run these before any non-trivial work:

```bash
aws sts get-caller-identity --profile <p>
aws configure list --profile <p>
```

---

## Authentication: modern SSO and sessions

Modern AWS CLI (v2.7+) uses `sso-session` to share authentication state across multiple profiles.

### SSO session configuration

In `~/.aws/config`:

```ini
[sso-session my-org]
sso_start_url = https://my-org.awsapps.com/start
sso_region = us-east-1
sso_registration_scopes = sso:account:access

[profile dev]
sso_session = my-org
sso_account_id = 111111111111
sso_role_name = Developer
region = us-east-1

[profile prod]
sso_session = my-org
sso_account_id = 222222222222
sso_role_name = AdministratorAccess
region = us-east-1
```

### SSO workflow

1. Login once for the session: `aws sso login --sso-session my-org`
2. Run commands: `aws s3 ls --profile dev`
3. If token expires: `aws sso login --profile dev` (renews all profiles in session)

---

## Performance: server-side filtering vs. client-side querying

Expert usage uses both to minimize latency and bandwidth.

| Filter Type | Parameter | Location | Logic | Use Case |
| ----------- | --------- | -------- | ----- | -------- |
| **Server** | `--filter` | AWS Server | AWS API | Large datasets; reducing API payload |
| **Client** | `--query` | Local CLI | JMESPath | Formatting; shaping; secondary filtering |

### Expert pattern: Combine both

```bash
# Server-side reduces 1000s of instances to 50;
# Client-side extracts just the IDs from those 50.
aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" \
  --query "Reservations[].Instances[].InstanceId" \
  --output text --profile <p>
```

---

## JMESPath expert patterns

Use `--query` to shape output. JMESPath is case-sensitive.

### Projections and selection

- **Multi-select Hash**: `{Key: Path, Key2: Path2}` creates a JSON object.
- **Multi-select List**: `[Path1, Path2]` creates an array.

```bash
# Get name and private IP as a JSON list of objects
aws ec2 describe-instances --query 'Reservations[].Instances[].{ID:InstanceId,IP:PrivateIpAddress}'
```

### Functions and operators

- **Filtering**: `[?Field == \`value\`]` (note backticks for literals).
- **Sorting**: `sort_by(Array, &Field)` (note ampersand for sort key).
- **Flattening**: `[]` vs `[*]`. Use `[]` to collapse nested levels.
- **Functions**: `contains(Field, \`string\`)`, `length(Array)`, `join(\`,\`, Array)`.

```bash
# Sort S3 buckets by creation date
aws s3api list-buckets --query "sort_by(Buckets, &CreationDate)[].Name"
```

---

## Pagination and scripting

### Auto-pagination (default)

CLI v2 automatically handles `NextToken` and returns the full result set.

### Manual pagination (scripting)

Use for massive datasets or memory-constrained environments:

```bash
aws s3api list-objects-v2 --bucket <b> --max-items 100 --starting-token <token>
```

### Scripting extraction

Use `read` with text output to capture multiple variables without `jq`:

```bash
read -r id state ip <<< $(aws ec2 describe-instances --query \
  'Reservations[0].Instances[0].[InstanceId,State.Name,PrivateIpAddress]' \
  --output text --profile <p>)
```

---

## Safe mutation patterns

### EC2 dry-run

```bash
aws ec2 stop-instances --instance-ids <id> --dry-run
```

### Skeleton generation

Inspect the required JSON shape for complex inputs:

```bash
aws ecs register-task-definition --generate-cli-skeleton input
```

---

## High-signal service command reference

### EC2 and VPC
```bash
aws ec2 describe-instances --filters "Name=vpc-id,Values=<vpc>"
aws ec2 describe-security-groups --query "SecurityGroups[?GroupName==\`web\`].GroupId"
```

### S3 and API
```bash
aws s3 sync ./local s3://bucket/prefix/ --delete --dryrun
aws s3api get-bucket-policy --bucket <b> --output text | jq .
```

### Identity and IAM
```bash
aws sts get-caller-identity
aws iam simulate-principal-policy --policy-source-arn <arn> --action-names <actions>
```

### Lambda and Serverless
```bash
aws lambda list-functions --query "sort_by(Functions, &MemorySize)[].FunctionName"
aws lambda invoke --function-name <f> --payload '{"k":"v"}' response.json
```
