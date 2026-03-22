# Installation

GitHub CLI is the official command-line client for GitHub. Install the binary
first, then authenticate separately.

## macOS

Homebrew:

```bash
brew install gh
```

Alternative:

- Download the macOS package from the official releases page:
  `https://github.com/cli/cli/releases`

## Linux

Debian or Ubuntu:

```bash
type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh -y
```

Fedora, RHEL, or CentOS:

```bash
sudo dnf install 'dnf-command(config-manager)'
sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
sudo dnf install gh
```

## Windows

Winget:

```powershell
winget install --id GitHub.cli
```

Scoop:

```powershell
scoop install gh
```

## Authentication

Interactive login:

```bash
gh auth login
gh auth status
```

Automation:

- Set `GH_TOKEN` or `GITHUB_TOKEN` for `github.com`
- Set `GH_ENTERPRISE_TOKEN` or `GITHUB_ENTERPRISE_TOKEN` for GitHub Enterprise
- Set `GH_HOST` when the target is not `github.com`

## Verification

```bash
gh --version
gh auth status
```
