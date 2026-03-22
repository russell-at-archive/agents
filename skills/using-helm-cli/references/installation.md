# Using Helm: Installation

## Contents

- Prerequisites
- Install from the official project
- Install with package managers
- Verification
- Cluster access check
- Official sources

---

## Prerequisites

- Permission to place the `helm` binary on `PATH`.
- Network access to download the release or package metadata.
- Match the Helm major version your environment expects before joining a shared
  workflow.

---

## Install from the official project

The official Helm project publishes install methods and release binaries. Prefer
those if you need a predictable upstream source.

### Official install script

```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
chmod 700 get_helm.sh
./get_helm.sh
```

### Manual binary install

Download the correct archive from the Helm releases page, unpack it, then move
the binary into place:

```bash
tar -zxvf helm-<version>-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
```

Replace `<version>` and platform as needed.

---

## Install with package managers

### macOS

```bash
brew install helm
```

### Debian or Ubuntu

```bash
sudo apt-get install curl gpg apt-transport-https --yes
curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```

### Fedora

```bash
sudo dnf install helm
```

### Windows

```powershell
winget install Helm.Helm
```

Or:

```powershell
choco install kubernetes-helm
```

---

## Verification

```bash
helm version
helm help
```

---

## Cluster access check

Installing Helm is not enough for release operations. Verify cluster access
separately:

```bash
kubectl config current-context
kubectl get ns
```

---

## Official sources

- [Helm install docs](https://helm.sh/docs/intro/install/)
- [Helm releases](https://github.com/helm/helm/releases)
