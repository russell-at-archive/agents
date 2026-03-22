# Using Kustomize: Installation

## Contents

- Prerequisites
- Option 1: use embedded Kustomize via `kubectl`
- Option 2: install standalone `kustomize`
- Verification
- Updating
- Official sources

---

## Prerequisites

- Decide whether you need the standalone `kustomize` binary or whether the
  `kubectl`-embedded version is sufficient.
- If you rely on newer Kustomize features, prefer the standalone binary.

---

## Option 1: use embedded Kustomize via `kubectl`

Kustomize ships inside `kubectl`. Install `kubectl`, then use:

```bash
kubectl kustomize <dir>
kubectl apply -k <dir>
```

To inspect the embedded Kustomize version:

```bash
kubectl version --client
```

The upstream Kustomize repository documents the mapping between `kubectl`
versions and embedded Kustomize versions.

---

## Option 2: install standalone `kustomize`

### Download from GitHub releases

Install the appropriate asset from the Kustomize releases page and place the
binary on `PATH`.

### Common package-manager path on macOS or Linux

```bash
brew install kustomize
```

If your environment standardizes on a different version manager, pin the
release there and verify the resulting binary version before use.

---

## Verification

### Standalone binary

```bash
kustomize version
```

### Embedded via kubectl

```bash
kubectl version --client
kubectl kustomize --help
```

---

## Updating

- For standalone installs, replace the binary with a newer release or re-run
  your package-manager upgrade path.
- For embedded Kustomize, update `kubectl`.

---

## Official sources

- [Kustomize repository](https://github.com/kubernetes-sigs/kustomize)
- [Kustomize releases](https://github.com/kubernetes-sigs/kustomize/releases)
- [kubectl install on Linux](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
- [kubectl install on macOS](https://kubernetes.io/docs/tasks/tools/install-kubectl-macos/)
- [kubectl install on Windows](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/)
