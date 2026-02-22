# Using AWS CLI: Examples

## Contents

- Configure SSO profile and authenticate
- Verify identity and active account
- EC2: inspect and control instances
- S3: list, copy, sync, and manage buckets
- IAM: inspect roles, policies, and simulate permissions
- Secrets Manager: read and write secrets
- SSM Parameter Store: get and put parameters
- Lambda: list, invoke, and update functions
- CloudFormation: validate, deploy, and monitor stacks
- ECS: inspect clusters and force redeployment
- Cross-account access via chained profile

---

## Configure SSO profile and authenticate

```bash
# One-time SSO profile setup
aws configure sso --profile my-sso-profile

# Authenticate (run at start of session or after expiry)
aws sso login --profile my-sso-profile

# Confirm identity
aws sts get-caller-identity --profile my-sso-profile --region us-east-1
```

---

## Verify identity and active account

```bash
# Confirm which account and principal is active
aws sts get-caller-identity --profile <profile> --region <region>

# View all configured profiles
aws configure list-profiles

# Inspect a specific profile's settings
aws configure list --profile <profile>
```

---

## EC2: inspect and control instances

```bash
# List all running instances with name tags
aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" \
  --query 'Reservations[*].Instances[*].[InstanceId,Tags[?Key==`Name`].Value|[0],PrivateIpAddress]' \
  --output table --profile <profile> --region <region>

# Get instance details
aws ec2 describe-instances \
  --instance-ids i-0abc123def456 \
  --profile <profile> --region <region>

# Stop an instance (safe: confirm ID first)
aws ec2 stop-instances \
  --instance-ids i-0abc123def456 \
  --profile <profile> --region <region>

# Dry-run start (validates permissions without executing)
aws ec2 start-instances \
  --instance-ids i-0abc123def456 \
  --dry-run --profile <profile> --region <region>

# List security groups in a VPC
aws ec2 describe-security-groups \
  --filters "Name=vpc-id,Values=vpc-0abc123" \
  --query 'SecurityGroups[*].[GroupId,GroupName,Description]' \
  --output table --profile <profile> --region <region>
```

---

## S3: list, copy, sync, and manage buckets

```bash
# List all buckets
aws s3api list-buckets \
  --query 'Buckets[*].[Name,CreationDate]' \
  --output table --profile <profile>

# List objects in a bucket with prefix
aws s3 ls s3://my-bucket/my-prefix/ --profile <profile>

# Copy a local file to S3
aws s3 cp ./report.csv s3://my-bucket/reports/report.csv \
  --profile <profile>

# Sync local directory to S3 (preview first)
aws s3 sync ./dist/ s3://my-bucket/static/ \
  --dryrun --profile <profile>

# Sync with deletions (only after review)
aws s3 sync ./dist/ s3://my-bucket/static/ \
  --delete --profile <profile>

# Download a single object
aws s3 cp s3://my-bucket/config/app.json ./app.json --profile <profile>

# Get bucket policy
aws s3api get-bucket-policy \
  --bucket my-bucket --profile <profile> \
  --query Policy --output text | python3 -m json.tool
```

---

## IAM: inspect roles, policies, and simulate permissions

```bash
# List all roles
aws iam list-roles \
  --query 'Roles[*].[RoleName,Arn]' \
  --output table --profile <profile>

# Get a role and its trust policy
aws iam get-role --role-name MyAppRole --profile <profile>

# List policies attached to a role
aws iam list-attached-role-policies \
  --role-name MyAppRole --profile <profile>

# Get policy document (latest version)
POLICY_ARN=arn:aws:iam::<account>:policy/MyPolicy
VERSION=$(aws iam get-policy --policy-arn "$POLICY_ARN" \
  --query 'Policy.DefaultVersionId' --output text --profile <profile>)
aws iam get-policy-version \
  --policy-arn "$POLICY_ARN" --version-id "$VERSION" --profile <profile>

# Simulate whether a principal can perform an action
aws iam simulate-principal-policy \
  --policy-source-arn arn:aws:iam::<account>:role/MyAppRole \
  --action-names s3:GetObject s3:PutObject \
  --resource-arns arn:aws:s3:::my-bucket/* \
  --profile <profile>
```

---

## Secrets Manager: read and write secrets

```bash
# List all secrets
aws secretsmanager list-secrets \
  --query 'SecretList[*].[Name,ARN]' \
  --output table --profile <profile> --region <region>

# Get a secret value (string)
aws secretsmanager get-secret-value \
  --secret-id /my-app/prod/db-password \
  --query SecretString --output text \
  --profile <profile> --region <region>

# Get a JSON secret and extract a field
aws secretsmanager get-secret-value \
  --secret-id /my-app/prod/credentials \
  --query SecretString --output text \
  --profile <profile> --region <region> | jq -r '.password'

# Update a secret value
aws secretsmanager put-secret-value \
  --secret-id /my-app/prod/db-password \
  --secret-string 'newpassword123' \
  --profile <profile> --region <region>

# Create a new secret from a file
aws secretsmanager create-secret \
  --name /my-app/prod/api-keys \
  --secret-string file://api-keys.json \
  --profile <profile> --region <region>
```

