# Crossplane CLI Installation

## Prerequisites

- Network access to download the CLI
- Permission to place an executable on `PATH`
- `kubectl` is optional for install, but required for live-cluster workflows

## Official install script

Use the install script documented by Crossplane:

```bash
curl -sL "https://raw.githubusercontent.com/crossplane/crossplane/main/install.sh" | sh
```

Useful variants:

```bash
curl -sL "https://raw.githubusercontent.com/crossplane/crossplane/main/install.sh" | XP_VERSION=v1.20.0 sh
curl -sL "https://raw.githubusercontent.com/crossplane/crossplane/main/install.sh" | XP_CHANNEL=master sh
```

## Manual install

Crossplane publishes the standalone CLI binary as `crank` in the release
repository. Download it from `https://releases.crossplane.io/stable/current/bin`
and rename or symlink it to `crossplane` if you want the standard command name.

Example final placement:

```bash
chmod +x crank
sudo mv crank /usr/local/bin/crossplane
```

## Verification

```bash
crossplane version
crossplane render --help
crossplane xpkg --help
crossplane beta trace --help
crossplane beta validate --help
```

If you kept the upstream filename:

```bash
crank version
```

## Notes

- The CLI is a standalone binary.
- The downloadable binary name is `crank`.
- The `crossplane` binary name inside Kubernetes images refers to the Crossplane
  pod image, not the standalone CLI artifact.

## Official sources

- `https://docs.crossplane.io/latest/cli/`
- `https://docs.crossplane.io/latest/cli/command-reference/`
