# Crossplane CLI Examples

## Render a composition pipeline

```bash
crossplane render xr.yaml composition.yaml functions.yaml
```

Render with richer output:

```bash
crossplane render xr.yaml composition.yaml functions.yaml \
  --include-full-xr \
  --include-function-results
```

## Validate a managed resource against provider schemas

```bash
crossplane beta validate provider.yaml resource.yaml
```

## Validate rendered output

```bash
crossplane render xr.yaml composition.yaml functions.yaml --include-full-xr \
  | crossplane beta validate schemas.yaml -
```

## Build a package

```bash
crossplane xpkg build --package-root=. --package-file=package.xpkg
```

## Scaffold a new package

```bash
crossplane xpkg init my-provider provider-template
crossplane xpkg init my-function function-template-go
```

## Install packages into a cluster

```bash
crossplane xpkg install Provider \
  xpkg.crossplane.io/crossplane-contrib/provider-aws-s3:v2.0.0 \
  --wait

crossplane xpkg install Function \
  xpkg.crossplane.io/crossplane-contrib/function-patch-and-transform:v0.8.2 \
  --wait
```

## Trace a resource tree

```bash
crossplane beta trace xbucket.example.org/example
crossplane beta trace xbucket.example.org/example --output=wide
crossplane beta trace configuration/my-platform --show-package-dependencies all
```

## Publish a package

```bash
crossplane xpkg login --username="$USER" --password -
crossplane xpkg push -f package.xpkg index.docker.io/acme/my-package:v0.1.0
```
