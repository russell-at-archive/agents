# Using AWS CLI: Installation

## Contents

- Prerequisites
- Installation: macOS
- Installation: Linux (x86_64 and ARM)
- Installation: Windows
- Verification
- Shell completion
- Updating the CLI

---

## Prerequisites

- Access to a terminal or command prompt.
- Internet connectivity to download the AWS CLI installer.
- Administrative (sudo) privileges for system-wide installation.

---

## Installation: macOS

### Using the PKG installer (Recommended)

```bash
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
```

### Using Homebrew

```bash
brew install awscli
```

---

## Installation: Linux (x86_64 and ARM)

```bash
# Download the installer
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
# For ARM: curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"

# Unzip and install
unzip awscliv2.zip
sudo ./aws/install

# Verify specific install location if needed
# sudo ./aws/install --install-dir /usr/local/aws-cli --bin-dir /usr/local/bin
```

---

## Installation: Windows

1. Download the MSI installer: `https://awscli.amazonaws.com/AWSCLIV2.msi`
2. Run the installer and follow the on-screen instructions.
3. Restart your terminal (PowerShell or CMD) to update the PATH.

---

## Verification

After installation, confirm the version and executable path:

```bash
aws --version
# Output should be: aws-cli/2.x.x ...

which aws
# Output: /usr/local/bin/aws (on macOS/Linux)
```

---

## Shell completion

Enable command completion to speed up CLI usage.

### Bash

Add to `~/.bashrc`:
```bash
complete -C '/usr/local/bin/aws_completer' aws
```

### Zsh

Add to `~/.zshrc`:
```zsh
source /usr/local/bin/aws_zsh_completer.sh
```

---

## Updating the CLI

To update, simply re-run the installation commands. For Linux, use the `--update` flag:

```bash
sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
```
