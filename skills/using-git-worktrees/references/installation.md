# Using Git Worktrees: Installation

## Contents

- Prerequisites
- Install Git on macOS
- Install Git on Linux
- Install Git on Windows
- Verification
- Updating
- Official sources

---

## Prerequisites

- Git installed locally.
- A Git version new enough to include `git worktree`. The command has existed
  for years, but using a current stable Git release is strongly preferred.

---

## Install Git on macOS

### Homebrew

```bash
brew install git
```

### Official installer

Download the macOS package from the Git downloads page and follow the
installer flow.

---

## Install Git on Linux

Use your distribution package manager or the official source tarball from
git-scm.com.

Examples:

```bash
sudo apt-get update
sudo apt-get install -y git
```

```bash
sudo dnf install -y git
```

---

## Install Git on Windows

### winget

```powershell
winget install --id Git.Git -e --source winget
```

### Official installer

Download Git for Windows from the official Git downloads page.

---

## Verification

```bash
git --version
git worktree list
git worktree add --help
```

If `git worktree` is unavailable, the installed Git is too old or incomplete.

---

## Updating

- Re-run the package-manager install or upgrade command you used originally.
- On Windows, upgrade through `winget upgrade Git.Git` or install a newer
  Git for Windows build from the official downloads page.

---

## Official sources

- [Git downloads](https://git-scm.com/downloads/)
- [git-worktree manual](https://git-scm.com/docs/git-worktree)
