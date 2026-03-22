# Installation

## Overview

Use these paths when `glab` is missing or first-time setup is required.

## Install

### macOS

```bash
brew install glab
```

### Windows

```bash
winget install --id GitLab.glab
```

### Linux

Use the official package or release channel for your distribution from the
GitLab CLI project:

```bash
apt-get install glab
```

If that package path is not available on the target distro, use the official
release instructions from the GitLab CLI README.

## Verify

```bash
glab --version
glab help
```

## Authenticate

Interactive:

```bash
glab auth login
glab auth status
```

Token from standard input:

```bash
glab auth login --hostname gitlab.com --stdin < token.txt
```

Self-managed or dedicated GitLab:

```bash
glab auth login --hostname gitlab.example.com --token glpat-xxx
```

CI job token login:

```bash
glab auth login --hostname "$CI_SERVER_HOST" --job-token "$CI_JOB_TOKEN"
```

## Notes

- `--use-keyring` stores credentials in the OS keychain instead of plain config
- `GITLAB_TOKEN`, `GITLAB_ACCESS_TOKEN`, and `OAUTH_TOKEN` override stored
  credentials
- `GLAB_ENABLE_CI_AUTOLOGIN=true` enables CI auto-login for supported commands
