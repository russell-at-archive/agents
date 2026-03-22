# Using Atmos: Troubleshooting

## Contents

- [atmos.yaml not found](#atmosyaml-not-found)
- [Stack name not resolving](#stack-name-not-resolving)
- [Wrong variable value after merge](#wrong-variable-value-after-merge)
- [List value is truncated or wrong](#list-value-is-truncated-or-wrong)
- [Component not found in stack](#component-not-found-in-stack)
- [Abstract component deployed accidentally](#abstract-component-deployed-accidentally)
- [_defaults.yaml showing up as a deployable stack](#_defaultsyaml-showing-up-as-a-deployable-stack)
- [Vendor pull fails or pulls wrong version](#vendor-pull-fails-or-pulls-wrong-version)
- [providers_override.tf.json not generated](#providers_overridetfjson-not-generated)
- [backend.tf.json uses wrong key or bucket](#backendtfjson-uses-wrong-key-or-bucket)
- [Terraform plan fails with unexpected provider config](#terraform-plan-fails-with-unexpected-provider-config)
- [describe affected returns everything](#describe-affected-returns-everything)
- [Remote state module returns wrong outputs](#remote-state-module-returns-wrong-outputs)
- [Locals not resolving or crossing import boundaries](#locals-not-resolving-or-crossing-import-boundaries)
- [Template syntax errors in stack YAML](#template-syntax-errors-in-stack-yaml)
- [Sprig and Gomplate function conflicts](#sprig-and-gomplate-function-conflicts)
- [Workflow fails to find steps or file](#workflow-fails-to-find-steps-or-file)
- [Component not appearing in describe affected](#component-not-appearing-in-describe-affected)

---

## atmos.yaml not found

**Symptom:** `Error: atmos.yaml not found` or Atmos uses the wrong config.

**Cause:** `atmos.yaml` was not found by the git-root search, or `base_path`
points to a container path (e.g., `/workspaces/atmos`).

**Fix:**

```bash
# Override base_path for local runs
export ATMOS_BASE_PATH=$(git rev-parse --show-toplevel)
atmos list stacks

# Or pass explicitly
atmos --base-path $(pwd) list stacks
```

Update `atmos.yaml` to use `base_path: "."` or `base_path: !repo-root` for
portable configuration that works in both containers and local dev.

---

## Stack name not resolving

**Symptom:** `atmos terraform plan vpc --stack bhco-co-dev` returns
"stack not found".

**Diagnosis:**

```bash
atmos list stacks                      # see what names Atmos resolves
atmos describe config                  # confirm name_pattern / name_template
```

**Common causes:**

- `name_pattern: "{namespace}-{tenant}-{stage}"` but the stack file sets
  `environment` not `stage` — check which vars are set in the stack's `vars:`.
- The stack file path is excluded by `excluded_paths`.
- The stack file is not matched by `included_paths`.
- A `name_template` exists in `atmos.yaml` and takes precedence over
  `name_pattern` — verify which one is active with `atmos describe config`.

**Fix:** Match the pattern tokens to the `vars:` keys set in the stack file.

---

## Wrong variable value after merge

**Symptom:** Terraform receives a value different from what you set.

**Diagnosis:**

```bash
atmos describe component <component> --stack <stack> --provenance
```

The `--provenance` output shows the exact file and line number where each
value originated.

**Merge order (later wins):**

```
imported files (in declared order)
  → global vars/settings in this file
    → terraform-type vars
      → component-level vars
        → metadata.inherits chain (left-to-right)
          → overrides (highest priority within file)
```

**Common causes:**

- A catalog entry or `_defaults.yaml` file sets a value your stack file
  imports but does not override.
- Import order matters: a later import overrides an earlier one at the same
  key level.
- The component name in the stack differs from the Terraform folder — check
  `metadata.component`.
- An `overrides:` block in a parent file is taking precedence.

---

## List value is truncated or wrong

**Symptom:** A list in `vars` has fewer items than expected, or the base
list is gone after overriding.

**Cause:** Lists are **replaced** by default, not merged. Overriding a list
at any level discards the parent list entirely.

**Fix option 1:** Re-state all required items:

```yaml
# catalog/terraform/eks.yaml
vars:
  enabled_cluster_log_types:
    - api
    - audit

# In the stack — must repeat all items you want to keep
vars:
  enabled_cluster_log_types:
    - api
    - audit
    - scheduler           # adds scheduler without dropping others
```

**Fix option 2:** Enable append strategy (globally or per-file):

```yaml
# atmos.yaml
settings:
  list_merge_strategy: append

# Then in the stack, only specify additions:
vars:
  enabled_cluster_log_types:
    - scheduler           # appended to [api, audit] from catalog
```

---

## Component not found in stack

**Symptom:** `atmos describe component foo --stack bar` shows the component
is not configured.

**Cause:** The catalog entry is not imported by the stack file, or the
component name in the stack does not match the Terraform folder name.

**Fix:**

```yaml
# Add the import to the stack file
import:
  - catalog/terraform/foo    # was missing

# If the component name differs from the folder, set metadata.component:
components:
  terraform:
    my-foo-instance:
      metadata:
        component: foo     # points to components/terraform/foo/
```

---

## Abstract component deployed accidentally

**Symptom:** Atmos refuses to deploy with "component is abstract".

**Cause and intent:** `metadata.type: abstract` is correct — it means the
component is a base definition only. The concrete instance must `inherits`
from it and be `type: real` (or omit `type`, since `real` is the default).

**Fix:**

```yaml
components:
  terraform:
    my-vpc:
      metadata:
        component: vpc
        type: real          # explicitly real, or omit (default)
        inherits:
          - vpc-defaults    # the abstract base
      vars:
        cidr_block: 10.0.0.0/18
```

---

## _defaults.yaml showing up as a deployable stack

**Symptom:** `atmos list stacks` shows `_defaults` entries.

**Cause:** `excluded_paths` in `atmos.yaml` does not exclude the
`_defaults` files.

**Fix in `atmos.yaml`:**

```yaml
stacks:
  excluded_paths:
    - "**/_defaults.yaml"
```

---

## Vendor pull fails or pulls wrong version

**Symptom:** `atmos vendor pull` network error or unexpected component files.

**Diagnosis:**

```bash
atmos vendor pull --dry-run              # preview what would be pulled
atmos vendor pull --component vpc        # isolate one component
```

**Common causes:**

- `version` field uses a branch name (`main`) instead of a tag/SHA.
- `source` URL has a typo or the `?ref={{ .Version }}` template is missing.
- GitHub rate limiting (unauthenticated requests).
- Private repo requires token auth.

**Fix:**

- Use exact semver tags: `version: "1.372.0"`
- For GitHub: set `GITHUB_TOKEN` or `ATMOS_GITHUB_TOKEN`
- For GitLab: set `GITLAB_TOKEN` or `ATMOS_GITLAB_TOKEN`
- Verify the source URL and `?ref={{ .Version }}` template is present

---

## providers_override.tf.json not generated

**Symptom:** Terraform uses the wrong provider config or no provider override.

**Cause:** The `providers:` section is missing from the stack component, or
`auto_generate_backend_file: true` is not set.

**Fix:** Add `providers:` to the component in the stack:

```yaml
components:
  terraform:
    vpc:
      providers:
        aws:
          region: us-east-1
          assume_role:
            role_arn: "arn:aws:iam::123456789012:role/terraform"
```

Then confirm the file is generated:

```bash
atmos terraform plan vpc --stack bhco-co-dev
ls components/terraform/vpc/providers_override.tf.json
```

---

## backend.tf.json uses wrong key or bucket

**Symptom:** State is written to the wrong S3 path.

**Diagnosis:**

```bash
atmos describe component vpc --stack bhco-co-dev
# Check the "backend" section in the output
```

**Common causes:**

- Template in the `key` field references a var not set in the stack context.
- `workspace_key_prefix` not set on the component backend override.
- Global `terraform.backend` not being inherited (check import order).

**Fix:** Ensure the `backend:` section template tokens match available
context variables (`.namespace`, `.tenant`, `.environment`, `.stage`,
`.component`):

```yaml
terraform:
  backend:
    s3:
      key: "{{ .namespace }}/{{ .tenant }}/{{ .environment }}/{{ .stage }}/{{ .component }}/terraform.tfstate"
```

---

## Terraform plan fails with unexpected provider config

**Symptom:** `Error: Invalid provider configuration` or wrong region/account.

**Common causes:**

- `providers_override.tf.json` was committed to git and is stale.
- The `providers:` section in the stack references a wrong role ARN.
- `providers_override.tf.json` is in `.gitignore` but was manually edited.

**Fix:**

```bash
# 1. Delete the stale file
rm components/terraform/vpc/providers_override.tf.json

# 2. Re-run plan — it regenerates the file
atmos terraform plan vpc --stack bhco-co-dev

# 3. Verify providers: section in the stack is correct
atmos describe component vpc --stack bhco-co-dev
# Check the "providers" section

# 4. Confirm the file is in .gitignore
grep providers_override .gitignore
```

---

## describe affected returns everything

**Symptom:** `atmos describe affected --ref main` lists all components as
affected, not just the changed ones.

**Common causes:**

- `atmos.yaml` changed (causes full re-evaluation).
- A shared catalog file or `_defaults.yaml` changed (cascades to all stacks
  that import it — this is correct behavior).
- The comparison ref (`--ref main`) doesn't exist locally.

**Fix:**

```bash
git fetch origin main
atmos describe affected --ref origin/main --format json
```

To understand cascade: if `stacks/orgs/bhco/_defaults.yaml` changed, every
stack that imports it (directly or transitively) is affected. This is
intentional — use `--exclude-locked` to skip components marked
`metadata.locked: true` if you want to suppress known-stable components.

---

## Remote state module returns wrong outputs

**Symptom:** A component reads another component's state but gets empty or
wrong values.

**Common causes:**

- `remote_state_backend` not set in the stack's `terraform:` section.
- The referenced component is in a different stack — requires explicit
  tenant/stage/environment context in the remote-state module call.
- The state backend role does not have read access.

**Fix:** Verify `remote_state_backend_type` and `remote_state_backend` are
set in the stack:

```yaml
terraform:
  remote_state_backend_type: s3
  remote_state_backend:
    s3:
      bucket: "acme-ue1-root-tfstate"
      region: us-east-1
      role_arn: "arn:aws:iam::111111111111:role/tfstate-reader"
```

---

## Locals not resolving or crossing import boundaries

**Symptom:** A local value from one file is `null` or missing when accessed
in another file.

**Cause:** `locals` are **file-scoped**. They never propagate across import
boundaries by design.

**Fix:** Promote the value to `vars:` if it needs to cross file boundaries:

```yaml
# In source file
locals:
  cluster_prefix: "{{ .vars.namespace }}-{{ .vars.environment }}"

vars:
  cluster_prefix: "{{ .locals.cluster_prefix }}"   # promote to var
```

Then the importing file can read it from `.vars.cluster_prefix`.

---

## Template syntax errors in stack YAML

**Symptom:** `Error: template: ...: unexpected "}"` or similar parse errors.

**Common causes:**

- Literal `{{` or `}}` in a string value meant for an external system
  (Helm, ArgoCD, Datadog).
- A template references a variable that doesn't exist in the context.

**Fix for literal braces:**

```yaml
# Use backtick escaping:
message: "App {{`{{ .app.name }}`}} ready"
```

**Fix for missing variables:**

```bash
# Check what variables are available in context:
atmos describe component <comp> --stack <stack>
# All fields in the output are available as template variables
```

**Fix for `.yaml.tmpl` files:** Files with the `.yaml.tmpl` extension are
pre-processed as Go templates, then parsed as YAML. Validate them with:

```bash
# Process template manually to see the YAML output
atmos describe component <comp> --stack <stack> --process-templates true
```

---

## Sprig and Gomplate function conflicts

**Symptom:** `Error: function "env" already defined` or unexpected function
behavior.

**Cause:** Both Sprig and Gomplate define a function with the same name
(e.g., `env`).

**Fix:** Disable one of the conflicting engines in `atmos.yaml`:

```yaml
templates:
  settings:
    sprig:
      enabled: true
    gomplate:
      enabled: false    # disable if you don't need datasource features
```

Or disable only the conflicting function by preferring one engine explicitly.

---

## Workflow fails to find steps or file

**Symptom:** `workflow not found` or `step not found`.

**Common causes:**

- The `--file` flag points to a filename without the `.yaml` extension, or
  uses the full path instead of the base name.
- The workflow name does not match exactly (case-sensitive).
- `--from-step` references a step name that does not exist.

**Fix:**

```bash
# File is stacks/workflows/bootstrap.yaml — use base name without extension
atmos workflow bootstrap-dev -f bootstrap

# List all available workflows to confirm names
atmos describe workflows

# Check step names in the workflow file
# Step names default to "step1", "step2" if not explicitly named
atmos workflow bootstrap-dev -f bootstrap --from-step step2
```

---

## Component not appearing in describe affected

**Symptom:** A component you modified is missing from `describe affected`.

**Common causes:**

- `metadata.locked: true` is set on the component.
- The component is `type: abstract` (abstract components don't appear as
  deployable targets).
- The changed file doesn't match the component's path pattern.

**Check:**

```bash
atmos describe component <comp> --stack <stack>
# Look for "locked: true" or "type: abstract" in metadata

# Re-run without locked exclusion
atmos describe affected --ref origin/main   # locked components appear if not using --exclude-locked
```

---

## Anti-patterns

| Anti-pattern | Problem | Fix |
|---|---|---|
| Editing `backend.tf.json` manually | Overwritten on next run | Edit the `backend:` section in the stack |
| `ref=main` in `vendor.yaml` | Non-reproducible pulls | Pin to exact tag or SHA |
| Credentials in `vars:` | Security risk | Use `role_arn` in `providers:` |
| Giant monolith component | Hard to change, slow plans | Split into focused components |
| No `excluded_paths` for `_defaults` | Defaults appear as stacks | Add `- "**/_defaults.yaml"` |
| Committing auto-generated files | Stale overrides, merge conflicts | Add to `.gitignore` |
| Assuming list merge appends | Silently drops inherited items | Re-state full list or use `list_merge_strategy: append` |
| Using `!terraform.output` in stack YAML | Runs terraform init (slow/fragile) | Use `!terraform.state` instead |
| `locals` in imported catalog expecting cross-file access | `null` values at runtime | Promote to `vars:` if cross-file access is needed |
| Hardcoded container path in `base_path` | Fails in local dev | Use `base_path: !repo-root` or `ATMOS_BASE_PATH` |
