# Using Crossplane: Examples

## Contents

- [Install Crossplane and a Provider](#install-crossplane-and-a-provider)
- [Minimal Managed Resource (S3 Bucket)](#minimal-managed-resource-s3-bucket)
- [Complete Platform API (XRD + Composition + Claim)](#complete-platform-api-xrd--composition--claim)
- [Multi-step Composition Pipeline](#multi-step-composition-pipeline)
- [Render a Composition Offline](#render-a-composition-offline)
- [Validate Before Apply](#validate-before-apply)
- [Trace a Resource Tree](#trace-a-resource-tree)
- [Import an Existing Resource](#import-an-existing-resource)
- [Multi-account Deployments](#multi-account-deployments)

---

## Install Crossplane and a Provider

```bash
# 1. Install Crossplane
helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update
helm install crossplane crossplane-stable/crossplane \
  --namespace crossplane-system \
  --create-namespace \
  --wait

# 2. Install the function used in compositions
kubectl apply -f - <<'EOF'
apiVersion: pkg.crossplane.io/v1beta1
kind: Function
metadata:
  name: function-patch-and-transform
spec:
  package: xpkg.upbound.io/crossplane-contrib/function-patch-and-transform:v0.6.0
EOF

# 3. Install the AWS S3 provider
kubectl apply -f - <<'EOF'
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-aws-s3
spec:
  package: xpkg.upbound.io/upbound/provider-aws-s3:v1.14.0
EOF

# Wait for HEALTHY
kubectl get provider provider-aws-s3 --watch

# 4. Create credentials secret
kubectl create secret generic aws-credentials \
  --namespace crossplane-system \
  --from-file=credentials=$HOME/.aws/credentials

# 5. Create ProviderConfig
kubectl apply -f - <<'EOF'
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
EOF
```

---

## Minimal Managed Resource (S3 Bucket)

```yaml
apiVersion: s3.aws.upbound.io/v1beta1
kind: Bucket
metadata:
  name: my-crossplane-bucket
  annotations:
    crossplane.io/external-name: my-crossplane-bucket-unique-12345
spec:
  forProvider:
    region: us-east-1
  providerConfigRef:
    name: default
  deletionPolicy: Delete
```

```bash
kubectl apply -f bucket.yaml
kubectl get bucket my-crossplane-bucket
# NAME                       READY   SYNCED   EXTERNAL-NAME                      AGE
# my-crossplane-bucket       True    True     my-crossplane-bucket-unique-12345  60s
```

---

## Complete Platform API (XRD + Composition + Claim)

### XRD

```yaml
apiVersion: apiextensions.crossplane.io/v1
kind: CompositeResourceDefinition
metadata:
  name: xobjectstores.platform.example.org
spec:
  group: platform.example.org
  names:
    kind: XObjectStore
    plural: xobjectstores
  claimNames:
    kind: ObjectStore
    plural: objectstores
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
              required: [parameters]
              properties:
                parameters:
                  type: object
                  required: [region]
                  properties:
                    region:
                      type: string
                      description: AWS region for the bucket.
                    versioning:
                      type: boolean
                      default: false
            status:
              type: object
              properties:
                bucketName:
                  type: string
```

### Composition

```yaml
apiVersion: apiextensions.crossplane.io/v1
kind: Composition
metadata:
  name: xobjectstores-aws
  labels:
    provider: aws
spec:
  compositeTypeRef:
    apiVersion: platform.example.org/v1alpha1
    kind: XObjectStore
  mode: Pipeline
  pipeline:
    - step: patch-and-transform
      functionRef:
        name: function-patch-and-transform
      input:
        apiVersion: pt.fn.crossplane.io/v1beta1
        kind: Resources
        resources:
          - name: bucket
            base:
              apiVersion: s3.aws.upbound.io/v1beta1
              kind: Bucket
              spec:
                forProvider:
                  region: us-east-1
                providerConfigRef:
                  name: default
            patches:
              - type: FromCompositeFieldPath
                fromFieldPath: spec.parameters.region
                toFieldPath: spec.forProvider.region
              - type: FromCompositeFieldPath
                fromFieldPath: metadata.name
                toFieldPath: metadata.annotations["crossplane.io/external-name"]
                transforms:
                  - type: string
                    string:
                      type: Format
                      fmt: "platform-%s"
              - type: ToCompositeFieldPath
                fromFieldPath: metadata.annotations["crossplane.io/external-name"]
                toFieldPath: status.bucketName
          - name: bucket-versioning
            base:
              apiVersion: s3.aws.upbound.io/v1beta1
              kind: BucketVersioning
              spec:
                forProvider:
                  region: us-east-1
                  bucketSelector:
                    matchControllerRef: true
                  versioningConfiguration:
                    - status: Suspended
                providerConfigRef:
                  name: default
            patches:
              - type: FromCompositeFieldPath
                fromFieldPath: spec.parameters.region
                toFieldPath: spec.forProvider.region
              - type: FromCompositeFieldPath
                fromFieldPath: spec.parameters.versioning
                toFieldPath: spec.forProvider.versioningConfiguration[0].status
                transforms:
                  - type: map
                    map:
                      "true": Enabled
                      "false": Suspended
```

### Claim (developer applies this)

```yaml
apiVersion: platform.example.org/v1alpha1
kind: ObjectStore
metadata:
  name: my-store
  namespace: team-a
spec:
  parameters:
    region: us-west-2
    versioning: true
```

```bash
kubectl apply -f claim.yaml
kubectl get objectstore my-store -n team-a
kubectl describe objectstore my-store -n team-a
```

---

## Multi-step Composition Pipeline

```yaml
spec:
  mode: Pipeline
  pipeline:
    # Step 1: generate base resources
    - step: base-resources
      functionRef:
        name: function-patch-and-transform
      input:
        apiVersion: pt.fn.crossplane.io/v1beta1
        kind: Resources
        resources:
          - name: bucket
            base:
              apiVersion: s3.aws.upbound.io/v1beta1
              kind: Bucket
              spec:
                forProvider:
                  region: us-east-1
            patches:
              - type: FromCompositeFieldPath
                fromFieldPath: spec.parameters.region
                toFieldPath: spec.forProvider.region

    # Step 2: mark XR ready when all composed resources are ready
    - step: automatically-detect-readiness
      functionRef:
        name: function-auto-ready
```

---

## Render a Composition Offline

Useful for CI validation and local development without a cluster.

```bash
# Prepare three files:
#   xr.yaml          — the XR or Claim manifest
#   composition.yaml — the Composition to render
#   functions.yaml   — list of Functions referenced in the pipeline

crossplane beta render \
  xr.yaml \
  composition.yaml \
  functions.yaml \
  --observed-resources=existing.yaml \  # optional: existing composed resources
  -o yaml

# Example xr.yaml
cat > xr.yaml <<'EOF'
apiVersion: platform.example.org/v1alpha1
kind: XObjectStore
metadata:
  name: test-render
spec:
  parameters:
    region: eu-west-1
    versioning: true
EOF
```

The command prints the expected managed resources to stdout. No cluster
or cloud credentials are required.

---

## Validate Before Apply

```bash
# Download schemas from a running cluster
kubectl get crds -o yaml > schemas/

# Validate a resource file against schemas
crossplane beta validate schemas/ claim.yaml
crossplane beta validate schemas/ composition.yaml

# Validate against a specific XRD
crossplane beta validate xrd.yaml xr.yaml
```

A zero-error result means the resource passes schema validation before
touching the cluster.

---

## Trace a Resource Tree

`crossplane beta trace` is the fastest way to see the full health of a
resource and all its children.

```bash
# Trace a Claim
crossplane beta trace ObjectStore/my-store -n team-a

# Example output:
# NAME                                          SYNCED   READY   STATUS
# ObjectStore/my-store (team-a)                 True     True    Available
# └─ XObjectStore/my-store-abc12                True     True    Available
#    ├─ Bucket/my-store-abc12-bucket            True     True    Available
#    └─ BucketVersioning/my-store-abc12-ver     True     True    Available

# Trace a managed resource directly
crossplane beta trace Bucket/my-crossplane-bucket
```

When any resource shows `Ready: False`, the trace output highlights it.
Then inspect that resource with `kubectl describe`.

---

## Import an Existing Resource

Use `managementPolicies: [Observe]` to import without Crossplane taking
over management, then switch to `["*"]` to begin managing.

```yaml
# Step 1: observe only
apiVersion: s3.aws.upbound.io/v1beta1
kind: Bucket
metadata:
  name: existing-bucket
  annotations:
    crossplane.io/external-name: my-existing-bucket-name
spec:
  forProvider:
    region: us-east-1
  providerConfigRef:
    name: default
  managementPolicies:
    - Observe
```

```bash
kubectl apply -f import.yaml
# Wait for Synced: True — Crossplane has read the external resource state

# Step 2: take over full management
kubectl patch bucket existing-bucket --type merge \
  -p '{"spec":{"managementPolicies":["*"]}}'
```

---

## Multi-account Deployments

Create multiple ProviderConfigs and reference them explicitly per resource.

```yaml
# ProviderConfig for account A
apiVersion: aws.upbound.io/v1beta1
kind: ProviderConfig
metadata:
  name: account-a
spec:
  credentials:
    source: Secret
    secretRef:
      namespace: crossplane-system
      name: aws-creds-account-a
      key: credentials
---
# ProviderConfig for account B
apiVersion: aws.upbound.io/v1beta1
kind: ProviderConfig
metadata:
  name: account-b
spec:
  credentials:
    source: Secret
    secretRef:
      namespace: crossplane-system
      name: aws-creds-account-b
      key: credentials
```

In a Composition, patch the `providerConfigRef.name` from the XR:

```yaml
patches:
  - type: FromCompositeFieldPath
    fromFieldPath: spec.parameters.accountConfig
    toFieldPath: spec.providerConfigRef.name
```
