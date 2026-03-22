# Using Terraform: Troubleshooting

## Contents

- [Plan shows unexpected destroy](#plan-shows-unexpected-destroy)
- [Error acquiring the state lock](#error-acquiring-the-state-lock)
- [Provider authentication errors](#provider-authentication-errors)
- [Cycle error in dependency graph](#cycle-error-in-dependency-graph)
- [for_each key change destroys and recreates](#for_each-key-change-destroys-and-recreates)
- [count vs for_each causes index drift](#count-vs-for_each-causes-index-drift)
- [Sensitive value in output not redacted](#sensitive-value-in-output-not-redacted)
- [terraform init fails on module source](#terraform-init-fails-on-module-source)
- [Provider version conflict](#provider-version-conflict)
- [State and real infrastructure out of sync (drift)](#state-and-real-infrastructure-out-of-sync-drift)
- [Error: Resource already exists](#error-resource-already-exists)
- [Terraform plan is very slow](#terraform-plan-is-very-slow)
- [for_each on a computed value](#for_each-on-a-computed-value)
- [Cannot destroy resource with prevent_destroy](#cannot-destroy-resource-with-prevent_destroy)
- [terraform.tfstate committed to git](#terraformtfstate-committed-to-git)
- [ignore_changes not working as expected](#ignore_changes-not-working-as-expected)
- [Module outputs depend on resources not yet created](#module-outputs-depend-on-resources-not-yet-created)
- [Anti-patterns reference](#anti-patterns-reference)

---

## Plan shows unexpected destroy

**Symptom:** `terraform plan` shows a resource will be destroyed/replaced
that you didn't intend to change.

**Common causes and fixes:**

**1. `for_each` key changed.**
Renaming a key destroys the old resource and creates a new one.
Fix: use a `moved` block to redirect the old address to the new one.
```hcl
moved {
  from = aws_instance.servers["old-key"]
  to   = aws_instance.servers["new-key"]
}
```

**2. Resource renamed in code.**
Fix: add a `moved` block before applying.
```hcl
moved {
  from = aws_security_group.web
  to   = aws_security_group.app
}
```

**3. Provider upgrade changed a default value.**
A new provider version may add required attributes or change defaults.
Fix: pin provider version with `= X.Y.Z` until you've reviewed the change.

**4. `create_before_destroy = false` on a resource with immutable attributes.**
Changing an immutable attribute (e.g., `availability_zone`) requires destroy.
Fix: add `create_before_destroy = true` in lifecycle, or use a `moved` pattern.

**5. A module was refactored without `moved` blocks.**
Moving a resource into or out of a module changes its state address.
Fix: add `moved` blocks in the parent configuration.

---

## Error acquiring the state lock

**Symptom:**
```
Error: Error locking state: Error acquiring the state lock
Lock Info:
  ID: abc-123-def
  Path: s3://bucket/key
  Who: user@host
  Created: 2024-01-15 ...
```

**Cause:** Another Terraform process holds the lock, or a previous run crashed
without releasing it.

**Fix:**
```bash
# Verify no other terraform process is actually running
ps aux | grep terraform

# If safe to unlock (no other process):
terraform force-unlock abc-123-def

# For DynamoDB-backed S3 state: check the lock table
aws dynamodb scan --table-name terraform-state-lock \
  --query 'Items[?LockID.S != `terraform-state-lock`]'
```

**Never** force-unlock while another `terraform apply` is genuinely running —
you risk state corruption.

---

## Provider authentication errors

**Symptom:**
```
Error: No valid credential sources found
Error: error configuring Terraform AWS Provider: no valid credential sources
```

**AWS fixes:**
```bash
# Check current identity
aws sts get-caller-identity

# Set profile
export AWS_PROFILE=my-profile

# Set role (assume role)
export AWS_ROLE_ARN=arn:aws:iam::123456789012:role/terraform

# For CI/CD: use instance role, OIDC, or explicit keys
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
```

**Google Cloud fixes:**
```bash
gcloud auth application-default login
export GOOGLE_CREDENTIALS=$(cat service-account-key.json)
```

**Azure fixes:**
```bash
az login
export ARM_SUBSCRIPTION_ID=...
export ARM_TENANT_ID=...
export ARM_CLIENT_ID=...
export ARM_CLIENT_SECRET=...
```

---

## Cycle error in dependency graph

**Symptom:**
```
Error: Cycle: aws_security_group.a, aws_security_group.b
```

**Cause:** Resource A references resource B which references resource A,
creating an infinite dependency loop.

**Common case: circular security group rules.**
Fix: separate the rules from the groups using `aws_security_group_rule`
resources instead of inline `ingress`/`egress` blocks.

```hcl
# Instead of inline rules that reference each other:
resource "aws_security_group" "app" {
  name = "app"
  # no ingress/egress blocks here
}

resource "aws_security_group" "db" {
  name = "db"
}

resource "aws_security_group_rule" "app_to_db" {
  type                     = "egress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.app.id
  source_security_group_id = aws_security_group.db.id
}

resource "aws_security_group_rule" "db_from_app" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db.id
  source_security_group_id = aws_security_group.app.id
}
```

---

## for_each key change destroys and recreates

**Symptom:** Renaming a key in a `for_each` map causes destroy + create
instead of an in-place update.

**Cause:** Terraform identifies resources by their address, which includes
the `for_each` key. Changing the key = changing the address = new resource.

**Fix:** Use `moved` blocks to map old keys to new keys:
```hcl
moved {
  from = aws_iam_user.users["old_name"]
  to   = aws_iam_user.users["new_name"]
}
```

**Alternative:** Use stable identifiers as keys (UUIDs, account IDs) rather
than human-readable names that might change.

---

## count vs for_each causes index drift

**Symptom:** Removing an item from the middle of a `count`-based list
destroys items at indexes above the removed item and recreates them.

**Cause:** `count` uses integer indexes. Removing index 1 from a 3-item list
causes what was [2] to shift to [1], triggering a destroy+create.

**Fix:** Migrate to `for_each` with stable keys:
```hcl
# Before (fragile):
resource "aws_instance" "server" {
  count = length(var.server_names)
  # ...
}

# After (stable):
resource "aws_instance" "server" {
  for_each = toset(var.server_names)
  # ...
}
```

Use `moved` blocks to migrate existing count resources to for_each:
```hcl
moved {
  from = aws_instance.server[0]
  to   = aws_instance.server["web-01"]
}
moved {
  from = aws_instance.server[1]
  to   = aws_instance.server["web-02"]
}
```

---

## Sensitive value in output not redacted

**Symptom:** A sensitive value (password, key) appears in plain text in
`terraform output` or plan output.

**Fix:** Mark the output `sensitive = true`:
```hcl
output "db_password" {
  value     = aws_db_instance.main.password
  sensitive = true
}
```

**Important:** `sensitive = true` only redacts CLI display. The value is still
stored in plain text in `terraform.tfstate`. Use encrypted backends and restrict
state file access via IAM.

---

## terraform init fails on module source

**Symptom:**
```
Error: Failed to download module
Could not retrieve module from source
```

**Common causes:**

**1. Git ref doesn't exist:**
```hcl
# Wrong ref:
source = "git::https://github.com/org/repo.git//modules/vpc?ref=v99.0.0"
# Fix: check available tags/branches in the remote repo
```

**2. SSH key not available:**
```bash
# Test SSH access:
ssh -T git@github.com
# Or use HTTPS instead of SSH in the source URL
```

**3. Wrong subpath (double-slash `//` separates repo from subpath):**
```hcl
source = "github.com/org/repo//modules/vpc?ref=v1.0.0"
#                             ^^--- double slash required
```

**4. Private registry needs auth:**
```bash
terraform login registry.terraform.io
# or for private:
terraform login app.terraform.io
```

---

## Provider version conflict

**Symptom:**
```
Error: Failed to query available provider packages
Could not retrieve the list of available versions for provider hashicorp/aws
```
Or: `Required provider version X not available`

**Fix:**
```bash
# See what versions are required and installed
terraform providers

# Update lock file to match new constraints
terraform init -upgrade

# If a module requires an incompatible version, pin your root constraint
# to the intersection of all requirements
```

**Lock file mismatch (CI platform differs from dev):**
```bash
# Regenerate lock file for all platforms
terraform providers lock \
  -platform=linux_amd64 \
  -platform=linux_arm64 \
  -platform=darwin_amd64 \
  -platform=darwin_arm64
# Commit .terraform.lock.hcl
```

---

## State and real infrastructure out of sync (drift)

**Symptom:** A resource exists in the cloud but Terraform doesn't know about
it (missing from state), or state has a resource that was deleted manually.

**Resource exists in cloud, missing from state:**
```bash
# Import it
terraform import aws_s3_bucket.existing my-bucket-name
# Or use import block (v1.5+)
```

**Resource in state was manually deleted:**
```bash
# Remove from state (Terraform will recreate it on next apply)
terraform state rm 'aws_instance.web'
# OR: run terraform apply and Terraform will recreate it
```

**Detect drift:**
```bash
terraform plan -refresh-only   # shows what changed outside Terraform
terraform apply -refresh-only  # update state to match reality (no infra changes)
```

---

## Error: Resource already exists

**Symptom:** `terraform apply` fails because the resource being created
already exists in the cloud provider.

**Cause:** The resource was created manually or by a previous Terraform run
that crashed before updating state.

**Fix:**
```bash
# Import the existing resource into state
terraform import aws_s3_bucket.example my-bucket-name
# Then re-run plan — should show no changes if config matches reality
```

---

## Terraform plan is very slow

**Causes and fixes:**

**1. Too many API calls (large state, many data sources):**
```bash
# Skip refresh for resources that haven't changed
terraform plan -refresh=false

# Target a specific component
terraform plan -target='module.app'
```

**2. Default parallelism is 10 — increase for large states:**
```bash
terraform apply -parallelism=20
```

**3. Many data sources refreshing on every plan:**
Replace frequently-called data sources with variables or locals where
the values are known and stable. Cache slow lookups in outputs or SSM.

---

## for_each on a computed value

**Symptom:**
```
Error: Invalid for_each argument
The "for_each" value depends on resource attributes that cannot be determined
until apply, so Terraform cannot predict how many instances will be created.
```

**Cause:** `for_each` must be known at plan time. A value computed during
apply (e.g., a resource ID) cannot be used as a `for_each` key.

**Fixes:**

**1. Use a known value as the key (not the computed one):**
```hcl
# Wrong: using computed ID as key
for_each = { for s in aws_subnet.private : s.id => s }

# Right: use a known value (e.g., the AZ name) as key
for_each = { for az in var.availability_zones : az => az }
```

**2. Use `count` instead (accepts computed values):**
```hcl
count = length(aws_subnet.private)
```

**3. Use `depends_on` to defer:** Not a complete fix — the limitation is
fundamental to the plan phase.

---

## Cannot destroy resource with prevent_destroy

**Symptom:**
```
Error: Instance cannot be destroyed
Resource aws_db_instance.main has lifecycle.prevent_destroy set
```

**Cause:** `prevent_destroy = true` is a safety guard. Terraform refuses to
generate a destroy plan for this resource.

**Fix (intentional destroy):**
1. Remove `prevent_destroy = true` from the lifecycle block (or set `false`)
2. Commit the change
3. Run `terraform apply` (this first apply changes only the lifecycle setting)
4. Run `terraform destroy -target='aws_db_instance.main'`

Never skip this process. The protection exists to prevent accidental data loss.

---

## terraform.tfstate committed to git

**Symptom:** `terraform.tfstate` file found in git history. May contain
secrets, resource IDs, and sensitive attributes in plain text.

**Immediate actions:**
```bash
# Add to .gitignore NOW
echo "*.tfstate" >> .gitignore
echo "*.tfstate.backup" >> .gitignore
echo ".terraform/" >> .gitignore

# Remove from git tracking (file stays on disk)
git rm --cached terraform.tfstate
git commit -m "stop tracking terraform state"
```

**Rotate any secrets that were in the state file.** State contains attribute
values for all managed resources, including passwords, private keys, and
access tokens set during resource creation.

**Migrate to remote state:**
```hcl
terraform {
  backend "s3" {
    bucket = "my-tf-state"
    key    = "myapp/terraform.tfstate"
    region = "us-east-1"
  }
}
```

```bash
terraform init -migrate-state   # moves local state to remote backend
```

---

## ignore_changes not working as expected

**Symptom:** Terraform still shows changes for an attribute listed in
`ignore_changes`.

**Common causes:**

**1. Wrong attribute path** — must match the exact schema path:
```hcl
# Wrong (nested block, not attribute):
ignore_changes = [tags]

# Right (for AWS resources, tags is a map argument):
ignore_changes = [tags, tags_all]
```

**2. `ignore_changes = all` — too broad** — ignores all attribute changes
including ones that matter. Use specific attribute names.

**3. The change is a forced replacement** (e.g., changing an immutable
attribute). `ignore_changes` prevents plan from detecting changes in state vs
config, but if the attribute appears in the plan as a replacement trigger,
it will still force replacement.

---

## Module outputs depend on resources not yet created

**Symptom:** A module output references a resource that doesn't exist at plan
time, causing a "known after apply" value to propagate unexpectedly.

**Fix options:**

**1. Pass the value as a module input instead of reading it from the module:**
```hcl
module "app" {
  vpc_id = module.vpc.vpc_id   # pass output directly as input
}
```

**2. Use `depends_on` at the module level** (coarse — delays all of the
module's operations):
```hcl
module "app" {
  depends_on = [module.vpc]
}
```

**3. Restructure to avoid the circular dependency.**

---

## Anti-patterns reference

| Anti-pattern | Problem | Fix |
|---|---|---|
| `terraform.tfstate` in git | Exposes secrets; merge conflicts | Use remote backend; add to `.gitignore` |
| No provider version constraints | Random upgrades break config | Pin with `~>` or `=` in `required_providers` |
| Credentials in `.tf` files | Secret leak to git | Use env vars, Vault, or IAM roles |
| `count` for named resources | Index shift on deletion destroys others | Use `for_each` with stable string keys |
| Hardcoded account IDs / region | Non-portable, error-prone | Use `data.aws_caller_identity` and `data.aws_region` |
| `depends_on` everywhere | Hides real dependency structure, serializes | Use resource references; `depends_on` only when needed |
| `apply -auto-approve` in production | No human review of plan | Require plan review in CI gate |
| `ignore_changes = all` | Masks real drift | List specific attributes |
| `provisioners` as first resort | Imperative in declarative workflow; fragile | Use user_data, SSM, cloud-init |
| Giant root module with 100+ resources | Hard to plan, review, test | Split into focused components/modules |
| No backend (local state) in teams | No locking; state not shared | Use remote backend from day one |
| Floating module source (no `?ref=`) | Non-reproducible | Always pin `?ref=v1.2.3` or commit SHA |
| Storing secrets in `sensitive` variables | Still in state plaintext | External secrets manager; encrypt backend |
| `terraform destroy` whole environment in one command | Destroys everything at once | Use `-target` or structure to allow selective destroy |
