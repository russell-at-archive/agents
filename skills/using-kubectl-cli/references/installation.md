# Using kubectl: Installation

## Contents

- Prerequisites
- Install on Linux
- Install on macOS
- Install on Windows
- Verification
- Updating
- Official sources

---

## Prerequisites

- Install a `kubectl` version within one minor version of the target cluster.
- Permission to place the binary on `PATH` or to use a package manager.

---

## Install on Linux

### Direct binary

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

### apt

```bash
sudo apt-get update
sudo apt-get install -y kubectl
```

### yum

```bash
sudo yum install -y kubectl
```

### snap

```bash
sudo snap install kubectl --classic
```

### Homebrew on Linux

```bash
brew install kubectl
```

---

## Install on macOS

### Homebrew

```bash
brew install kubectl
```

### Direct binary

Intel:

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"
```

Apple Silicon:

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/arm64/kubectl"
```

Then mark it executable and move it onto `PATH`.

---

## Install on Windows

### winget

```powershell
winget install -e --id Kubernetes.kubectl
```

### Chocolatey

```powershell
choco install kubernetes-cli
```

### Scoop

```powershell
scoop install kubectl
```

---

## Verification

```bash
kubectl version --client
kubectl config current-context
```

The second command may fail if no cluster is configured yet; that is expected
on a fresh installation.

---

## Updating

- Re-run the installation method you used originally.
- For direct binary installs, download a newer version and replace the
  existing executable.
- For distro repositories, update the configured Kubernetes repo minor version
  before upgrading across Kubernetes minor releases.

---

## Official sources

- [kubectl install on Linux](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
- [kubectl install on macOS](https://kubernetes.io/docs/tasks/tools/install-kubectl-macos/)
- [kubectl install on Windows](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/)
