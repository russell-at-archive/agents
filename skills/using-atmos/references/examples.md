# Using Atmos: Examples

## Contents

- [Run a plan for a component](#run-a-plan-for-a-component)
- [Debug unexpected variable values](#debug-unexpected-variable-values)
- [Add a new component to a stack](#add-a-new-component-to-a-stack)
- [Add a new stack for a new environment](#add-a-new-stack-for-a-new-environment)
- [Write a catalog entry](#write-a-catalog-entry)
- [Use component inheritance](#use-component-inheritance)
- [Vendor a component from GitHub](#vendor-a-component-from-github)
- [Write a workflow](#write-a-workflow)
- [CI/CD: scoped plan on PR](#cicd-scoped-plan-on-pr)

---

## Run a plan for a component

```bash
# Identify the stack name from atmos.yaml name_pattern
# name_pattern: "{namespace}-{tenant}-{stage}" → bhco-co-dev

atmos terraform plan eks --stack bhco-co-dev

# Pass Terraform flags after --
atmos terraform plan eks --stack bhco-co-dev -- -target=aws_eks_cluster.this
```

---

## Debug unexpected variable values

Use `atmos describe component` to see the fully merged result before running
Terraform. The `--provenance` flag shows which file each value came from.

```bash
atmos describe component eks --stack bhco-co-dev
atmos describe component eks --stack bhco-co-dev --provenance
```

**What to look for:**
- `vars` section shows exactly what Terraform will receive as variables.
- `backend` shows the generated backend configuration.
- `providers` shows what goes into `providers_override.tf.json`.
- `workspace` shows the Terraform workspace name.
- `component` under `metadata` confirms which folder is being used.

If a var has the wrong value, trace the import chain:
1. Check the stack file (`orgs/.../dev/us-east-1.yaml`)
2. Check the catalog entry (`catalog/terraform/eks.yaml`)
3. Check the `_defaults.yaml` files in the hierarchy

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
      vars:
        enabled: true
        name: redis
        instance_type: cache.t3.micro
        cluster_size: 1
        family: redis7
```

**Step 3:** Import the catalog entry in the stack and override as needed:

```yaml
# stacks/orgs/bhco/co/dev/us-east-1.yaml
import:
  - catalog/terraform/redis    # add this line
  # ... existing imports

components:
  terraform:
    redis:
      vars:
        cluster_size: 2        # dev-specific override
```

**Step 4:** Verify the merged config:

```bash
atmos describe component redis --stack bhco-co-dev
atmos terraform plan redis --stack bhco-co-dev
```

---

## Add a new stack for a new environment

Assume adding a `uat` stage under the `bhco/co` tenant.

**Step 1:** Create the stack file:

```yaml
# stacks/orgs/bhco/co/uat/us-east-1.yaml
import:
  - catalog/terraform/vpc
  - catalog/terraform/eks
  - mixins/accounts/dev          # or create mixins/accounts/uat.yaml
  - orgs/bhco/co/_defaults

vars:
  namespace: bhco
  tenant: co
  environment: uat
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

**Step 2:** Verify it is discovered:

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
        type: abstract          # cannot be deployed without inheriting
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
# In stacks/orgs/bhco/co/dev/us-east-1.yaml
components:
  terraform:
    rds:
      metadata:
        type: real              # override to make deployable
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

    # Two concrete instances inheriting from the abstract base
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

Commit the vendored files. Never edit them directly — update `version` in
`vendor.yaml` and re-pull.

---

## Write a workflow

```yaml
# stacks/workflows/bootstrap.yaml
workflows:
  bootstrap-dev:
    description: Bootstrap dev environment in dependency order
    steps:
      - name: tfstate-backend
        command: terraform apply tfstate-backend -s bhco-co-dev -auto-approve
      - name: vpc
        command: terraform apply vpc -s bhco-co-dev -auto-approve
      - name: eks
        command: terraform apply eks -s bhco-co-dev -auto-approve
      - name: notify
        shell: echo "Dev environment bootstrapped"
```

```bash
atmos workflow bootstrap-dev -f bootstrap
atmos workflow bootstrap-dev -f bootstrap --from-step vpc   # resume after failure
atmos workflow bootstrap-dev -f bootstrap --dry-run         # preview steps
```

---

## CI/CD: scoped plan on PR

```bash
# Find only the components affected by this branch vs. main
atmos describe affected --ref main --format json

# Example output:
# [
#   {"component": "eks", "stack": "bhco-co-dev", "affected": "component"},
#   {"component": "vpc", "stack": "bhco-co-prod", "affected": "stack.vars"}
# ]

# Plan only the affected components
atmos terraform plan eks --stack bhco-co-dev
atmos terraform plan vpc --stack bhco-co-prod
```

`affected` values:
- `component` — files in `components/terraform/<name>/` changed
- `stack.vars` — stack YAML config changed
- `stack.settings` — stack settings changed
