# Using Crossplane: Full Reference

## Contents

- [Object Model](#object-model)
- [Resource Hierarchy](#resource-hierarchy)
- [Status Conditions](#status-conditions)
- [Installing Crossplane](#installing-crossplane)
- [Providers and ProviderConfig](#providers-and-providerconfig)
- [Managed Resources](#managed-resources)
- [Composite Resource Definitions (XRDs)](#composite-resource-definitions-xrds)
- [Composite Resources (XRs) and Claims (XRCs)](#composite-resources-xrs-and-claims-xrcs)
- [Compositions](#compositions)
- [Composition Functions](#composition-functions)
- [Function Patch and Transform](#function-patch-and-transform)
- [Packages and the crossplane CLI](#packages-and-the-crossplane-cli)
- [crossplane beta Commands](#crossplane-beta-commands)
- [Observing Resources with kubectl](#observing-resources-with-kubectl)
- [Credentials and Secrets Patterns](#credentials-and-secrets-patterns)
- [Best Practices](#best-practices)

---

## Object Model

| Kind | Scope | Purpose |
| ---- | ----- | ------- |
| `Provider` | Cluster | Installs provider package (CRDs + controller) |
| `ProviderConfig` | Cluster | Configures provider credentials and settings |
| Managed Resource (MR) | Cluster | Maps 1:1 to an external API resource |
| `CompositeResourceDefinition` (XRD) | Cluster | Defines the schema for a custom API (XR + optional Claim) |
| `Composition` | Cluster | Template: what MRs to create for a given XR |
| Composite Resource (XR) | Cluster | Instance of a custom API; owns a set of MRs |
| Claim (XRC) | Namespace | Namespaced proxy for an XR; used by developers |
| `Function` | Cluster | Installs a composition function package |
| `Configuration` | Cluster | Installs a bundle of XRDs + Compositions |

---

## Resource Hierarchy

```text
Claim (namespace-scoped)
  └── Composite Resource / XR (cluster-scoped)
        ├── Managed Resource A (cluster-scoped)
        ├── Managed Resource B (cluster-scoped)
        └── Managed Resource C (cluster-scoped)
```

- A Claim is a lightweight proxy. Deleting a Claim deletes its XR.
- Deleting an XR directly does **not** delete its Claim — use the Claim
  as the delete target.
- Managed resources are owned by the XR and deleted when the XR is deleted
  (unless `deletionPolicy: Orphan` is set).

---

## Status Conditions

Every Crossplane resource carries two standard conditions:

| Condition | Meaning |
| --------- | ------- |
| `Synced: True` | Controller reconciled desired state successfully |
| `Synced: False` | Reconciliation error; inspect `message` for details |
| `Ready: True` | Resource is available and healthy |
| `Ready: False` | Resource exists but is not yet ready |

Readiness propagates upward: all MRs must be `Ready: True` before the XR
is `Ready: True`, and the XR must be ready before the Claim is ready.

Check conditions:

```bash
kubectl get <kind> <name> -o jsonpath='{.status.conditions}' | jq .
kubectl describe <kind> <name>
```

---

## Installing Crossplane

```bash
helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update
helm install crossplane crossplane-stable/crossplane \
  --namespace crossplane-system \
  --create-namespace \
  --wait
```

Verify:

```bash
kubectl get pods -n crossplane-system
kubectl get crds | grep crossplane
```

---

## Providers and ProviderConfig

### Installing a Provider

```yaml
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-aws-s3
spec:
  package: xpkg.upbound.io/upbound/provider-aws-s3:v1.14.0
  packagePullPolicy: IfNotPresent
```

Wait for the provider to become healthy:

```bash
kubectl get provider provider-aws-s3
# INSTALLED   HEALTHY   PACKAGE                                       AGE
# True        True      xpkg.upbound.io/upbound/provider-aws-s3:v1.14.0   2m
```

### ProviderConfig — AWS (Secret-based)

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: aws-credentials
  namespace: crossplane-system
type: Opaque
stringData:
  credentials: |
    [default]
    aws_access_key_id = AKIAIOSFODNN7EXAMPLE
    aws_secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
---
apiVersion: aws.upbound.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
spec:
  credentials:
    source: Secret
    secretRef:
      namespace: crossplane-system
      name: aws-credentials
      key: credentials
```

### ProviderConfig — AWS (IRSA / Pod Identity)

```yaml
apiVersion: aws.upbound.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
spec:
  credentials:
    source: IRSA
```

### Provider Families

Large providers (AWS, GCP, Azure) ship as a **family**: a shared
`provider-family-aws` handles auth, and per-service sub-providers
(e.g., `provider-aws-s3`, `provider-aws-rds`) are installed separately.
Installing any sub-provider automatically installs the family provider.

---

## Managed Resources

A managed resource directly represents one external API object.

```yaml
apiVersion: s3.aws.upbound.io/v1beta1
kind: Bucket
metadata:
  name: my-bucket
  annotations:
    crossplane.io/external-name: my-globally-unique-bucket-name
spec:
  forProvider:
    region: us-east-1
  providerConfigRef:
    name: default
  deletionPolicy: Delete   # or Orphan
  managementPolicies:
    - "*"                  # Observe, Create, Update, Delete
```

Key fields on every MR:

| Field | Purpose |
| ----- | ------- |
| `spec.forProvider` | Cloud-side configuration |
| `spec.providerConfigRef.name` | Which ProviderConfig to use |
| `spec.deletionPolicy` | `Delete` (default) or `Orphan` |
| `spec.managementPolicies` | `["*"]` full management or `["Observe"]` import-only |
| `metadata.annotations["crossplane.io/external-name"]` | Override the external resource name |

---

## Composite Resource Definitions (XRDs)

An XRD generates a CRD for the XR kind and (optionally) a namespaced
Claim kind.

```yaml
apiVersion: apiextensions.crossplane.io/v1
kind: CompositeResourceDefinition
metadata:
  name: xpostgresdatabases.platform.example.org
spec:
  group: platform.example.org
  names:
    kind: XPostgresDatabase
    plural: xpostgresdatabases
  claimNames:              # omit to disable Claims
    kind: PostgresDatabase
    plural: postgresdatabases
  versions:
    - name: v1alpha1
      served: true
      referenceable: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              properties:
                parameters:
                  type: object
                  required: [storageGB]
                  properties:
                    storageGB:
                      type: integer
                      minimum: 20
```

Check XRD status after apply:

```bash
kubectl get xrd xpostgresdatabases.platform.example.org
# Condition Established: True means the CRD is ready
```

---

## Composite Resources (XRs) and Claims (XRCs)

### Creating an XR directly (cluster-scoped)

```yaml
apiVersion: platform.example.org/v1alpha1
kind: XPostgresDatabase
metadata:
  name: my-db
spec:
  parameters:
    storageGB: 100
  compositionRef:
    name: xpostgresdatabases-aws      # optional: pin to a specific Composition
```

### Creating a Claim (namespace-scoped, preferred for developers)

```yaml
apiVersion: platform.example.org/v1alpha1
kind: PostgresDatabase
metadata:
  name: my-db
  namespace: team-a
spec:
  parameters:
    storageGB: 100
```

Check status:

```bash
kubectl get postgresdb my-db -n team-a
kubectl describe postgresdb my-db -n team-a
```

---

## Compositions

A Composition defines what managed resources to create for a given XR.

```yaml
apiVersion: apiextensions.crossplane.io/v1
kind: Composition
metadata:
  name: xpostgresdatabases-aws
spec:
  compositeTypeRef:
    apiVersion: platform.example.org/v1alpha1
    kind: XPostgresDatabase
  mode: Pipeline
  pipeline:
    - step: patch-and-transform
      functionRef:
        name: function-patch-and-transform
      input:
        apiVersion: pt.fn.crossplane.io/v1beta1
        kind: Resources
        resources:
          - name: rds-instance
            base:
              apiVersion: rds.aws.upbound.io/v1beta1
              kind: DBInstance
              spec:
                forProvider:
                  region: us-east-1
                  dbInstanceClass: db.t3.micro
                  engine: postgres
                  engineVersion: "15"
                  skipFinalSnapshot: true
            patches:
              - type: FromCompositeFieldPath
                fromFieldPath: spec.parameters.storageGB
                toFieldPath: spec.forProvider.allocatedStorage
```

`mode: Pipeline` is the modern approach. The legacy `mode: Resources`
(no pipeline) is deprecated — use `crossplane beta convert` to migrate.

---

## Composition Functions

Functions are OCI-packaged gRPC services that implement composition logic.
They replace embedded patching logic with a composable pipeline.

```yaml
apiVersion: pkg.crossplane.io/v1beta1
kind: Function
metadata:
  name: function-patch-and-transform
spec:
  package: xpkg.upbound.io/crossplane-contrib/function-patch-and-transform:v0.6.0
```

Common functions:

| Function | Purpose |
| -------- | ------- |
| `function-patch-and-transform` | Declarative patch and transform (replaces legacy mode) |
| `function-go-templating` | Go template-based resource generation |
| `function-kcl` | KCL language-based composition |
| `function-cue` | CUE language-based composition |
| `function-auto-ready` | Propagates readiness automatically |
| `function-sequencer` | Controls creation order across steps |

Pipeline steps run sequentially; each function receives the output of the
previous step.

---

## Function Patch and Transform

Patch types in `function-patch-and-transform`:

| Type | Direction | Description |
| ---- | --------- | ----------- |
| `FromCompositeFieldPath` | XR → MR | Copy field from XR to MR |
| `ToCompositeFieldPath` | MR → XR | Copy field from MR back to XR |
| `CombineFromComposite` | XR → MR | Combine multiple XR fields into one MR field |
| `FromEnvironmentFieldPath` | Env → MR | Copy from EnvironmentConfig |
| `PatchSet` | — | Apply a named reusable patch set |

Transform examples:

```yaml
patches:
  # Direct copy
  - type: FromCompositeFieldPath
    fromFieldPath: spec.parameters.region
    toFieldPath: spec.forProvider.region

  # String format
  - type: FromCompositeFieldPath
    fromFieldPath: metadata.name
    toFieldPath: spec.forProvider.dbName
    transforms:
      - type: string
        string:
          type: Format
          fmt: "db-%s"

  # Map (enum mapping)
  - type: FromCompositeFieldPath
    fromFieldPath: spec.parameters.size
    toFieldPath: spec.forProvider.dbInstanceClass
    transforms:
      - type: map
        map:
          small: db.t3.micro
          medium: db.m5.large
          large: db.m5.4xlarge

  # Write-back: copy connection detail from MR to XR
  - type: ToCompositeFieldPath
    fromFieldPath: status.atProvider.endpoint
    toFieldPath: status.endpoint
```

---

## Packages and the crossplane CLI

Install the CLI:

```bash
# macOS
brew install crossplane/tap/crossplane

# Linux
curl -sL https://raw.githubusercontent.com/crossplane/crossplane/main/install.sh | sh
```

### xpkg commands

```bash
# Install a package (provider, function, or configuration)
crossplane xpkg install provider \
  xpkg.upbound.io/upbound/provider-aws-s3:v1.14.0

crossplane xpkg install function \
  xpkg.upbound.io/crossplane-contrib/function-patch-and-transform:v0.6.0

crossplane xpkg install configuration \
  xpkg.upbound.io/upbound/platform-ref-aws:v0.9.0

# Use --wait to block until HEALTHY
crossplane xpkg install provider xpkg.upbound.io/upbound/provider-aws-s3:v1.14.0 --wait

# Initialize a new package directory
crossplane xpkg init my-platform configuration-template

# Build an OCI package from the current directory
crossplane xpkg build --package-root=. --package-file=my-platform.xpkg

# Push to a registry
crossplane xpkg push my-registry.example.com/my-platform:v0.1.0 \
  --package-files=my-platform.xpkg
```

---

## crossplane beta Commands

```bash
# Render a Composition locally (offline, no cluster needed)
crossplane beta render \
  xr.yaml \
  composition.yaml \
  functions.yaml \
  -o yaml

# Validate resources against XRD or provider schemas
crossplane beta validate schemas/ resources.yaml

# Trace a resource tree (shows full hierarchy and conditions)
crossplane beta trace PostgresDatabase/my-db -n team-a
crossplane beta trace XPostgresDatabase/my-db
crossplane beta trace Bucket/my-bucket

# Convert legacy Composition to pipeline mode
crossplane beta convert pipeline-composition composition.yaml \
  -f function-patch-and-transform

# Convert ControllerConfig to DeploymentRuntimeConfig
crossplane beta convert deployment-runtime-config controllerconfig.yaml

# Show CLI and control plane version
crossplane version
```

---

## Observing Resources with kubectl

```bash
# List all Crossplane-managed resources in the cluster
kubectl get managed

# List all composite resources
kubectl get composite

# List all claims (across all namespaces)
kubectl get claim -A

# List all Crossplane packages
kubectl get providers
kubectl get functions
kubectl get configurations

# Get provider health
kubectl get provider provider-aws-s3
kubectl get providerrevision

# Inspect a managed resource
kubectl get bucket my-bucket -o yaml
kubectl describe bucket my-bucket

# Watch reconciliation
kubectl get bucket my-bucket -w

# Check events for any resource
kubectl get events --field-selector involvedObject.name=my-bucket
```

---

## Credentials and Secrets Patterns

- Store credentials in Kubernetes Secrets in `crossplane-system`.
- Prefer workload identity (IRSA, Workload Identity, Pod Identity) over
  long-lived key pairs.
- Use `spec.credentials.source: InjectedIdentity` for in-cluster auth
  (EKS Pod Identity, GKE Workload Identity).
- Reference the ProviderConfig by name from each managed resource's
  `spec.providerConfigRef.name`.
- Multiple ProviderConfigs can coexist; managed resources can reference
  different ones for multi-account or multi-region deployments.

---

## Best Practices

- **Pin package versions**: never use floating tags in production Providers,
  Functions, or Configurations.
- **Use Claims** as the developer interface; reserve direct XR creation for
  platform team operations.
- **Set `deletionPolicy: Orphan`** on stateful resources (databases, storage)
  during early development to avoid accidental deletion.
- **Use `crossplane beta render`** to verify Composition logic before
  deploying to a live cluster.
- **Use `crossplane beta trace`** as the first debugging step for any
  `Synced: False` or `Ready: False` condition.
- **Layer Configurations**: package XRDs + Compositions as a Configuration
  OCI package for distribution and versioning.
- **Separate ProviderConfigs per environment**: use different named
  ProviderConfigs for dev/staging/prod accounts.
