# Using Atmos: Examples

## Contents

- [Run a plan for a component](#run-a-plan-for-a-component)
- [Debug unexpected variable values](#debug-unexpected-variable-values)
- [Add a new component to a stack](#add-a-new-component-to-a-stack)
- [Add a new environment stack](#add-a-new-environment-stack)
- [Write a catalog entry](#write-a-catalog-entry)
- [Use component inheritance](#use-component-inheritance)
- [Use locals for intermediate values](#use-locals-for-intermediate-values)
- [Use overrides for file-scoped priority](#use-overrides-for-file-scoped-priority)
- [Vendor a component from GitHub](#vendor-a-component-from-github)
- [Write a workflow with retry](#write-a-workflow-with-retry)
- [Use YAML functions](#use-yaml-functions)
- [CI/CD: scoped plan on PR](#cicd-scoped-plan-on-pr)
- [Generate backend files for all stacks](#generate-backend-files-for-all-stacks)
- [Debug with atmos terraform shell](#debug-with-atmos-terraform-shell)
- [Use list_merge_strategy append](#use-list_merge_strategy-append)

---

## Run a plan for a component

```bash
# Identify the stack name from atmos.yaml name_pattern
# name_pattern: "{namespace}-{tenant}-{stage}" → bhco-co-dev

atmos terraform plan eks --stack bhco-co-dev

# Pass Terraform flags after --
atmos terraform plan eks --stack bhco-co-dev -- -target=aws_eks_cluster.this

# Use short flag -s instead of --stack
atmos terraform plan eks -s bhco-co-dev
```

---

## Debug unexpected variable values

Use `atmos describe component` to see the fully merged result before running
Terraform. The `--provenance` flag shows which file and line each value came from.

```bash
atmos describe component eks --stack bhco-co-dev
atmos describe component eks --stack bhco-co-dev --provenance
```

**What to look for:**

- `vars` — exactly what Terraform will receive as variables
- `backend` — the generated backend configuration
- `providers` — what goes into `providers_override.tf.json`
- `workspace` — the Terraform workspace name
- `metadata.component` — confirms which folder is being used
- `deps` / `imports` — full import chain used to build this config

If a var has the wrong value, trace the import chain:

1. Check `--provenance` to identify the source file
2. Check the stack file (`orgs/.../dev/us-east-1.yaml`)
3. Check the catalog entry (`catalog/terraform/eks.yaml`)
4. Check the `_defaults.yaml` files in the hierarchy

---

## Add a new component to a stack

**Step 1:** Create the Terraform module folder:

```
components/terraform/redis/
├── main.tf
├── variables.tf
├── outputs.tf
└── versions.tf
```

**Step 2:** Add a catalog entry with defaults:

```yaml
# stacks/catalog/terraform/redis.yaml
components:
  terraform:
    redis:
      metadata:
        type: abstract
      vars:
        enabled: true
        name: redis
        instance_type: cache.t3.micro
        cluster_size: 1
        family: redis7
```

**Step 3:** Import the catalog entry in the stack and make it concrete:

```yaml
# stacks/orgs/bhco/co/dev/us-east-1.yaml
import:
  - catalog/terraform/redis

components:
  terraform:
    redis:
      metadata:
        type: real              # override abstract to make deployable
      vars:
        cluster_size: 2         # dev-specific override
```

**Step 4:** Verify the merged config:

```bash
atmos describe component redis --stack bhco-co-dev
atmos terraform plan redis --stack bhco-co-dev
```

---

## Add a new environment stack

Adding a `uat` stage under the `bhco/co` tenant:

```yaml
# stacks/orgs/bhco/co/uat/us-east-1.yaml
import:
  - catalog/terraform/vpc
  - catalog/terraform/eks
  - mixins/accounts/dev
  - orgs/bhco/co/_defaults

vars:
  namespace: bhco
  tenant: co
  environment: ue2
  region: us-east-1
  stage: uat

components:
  terraform:
    vpc:
      vars:
        cidr_block: 10.160.0.0/18
    eks:
      vars:
        kubernetes_version: "1.33"
```

Verify it is discovered:

```bash
atmos list stacks                    # should show bhco-co-uat
atmos describe component vpc --stack bhco-co-uat
```

---

## Write a catalog entry

Catalog entries set sensible defaults and optionally mark the component
abstract to prevent direct deployment:

```yaml
# stacks/catalog/terraform/rds.yaml
components:
  terraform:
    rds:
      metadata:
        component: rds
        type: abstract
      vars:
        enabled: true
        name: rds
        engine: postgres
        engine_version: "16"
        instance_class: db.t3.medium
        allocated_storage: 20
        multi_az: false
        deletion_protection: true
        backup_retention_period: 7
```

Stack files then make it concrete:

```yaml
# stacks/orgs/bhco/co/dev/us-east-1.yaml
components:
  terraform:
    rds:
      metadata:
        type: real
      vars:
        multi_az: false
        instance_class: db.t3.small
```

---

## Use component inheritance

Multiple instances of the same Terraform module with shared defaults:

```yaml
# stacks/catalog/terraform/redis.yaml
components:
  terraform:
    redis-defaults:
      metadata:
        component: redis
        type: abstract
      vars:
        enabled: true
        family: redis7
        cluster_size: 1

    redis/sessions:
      metadata:
        component: redis
        inherits:
          - redis-defaults
      vars:
        name: sessions
        instance_type: cache.t3.micro

    redis/cache:
      metadata:
        component: redis
        inherits:
          - redis-defaults
      vars:
        name: cache
        instance_type: cache.t3.small
        cluster_size: 2
```

Plan a specific instance:

```bash
atmos terraform plan redis/sessions --stack bhco-co-dev
atmos terraform plan redis/cache --stack bhco-co-dev
```

---

## Use locals for intermediate values

`locals` are file-scoped and never passed to Terraform. Use them to build
intermediate values and then promote what Terraform needs to `vars`:

```yaml
# stacks/catalog/terraform/eks.yaml
locals:
  cluster_prefix: "{{ .vars.namespace }}-{{ .vars.environment }}"
  node_group_name: "{{ .locals.cluster_prefix }}-ng"

components:
  terraform:
    eks:
      vars:
        cluster_name: "{{ .locals.cluster_prefix }}-eks"
        node_group_name: "{{ .locals.node_group_name }}"
        tags:
          cluster: "{{ .locals.cluster_prefix }}"
```

For environment-specific values from AWS:

```yaml
locals:
  account_id: !aws.account_id
  region: !aws.region

components:
  terraform:
    vpc:
      vars:
        account_id: "{{ .locals.account_id }}"
        region: "{{ .locals.region }}"
```

---

## Use overrides for file-scoped priority

`overrides` apply at the highest priority within a file and never leak to
other imported files. Useful in multi-team repos:

```yaml
# stacks/orgs/bhco/co/dev/us-east-1.yaml
import:
  - catalog/terraform/vpc
  - catalog/terraform/eks

# Shared overrides — apply to ALL components in this file
overrides:
  vars:
    owner: "team-platform"
    cost_center: "cc-1234"
  providers:
    aws:
      assume_role:
        role_arn: "arn:aws:iam::111111111111:role/dev-deploy"

components:
  terraform:
    vpc:
      vars:
        cidr_block: 10.0.0.0/16
    eks:
      vars:
        kubernetes_version: "1.33"
```

Both `vpc` and `eks` inherit `owner`, `cost_center`, and the provider role
from `overrides`, without polluting the catalog entries.

---

## Vendor a component from GitHub

```yaml
# vendor.yaml
apiVersion: atmos/v1
kind: AtmosVendorConfig
spec:
  sources:
    - component: vpc
      source: "github.com/cloudposse/terraform-aws-components.git//modules/vpc?ref={{ .Version }}"
      version: "1.372.0"
      targets:
        - "components/terraform/vpc"
      excluded_paths:
        - "**/providers.tf"     # Atmos generates providers_override.tf.json
        - "**/test/**"
        - "**/*.md"
      tags:
        - networking
```

```bash
atmos vendor pull --dry-run              # preview
atmos vendor pull --component vpc        # pull just vpc
atmos vendor pull --tags networking      # pull all networking-tagged components
atmos vendor pull                        # pull everything
```

Commit the vendored files. To upgrade: change `version` in `vendor.yaml`
and re-run `atmos vendor pull --component vpc`.

---

## Write a workflow with retry

```yaml
# stacks/workflows/bootstrap.yaml
workflows:
  bootstrap-dev:
    description: Bootstrap dev environment in dependency order
    steps:
      - name: tfstate-backend
        command: terraform apply tfstate-backend -s bhco-co-dev -auto-approve
        retry:
          max_attempts: 3
          backoff_strategy: exponential
          initial_delay: "5s"
          max_delay: "60s"
      - name: vpc
        command: terraform apply vpc -s bhco-co-dev -auto-approve
      - name: eks
        command: terraform apply eks -s bhco-co-dev -auto-approve
      - name: notify
        command: echo "Dev bootstrapped"
        type: shell
```

```bash
atmos workflow bootstrap-dev -f bootstrap
atmos workflow bootstrap-dev -f bootstrap --from-step vpc   # resume after failure
atmos workflow bootstrap-dev -f bootstrap --dry-run         # preview steps
```

When a step fails, Atmos prints the exact `--from-step` command to resume.

---

## Use YAML functions

YAML functions are processed before Go templates and are preferred for
type-safe dynamic values:

```yaml
# Read from environment
vars:
  account_id: !env AWS_ACCOUNT_ID
  region: !env AWS_DEFAULT_REGION

# Read current AWS context (no env var needed)
locals:
  account_id: !aws.account_id
  aws_region: !aws.region

# Fast state read (no terraform init required)
vars:
  vpc_id: !terraform.state vpc .vpc_id
  subnet_ids: !terraform.state vpc .private_subnet_ids

# Include another YAML file
# (useful for sharing common settings blocks)
settings: !include stacks/catalog/common-settings.yaml

# Run a shell command to get a value
locals:
  git_sha: !exec git rev-parse --short HEAD
```

---

## CI/CD: scoped plan on PR

```bash
# Find only the components affected by this branch vs. main
git fetch origin main
atmos describe affected --ref origin/main --format json

# Example output:
# [
#   {"component": "eks", "stack": "bhco-co-dev", "affected": "component"},
#   {"component": "vpc", "stack": "bhco-co-prod", "affected": "stack.vars"},
#   {"component": "old-svc", "stack": "bhco-co-dev", "affected": "deleted", "deleted": true}
# ]

# Plan only the non-deleted affected components
atmos terraform plan eks --stack bhco-co-dev
atmos terraform plan vpc --stack bhco-co-prod

# Deleted components need destroy — MUST be on base branch (stack config exists there)
git checkout main
atmos terraform destroy old-svc --stack bhco-co-dev
```

Filter with YQ expressions:

```bash
# Only non-deleted terraform components
atmos describe affected --ref origin/main \
  --query '[.[] | select(.deleted != true and .component_type == "terraform")]'
```

`affected` field values:

| Value | Meaning |
|-------|---------|
| `component` | Files in `components/terraform/<name>/` changed |
| `stack.vars` | Stack YAML config changed |
| `stack.env` | Stack env section changed |
| `stack.settings` | Stack settings changed |
| `stack.metadata` | Stack metadata changed |
| `component.module` | Dependency module changed |
| `deleted` | Component removed (destroy needed) |

---

## Generate backend files for all stacks

Useful for Atlantis, Spacelift, or scripts that need pre-generated files:

```bash
# Generate all backend files with a path template
atmos terraform generate backends \
  --file-template "backends/{tenant}/{environment}/{component}.tf.json" \
  --format json

# Generate varfiles for all components in all stacks
atmos terraform generate varfiles

# Scope to specific stacks
atmos terraform generate backends \
  --stacks "bhco-co-dev,bhco-co-prod" \
  --components "vpc,eks"
```

---

## Debug with atmos terraform shell

`atmos terraform shell` drops you into an interactive shell with all
context variables and generated files in place — ideal for running raw
Terraform commands or debugging:

```bash
atmos terraform shell vpc --stack bhco-co-dev
# Now inside the shell, with backend.tf.json and *.tfvars.json generated:
terraform plan -var-file=bhco-co-dev.tfvars.json
terraform state list
terraform console
exit
```

The shell prompt shows the component and stack name. The `ATMOS_SHLVL`
variable is set so nested atmos calls are detected.

---

## Use list_merge_strategy append

By default, lists are **replaced** during deep merge, not appended. If you
want to extend inherited lists without restating all items, enable append:

```yaml
# atmos.yaml — global setting
settings:
  list_merge_strategy: append
```

Or per-stack in the `settings:` section:

```yaml
# A specific stack file
settings:
  list_merge_strategy: append

components:
  terraform:
    eks:
      vars:
        enabled_cluster_log_types:
          - scheduler   # this APPENDS to the catalog's [api, audit] rather than replacing
```

Without `append` strategy, you must re-state the full list:

```yaml
vars:
  enabled_cluster_log_types:
    - api
    - audit
    - scheduler    # all three items — replace semantics
```
