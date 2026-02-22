# Using AWS CLI: Overview

## Contents

- Command posture
- Pre-flight checks
- Authentication and credential configuration
- Global flags and output control
- JMESPath query patterns
- Pagination
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

Never begin with mutation unless the user explicitly requests emergency
containment.

---

## Pre-flight checks

Run these before any non-trivial work:

```bash
aws sts get-caller-identity --profile <profile> --region <region>
aws configure list --profile <profile>
```

For cross-account operations, confirm the assumed role ARN matches
expectations before proceeding.

---

## Authentication and credential configuration

### IAM credentials (static)

Stored in `~/.aws/credentials` and `~/.aws/config`:

```ini
[profile my-profile]
aws_access_key_id     = AKIAIOSFODNN7EXAMPLE
aws_secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
region                = us-east-1
```

Prefer short-lived credentials from SSO or assumed roles over static keys.

### AWS SSO (recommended)

Configure once:

```bash
aws configure sso --profile <profile>
```

Authenticate before each session or after token expiry:

```bash
aws sso login --profile <profile>
```

Verify login:

```bash
aws sts get-caller-identity --profile <profile>
```

### AssumeRole (cross-account)

```bash
aws sts assume-role \
  --role-arn arn:aws:iam::<account-id>:role/<role-name> \
  --role-session-name my-session \
  --profile <source-profile> \
  --region <region>
```

Export the returned credentials as environment variables, or configure
a chained profile in `~/.aws/config`:

```ini
[profile cross-account]
role_arn       = arn:aws:iam::<account-id>:role/<role-name>
source_profile = my-profile
region         = us-east-1
```

### Environment variables (precedence override)

```bash
export AWS_PROFILE=my-profile
export AWS_DEFAULT_REGION=us-east-1
# Or short-lived:
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_SESSION_TOKEN=...
```

Environment variables override all profile settings.

---

## Global flags and output control

Always pass these on mutating commands:

| Flag | Purpose |
| ---- | ------- |
| `--profile <name>` | Select named credentials profile |
| `--region <region>` | Target AWS region |
| `--output json\|yaml\|text\|table` | Control output format |
| `--query '<jmespath>'` | Filter response client-side |
| `--no-cli-pager` | Disable interactive pager (required in scripts) |
| `--no-paginate` | Return first page only (use with care) |
| `--endpoint-url <url>` | Override endpoint (LocalStack, VPC endpoints) |

Default output is `json`. Use `--output text` for simple shell extraction
and `--output table` for human inspection.

---

## JMESPath query patterns

Use `--query` to extract fields without external tools:

```bash
# Single field
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[*].InstanceId' \
  --output text --profile <p> --region <r>

# Multiple fields as table
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[*].[InstanceId,State.Name,Tags[?Key==`Name`].Value|[0]]' \
  --output table --profile <p> --region <r>

# Filter by value
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[?State.Name==`running`].InstanceId' \
  --output text --profile <p> --region <r>
```

Use `--filters` for server-side filtering (faster for large result sets):

```bash
aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" \
  --profile <p> --region <r>
```

---

## Pagination

AWS API responses are paginated. By default the CLI auto-paginates and
returns all results. To control this:

```bash
# Disable auto-pagination (first page only)
aws s3api list-objects-v2 --bucket <bucket> --no-paginate

# Limit result count and get continuation token
aws s3api list-objects-v2 --bucket <bucket> \
  --max-items 100 --page-size 100

# Continue from a token
aws s3api list-objects-v2 --bucket <bucket> \
  --starting-token <NextToken>
```

For scripting large result sets, prefer auto-pagination and pipe to `jq`.

---

## Safe mutation patterns

### Dry-run (EC2)

EC2 supports `--dry-run` to validate permissions without executing:

```bash
aws ec2 start-instances --instance-ids i-0abc123 --dry-run \
  --profile <p> --region <r>
```

### CloudFormation change sets

Preview changes before executing:

