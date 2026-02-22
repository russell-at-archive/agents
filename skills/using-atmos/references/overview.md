# Using Atmos: Full Reference

## Contents

- [Core Concepts](#core-concepts)
- [atmos.yaml Schema](#atmosyaml-schema)
- [Stack YAML Schema](#stack-yaml-schema)
- [Merge and Inheritance Rules](#merge-and-inheritance-rules)
- [Templating](#templating)
- [Key CLI Commands](#key-cli-commands)
- [Vendoring](#vendoring)
- [Workflows](#workflows)
- [Validation](#validation)
- [CI/CD Pattern](#cicd-pattern)
- [Auto-Generated Files](#auto-generated-files)
- [Remote State Between Components](#remote-state-between-components)
- [Best Practices](#best-practices)

---

## Core Concepts

**Stacks** — YAML manifests that declare which components to deploy and with
what configuration. They are environment definitions, not code.

**Components** — Terraform root modules (or Helmfile releases) under
`components/terraform/<name>/`. One component per infrastructure concern.

**Catalog** — `stacks/catalog/` holds reusable default configs for each
component. Stack files import from the catalog and override as needed.

**Mixins** — Small composable YAML files that set a narrow concern (region
vars, account vars). Imported by stack files.

**`_defaults.yaml`** — Convention for org/tenant/stage hierarchy files.
Excluded from stack discovery via `excluded_paths` but imported explicitly.

---

## atmos.yaml Schema

```yaml
base_path: "."                         # repo root; override with ATMOS_BASE_PATH

components:
  terraform:
    base_path: "components/terraform"
    command: terraform                 # or "tofu" for OpenTofu
    apply_auto_approve: false
    deploy_run_init: true
    init_run_reconfigure: true
    auto_generate_backend_file: true   # writes backend.tf.json before each run

stacks:
  base_path: "stacks"
  included_paths:
    - "orgs/**/*"                      # glob patterns for real stack files
  excluded_paths:
    - "**/_defaults.yaml"              # keep defaults out of discovery
  name_pattern: "{namespace}-{tenant}-{stage}"
  # OR Go template:
  # name_template: "{{ .vars.tenant }}-{{ .vars.environment }}-{{ .vars.stage }}"

workflows:
  base_path: "stacks/workflows"

schemas:
  jsonschema:
    base_path: "stacks/schemas/jsonschema"
  opa:
    base_path: "stacks/schemas/opa"

integrations:
  atlantis:
    path: "atlantis.yaml"
```

---

## Stack YAML Schema

```yaml
# ── Imports ──────────────────────────────────────────────────────────────
import:
  - catalog/terraform/vpc             # relative to stacks.base_path
  - mixins/accounts/dev
  - orgs/bhco/co/_defaults
  # Remote (go-getter):
  # - "github.com/org/repo//stacks/catalog?ref=v1.0.0"

# ── Global vars (all components inherit) ─────────────────────────────────
vars:
  namespace: acme
  tenant: plat
  environment: ue2
  stage: dev
  region: us-east-2

# ── File-scoped locals (NOT propagated across imports) ───────────────────
locals:
  prefix: "{{ .locals.namespace }}-{{ .locals.stage }}"

# ── Global env vars ───────────────────────────────────────────────────────
env:
  AWS_PROFILE: acme-dev

# ── Terraform-scoped defaults ─────────────────────────────────────────────
terraform:
  backend_type: s3
  backend:
    s3:
      bucket: "acme-ue1-root-tfstate"
      key: "{{ .namespace }}/{{ .tenant }}/{{ .environment }}/{{ .stage }}/{{ .component }}/terraform.tfstate"
      region: "us-east-1"
      encrypt: true
      dynamodb_table: "acme-ue1-root-tfstate-lock"
  remote_state_backend_type: s3
  remote_state_backend:
    s3:
      bucket: "acme-ue1-root-tfstate"
      region: "us-east-1"

# ── Components ────────────────────────────────────────────────────────────
components:
  terraform:
    vpc:
      metadata:
        component: vpc            # Terraform folder name (if different from instance name)
        type: real                # "abstract" prevents direct deployment
        inherits:
          - vpc-defaults          # left-to-right, later wins
      vars:
        enabled: true
        cidr_block: 10.9.0.0/18
      env:
        AWS_DEFAULT_REGION: us-east-2
      settings:
        depends_on:
          1:
            component: vpc-flow-logs-bucket
        validation:
          check-vpc:
            schema_type: jsonschema
            schema_path: "vpc/validate-vpc.json"
      backend_type: s3
      backend:
        s3:
          workspace_key_prefix: vpc
      providers:
        aws:
          region: us-east-2
          assume_role:
            role_arn: "arn:aws:iam::222222222222:role/acme-plat-dev"
```

---

## Merge and Inheritance Rules

**Merge order (later wins):**

```
imported files (in declared order)
  → global vars/env/settings
    → component-type level (terraform.vars)
      → component level (components.terraform.vpc.vars)
        → metadata.inherits chain (left-to-right)
```

**Maps** are recursively deep-merged.
**Lists** are **replaced**, not appended. To extend an inherited list you
must re-state all items in the overriding file.

**Locals** are file-scoped and never cross import boundaries.

---

## Templating

Go templates with Sprig and Gomplate run throughout stack YAML values.

**Available context variables:**

| Variable | Value |
|---|---|
| `.atmos_component` | Component instance name |
| `.atmos_stack` | Resolved stack name |
| `.workspace` | Terraform workspace |
| `.vars.*` | All merged component vars |
| `.namespace` `.tenant` `.environment` `.stage` | Context shorthand |

**Examples:**

```yaml
vars:
  tags:
    atmos_stack:  "{{ .atmos_stack }}"
    managed_by:   '{{ env "USER" }}'
    workspace:    "{{ .workspace }}"
```

**YAML functions in `atmos.yaml`** (CLI config only, not stack files):

```yaml
base_path: !repo-root        # git repo root
api_key:   !env MY_API_KEY   # inject env var
```

---

## Key CLI Commands

```bash
# ── Terraform operations ──────────────────────────────────────────────────
atmos terraform plan    <component> --stack <stack>
atmos terraform apply   <component> --stack <stack>
atmos terraform deploy  <component> --stack <stack>    # plan + apply
atmos terraform destroy <component> --stack <stack>
atmos terraform apply   <component> --stack <stack> --from-plan
atmos terraform shell   <component> --stack <stack>    # interactive shell with context

# Pass flags to Terraform directly (after --)
atmos terraform plan vpc --stack bhco-co-dev -- -target=aws_vpc.main

# ── Introspection (run before editing to understand current state) ─────────
atmos describe component <component> --stack <stack>
atmos describe component <component> --stack <stack> --provenance
atmos describe stacks
atmos describe stacks --stack <stack> --format json
atmos describe affected --ref main --format json
atmos describe config

# ── Listing ────────────────────────────────────────────────────────────────
atmos list stacks
atmos list stacks -c <component>       # stacks containing a component
atmos list components
atmos list components --stack <stack>

# ── Vendoring ──────────────────────────────────────────────────────────────
atmos vendor pull
atmos vendor pull --component <name>
atmos vendor pull --tags <tag>
atmos vendor pull --dry-run

# ── Workflows ──────────────────────────────────────────────────────────────
atmos workflow <name> -f <workflow-file>
atmos workflow <name> -f <file> --stack <stack>
atmos workflow <name> -f <file> --from-step <step-name>
atmos workflow <name> -f <file> --dry-run

# ── Validation ─────────────────────────────────────────────────────────────
atmos validate stacks
atmos validate component <component> --stack <stack>
```

---

## Vendoring

`vendor.yaml` at repo root declares external sources:

```yaml
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
        - "**/providers.tf"    # always exclude — Atmos manages providers
        - "**/test/**"
      tags:
        - networking

    - component: eks
      source: "oci://registry.example.com/modules/eks:{{ .Version }}"
      version: "2.1.0"
      targets:
        - "components/terraform/eks"
```

Run `atmos vendor pull --dry-run` before pulling to preview changes.
Always commit vendored files. Version strings must be exact tags or SHAs.

---

## Workflows

```yaml
# stacks/workflows/networking.yaml
workflows:
  deploy-networking:
    description: Deploy VPC and dependencies in order
    steps:
      - name: vpc-flow-logs-bucket
        command: terraform apply vpc-flow-logs-bucket -s bhco-co-dev -auto-approve
      - name: vpc
        command: terraform apply vpc -s bhco-co-dev -auto-approve
      - name: notify
        shell: echo "Networking deployed"

  plan-all-vpcs:
    steps:
      - command: terraform plan vpc -s bhco-co-dev
      - command: terraform plan vpc -s bhco-co-prod
```

Resume after a failed step: `atmos workflow deploy-networking -f networking --from-step vpc`

---

## Validation

**JSON Schema** — validates the merged vars of a component:

```yaml
settings:
  validation:
    validate-vpc:
      schema_type: jsonschema
      schema_path: "vpc/validate-vpc.json"
```

**OPA** — enforces policy rules across component configuration:

```yaml
settings:
  validation:
    check-vpc-policy:
      schema_type: opa
      schema_path: "vpc/policy.rego"
      module_paths:
        - "catalog/constants"
      timeout: 10
```

Run all validation: `atmos validate stacks`

---

## CI/CD Pattern

```bash
# 1. Find what changed relative to main
atmos describe affected --ref main --format json
# Output: [{component, stack, affected, file}, ...]

# 2. Plan each affected component (store planfile to S3)
atmos terraform plan vpc --stack bhco-co-dev

# 3. On PR merge, apply from stored planfile
atmos terraform apply vpc --stack bhco-co-dev --from-plan
```

GitHub Actions suite:
- `cloudposse/github-action-atmos-affected-stacks` — detect changed components
- `cloudposse/github-action-atmos-terraform-plan` — plan + PR comment + S3 store
- `cloudposse/github-action-atmos-terraform-apply` — apply from stored planfile
- `cloudposse/github-action-atmos-terraform-drift-detection` — scheduled drift checks

---

## Auto-Generated Files

Add to `.gitignore` — overwritten on every `atmos terraform` run:

```
backend.tf.json
providers_override.tf.json
*.tfvars.json
```

| File | Source |
|---|---|
| `backend.tf.json` | `backend:` + `backend_type:` in stack |
| `providers_override.tf.json` | `providers:` in stack |
| `<stack>.tfvars.json` | `vars:` in component |

---

## Remote State Between Components

Use the CloudPosse Terraform module to read outputs from another component
in the same or a different stack:

```hcl
module "vpc" {
  source    = "cloudposse/stack-config/yaml//modules/remote-state"
  version   = "1.5.0"
  component = "vpc"
  context   = module.this.context
}

resource "aws_eks_cluster" "this" {
  vpc_config {
    subnet_ids = module.vpc.outputs.private_subnet_ids
  }
}
```

Configure `remote_state_backend_type` and `remote_state_backend` in the
stack's `terraform:` section to control which backend is used for reads.

---

## Best Practices

1. Always run `atmos describe component` before plan/apply to verify merged config.
2. Mark catalog base configs `metadata.type: abstract` to prevent direct deployment.
3. Pin all vendored versions to exact tags or SHAs — never `ref=main`.
4. Exclude `providers.tf` from vendor pulls; let Atmos manage providers via stacks.
5. Use `settings.depends_on` to declare explicit component ordering.
6. Use `_defaults.yaml` naming for hierarchy files; add pattern to `excluded_paths`.
7. Never embed credentials; use `role_arn` in the `providers:` or `backend:` sections.
8. Use `atmos describe affected` in CI to scope plans to only changed components.
9. Lists replace on merge — always re-state full list when overriding inherited lists.
10. Use `atmos terraform shell` to debug interactively with all context variables set.
