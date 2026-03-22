# Installation

## Install the argo CLI

### macOS (Homebrew — recommended)

```bash
brew install argo
```

### macOS / Linux — direct download

Match the version to your Argo Workflows server. Replace `v4.0.3` with the
actual server version.

```bash
# macOS arm64 (Apple Silicon)
curl -sLO https://github.com/argoproj/argo-workflows/releases/download/v4.0.3/argo-darwin-arm64.gz
gunzip argo-darwin-arm64.gz && chmod +x argo-darwin-arm64
sudo mv argo-darwin-arm64 /usr/local/bin/argo

# macOS amd64 (Intel)
curl -sLO https://github.com/argoproj/argo-workflows/releases/download/v4.0.3/argo-darwin-amd64.gz
gunzip argo-darwin-amd64.gz && chmod +x argo-darwin-amd64
sudo mv argo-darwin-amd64 /usr/local/bin/argo

# Linux amd64
curl -sLO https://github.com/argoproj/argo-workflows/releases/download/v4.0.3/argo-linux-amd64.gz
gunzip argo-linux-amd64.gz && chmod +x argo-linux-amd64
sudo mv argo-linux-amd64 /usr/local/bin/argo

# Linux arm64
curl -sLO https://github.com/argoproj/argo-workflows/releases/download/v4.0.3/argo-linux-arm64.gz
gunzip argo-linux-arm64.gz && chmod +x argo-linux-arm64
sudo mv argo-linux-arm64 /usr/local/bin/argo
```

### Download from the Argo Server (version-matched automatically)

If you have access to the running server, download the matching binary directly
from it — no GitHub version lookup needed:

```bash
curl -sL https://<argo-server-host>/assets/argo-linux-amd64.gz \
  | gunzip > argo && chmod +x argo && sudo mv argo /usr/local/bin/argo
```

## Verify installation

```bash
argo version
```

Check that the client version matches the server version shown in the output.

## Match CLI version to server version

Version skew causes `unknown flag` errors, missing subcommands, and silent
output format differences. Find the server version:

```bash
kubectl -n argo get deploy argo-server \
  -o jsonpath='{.spec.template.spec.containers[0].image}'
```

Then install the matching CLI from GitHub releases or the server's `/assets`
endpoint.

## Configure authentication

Set these environment variables before running any `argo` command:

```bash
export ARGO_SERVER=argo.example.com:2746   # host:port — NO https:// prefix
export ARGO_TOKEN="Bearer <token>"          # literal "Bearer " prefix required
export ARGO_NAMESPACE=argo                  # optional default namespace
export ARGO_SECURE=true                     # false only for non-TLS local dev
```

For local port-forwarded access (development only):

```bash
kubectl port-forward svc/argo-server 2746:2746 -n argo &
export ARGO_SERVER=localhost:2746
export ARGO_SECURE=false
export ARGO_TOKEN=""
```

View the token the CLI is currently using:

```bash
argo auth token
```

Create a long-lived service account token for CI automation:

```bash
kubectl create role ci-runner \
  --verb=list,update,create,delete \
  --resource=workflows.argoproj.io -n argo
kubectl create sa ci-runner -n argo
kubectl create rolebinding ci-runner \
  --role=ci-runner --serviceaccount=argo:ci-runner -n argo

kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: ci-runner.service-account-token
  namespace: argo
  annotations:
    kubernetes.io/service-account.name: ci-runner
type: kubernetes.io/service-account-token
EOF

TOKEN=$(kubectl get secret ci-runner.service-account-token \
  -n argo -o jsonpath='{.data.token}' | base64 -d)
export ARGO_TOKEN="Bearer $TOKEN"
```
