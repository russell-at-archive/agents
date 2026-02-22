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
- [providers_override.tf.json not generated](#providers_overrideтfjson-not-generated)
- [backend.tf.json uses wrong key or bucket](#backendтfjson-uses-wrong-key-or-bucket)
- [Terraform plan fails with unexpected provider config](#terraform-plan-fails-with-unexpected-provider-config)
- [atmos describe affected returns everything](#atmos-describe-affected-returns-everything)
- [Remote state module returns wrong outputs](#remote-state-module-returns-wrong-outputs)

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
portable configuration.

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

**Fix:** Match the pattern tokens to the `vars:` keys set in the stack file.

---

## Wrong variable value after merge

**Symptom:** Terraform receives a value different from what you set.

**Diagnosis:**

```bash
atmos describe component <component> --stack <stack> --provenance
```

**Merge order (later wins):**
imported files → global vars → component-type vars → component vars → inherits chain

**Common causes:**
- A catalog entry or `_defaults.yaml` file sets a value that your stack
  file imports but does not override.
- Import order matters: a later import overrides an earlier one at the same
  key level.
- The component name in the stack differs from the Terraform folder — check
  `metadata.component`.

---

## List value is truncated or wrong

**Symptom:** A list in `vars` has fewer items than expected, or the base
list is gone after overriding.

**Cause:** Lists are **replaced**, not merged. Overriding a list at any level
discards the parent list entirely.

**Fix:** Re-state all required items in the overriding file:

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
    - scheduler           # adds scheduler without dropping the others
```

There is no "append" operator. Always state the complete desired list.

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
component is a base definition only, not a deployable unit. The concrete
instance must `inherits` from it and set `type: real` (or omit `type`).

**Fix:**

```yaml
components:
  terraform:
    my-vpc:
      metadata:
        component: vpc
        type: real          # explicitly real, or omit (default is real)
        inherits:
          - vpc-defaults    # the abstract base
      vars:
        cidr_block: 10.0.0.0/18
```

---

## _defaults.yaml showing up as a deployable stack

**Symptom:** `atmos list stacks` shows `_defaults` entries.

**Cause:** `excluded_paths` in `atmos.yaml` does not exclude the `_defaults`
files.

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
- GitHub rate limiting (use a token or authenticated go-getter URL).

**Fix:**
- Use exact semver tags: `version: "1.372.0"`
- Verify the source URL is correct by testing with `curl` or browser
- For private repos, ensure `GITHUB_TOKEN` or SSH key is configured

---

## providers_override.tf.json not generated

**Symptom:** Terraform uses the wrong provider config or no provider override.

**Cause:** The `providers:` section is missing from the stack component, or
`auto_generate_backend_file: true` is not set for `providers_override`.

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
`.component`).

---

## Terraform plan fails with unexpected provider config

**Symptom:** `Error: Invalid provider configuration` or wrong region/account.

**Common causes:**
- `providers_override.tf.json` was committed to git and is stale.
- The `providers:` section in the stack references a wrong role ARN.
- `providers_override.tf.json` is in `.gitignore` but was manually edited.

**Fix:**
1. Delete `providers_override.tf.json` from the component folder.
2. Re-run `atmos terraform plan` — it regenerates the file.
3. Verify `providers:` section in the stack is correct.
4. Confirm `providers_override.tf.json` is in `.gitignore`.

---

## atmos describe affected returns everything

**Symptom:** `atmos describe affected --ref main` lists all components as
affected, not just the changed ones.

**Common causes:**
- `atmos.yaml` changed (causes full re-evaluation).
- A shared catalog file or `_defaults.yaml` changed (cascades to all stacks
  that import it).
- The comparison ref (`--ref main`) doesn't exist locally.

**Fix:**

```bash
git fetch origin main
atmos describe affected --ref origin/main --format json
```

To understand the cascade: if `stacks/orgs/bhco/_defaults.yaml` changed,
every stack that imports it (directly or transitively) is affected.

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

## Anti-patterns

| Anti-pattern | Problem | Fix |
|---|---|---|
| Editing `backend.tf.json` manually | Overwritten on next run | Edit the `backend:` section in the stack |
| `ref=main` in `vendor.yaml` | Non-reproducible pulls | Pin to exact tag or SHA |
| Credentials in `vars:` | Security risk | Use `role_arn` in `providers:` |
| Giant monolith component | Hard to change, slow plans | Split into focused components |
| No `excluded_paths` for `_defaults` | Defaults appear as stacks | Add `- "**/_defaults.yaml"` |
| Committing auto-generated files | Stale overrides, merge conflicts | Add to `.gitignore` |
| Assuming list merge appends | Silently drops inherited items | Always re-state full list |
