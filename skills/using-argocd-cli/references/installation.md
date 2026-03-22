# Installation

Use the official Argo CD CLI installation flow and keep the client version close
to the server version you are operating.

## macOS

```bash
brew install argocd
```

Alternative official binary install:

```bash
VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
curl -sSL -o argocd "https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-darwin-arm64"
sudo install -m 555 argocd /usr/local/bin/argocd
rm argocd
```

## Linux and WSL

```bash
brew install argocd
```

Or install the official binary:

```bash
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64
```

## Windows

Use the official release artifact and put `argocd.exe` on `PATH`.

## Verify

```bash
argocd version --client
```

## First Auth Check

```bash
argocd login <server>
argocd context
```

If commands hang or fail behind an ingress, retry with `--grpc-web`. If direct
API access is not practical, consider `--port-forward`.
