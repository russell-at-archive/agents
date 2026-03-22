# Using Atmos: Full Reference

## Contents

- [Core Concepts](#core-concepts)
- [atmos.yaml Schema](#atmosyaml-schema)
- [Config Discovery and Environment Variables](#config-discovery-and-environment-variables)
- [Stack YAML Schema](#stack-yaml-schema)
- [Merge and Inheritance Rules](#merge-and-inheritance-rules)
- [locals vs vars](#locals-vs-vars)
- [overrides Section](#overrides-section)
- [Templating](#templating)
- [YAML Functions](#yaml-functions)
- [Key CLI Commands](#key-cli-commands)
- [Vendoring](#vendoring)
- [Workflows](#workflows)
- [Validation](#validation)
- [CI/CD Pattern](#cicd-pattern)
- [Auto-Generated Files](#auto-generated-files)
- [Remote State Between Components](#remote-state-between-components)
- [Helmfile Support](#helmfile-support)
- [Integrations](#integrations)
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

**`locals`** — File-scoped temporary values. Not inherited across imports.
Not passed to Terraform. Useful for intermediate computations.

**`overrides`** — File-scoped highest-priority overrides. Never leak to
other imported files. Useful in multi-team repos to apply values without
polluting imported manifests.

---

## atmos.yaml Schema

```yaml
base_path: "."                         # repo root; override with ATMOS_BASE_PATH
                                       # Use !repo-root for portable config

vendor:
  base_path: "./vendor.yaml"           # path to vendor manifest

components:
  terraform:
    base_path: "components/terraform"
    command: terraform                 # or "tofu" for OpenTofu
    apply_auto_approve: false
    deploy_run_init: true
    init_run_reconfigure: true
    auto_generate_backend_file: true   # writes backend.tf.json before each run
    append_user_agent: "Atmos/1.0"    # sets TF_APPEND_USER_AGENT
    workspaces_enabled: true           # enable Terraform workspaces
    shell:
      prompt: "({atmos_stack}) $ "    # custom shell prompt (Go template)
  helmfile:
    base_path: "components/helmfile"
    use_eks: true
    kubeconfig_path: /dev/shm

stacks:
  base_path: "stacks"
  included_paths:
    - "orgs/**/*"                      # glob patterns for real stack files
  excluded_paths:
    - "**/_defaults.yaml"              # keep defaults out of discovery
  name_pattern: "{namespace}-{tenant}-{stage}"
  # OR Go template (takes precedence over name_pattern):
  # name_template: "{{ .vars.tenant }}-{{ .vars.environment }}-{{ .vars.stage }}"

workflows:
  base_path: "stacks/workflows"

logs:
  file: "/dev/stderr"
  level: Info                          # Trace|Debug|Info|Warning|Error|Fatal

schemas:
  jsonschema:
    base_path: "stacks/schemas/jsonschema"
  opa:
    base_path: "stacks/schemas/opa"
  atmos:
    manifest: "stacks/schemas/atmos/atmos-manifest/1.0/atmos-manifest.json"

templates:
  settings:
    enabled: true
    evaluations: 2                     # multi-pass for templates referencing templates
    sprig:
      enabled: true
    gomplate:
      enabled: true
      timeout: 5
      datasources:
        secrets:
          url: "aws+sm:///path/to/secret"

settings:
  list_merge_strategy: replace         # "replace" (default) or "append"

integrations:
  github:
    gitops:
      terraform-version: "1.9.0"
      artifact-storage:
        region: us-east-1
        bucket: my-atmos-planfiles
        table: atmos-plan-metadata
        role: arn:aws:iam::123456789012:role/atmos-artifact-storage
  atlantis:
    path: "atlantis.yaml"

version:
  check:
    enabled: true
    frequency: daily                   # hourly|daily|weekly|monthly
```

### YAML Functions in `atmos.yaml`

| Function | Purpose |
|----------|---------|
| `!repo-root` | Git repository root path |
| `!cwd` | Current working directory |
| `!env VAR` | Inject environment variable |
| `!exec cmd` | Embed shell command output |
| `!include path` | Merge external YAML file |

---

## Config Discovery and Environment Variables

Atmos searches for `atmos.yaml` in this order (highest wins):

1. `--config` / `ATMOS_CLI_CONFIG_PATH` env var
2. `./atmos.yaml` (current directory)
3. Git repository root (upward walk)
4. Parent directories (upward)
5. `~/.atmos/atmos.yaml`

Fragments in `.atmos.d/` directories are auto-discovered and merged
(shallower first, then alphabetically).

### Key Environment Variables

| Variable | Purpose |
|----------|---------|
| `ATMOS_BASE_PATH` | Overrides `base_path` |
| `ATMOS_CLI_CONFIG_PATH` | Config file location; disables parent dir searching |
| `ATMOS_LOGS_LEVEL` | Logging verbosity (Debug, Info, etc.) |
| `ATMOS_COMPONENTS_TERRAFORM_INIT_RUN_RECONFIGURE` | Bool override |
| `ATMOS_COMPONENTS_TERRAFORM_WORKSPACES_ENABLED` | Bool override |
| `GITHUB_TOKEN` / `ATMOS_GITHUB_TOKEN` | GitHub API auth for vendoring |
| `GITLAB_TOKEN` / `ATMOS_GITLAB_TOKEN` | GitLab auth for vendoring |
| `ATMOS_BITBUCKET_TOKEN` | Bitbucket auth for vendoring |
| `ATMOS_PRO_TOKEN` | Atmos Pro upload endpoint auth |

---

## Stack YAML Schema

### Stack Naming Priority (highest to lowest)

1. `name:` field in the stack manifest (explicit override)
2. `name_template:` in `atmos.yaml` (Go template)
3. `name_pattern:` in `atmos.yaml` (token-based: `{namespace}`, `{tenant}`,
   `{environment}`, `{stage}`, `{region}`)
4. Stack filename (default fallback)

### Full Stack Manifest Structure

```yaml
# Optional: explicit stack name (overrides name_pattern and name_template)
name: "my-explicit-stack-name"

# Imports — resolved relative to stacks.base_path unless prefixed with ./
import:
  - catalog/terraform/vpc             # base_path-relative
  - ./sibling-file                    # file-relative (./ prefix)
  - ../shared/_defaults               # file-relative parent
  - path: "catalog/config.yaml.tmpl"  # object syntax with options
    context:
      flavor: "blue"
    skip_if_missing: false
    skip_templates_processing: false
  # Remote (go-getter):
  # - git::https://github.com/acme/infra.git//stacks/catalog/vpc?ref=v1.2.0

# File-scoped locals (NOT inherited across imports, NOT passed to Terraform)
locals:
  account_id: !aws.account_id
  region: !env AWS_REGION
  cluster_prefix: "{{ .vars.namespace }}-{{ .vars.environment }}"

# Global variables (deep-merged, passed to ALL components in this stack)
vars:
  namespace: acme
  tenant: plat
  environment: ue2
  stage: dev
  region: us-east-2

# Global environment variables set before running components
env:
  AWS_DEFAULT_REGION: us-east-2

# Global settings (integrations config — deep-merged)
settings:
  list_merge_strategy: append         # override for this file
  spacelift:
    workspace_enabled: true
  atlantis:
    config_template: config-1
  depends_on:
    vpc:
      component: vpc
      environment: ue2
      stage: dev
  validation:
    check-vpc:
      schema_type: jsonschema
      schema_path: "vpc/validate-vpc.json"

# Overrides — highest priority within this file, never leak to other files
overrides:
  vars:
    owner: "team-platform"
  env: {}
  settings: {}
  providers: {}

# Terraform-type-level defaults (apply to all terraform components)
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

# Components
components:
  terraform:
    vpc:
      metadata:
        component: vpc            # Terraform folder name (if different from instance name)
        type: real                # "abstract" prevents direct deployment
        inherits:
          - vpc-defaults          # left-to-right, later wins (C3 MRO)
        locked: false             # true = excluded from describe affected
      command: "tofu"             # override terraform executable per-component
      workspace_key_prefix: "{{ .vars.tenant }}-{{ .vars.stage }}"
      vars:
        enabled: true
        cidr_block: 10.9.0.0/18
      env:
        AWS_DEFAULT_REGION: us-east-2
      settings:
        spacelift:
          workspace_enabled: true
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

### Merge Order (later wins)

```
imported files (in declared order)
  → global vars/env/settings in this file
    → terraform-type vars
      → component-level vars
        → metadata.inherits chain (left-to-right)
          → overrides (highest priority within file)
```

**Maps** are recursively deep-merged.
**Lists** are **replaced** by default (not appended). Set
`settings.list_merge_strategy: append` in `atmos.yaml` to change this
globally, or per-file in the `settings:` section.

### Component Inheritance (`metadata.inherits`)

Multiple components can inherit from a shared abstract base:

```yaml
components:
  terraform:
    redis-defaults:
      metadata:
        component: redis
        type: abstract
      vars:
        family: redis7
        cluster_size: 1

    redis/sessions:
      metadata:
        component: redis
        inherits: [redis-defaults]
      vars:
        name: sessions

    redis/cache:
      metadata:
        component: redis
        inherits: [redis-defaults]
      vars:
        name: cache
        cluster_size: 2
```

The `/` in component names (e.g., `redis/sessions`) is a namespace
separator creating unique identity while sharing the same Terraform module.

### What Is/Is Not Inherited

| Section | Inherited |
|---------|-----------|
| `vars` | Yes (deep-merged) |
| `settings` | Yes (deep-merged) |
| `env` | Yes (deep-merged) |
| `backend` | Yes (deep-merged) |
| `remote_state_backend` | Yes (deep-merged) |
| `providers` | Yes (deep-merged) |
| `metadata.component` | Yes |
| `metadata.inherits` | No |
| `metadata.type` | No |

---

## locals vs vars

| Aspect | `locals` | `vars` |
|--------|----------|--------|
| Scope | File-scoped only | Inherited across all imports |
| Purpose | Intermediate computations | Input variables to Terraform |
| Passed to Terraform | No | Yes (as `.tfvars.json`) |
| Cross-file access | Impossible | Propagates through imports |
| Self-referencing | Yes, `{{ .locals.name }}` | No |

```yaml
locals:
  base_name: "{{ .vars.namespace }}-{{ .vars.stage }}"
  cluster_name: "{{ .locals.base_name }}-eks"    # references another local

vars:
  cluster_name: "{{ .locals.cluster_name }}"     # promote local to var
```

Locals support YAML functions (`!env`, `!exec`, `!aws.account_id`, etc.)
and Go templates. They are resolved before template processing in vars.

---

## overrides Section

File-scoped, highest-priority overrides. Values never leak to components
in other imported files — ideal for multi-team setups:

```yaml
overrides:
  vars:
    owner: "team-platform"
    cost_center: "123"
  env:
    CUSTOM_TAG: "overridden"
  settings:
    spacelift:
      autodeploy: false
  providers:
    aws:
      assume_role:
        role_arn: "arn:aws:iam::999999999999:role/override-role"
```

---

## Templating

Go templates with Sprig and Gomplate run throughout stack YAML values.

### Available Context Variables

| Variable | Value |
|---|---|
| `.atmos_component` | Component instance name |
| `.atmos_stack` | Resolved stack name |
| `.atmos_stack_file` | Source stack file path |
| `.workspace` | Terraform workspace |
| `.vars.*` | All merged component vars |
| `.locals.*` | File-scoped locals |
| `.namespace` `.tenant` `.environment` `.stage` | Context shorthand |
| `.component` | Terraform module folder name |

### Example

```yaml
vars:
  tags:
    atmos_stack:    "{{ .atmos_stack }}"
    managed_by:     '{{ env "USER" }}'
    workspace:      "{{ .workspace }}"
    cluster_prefix: "{{ .vars.namespace }}-{{ .vars.environment }}"
```

### Multi-pass Evaluation

`evaluations: 2` in `atmos.yaml` processes templates multiple times,
allowing templates to reference outputs of earlier evaluation passes.

### Escaping Template Syntax

```yaml
# Pass literal {{ }} to external systems (ArgoCD, Datadog, Helm):
message: "App {{`{{ .app.name }}`}} ready"
```

### Template File Auto-detection

Files with `.yaml.tmpl` extension are processed as Go templates before
YAML parsing, and skipped by `atmos validate stacks`.

---

## YAML Functions

YAML functions are native YAML tags processed before Go templates. They
are preferred over Go templates for type safety.

| Function | Syntax | Description |
|----------|--------|-------------|
| `!env` | `!env VAR_NAME` | Read environment variable |
| `!exec` | `!exec command arg1` | Run shell command |
| `!include` | `!include path/to/file.yaml` | Merge external YAML |
| `!repo-root` | `!repo-root` | Git repository root path |
| `!cwd` | `!cwd` | Current working directory |
| `!aws.account_id` | `!aws.account_id` | Current AWS account ID |
| `!aws.region` | `!aws.region` | Current AWS region |
| `!terraform.state` | `!terraform.state <comp> <output>` | Read state directly (fast) |
| `!terraform.output` | `!terraform.output <comp> <stack> <out>` | Run terraform output (slow) |
| `!store` | `!store <store-name> <key>` | External key-value store read |

**Processing order:** YAML functions → locals resolution → Go templates.

**Performance note:** Prefer `!terraform.state` over `!terraform.output`.
The former reads state directly (very fast); the latter runs `terraform init`
and `output` (slow and fragile in CI).

---

## Key CLI Commands

### Terraform Operations

```bash
atmos terraform plan    <component> --stack <stack>
atmos terraform apply   <component> --stack <stack>
atmos terraform deploy  <component> --stack <stack>    # plan + apply -auto-approve
atmos terraform destroy <component> --stack <stack>
atmos terraform init    <component> --stack <stack>
atmos terraform output  <component> --stack <stack> --format json
atmos terraform validate <component> --stack <stack>
atmos terraform clean   <component> --stack <stack>    # remove .terraform and generated files
atmos terraform shell   <component> --stack <stack>    # interactive shell with context set
atmos terraform workspace <component> --stack <stack>  # select/create workspace

# Apply previously generated planfile
atmos terraform apply <component> --stack <stack> --from-plan

# Pass native Terraform flags after --
atmos terraform plan vpc --stack bhco-co-dev -- -target=aws_vpc.main -parallelism=20
```

**terraform output formats:** `json`, `yaml`, `hcl`, `env`, `dotenv`,
`bash`, `csv`, `tsv`, `github`

**terraform clean flags:**

| Flag | Purpose |
|------|---------|
| `--force` / `-f` | Skip confirmation |
| `--skip-lock-file` | Preserve `.terraform.lock.hcl` |
| `--everything` | Also remove state files (DANGEROUS) |

### Bulk File Generation

```bash
# Generate all backend files
atmos terraform generate backends \
  --file-template "backends/{tenant}/{environment}/{component}.tf" \
  --format json

# Generate all varfiles
atmos terraform generate varfiles

# Generate for specific stacks/components only
atmos terraform generate backends --stacks "acme-ue2-dev,acme-ue2-prod" \
  --components "vpc,eks"
```

### Introspection (run before editing to understand current state)

```bash
atmos describe component <component> --stack <stack>
atmos describe component <component> --stack <stack> --provenance   # show value origins
atmos describe stacks
atmos describe stacks --stack <stack> --format json
atmos describe stacks --sections vars,backend,providers             # partial output
atmos describe config
atmos describe affected --ref main --format json
atmos describe affected --ref main --query '[.[] | select(.deleted != true)]'
atmos describe locals --stack <stack>                               # resolved locals
atmos describe workflows                                            # all workflow defs
```

**describe affected output fields:**

| Field | Meaning |
|-------|---------|
| `component` | Component name |
| `stack` | Stack name |
| `affected` | Why: `component`, `stack.vars`, `stack.env`, `stack.settings`, `stack.metadata`, `component.module`, `file`, `folder`, `deleted` |
| `deleted` | `true` if removed (destroy needed) |
| `dependents` | Array of dependent components (with `--include-dependents`) |

### Listing

```bash
atmos list stacks
atmos list stacks -c <component>           # stacks containing a component
atmos list stacks --format table|json|yaml|csv|tsv|tree
atmos list components
atmos list components --stack <stack>
atmos list components --type real|abstract|all
```

### Vendoring

```bash
atmos vendor pull
atmos vendor pull --component <name>
atmos vendor pull --tags <tag>
atmos vendor pull --tags networking,vpc     # sources with either tag
atmos vendor pull --dry-run                 # preview without pulling
```

### Workflows

```bash
atmos workflow <name> -f <workflow-file>
atmos workflow <name> -f <file> --stack <stack>
atmos workflow <name> -f <file> --from-step <step-name>
atmos workflow <name> -f <file> --dry-run
atmos workflow                              # interactive selector (arrow keys, /)
```

### Validation

```bash
atmos validate stacks
atmos validate stacks --schemas-atmos-manifest https://atmos.tools/schemas/atmos/atmos-manifest/1.0/atmos-manifest.json
atmos validate component <component> --stack <stack>
atmos validate component <component> --stack <stack> \
  --schema-path stacks/schemas/jsonschema/vpc.json \
  --schema-type jsonschema
```

### Version Management

```bash
atmos version
atmos version list [--limit 10] [--installed] [--format json]
```

---

## Vendoring

`vendor.yaml` at repo root declares external sources:

```yaml
apiVersion: atmos/v1
kind: AtmosVendorConfig

spec:
  imports:
    - vendor/networking.yaml          # reference other vendor manifests

  sources:
    - component: vpc
      source: "github.com/cloudposse/terraform-aws-components.git//modules/vpc?ref={{ .Version }}"
      version: "1.372.0"
      targets:
        - "components/terraform/vpc"
      included_paths:
        - "**/*.tf"
      excluded_paths:
        - "**/providers.tf"           # always exclude — Atmos manages providers
        - "**/test/**"
        - "**/*.md"
      tags:
        - networking

    - component: eks
      source: "oci://registry.example.com/modules/eks:{{ .Version }}"
      version: "2.1.0"
      targets:
        - "components/terraform/eks"
      tags:
        - kubernetes
```

### Supported Source Schemes

- `github.com/org/repo.git//subpath?ref=v1.0` — GitHub (go-getter)
- `git::https://gitlab.com/org/repo.git//subpath?ref=v1.0` — GitLab
- `oci://registry/image:tag` — OCI registry
- `s3::https://s3.amazonaws.com/bucket/path` — S3
- `gs::https://storage.googleapis.com/bucket/path` — GCS
- Local directory path

Run `atmos vendor pull --dry-run` before pulling to preview changes.
Always commit vendored files. Never edit vendored files — update `version`
in `vendor.yaml` and re-pull.

---

## Workflows

```yaml
# stacks/workflows/networking.yaml
workflows:
  deploy-networking:
    description: Deploy VPC and dependencies in order
    stack: bhco-co-dev                 # optional default stack
    steps:
      - name: vpc-flow-logs-bucket
        command: terraform apply vpc-flow-logs-bucket -s bhco-co-dev -auto-approve
        type: atmos                    # "atmos" (default) or "shell"
        retry:
          max_attempts: 3
          max_elapsed_time: "10m"
          backoff_strategy: exponential  # constant|linear|exponential
          initial_delay: "5s"
          max_delay: "60s"
      - name: vpc
        command: terraform apply vpc -s bhco-co-dev -auto-approve
      - name: notify
        command: echo "Networking deployed"
        type: shell
```

**Stack resolution priority (lowest → highest):**

1. Inline in step command
2. Workflow-level `stack:`
3. Step-level `stack:`
4. CLI `--stack` flag

Resume after a failed step:

```bash
atmos workflow deploy-networking -f networking --from-step vpc
```

Without `--file`, Atmos searches all files in `workflows.base_path`.

---

## Validation

### JSON Schema — validates merged component vars

```yaml
settings:
  validation:
    validate-vpc:
      schema_type: jsonschema
      schema_path: "vpc/validate-vpc.json"
      description: "Validate VPC vars"
```

### OPA — enforces policy rules

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
# Output: [{component, stack, affected, deleted, ...}, ...]

# 2. Plan each affected component (store planfile)
atmos terraform plan vpc --stack bhco-co-dev

# 3. On PR merge, apply from stored planfile
atmos terraform apply vpc --stack bhco-co-dev --from-plan

# 4. Handle deleted components — MUST checkout base branch first
# (the stack config only exists on the base branch for destroyed resources)
atmos describe affected --query '[.[] | select(.deleted == true)]'
# Then on base branch: atmos terraform destroy <comp> -s <stack>
```

### GitHub Actions Suite

- `cloudposse/github-action-setup-atmos` — install Atmos in a workflow
- `cloudposse/github-action-atmos-affected-stacks` — detect changed components
- `cloudposse/github-action-atmos-terraform-plan` — plan + PR comment + S3 store
- `cloudposse/github-action-atmos-terraform-apply` — apply from stored planfile
- `cloudposse/github-action-atmos-terraform-drift-detection` — scheduled drift checks
- `cloudposse/github-action-atmos-terraform-drift-remediation` — IssueOps remediation
- `cloudposse/github-action-atmos-component-updater` — automate vendor updates

### Required Infrastructure for GitOps

```yaml
# atmos.yaml
integrations:
  github:
    gitops:
      terraform-version: "1.9.0"
      artifact-storage:
        region: us-east-1
        bucket: my-atmos-planfiles        # S3 bucket for planfiles
        table: atmos-plan-metadata        # DynamoDB (hash key: id, GSI on pr/createdAt)
        role: arn:aws:iam::123456789012:role/atmos-artifact-storage
```

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

### Stack Configuration

```yaml
terraform:
  remote_state_backend_type: s3
  remote_state_backend:
    s3:
      bucket: "acme-ue1-root-tfstate"
      region: "us-east-1"
      role_arn: "arn:aws:iam::111111111111:role/tfstate-reader"
```

`remote_state_backend` deep-merges with `backend`, so you only need to
override differing fields (e.g., a read-only role ARN).

### Terraform HCL (component code)

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

### Via YAML Functions (stack YAML)

```yaml
vars:
  vpc_id:   !terraform.state vpc .vpc_id           # fast — reads state directly
  vpc_cidr: !terraform.output vpc dev vpc_cidr     # slow — runs terraform output
```

---

## Helmfile Support

### Commands

```bash
atmos helmfile apply    <component> -s <stack>
atmos helmfile sync     <component> -s <stack>
atmos helmfile destroy  <component> -s <stack>
atmos helmfile diff     <component> -s <stack>
atmos helmfile template <component> -s <stack>
atmos helmfile list     <component> -s <stack>
```

### Stack Definition

```yaml
components:
  helmfile:
    nginx-ingress:
      metadata:
        component: nginx-ingress
        type: real
      vars:
        installed: true
        namespace: kube-system
        chart_version: "4.7.1"
      env:
        KUBECONFIG: /dev/shm/kubeconfig
```

---

## Integrations

### Atlantis

```bash
atmos atlantis generate repo-config \
  --config-template config-1 \
  --project-template project-1 \
  --output-path atlantis.yaml
```

### Spacelift

Configure per-component in `settings.spacelift`:

```yaml
settings:
  spacelift:
    workspace_enabled: true
    autodeploy: false
    branch: main
    labels: [managed-by-atmos]
    terraform_workflow_tool: OPEN_TOFU  # or TERRAFORM_FOSS
```

---

## Best Practices

1. Always run `atmos describe component` before plan/apply to verify merged config.
2. Mark catalog base configs `metadata.type: abstract` to prevent direct deployment.
3. Pin all vendored versions to exact tags or SHAs — never `ref=main`.
4. Exclude `providers.tf` from vendor pulls; let Atmos manage providers via stacks.
5. Use `settings.depends_on` to declare explicit component ordering.
6. Use `_defaults.yaml` naming for hierarchy files; add pattern to `excluded_paths`.
7. Never embed credentials; use `role_arn` in `providers:` or `backend:` sections.
8. Use `atmos describe affected` in CI to scope plans to only changed components.
9. Lists replace on merge by default — re-state full list when overriding, or set
   `list_merge_strategy: append`.
10. Use `atmos terraform shell` to debug interactively with all context variables set.
11. Use `locals` for intermediate computations; promote to `vars` only what Terraform needs.
12. Use `overrides` in multi-team repos to apply file-scoped values without polluting imports.
13. Pin remote stack imports with `?ref=` for reproducibility.
14. Use `--provenance` flag on `describe component` to trace exactly where each value came from.
15. Prefer `!terraform.state` over `!terraform.output` in stack YAML — it's 10-100x faster.
