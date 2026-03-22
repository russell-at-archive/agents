# Using AWS CLI: Examples

## Contents

- SSO: modern sso-session and named profiles
- JMESPath: sorting, filtering, and projecting
- Performance: combining --filter and --query
- Scripting: multi-variable capture and looping
- EC2: complex instance queries
- S3: sync, copy, and lifecycle policies
- Lambda: invoke, wait, and sort functions

---

## SSO: modern sso-session and named profiles

```bash
# Register an SSO session once
aws configure sso --profile dev

# config (~/.aws/config)
# [sso-session my-org]
# sso_start_url = https://my-org.awsapps.com/start
# sso_region = us-east-1

# [profile dev]
# sso_session = my-org
# sso_account_id = 111111111111
# sso_role_name = Developer

# Login to ALL profiles in the session
aws sso login --sso-session my-org

# Confirm identity
aws sts get-caller-identity --profile dev
```

---

## JMESPath: sorting, filtering, and projecting

```bash
# Sort S3 buckets by creation date and list names
aws s3api list-buckets \
  --query "sort_by(Buckets, &CreationDate)[].Name" \
  --output text --profile dev

# Filter Lambda functions by runtime and project a JSON object
aws lambda list-functions \
  --query "Functions[?Runtime==\`python3.11\`].{Name:FunctionName, Memory:MemorySize}" \
  --output json --profile dev

# Check if an IAM role has a specific tag
aws iam list-roles \
  --query "Roles[?Tags[?Key==\`Project\` && Value==\`Alpha\`]].RoleName" \
  --output text --profile dev
```

---

## Performance: combining --filter and --query

```bash
# Server-side (--filters) reduces data set on AWS server
# Client-side (--query) shapes the remaining data locally
aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" \
  --query "Reservations[].Instances[].{ID:InstanceId, Type:InstanceType}" \
  --output table --profile dev --region us-east-1
```

---

## Scripting: multi-variable capture and looping

```bash
# Capture multiple values into shell variables in one call
read -r id state ip <<< $(aws ec2 describe-instances \
  --instance-ids i-0abc123def \
  --query "Reservations[0].Instances[0].[InstanceId, State.Name, PrivateIpAddress]" \
  --output text --profile dev)

echo "Instance $id is $state at $ip"

# Loop over resources for destructive or audit actions
for id in $(aws ec2 describe-instances \
  --filters "Name=tag:Project,Values=Alpha" \
  --query "Reservations[].Instances[].InstanceId" \
  --output text --profile dev); do
    echo "Inspecting instance $id..."
    aws ec2 describe-instance-status --instance-id "$id" --profile dev
done
```

---

## EC2: complex instance queries

```bash
# List all subnets in a VPC with their available IP count
aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=vpc-0abc123" \
  --query "Subnets[].{ID:SubnetId, CIDR:CidrBlock, Available:AvailableIpAddressCount}" \
  --output table --profile dev

# Get the latest AMI ID for Amazon Linux 2
aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=amzn2-ami-hvm-2.0.*-x86_64-gp2" \
  --query "sort_by(Images, &CreationDate)[-1].ImageId" \
  --output text --profile dev
```

---

## S3: sync, copy, and lifecycle policies

```bash
# Sync local to S3 (dryrun first to check deletions)
aws s3 sync ./dist s3://my-bucket/app/ --delete --dryrun --profile dev

# Download multiple files by prefix using --exclude/--include
aws s3 cp s3://my-bucket/logs/ ./local-logs/ \
  --recursive --exclude "*" --include "error-*.log" --profile dev

# Get bucket lifecycle configuration
aws s3api get-bucket-lifecycle-configuration \
  --bucket my-bucket --query "Rules[].{ID:ID, Status:Status}" \
  --output table --profile dev
```

---

## Lambda: invoke, wait, and sort functions

```bash
# Sort Lambda functions by memory size and return CSV
aws lambda list-functions \
  --query "sort_by(Functions, &MemorySize)[].[FunctionName,MemorySize]" \
  --output text --profile dev | tr '\t' ','

# Invoke and wait for a specific state (async pattern)
aws lambda invoke --function-name my-f --payload '{"k":"v"}' out.json --profile dev
aws lambda wait function-active --function-name my-f --profile dev
```
