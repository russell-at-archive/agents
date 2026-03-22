# Using Atmos: Installation

## Contents

- Prerequisites
- Install on macOS
- Install on Linux
- Install on Windows
- Alternative install methods
- Verification
- Updating
- Official sources

---

## Prerequisites

- Network access to download the CLI or package metadata.
- A shell with permission to install packages on the machine.
- A modern terminal. Atmos recommends ANSI-capable terminals and a Nerd Font
  for the best TUI experience.

---

## Install on macOS

### Homebrew

```bash
brew install atmos
```

### Official installer

```bash
curl -fsSL https://atmos.tools/install.sh | bash
```

---

## Install on Linux

### Official installer

```bash
curl -fsSL https://atmos.tools/install.sh | bash
```

### Debian or Ubuntu

```bash
sudo apt-get update
sudo apt-get install -y apt-utils curl
curl -1sLf 'https://dl.cloudsmith.io/public/cloudposse/packages/cfg/setup/bash.deb.sh' | sudo bash
sudo apt-get install atmos
```

### RHEL, CentOS, or compatible RPM systems

```bash
curl -1sLf 'https://dl.cloudsmith.io/public/cloudposse/packages/setup.rpm.sh' | sudo -E bash
sudo yum install atmos
```

### Alpine

```bash
curl -fsSL 'https://dl.cloudsmith.io/public/cloudposse/packages/setup.alpine.sh' | bash
sudo apk add atmos@cloudposse
```

---

## Install on Windows

### Scoop

```powershell
scoop install atmos
```

### Download a release binary

Download the correct `atmos_<version>_windows_<arch>.exe` asset from the
GitHub releases page and place it on `PATH`.

---

## Alternative install methods

### Go

```bash
go install github.com/cloudposse/atmos@latest
```

### asdf

```bash
asdf plugin add atmos https://github.com/cloudposse/asdf-atmos.git
asdf install atmos latest
```

### mise

```bash
mise use atmos@latest
```

---

## Verification

```bash
atmos version
atmos help
```

If the binary runs but the TUI renders poorly, set:

```bash
export TERM=xterm-256color
```

---

## Updating

- Re-run the package-manager install command you used originally.
- If you use the installer script, run it again.

### Built-in version manager

```bash
# List available releases (from GitHub)
atmos version list
atmos version list --limit 10
atmos version list --installed          # only locally installed versions
atmos version list --include-prereleases

# Install a specific version
atmos version install <version>

# Check current version
atmos version
```

---

## Official sources

- [Atmos install docs](https://atmos.tools/install/)
- [Atmos releases](https://github.com/cloudposse/atmos/releases)
