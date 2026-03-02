# Using Terraform: Full Reference

## Contents

- [HCL Syntax Fundamentals](#hcl-syntax-fundamentals)
- [Providers](#providers)
- [Resources](#resources)
- [Data Sources](#data-sources)
- [Variables, Outputs, and Locals](#variables-outputs-and-locals)
- [Expressions and Functions](#expressions-and-functions)
- [Meta-Arguments](#meta-arguments)
- [Lifecycle Rules](#lifecycle-rules)
- [Dynamic Blocks](#dynamic-blocks)
- [Modules](#modules)
- [State Management](#state-management)
- [Backends](#backends)
- [Import Block (v1.5+)](#import-block-v15)
- [Moved Block](#moved-block)
- [Check Block (v1.5+)](#check-block-v15)
- [Workspaces](#workspaces)
- [CLI Commands](#cli-commands)
- [Testing Framework (v1.6+)](#testing-framework-v16)
- [Debugging](#debugging)
- [Best Practices and Patterns](#best-practices-and-patterns)
- [OpenTofu Compatibility](#opentofu-compatibility)

---

## HCL Syntax Fundamentals

```hcl
# Block syntax: <type> "<label1>" "<label2>" { ... }
resource "aws_instance" "web" {
  ami           = "ami-12345678"
  instance_type = "t3.micro"
}

# Argument: name = expression
# Nested block (no = sign):
resource "aws_security_group" "example" {
  name = "example"

  ingress {           # nested block
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
  }
}

# Comments
# single line
/* multi
   line */
```

**File conventions:**
- `main.tf` — core resources
- `variables.tf` — input variable declarations
- `outputs.tf` — output value declarations
- `providers.tf` — provider and terraform blocks
- `versions.tf` — `terraform {}` block with `required_providers`
- `locals.tf` — local value declarations
- `backend.tf` — backend configuration (or inline in `terraform {}`)

---

## Providers

```hcl
# versions.tf / providers.tf
terraform {
  required_version = ">= 1.5.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"     # pessimistic constraint: >= 5.0, < 6.0
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "= 2.25.0"   # exact pin
    }
  }
}

# Default provider configuration
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# Provider alias — for multi-region or multi-account
provider "aws" {
  alias  = "us_west"
  region = "us-west-2"
}

resource "aws_instance" "west" {
  provider      = aws.us_west
  ami           = "ami-..."
  instance_type = "t3.micro"
}
```

**Version constraint operators:**
- `= 1.0.0` — exact
- `!= 1.0.0` — exclude
- `> 1.0.0`, `>= 1.0.0`, `< 2.0.0`, `<= 2.0.0`
- `~> 1.0` — allows `1.x`, not `2.0` (pessimistic/tilde)
- `~> 1.0.0` — allows `1.0.x`, not `1.1`

---

## Resources

```hcl
resource "aws_s3_bucket" "example" {
  bucket = "my-unique-bucket-name"
  tags   = local.common_tags
}

# Referencing resource attributes
resource "aws_s3_bucket_versioning" "example" {
  bucket = aws_s3_bucket.example.id   # <type>.<name>.<attribute>

  versioning_configuration {
    status = "Enabled"
  }
}

# Timeouts (provider-defined)
resource "aws_db_instance" "main" {
  # ...
  timeouts {
    create = "60m"
    update = "30m"
    delete = "20m"
  }
}
```

---

## Data Sources

Read-only queries to provider APIs. Do not manage the resource.

```hcl
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]   # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-22.04-amd64-server-*"]
  }
}

data "aws_vpc" "selected" {
  tags = {
    Environment = var.environment
  }
}

# Reference: data.<type>.<name>.<attribute>
resource "aws_instance" "web" {
  ami  = data.aws_ami.ubuntu.id
  subnet_id = data.aws_vpc.selected.id
}

# terraform_remote_state — read outputs from another Terraform state
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "my-terraform-state"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}
# Use: data.terraform_remote_state.network.outputs.vpc_id
```

---

## Variables, Outputs, and Locals

### Input Variables

```hcl
variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Must be dev, staging, or prod."
  }
}

variable "instance_count" {
  type    = number
  default = 1
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "enabled_features" {
  type    = list(string)
  default = []
}

variable "db_password" {
  type      = string
  sensitive = true    # redacted in plan/apply output; still in state
}

# Object type with optional attributes
variable "config" {
  type = object({
    name    = string
    count   = optional(number, 1)
    enabled = optional(bool, true)
  })
}
```

**Supplying variable values (priority order, last wins):**
1. Default in declaration
2. `terraform.tfvars` or `terraform.tfvars.json` (auto-loaded)
3. `*.auto.tfvars` or `*.auto.tfvars.json` (auto-loaded, alphabetical)
4. `-var-file="staging.tfvars"` flag
5. `-var="key=value"` flag
6. `TF_VAR_<name>` environment variable

### Output Values

```hcl
output "instance_ip" {
  description = "Public IP of the web instance"
  value       = aws_instance.web.public_ip
  sensitive   = false   # set true to redact from CLI output
}

output "db_endpoint" {
  value     = aws_db_instance.main.endpoint
  sensitive = true
}
```

### Local Values

```hcl
locals {
  # Computed once, referenced as local.<name>
  environment   = var.environment
  name_prefix   = "${var.namespace}-${var.environment}"
  common_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "terraform"
  }

  # Conditional local
  instance_type = var.environment == "prod" ? "m5.large" : "t3.medium"
}
```

### Variable Types

```hcl
# Primitives
string, number, bool

# Collection types
list(string)
set(string)        # unordered, unique values
map(string)        # string keys, same-type values
map(any)

# Structural types
object({ key = type, ... })
tuple([type, type, ...])

# any — dynamic type inference
```

---

## Expressions and Functions

### References

```hcl
var.name                          # input variable
local.name                        # local value
module.name.output_name           # module output
resource_type.resource_name.attr  # resource attribute
data.source_type.name.attr        # data source attribute
path.module                       # directory of current module
path.root                         # directory of root module
terraform.workspace               # current workspace name
```

### Operators and Conditionals

```hcl
# Conditional (ternary)
count = var.enabled ? 1 : 0
instance_type = var.env == "prod" ? "m5.large" : "t3.micro"

# Null coalescing
name = coalesce(var.name, local.default_name)

# String interpolation
name = "${var.prefix}-${var.environment}-resource"

# Heredoc
user_data = <<-EOT
  #!/bin/bash
  echo "Hello ${var.name}"
EOT
```

### For Expressions

```hcl
# List → list
[for s in var.list : upper(s)]

# Map → list
[for k, v in var.map : "${k}=${v}"]

# List → map
{for item in var.list : item.name => item.value}

# With filter
[for s in var.list : s if s != ""]

# Map → map with filter
{for k, v in var.map : k => v if v != null}
```

### Splat Expressions

```hcl
# Legacy splat (list of resources)
aws_instance.web[*].id

# Full splat (objects/tuples)
var.list[*].name

# Equivalent for expressions:
[for instance in aws_instance.web : instance.id]
```

### Key Functions

```hcl
# String
format("Hello, %s!", var.name)
formatlist("item-%s", var.list)
join(",", var.list)
split(",", var.string)
replace(var.string, "old", "new")
trimspace(var.string)
lower(var.string) / upper(var.string)
substr(var.string, 0, 5)
startswith(var.string, "prefix")
endswith(var.string, "suffix")
regex("pattern", var.string)
regexall("pattern", var.string)
templatefile("path/to/template.tpl", { key = value })

# Numeric
min(a, b) / max(a, b)
abs(var.number)
ceil(var.number) / floor(var.number)
parseint("FF", 16)

# Collection
length(var.list)
contains(var.list, "value")
distinct(var.list)
flatten([list1, list2])
concat(list1, list2)
merge(map1, map2)           # later map wins on key conflict
toset(var.list)
tolist(var.set)
tomap(var.object)
keys(var.map)
values(var.map)
lookup(var.map, "key", "default")
element(var.list, index)
slice(var.list, 0, 3)
sort(var.list)
reverse(var.list)
zipmap(keys_list, values_list)
setsubtract(setA, setB)
setintersection(setA, setB)
setunion(setA, setB)
one(var.list)              # assert list has exactly one element, return it
try(expr, fallback)        # return first expression that doesn't error
can(expr)                  # true if expression evaluates without error

# Filesystem
file("path/to/file")
filebase64("path/to/file")
filemd5("path/to/file")
filesha256("path/to/file")

# Encoding
base64encode(var.string)
base64decode(var.string)
jsonencode(var.object)
jsondecode(var.json_string)
yamlencode(var.object)
yamldecode(var.yaml_string)

# Hash
md5(var.string)
sha256(var.string)
bcrypt(var.string)

# Date/Time
timestamp()           # current time as RFC 3339 string
formatdate("YYYY-MM-DD", timestamp())
timeadd(timestamp(), "24h")

# IP Network
cidrsubnet("10.0.0.0/8", 8, 2)   # → "10.2.0.0/16"
cidrhost("10.0.0.0/8", 5)        # → "10.0.0.5"
cidrnetmask("10.0.0.0/8")        # → "255.0.0.0"
cidrsubnets("10.0.0.0/8", 4, 4, 8)

# Type conversion
tostring(var.number)
tonumber(var.string)
tobool(var.string)
```

---

## Meta-Arguments

Available on all `resource` and `module` blocks.

### `count`

```hcl
resource "aws_instance" "server" {
  count         = var.instance_count
  ami           = "ami-..."
  instance_type = "t3.micro"
  tags = {
    Name = "server-${count.index}"
  }
}

# Reference: aws_instance.server[0].id
# All IDs: aws_instance.server[*].id
```

### `for_each`

Preferred over `count` for named resources. Key changes don't force destroy/recreate of other instances.

```hcl
# Map
resource "aws_iam_user" "users" {
  for_each = toset(var.user_names)
  name     = each.key      # each.key == each.value for sets
}

resource "aws_route53_record" "records" {
  for_each = var.dns_records   # map(object)
  name     = each.key
  type     = each.value.type
  ttl      = each.value.ttl
  records  = each.value.records
}

# Reference: aws_iam_user.users["alice"].arn
# All ARNs: values(aws_iam_user.users)[*].arn
# OR: [for u in aws_iam_user.users : u.arn]
```

### `depends_on`

Explicit dependency when implicit references aren't enough:

```hcl
resource "aws_instance" "app" {
  depends_on = [aws_iam_role_policy.allow_s3]
}
```

### `provider`

```hcl
resource "aws_instance" "west" {
  provider = aws.us_west
}
```

---

## Lifecycle Rules

```hcl
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  lifecycle {
    # Create replacement before destroying old one (zero-downtime)
    create_before_destroy = true

    # Prevent any destroy (plan will error if destroy is needed)
    prevent_destroy = true

    # Ignore external changes to these attributes
    ignore_changes = [
      tags["LastModified"],
      user_data,
    ]

    # Force replacement when this expression changes (v1.2+)
    replace_triggered_by = [
      aws_launch_template.app.latest_version
    ]

    # Precondition — validate before create/update (v1.2+)
    precondition {
      condition     = data.aws_ami.ubuntu.architecture == "x86_64"
      error_message = "AMI must be x86_64 architecture."
    }

    # Postcondition — validate after create/update (v1.2+)
    postcondition {
      condition     = self.public_ip != ""
      error_message = "Instance must have a public IP."
    }
  }
}
```

---

## Dynamic Blocks

Generate repeated nested blocks from a collection:

```hcl
variable "ingress_rules" {
  type = list(object({
    port        = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

resource "aws_security_group" "web" {
  name = "web-sg"

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}
```

The iterator name defaults to the block type (`ingress`). Override with `iterator`:

```hcl
dynamic "ingress" {
  for_each = var.ingress_rules
  iterator = rule
  content {
    from_port = rule.value.port
  }
}
```

---

## Modules

### Calling a Module

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"   # Terraform registry
  version = "~> 5.0"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
}

# Reference module outputs
resource "aws_instance" "app" {
  subnet_id = module.vpc.private_subnets[0]
}
```

### Module Sources

```hcl
# Terraform Registry (public)
source = "hashicorp/consul/aws"
source = "terraform-aws-modules/vpc/aws"
version = "~> 5.0"

# Private registry
source = "app.terraform.io/my-org/vpc/aws"

# GitHub
source = "github.com/org/terraform-aws-vpc"
source = "git::https://github.com/org/repo.git//modules/vpc?ref=v2.0.0"
source = "git::ssh://git@github.com/org/repo.git//modules/vpc?ref=v2.0.0"

# Local path
source = "./modules/vpc"
source = "../shared/modules/network"

# S3 / GCS
source = "s3::https://s3.amazonaws.com/bucket/module.zip"
source = "gcs::https://www.googleapis.com/storage/v1/my-bucket/module.zip"
```

### Writing a Module

Canonical module structure:

```
modules/vpc/
├── main.tf          # resources
├── variables.tf     # input variables
├── outputs.tf       # output values
├── versions.tf      # required_providers (no backend)
├── README.md        # usage docs
└── examples/
    └── complete/
        ├── main.tf
        └── outputs.tf
```

Module `variables.tf`:
```hcl
variable "name" {
  description = "Name prefix for all resources"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
```

Module `outputs.tf`:
```hcl
output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.this.id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = aws_subnet.private[*].id
}
```

---

## State Management

### State Subcommands

```bash
# List all resources in state
terraform state list
terraform state list 'module.vpc.*'

# Show state of a specific resource
terraform state show 'aws_instance.web'
terraform state show 'module.vpc.aws_subnet.private[0]'

# Move resource in state (rename without destroy/recreate)
terraform state mv 'aws_instance.web' 'aws_instance.app'
terraform state mv 'module.old_name' 'module.new_name'

# Remove resource from state (stop managing, do NOT destroy)
terraform state rm 'aws_instance.web'

# Pull current remote state to stdout
terraform state pull > backup.tfstate

# Push local state to remote (dangerous — overwrites)
terraform state push terraform.tfstate

# Force-unlock a stuck lock
terraform force-unlock <LOCK_ID>

# Replace a resource in state with a freshly-created one
terraform apply -replace='aws_instance.web'
```

### State Import

**Legacy CLI (still works):**
```bash
terraform import aws_s3_bucket.example my-bucket-name
terraform import 'aws_instance.servers[0]' i-1234567890abcdef0
```

**Import block (v1.5+, preferred):**
```hcl
import {
  to = aws_s3_bucket.example
  id = "my-bucket-name"
}
```
Run `terraform plan` — shows what config would be generated.
Run `terraform apply` — imports and adds to state.

```bash
# Generate config for imported resource (v1.5+)
terraform plan -generate-config-out=generated.tf
```

---

## Backends

Backends store state remotely and enable locking.

**Never put secrets in backend config.** Use partial configuration + `-backend-config`:

```hcl
# versions.tf — partial config (no secrets)
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
    # role_arn provided via -backend-config or env
  }
}
```

```bash
# Supply secrets at init time
terraform init \
  -backend-config="role_arn=arn:aws:iam::123456789012:role/terraform" \
  -backend-config="backend.hcl"
```

**Common backends:**

```hcl
# S3 (most common for AWS)
backend "s3" {
  bucket         = "my-tf-state"
  key            = "component/terraform.tfstate"
  region         = "us-east-1"
  encrypt        = true
  dynamodb_table = "tf-state-lock"
  use_lockfile   = true        # S3-native locking (v1.10+, no DynamoDB needed)
}

# GCS (Google Cloud)
backend "gcs" {
  bucket = "my-tf-state"
  prefix = "component"
}

# Azure Blob
backend "azurerm" {
  resource_group_name  = "rg-terraform"
  storage_account_name = "tfstate"
  container_name       = "tfstate"
  key                  = "prod.terraform.tfstate"
}

# HCP Terraform / Terraform Cloud
backend "remote" {
  organization = "my-org"
  workspaces {
    name = "my-workspace"
  }
}
# OR (preferred v1.1+):
cloud {
  organization = "my-org"
  workspaces {
    name = "my-workspace"
  }
}

# Local (default, not for teams)
backend "local" {
  path = "relative/path/terraform.tfstate"
}
```

---

## Import Block (v1.5+)

```hcl
import {
  to = aws_instance.web
  id = "i-1234567890abcdef0"
}

# For_each resources
import {
  for_each = { alice = "arn:...:user/alice", bob = "arn:...:user/bob" }
  to       = aws_iam_user.users[each.key]
  id       = each.value
}

resource "aws_instance" "web" {
  # Can leave empty and use -generate-config-out, or fill in manually
  ami           = "ami-..."
  instance_type = "t3.micro"
}
```

```bash
terraform plan -generate-config-out=generated.tf   # generate HCL for imported resources
terraform apply                                     # import into state
```

---

## Moved Block

Refactor resource addresses without destroy/recreate:

```hcl
# Rename a resource
moved {
  from = aws_instance.old_name
  to   = aws_instance.new_name
}

# Move into a module
moved {
  from = aws_s3_bucket.example
  to   = module.storage.aws_s3_bucket.this
}

# Refactor count → for_each
moved {
  from = aws_instance.server[0]
  to   = aws_instance.server["web"]
}
```

Keep `moved` blocks in the configuration until all consumers have run `apply`.
Then they can be deleted (or kept indefinitely as documentation).

---

## Check Block (v1.5+)

Validate infrastructure state post-apply without failing the apply:

```hcl
check "health_check" {
  data "http" "app" {
    url = "https://${aws_lb.app.dns_name}/health"
  }

  assert {
    condition     = data.http.app.status_code == 200
    error_message = "Health check endpoint returned ${data.http.app.status_code}."
  }
}
```

Checks run after apply and emit warnings (not errors) if they fail.

---

## Workspaces

Named isolated state environments within a single backend.

```bash
terraform workspace list          # list workspaces
terraform workspace new staging   # create and switch
terraform workspace select prod   # switch to existing
terraform workspace show          # current workspace name
terraform workspace delete dev    # delete (must not be current)
```

```hcl
# Reference current workspace in config
resource "aws_instance" "web" {
  instance_type = terraform.workspace == "prod" ? "m5.large" : "t3.micro"
  tags = {
    Environment = terraform.workspace
  }
}
```

**Workspace vs directory-per-environment:**
Workspaces share the same code but have separate state. Directory-per-env
(`envs/prod/`, `envs/staging/`) has fully separate configs and state.
Most teams prefer directory-per-env for isolation; workspaces work well for
ephemeral environments (feature branches, PR previews).

---

## CLI Commands

```bash
# ── Initialization ────────────────────────────────────────────────────────
terraform init                       # download providers and modules
terraform init -upgrade              # upgrade providers to latest allowed
terraform init -backend-config=b.hcl # supply backend config file
terraform init -reconfigure          # reinitialize with new backend
terraform init -migrate-state        # migrate state to new backend

# ── Validation and formatting ─────────────────────────────────────────────
terraform validate                   # validate HCL syntax and types
terraform fmt                        # format current directory
terraform fmt -recursive             # format all subdirectories
terraform fmt -check                 # exit non-zero if not formatted (CI)
terraform fmt -diff                  # show diff without changing files

# ── Planning ──────────────────────────────────────────────────────────────
terraform plan                       # show execution plan
terraform plan -out=plan.tfplan      # save plan for later apply
terraform plan -var="key=value"
terraform plan -var-file="prod.tfvars"
terraform plan -target='aws_instance.web'   # plan only specific resource
terraform plan -refresh=false        # skip state refresh (faster, less safe)
terraform plan -destroy              # plan a full destroy
terraform plan -generate-config-out=generated.tf  # generate config for imports

# ── Applying ──────────────────────────────────────────────────────────────
terraform apply                      # plan + prompt to apply
terraform apply plan.tfplan          # apply a saved plan (no prompt)
terraform apply -auto-approve        # skip confirmation (CI only)
terraform apply -target='module.vpc' # apply only specific target
terraform apply -replace='aws_instance.web'  # force replace resource
terraform apply -parallelism=20      # concurrent operations (default 10)

# ── Destroying ────────────────────────────────────────────────────────────
terraform destroy                    # destroy all managed resources
terraform destroy -target='module.app'
terraform destroy -auto-approve      # skip confirmation

# ── State ─────────────────────────────────────────────────────────────────
terraform state list
terraform state show 'resource.name'
terraform state mv 'old' 'new'
terraform state rm 'resource.name'
terraform state pull
terraform state push state.tfstate
terraform force-unlock <LOCK_ID>

# ── Outputs ───────────────────────────────────────────────────────────────
terraform output                     # all outputs
terraform output -json               # JSON format
terraform output instance_ip         # specific output
terraform output -raw instance_ip    # raw value (no quotes)

# ── Other ─────────────────────────────────────────────────────────────────
terraform providers                  # list providers in config
terraform providers lock             # update .terraform.lock.hcl
terraform graph | dot -Tsvg > graph.svg   # visualize dependency graph
terraform version                    # show Terraform version
terraform console                    # interactive HCL expression evaluator
terraform login                      # authenticate to HCP Terraform
```

---

## Testing Framework (v1.6+)

```hcl
# tests/main.tftest.hcl
variables {
  environment = "test"
  instance_type = "t3.micro"
}

provider "aws" {
  region = "us-east-1"
}

run "creates_instance" {
  command = plan   # or apply (creates real resources)

  assert {
    condition     = aws_instance.web.instance_type == "t3.micro"
    error_message = "Wrong instance type in non-prod."
  }

  assert {
    condition     = aws_instance.web.tags["Environment"] == "test"
    error_message = "Environment tag not set correctly."
  }
}

run "prod_gets_larger_instance" {
  variables {
    environment = "prod"
  }

  assert {
    condition     = aws_instance.web.instance_type == "m5.large"
    error_message = "Prod should use m5.large."
  }
}
```

```hcl
# Mock provider (avoids real API calls)
mock_provider "aws" {
  mock_resource "aws_instance" {
    defaults = {
      id         = "i-mock1234567890"
      public_ip  = "1.2.3.4"
      private_ip = "10.0.0.5"
    }
  }
}
```

```bash
terraform test                       # run all *.tftest.hcl files
terraform test -filter=tests/main.tftest.hcl
terraform test -verbose
```

---

## Debugging

```bash
# Log levels: TRACE, DEBUG, INFO, WARN, ERROR
export TF_LOG=DEBUG
export TF_LOG=TRACE
export TF_LOG_PATH=./terraform.log   # write to file instead of stderr

# Per-provider logging (v1.1+)
export TF_LOG_CORE=INFO
export TF_LOG_PROVIDER=DEBUG

# JSON plan output (machine-readable, pipe to jq)
terraform plan -json | jq '.resource_changes[] | select(.change.actions[] | contains("delete"))'

# Interactive REPL for testing expressions
terraform console
> cidrsubnet("10.0.0.0/8", 8, 2)
"10.2.0.0/16"
> [for k, v in { a = 1, b = 2 } : "${k}=${v}"]
["a=1", "b=2"]

# Crash log: if Terraform panics, it writes crash.log to CWD
```

---

## Best Practices and Patterns

### Directory Layout (directory-per-environment)

```
infrastructure/
├── modules/
│   ├── vpc/
│   ├── eks/
│   └── rds/
├── envs/
│   ├── dev/
│   │   ├── main.tf          # calls modules
│   │   ├── variables.tf
│   │   ├── terraform.tfvars # dev values
│   │   └── versions.tf
│   ├── staging/
│   └── prod/
└── shared/
    └── state-backend/       # bootstrap: S3 bucket + DynamoDB table
```

### Secrets Management

```bash
# Never in .tf files. Use:
export TF_VAR_db_password=$(aws secretsmanager get-secret-value ...)
# OR: Vault provider, AWS SSM, SOPS-encrypted tfvars
```

### Pinning and Lock File

```bash
terraform providers lock \
  -platform=linux_amd64 \
  -platform=darwin_amd64 \
  -platform=darwin_arm64
# Commit .terraform.lock.hcl to git
```

### Conditional Resources

```hcl
resource "aws_cloudwatch_log_group" "app" {
  count = var.enable_logging ? 1 : 0
  name  = "/app/${var.name}"
}

# Reference: one(aws_cloudwatch_log_group.app[*].name)
# OR:        try(aws_cloudwatch_log_group.app[0].name, null)
```

### Remote State as Data Source

```hcl
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "my-tf-state"
    key    = "vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

locals {
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
}
```

### Default Tags (AWS)

```hcl
provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "terraform"
      Repository  = "github.com/org/repo"
    }
  }
}
# All resources get these tags automatically; per-resource tags are merged
```

### Avoid Provisioners

Prefer: `user_data`, cloud-init, AWS Systems Manager, Ansible post-provisioning.
Only use provisioners when no other option exists, and use `on_failure = continue`
carefully.

---

## OpenTofu Compatibility

OpenTofu is the CNCF-governed open-source fork of Terraform (forked at v1.5).
It is a drop-in replacement for most use cases:

- Binary: `tofu` instead of `terraform`
- Registry: `registry.opentofu.org` (mirrors Terraform Registry)
- HCL: fully compatible through v1.5; diverging for new features post-fork
- Key OpenTofu additions: provider-level `for_each`, encrypted state, OIDC auth
- Lock file: compatible (`.terraform.lock.hcl`)
- State: fully compatible format

```bash
# Switch: replace terraform with tofu
tofu init
tofu plan
tofu apply
```

When using Atmos: set `command: "tofu"` in `atmos.yaml` under
`components.terraform`.