---

## SSM Parameter Store: get and put parameters

```bash
# Get a single parameter (decrypted)
aws ssm get-parameter \
  --name /my-app/prod/db-host \
  --with-decryption \
  --query Parameter.Value --output text \
  --profile <profile> --region <region>

# Get all parameters under a path
aws ssm get-parameters-by-path \
  --path /my-app/prod/ \
  --recursive --with-decryption \
  --query 'Parameters[*].[Name,Value]' \
  --output table --profile <profile> --region <region>

# Put a SecureString parameter
aws ssm put-parameter \
  --name /my-app/prod/db-password \
  --value 'secret123' \
  --type SecureString \
  --overwrite \
  --profile <profile> --region <region>
```

---

## Lambda: list, invoke, and update functions

```bash
# List all Lambda functions
aws lambda list-functions \
  --query 'Functions[*].[FunctionName,Runtime,LastModified]' \
  --output table --profile <profile> --region <region>

# Get function configuration
aws lambda get-function \
  --function-name my-function \
  --profile <profile> --region <region>

# Invoke synchronously and capture response
aws lambda invoke \
  --function-name my-function \
  --payload '{"key":"value"}' \
  --cli-binary-format raw-in-base64-out \
  --log-type Tail \
  response.json --profile <profile> --region <region>

cat response.json

# Update function code from ECR image
aws lambda update-function-code \
  --function-name my-function \
  --image-uri <account>.dkr.ecr.<region>.amazonaws.com/my-repo:latest \
  --profile <profile> --region <region>

# Wait for update to complete
aws lambda wait function-updated \
  --function-name my-function \
  --profile <profile> --region <region>
```

---

## CloudFormation: validate, deploy, and monitor stacks

```bash
# Validate a template
aws cloudformation validate-template \
  --template-body file://template.yaml \
  --profile <profile> --region <region>

# Deploy (create or update) a stack
aws cloudformation deploy \
  --stack-name my-stack \
  --template-file template.yaml \
  --parameter-overrides Env=prod AppVersion=1.2.3 \
  --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
  --no-fail-on-empty-changeset \
  --profile <profile> --region <region>

# Describe stack outputs
aws cloudformation describe-stacks \
  --stack-name my-stack \
  --query 'Stacks[0].Outputs' \
  --output table --profile <profile> --region <region>

# Watch stack events during deploy
aws cloudformation describe-stack-events \
  --stack-name my-stack \
  --query 'StackEvents[*].[Timestamp,ResourceStatus,ResourceType,LogicalResourceId]' \
  --output table --profile <profile> --region <region>

# List stacks by status
aws cloudformation list-stacks \
  --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE UPDATE_ROLLBACK_COMPLETE \
  --query 'StackSummaries[*].[StackName,StackStatus,LastUpdatedTime]' \
  --output table --profile <profile> --region <region>
```

---

## ECS: inspect clusters and force redeployment

```bash
# List clusters
aws ecs list-clusters --profile <profile> --region <region>

# List services in a cluster
aws ecs list-services \
  --cluster my-cluster \
  --profile <profile> --region <region>

# Describe a service (check desired/running counts)
aws ecs describe-services \
  --cluster my-cluster \
  --services my-service \
  --query 'services[0].{Status:status,Desired:desiredCount,Running:runningCount,Pending:pendingCount}' \
  --profile <profile> --region <region>

# Force new deployment (rolling update with latest task def)
aws ecs update-service \
  --cluster my-cluster \
  --service my-service \
  --force-new-deployment \
  --profile <profile> --region <region>

# Watch service stabilize
aws ecs wait services-stable \
  --cluster my-cluster \
  --services my-service \
  --profile <profile> --region <region>

# Get logs for a running task
TASK=$(aws ecs list-tasks --cluster my-cluster --service-name my-service \
  --query 'taskArns[0]' --output text --profile <profile> --region <region>)
aws ecs describe-tasks \
  --cluster my-cluster --tasks "$TASK" \
  --profile <profile> --region <region>
```

---

## Cross-account access via chained profile

Configure `~/.aws/config`:

```ini
[profile source-account]
sso_start_url  = https://my-sso.awsapps.com/start
sso_account_id = 111111111111
sso_role_name  = Developer
region         = us-east-1

[profile target-account]
role_arn       = arn:aws:iam::222222222222:role/CrossAccountRole
source_profile = source-account
region         = us-east-1
```

Verify cross-account identity:

```bash
aws sts get-caller-identity --profile target-account
```

All subsequent commands use `--profile target-account` to operate in
the target account with the assumed role.