```bash
aws cloudformation create-change-set \
  --stack-name <stack> \
  --change-set-name preview-$(date +%s) \
  --template-body file://template.yaml \
  --capabilities CAPABILITY_IAM \
  --profile <p> --region <r>

aws cloudformation describe-change-set \
  --stack-name <stack> \
  --change-set-name <change-set-name> \
  --profile <p> --region <r>

# Execute only after review
aws cloudformation execute-change-set \
  --stack-name <stack> \
  --change-set-name <change-set-name> \
  --profile <p> --region <r>
```

### Generate CLI skeleton

Inspect expected input shape before constructing complex commands:

```bash
aws ecs create-service --generate-cli-skeleton input
```

---

## High-signal service command reference

### Identity and STS

```bash
aws sts get-caller-identity
aws sts assume-role --role-arn <arn> --role-session-name <name>
```

### EC2

```bash
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running"
aws ec2 start-instances --instance-ids <id>
aws ec2 stop-instances --instance-ids <id>
aws ec2 describe-security-groups
aws ec2 describe-vpcs
aws ec2 describe-subnets --filters "Name=vpc-id,Values=<vpc-id>"
```

### S3

```bash
aws s3 ls s3://<bucket>/
aws s3 cp <src> <dst>
aws s3 sync <src> s3://<bucket>/<prefix>/ --delete
aws s3api list-buckets
aws s3api get-bucket-policy --bucket <bucket>
```

### IAM

```bash
aws iam list-users
aws iam list-roles
aws iam get-role --role-name <name>
aws iam list-attached-role-policies --role-name <name>
aws iam get-policy --policy-arn <arn>
aws iam simulate-principal-policy \
  --policy-source-arn <arn> --action-names s3:GetObject
```

### ECS

```bash
aws ecs list-clusters
aws ecs list-services --cluster <cluster>
aws ecs describe-services --cluster <cluster> --services <service>
aws ecs update-service --cluster <cluster> --service <service> \
  --force-new-deployment
aws ecs list-tasks --cluster <cluster> --service-name <service>
aws ecs describe-tasks --cluster <cluster> --tasks <task-arn>
```

### Lambda

```bash
aws lambda list-functions
aws lambda get-function --function-name <name>
aws lambda invoke --function-name <name> \
  --payload '{}' --cli-binary-format raw-in-base64-out response.json
aws lambda update-function-code --function-name <name> \
  --image-uri <ecr-uri>
```

### CloudFormation

```bash
aws cloudformation list-stacks \
  --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE
aws cloudformation describe-stacks --stack-name <name>
aws cloudformation describe-stack-events --stack-name <name>
aws cloudformation validate-template --template-body file://template.yaml
aws cloudformation deploy \
  --stack-name <name> --template-file template.yaml \
  --capabilities CAPABILITY_IAM --no-fail-on-empty-changeset
```

### Secrets Manager

```bash
aws secretsmanager list-secrets
aws secretsmanager get-secret-value --secret-id <name-or-arn>
aws secretsmanager put-secret-value --secret-id <name> \
  --secret-string '{"key":"value"}'
aws secretsmanager create-secret --name <name> \
  --secret-string file://secret.json
```

### SSM Parameter Store

```bash
aws ssm get-parameter --name /my/param --with-decryption
aws ssm get-parameters-by-path --path /my/ --recursive --with-decryption
aws ssm put-parameter --name /my/param --value <val> \
  --type SecureString --overwrite
```

### RDS

```bash
aws rds describe-db-instances
aws rds describe-db-clusters
aws rds start-db-instance --db-instance-identifier <id>
aws rds stop-db-instance --db-instance-identifier <id>
aws rds create-db-snapshot --db-instance-identifier <id> \
  --db-snapshot-identifier <snap-name>
```

### ECR

```bash
aws ecr describe-repositories
aws ecr list-images --repository-name <name>
aws ecr get-login-password --region <r> | \
  docker login --username AWS --password-stdin <account>.dkr.ecr.<r>.amazonaws.com
```

### Route 53

```bash
aws route53 list-hosted-zones
aws route53 list-resource-record-sets --hosted-zone-id <id>
aws route53 change-resource-record-sets \
  --hosted-zone-id <id> --change-batch file://change.json
```
