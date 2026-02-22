# Using Terraform: Examples

## Contents

- [Minimal working configuration](#minimal-working-configuration)
- [Multi-environment with separate directories](#multi-environment-with-separate-directories)
- [Reusable module with variables and outputs](#reusable-module-with-variables-and-outputs)
- [for_each over a map of objects](#for_each-over-a-map-of-objects)
- [Dynamic blocks from a variable](#dynamic-blocks-from-a-variable)
- [Conditional resource creation](#conditional-resource-creation)
- [Data source + remote state lookup](#data-source--remote-state-lookup)
- [Import existing resource (v1.5+ block)](#import-existing-resource-v15-block)
- [Rename resource without destroy using moved block](#rename-resource-without-destroy-using-moved-block)
- [Lifecycle: prevent_destroy and ignore_changes](#lifecycle-prevent_destroy-and-ignore_changes)
- [S3 backend with DynamoDB locking](#s3-backend-with-dynamodb-locking)
- [Generating config with templatefile](#generating-config-with-templatefile)
- [Writing a terraform test](#writing-a-terraform-test)
- [Useful one-liners](#useful-one-liners)

---

## Minimal working configuration

```hcl
# versions.tf
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# providers.tf
provider "aws" {
  region = "us-east-1"
}

# main.tf
resource "aws_s3_bucket" "example" {
  bucket = "my-unique-bucket-${random_id.suffix.hex}"
}

resource "random_id" "suffix" {
  byte_length = 4
}

# outputs.tf
output "bucket_name" {
  value = aws_s3_bucket.example.bucket
}
```

```bash
terraform init
terraform plan
terraform apply
```

---

## Multi-environment with separate directories

```
infrastructure/
├── modules/app/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
└── envs/
    ├── dev/
    │   ├── main.tf
    │   ├── terraform.tfvars
    │   └── versions.tf
    └── prod/
        ├── main.tf
        ├── terraform.tfvars
        └── versions.tf
```

```hcl
# envs/prod/main.tf
terraform {
  backend "s3" {
    bucket         = "my-tf-state"
    key            = "prod/app/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-state-lock"
    encrypt        = true
  }
}

module "app" {
  source = "../../modules/app"

  environment    = var.environment
  instance_type  = var.instance_type
  min_capacity   = var.min_capacity
}
```

```hcl
# envs/prod/terraform.tfvars
environment   = "prod"
instance_type = "m5.large"
min_capacity  = 3
```

```bash
cd envs/prod
terraform init
terraform plan -var-file=terraform.tfvars
```

---

## Reusable module with variables and outputs

```hcl
# modules/rds/variables.tf
variable "name" {
  description = "Identifier prefix for all resources"
  type        = string
}

variable "engine_version" {
  type    = string
  default = "16"
}

variable "instance_class" {
  type    = string
  default = "db.t3.medium"
}

variable "multi_az" {
  type    = bool
  default = false
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
```

```hcl
# modules/rds/main.tf
resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-subnet-group"
  subnet_ids = var.subnet_ids
  tags       = var.tags
}

resource "aws_security_group" "rds" {
  name   = "${var.name}-rds-sg"
  vpc_id = var.vpc_id
  tags   = var.tags
}

resource "aws_db_instance" "this" {
  identifier        = var.name
  engine            = "postgres"
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  multi_az          = var.multi_az
  username          = "admin"
  password          = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  skip_final_snapshot    = !var.multi_az
  deletion_protection    = var.multi_az

  lifecycle {
    prevent_destroy = true   # set on module root, not the instance
    ignore_changes  = [password]
  }

  tags = var.tags
}
```

```hcl
# modules/rds/outputs.tf
output "endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.this.endpoint
}

output "port" {
  value = aws_db_instance.this.port
}

output "security_group_id" {
  value = aws_security_group.rds.id
}
```

```hcl
# Calling the module
module "db" {
  source = "../../modules/rds"

  name           = "prod-myapp"
  instance_class = "db.r6g.large"
  multi_az       = true
  db_password    = var.db_password   # supplied via TF_VAR_db_password
  subnet_ids     = module.vpc.private_subnet_ids
  vpc_id         = module.vpc.vpc_id
  tags           = local.common_tags
}

output "db_endpoint" {
  value = module.db.endpoint
}
```

---

## for_each over a map of objects

```hcl
variable "dns_records" {
  type = map(object({
    type    = string
    ttl     = number
    records = list(string)
  }))
  default = {
    "api" = { type = "A", ttl = 300, records = ["10.0.0.1"] }
    "www" = { type = "CNAME", ttl = 3600, records = ["api.example.com"] }
  }
}

resource "aws_route53_record" "this" {
  for_each = var.dns_records

  zone_id = data.aws_route53_zone.primary.zone_id
  name    = each.key
  type    = each.value.type
  ttl     = each.value.ttl
  records = each.value.records
}

# Collect all FQDNs into a list
output "record_fqdns" {
  value = [for r in aws_route53_record.this : r.fqdn]
}
```

```hcl
# for_each on a module — create N instances of a module
module "microservices" {
  for_each = toset(["auth", "api", "worker"])
  source   = "./modules/service"

  name        = each.key
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
}

# Access a specific instance
output "api_url" {
  value = module.microservices["api"].url
}
```

---

## Dynamic blocks from a variable

```hcl
variable "ingress_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      description = "HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

resource "aws_security_group" "app" {
  name   = "${var.name}-sg"
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

---

## Conditional resource creation

```hcl
variable "enable_waf" {
  type    = bool
  default = false
}

# count pattern
resource "aws_wafv2_web_acl" "main" {
  count = var.enable_waf ? 1 : 0
  name  = "${var.name}-waf"
  scope = "REGIONAL"

  default_action { allow {} }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.name}-waf"
    sampled_requests_enabled   = true
  }
}

# Reference safely with one() or try()
resource "aws_wafv2_web_acl_association" "alb" {
  count        = var.enable_waf ? 1 : 0
  resource_arn = aws_lb.main.arn
  web_acl_arn  = one(aws_wafv2_web_acl.main[*].arn)
}

# Output with conditional
output "waf_arn" {
  value = var.enable_waf ? one(aws_wafv2_web_acl.main[*].arn) : null
}
```

---

## Data source + remote state lookup

```hcl
# Read outputs from another Terraform state (cross-component dependency)
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "my-tf-state"
    key    = "shared/vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

# Read an existing resource not managed by this config
data "aws_ssm_parameter" "db_password" {
  name            = "/myapp/prod/db_password"
  with_decryption = true
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  vpc_id            = data.terraform_remote_state.vpc.outputs.vpc_id
  private_subnets   = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  account_id        = data.aws_caller_identity.current.account_id
  region            = data.aws_region.current.name
}
```

---

## Import existing resource (v1.5+ block)

```hcl
# Step 1: declare the import block
import {
  to = aws_s3_bucket.legacy
  id = "my-existing-bucket-name"
}

# Step 2: optionally let Terraform generate the config
# terraform plan -generate-config-out=generated.tf
# Then review and clean up generated.tf

# Step 3: write the resource config manually (or use generated)
resource "aws_s3_bucket" "legacy" {
  bucket = "my-existing-bucket-name"
  # Terraform will import state and set remaining attributes from API
}
```

```bash
terraform plan -generate-config-out=generated.tf
# Review generated.tf
terraform apply
# Remove the import block after successful apply
```

**Multiple imports with for_each:**
```hcl
locals {
  existing_users = {
    alice = "arn:aws:iam::123456789012:user/alice"
    bob   = "arn:aws:iam::123456789012:user/bob"
  }
}

import {
  for_each = local.existing_users
  to       = aws_iam_user.team[each.key]
  id       = each.key
}

resource "aws_iam_user" "team" {
  for_each = local.existing_users
  name     = each.key
}
```

---

## Rename resource without destroy using moved block

```hcl
# Scenario 1: simple rename
moved {
  from = aws_security_group.web
  to   = aws_security_group.app
}

# Scenario 2: move resource into a module
moved {
  from = aws_s3_bucket.logs
  to   = module.logging.aws_s3_bucket.this
}

# Scenario 3: refactor count → for_each (must map old indices to new keys)
moved {
  from = aws_instance.server[0]
  to   = aws_instance.server["primary"]
}

moved {
  from = aws_instance.server[1]
  to   = aws_instance.server["secondary"]
}
```

```bash
# After adding moved blocks:
terraform plan   # should show 0 adds, 0 destroys, 0 changes — just moves
terraform apply  # updates state only
```

---

## Lifecycle: prevent_destroy and ignore_changes

```hcl
resource "aws_db_instance" "main" {
  identifier     = "prod-postgres"
  instance_class = "db.r6g.xlarge"
  engine         = "postgres"
  engine_version = "16"
  username       = "admin"
  password       = var.db_password

  lifecycle {
    # Error if anything would destroy this resource
    prevent_destroy = true

    # Don't track these attributes (externally managed)
    ignore_changes = [
      password,              # rotated by secrets manager
      snapshot_identifier,  # set at creation only
    ]

    # Replace instance when launch template version changes
    replace_triggered_by = [
      aws_launch_template.app.latest_version
    ]

    precondition {
      condition     = var.environment == "prod" ? var.multi_az : true
      error_message = "Production databases must be multi-AZ."
    }
  }
}
```

---

## S3 backend with DynamoDB locking

```hcl
# versions.tf
terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    # Partial config — secrets supplied via -backend-config at init time
    bucket         = "my-org-terraform-state"
    key            = "prod/app/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

```bash
# Supply role_arn at init time (not in .tf files)
terraform init \
  -backend-config="role_arn=arn:aws:iam::123456789012:role/terraform-state"

# Or use a backend config file
cat > backend.hcl << EOF
role_arn = "arn:aws:iam::123456789012:role/terraform-state"
EOF
terraform init -backend-config=backend.hcl
```

**Bootstrap the state bucket (chicken-and-egg — use local state first):**
```hcl
# state-bootstrap/main.tf (uses local backend)
resource "aws_s3_bucket" "tfstate" {
  bucket = "my-org-terraform-state"
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_dynamodb_table" "tflock" {
  name         = "terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute { name = "LockID"; type = "S" }
}
```

---

## Generating config with templatefile

```hcl
# templates/user_data.sh.tpl
#!/bin/bash
set -e
hostnamectl set-hostname ${hostname}
echo "ENVIRONMENT=${environment}" >> /etc/environment
echo "DB_HOST=${db_host}" >> /etc/environment

%{ for pkg in packages ~}
apt-get install -y ${pkg}
%{ endfor ~}
```

```hcl
resource "aws_instance" "app" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  user_data = templatefile("${path.module}/templates/user_data.sh.tpl", {
    hostname    = "${var.name}-${var.environment}"
    environment = var.environment
    db_host     = module.db.endpoint
    packages    = ["nginx", "awscli", "jq"]
  })
}
```

---

## Writing a terraform test

```hcl
# tests/vpc.tftest.hcl
variables {
  name        = "test-vpc"
  cidr_block  = "10.99.0.0/16"
  environment = "test"
}

# Use mock provider to avoid real API calls during unit tests
mock_provider "aws" {
  mock_resource "aws_vpc" {
    defaults = {
      id                   = "vpc-mock12345"
      default_route_table_id = "rtb-mock12345"
    }
  }

  mock_resource "aws_subnet" {
    defaults = {
      id = "subnet-mock12345"
    }
  }
}

run "vpc_has_correct_cidr" {
  command = plan

  assert {
    condition     = aws_vpc.this.cidr_block == "10.99.0.0/16"
    error_message = "VPC CIDR block is wrong: ${aws_vpc.this.cidr_block}"
  }
}

run "subnets_are_in_vpc_cidr" {
  command = plan

  assert {
    condition = alltrue([
      for s in aws_subnet.private : startswith(s.cidr_block, "10.99.")
    ])
    error_message = "Private subnet CIDRs not within VPC CIDR."
  }
}

run "prod_has_more_subnets" {
  variables {
    environment = "prod"
  }

  assert {
    condition     = length(aws_subnet.private) >= 3
    error_message = "Prod should have at least 3 private subnets."
  }
}
```

```bash
terraform test
terraform test -verbose
terraform test -filter=tests/vpc.tftest.hcl
```

---

## Useful one-liners

```bash
# List all resources of a specific type
terraform state list | grep aws_instance

# Show the full state of all resources (verbose)
terraform state list | xargs -I{} terraform state show {}

# Plan JSON — find what would be destroyed
terraform plan -out=plan.bin
terraform show -json plan.bin | jq '[.resource_changes[] | select(.change.actions | contains(["delete"]))] | length'

# Get a specific output value as raw string (no quotes)
terraform output -raw vpc_id

# Force-replace a resource (equivalent to taint, which is deprecated)
terraform apply -replace='aws_instance.web'

# Target a single module for faster iteration
terraform plan -target='module.vpc'

# Unlock stuck state
terraform force-unlock $(terraform state pull | jq -r '.serial')  # not reliable
# Better: check DynamoDB for the lock ID
aws dynamodb scan --table-name terraform-state-lock

# Format check in CI
terraform fmt -check -recursive

# Upgrade providers to latest allowed versions
terraform init -upgrade

# Evaluate an expression interactively
echo 'cidrsubnet("10.0.0.0/16", 4, 2)' | terraform console

# Count resources by type
terraform state list | sed 's/\..*//' | sort | uniq -c | sort -rn
```
