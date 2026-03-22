# Using Terraform: Installation

## Contents

- Prerequisites
- Install Terraform
- Install OpenTofu
- Verification
- Updating
- Official sources

---

## Prerequisites

- Decide whether the environment standard is HashiCorp Terraform or OpenTofu
  before installing.
- Permission to add vendor package repositories or place a standalone binary on
  `PATH`.

---

## Install Terraform

### macOS

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

### Windows

```powershell
choco install terraform
```

### Debian or Ubuntu

```bash
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt-get install terraform
```

### RHEL or CentOS

```bash
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install terraform
```

### Fedora

```bash
sudo dnf install -y dnf-plugins-core
sudo dnf config-manager addrepo --from-repofile=https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
sudo dnf -y install terraform
```

### Manual install

Download the appropriate zip archive from HashiCorp, unpack it, and move the
`terraform` binary onto `PATH`.

---

## Install OpenTofu

OpenTofu publishes installation guides by OS and package format. Common
options include Homebrew, `.deb`, `.rpm`, Snap, Windows installers, and
standalone binaries.

### Homebrew

```bash
brew install opentofu
```

For Debian, RPM, Snap, Windows, and standalone binary installs, follow the
current OS-specific instructions in the official OpenTofu install guide.

---

## Verification

### Terraform

```bash
terraform -help
terraform version
```

### OpenTofu

```bash
tofu version
```

---

## Updating

- Re-run the package-manager install or upgrade path you used originally.
- For standalone installs, replace the existing binary with the newer release.
- After upgrades, re-run `terraform version` or `tofu version` and confirm the
  repo's pinned version expectations still match.

---

## Official sources

- [Terraform install docs](https://developer.hashicorp.com/terraform/install)
- [Terraform CLI install tutorial](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [OpenTofu install docs](https://opentofu.org/docs/intro/install/)
