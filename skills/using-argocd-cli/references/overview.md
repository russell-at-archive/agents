# Using argocd (Argo CD CLI): Overview

## Contents

- Environment and authentication
- Command posture
- Application management
- Sync operations
- Application inspection and diff
- Rollback and history
- ApplicationSet management
- Repository management
- Cluster management
- Project management
- Output formats
- High-signal command set

## Environment and Authentication

Set these environment variables before running any command:

```bash
export ARGOCD_SERVER=<host>:<port>        # e.g. argocd.example.com or localhost:8080
export ARGOCD_AUTH_TOKEN=<token>          # service account or user token
export ARGOCD_OPTS="--grpc-web"           # optional: set global flags
```

Log in interactively (creates a local session):

```bash
argocd login <server>                          # prompts for credentials
argocd login <server> --sso                    # SSO login
argocd login <server> --username admin \
  --password <password>
```

Log in with a token (CI-safe, non-interactive):

```bash
argocd login <server> \
  --auth-token "$ARGOCD_AUTH_TOKEN" \
  --grpc-web
```

List and switch contexts:

```bash
argocd context                                 # list all contexts
argocd context <context-name>                  # switch active context
```

Display current user:

```bash
argocd account get-user-info
```

Generate an API token for automation:

```bash
argocd account generate-token --account <account-name>
```

Log out:

```bash
argocd logout <server>
```

## Command Posture

Treat every `argocd` session as a sequence:

1. Scope: confirm context with `argocd context`.
2. Observe: inspect state with read-only commands (`get`, `diff`, `list`).
3. Decide: identify the required action and its blast radius.
4. Act: execute with explicit app names and flags.
5. Verify: confirm outcome with `argocd app get` or `argocd app wait`.

Never begin with destructive commands (`delete`, `sync --prune`, `rollback`)
without first running `argocd app get` to confirm the target.

## Application Management

List all applications:

```bash
argocd app list
argocd app list -o wide
argocd app list --selector environment=production
```

Get application detail:

```bash
argocd app get <app-name>
argocd app get <app-name> -o yaml
argocd app get <app-name> -o json
```

Create an application:

```bash
argocd app create <app-name> \
  --repo https://github.com/org/repo \
  --path manifests/production \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace production \
  --project default
```

Update application settings:

```bash
argocd app set <app-name> --sync-policy automated
argocd app set <app-name> --auto-prune
argocd app set <app-name> --self-heal
argocd app set <app-name> -p key=value     # override Helm/Kustomize param
```

Delete an application (leaves cluster resources intact by default):

```bash
argocd app delete <app-name>
argocd app delete <app-name> --cascade     # also deletes cluster resources
```

Terminate an in-progress sync or operation:

```bash
argocd app terminate-op <app-name>
```

## Sync Operations

Sync an application to the desired state in Git:

```bash
argocd app sync <app-name>
```

Sync with dry-run (shows what would change without applying):

```bash
argocd app sync <app-name> --dry-run
```

Sync and wait for healthy status (CI-safe):

```bash
argocd app sync <app-name> --wait
```

Sync with prune (removes resources no longer in Git):

```bash
argocd app sync <app-name> --prune
```

Force sync (replaces resources even if unchanged):

```bash
argocd app sync <app-name> --force
```

Sync only specific resources:

```bash
argocd app sync <app-name> \
  --resource apps:Deployment:my-deployment
```

Sync a specific revision:

```bash
argocd app sync <app-name> --revision v1.2.3
```

Wait for an application to reach a target state:

```bash
argocd app wait <app-name>
argocd app wait <app-name> --health
argocd app wait <app-name> --sync
argocd app wait <app-name> --timeout 120
argocd app wait <app-name> --suspended
```

## Application Inspection and Diff

Diff current cluster state against Git target:

```bash
argocd app diff <app-name>
argocd app diff <app-name> --revision HEAD~1
argocd app diff <app-name> --local ./manifests
```

List application resources:

```bash
argocd app resources <app-name>
```

Stream application logs:

```bash
argocd app logs <app-name>
argocd app logs <app-name> -c <container>
argocd app logs <app-name> --follow
argocd app logs <app-name> --tail=200
argocd app logs <app-name> \
  --group apps --kind Deployment --name my-deployment
```

List and run resource actions:

```bash
argocd app actions list <app-name>
argocd app actions run <app-name> restart \
  --kind Deployment --resource-name my-deployment
```

Patch an application spec:

```bash
argocd app patch <app-name> \
  --patch '{"spec": {"source": {"targetRevision": "main"}}}'
```

## Rollback and History

View deployment history:

```bash
argocd app history <app-name>
```

Roll back to a previous deployment ID:

```bash
argocd app rollback <app-name> <history-id>
argocd app rollback <app-name> <history-id> --prune
```

## ApplicationSet Management

List ApplicationSets:

```bash
argocd appset list
argocd appset list -o wide
```

Get an ApplicationSet:

```bash
argocd appset get <appset-name>
argocd appset get <appset-name> -o yaml
```

Create an ApplicationSet:

```bash
argocd appset create appset.yaml
```

Delete an ApplicationSet:

```bash
argocd appset delete <appset-name>
```

## Repository Management

List registered repositories:

```bash
argocd repo list
```

Add a repository (HTTPS with credentials):

```bash
argocd repo add https://github.com/org/repo \
  --username <user> \
  --password <token>
```

Add a repository (SSH):

```bash
argocd repo add git@github.com:org/repo.git \
  --ssh-private-key-path ~/.ssh/id_rsa
```

Get repository details:

```bash
argocd repo get https://github.com/org/repo
```

Remove a repository:

```bash
argocd repo rm https://github.com/org/repo
```

## Cluster Management

List registered clusters:

```bash
argocd cluster list
```

Add a cluster (uses current kubeconfig context):

```bash
argocd cluster add <context-name>
argocd cluster add <context-name> --name friendly-name
```

Get cluster details:

```bash
argocd cluster get <server-url>
```

Remove a cluster:

```bash
argocd cluster rm <server-url>
```

## Project Management

List projects:

```bash
argocd proj list
```

Get a project:

```bash
argocd proj get <project-name>
```

Create a project:

```bash
argocd proj create <project-name> \
  --description "Production workloads"
```

Add a source repository to a project:

```bash
argocd proj add-source <project-name> https://github.com/org/repo
```

Add a deployment destination to a project:

```bash
argocd proj add-destination <project-name> \
  https://kubernetes.default.svc production
```

Delete a project:

```bash
argocd proj delete <project-name>
```

## Output Formats

Control output format:

```bash
argocd app get <app-name> -o yaml    # full YAML spec
argocd app get <app-name> -o json    # JSON
argocd app list -o wide              # wide table with extra columns
argocd app list -o name              # names only, useful for scripting
```

## High-Signal Command Set

Keep these commands close:

- Auth: `login`, `context`, `logout`, `account get-user-info`
- Discovery: `app list`, `app get`, `app diff`, `app resources`
- Sync: `app sync`, `app sync --dry-run`, `app sync --wait`, `app wait --health`
- Lifecycle: `app set`, `app create`, `app delete --cascade`, `app terminate-op`
- Rollback: `app history`, `app rollback`
- Logs: `app logs --follow`, `app logs --tail`
- Repos: `repo list`, `repo add`, `repo rm`
- Clusters: `cluster list`, `cluster add`, `cluster rm`
- Projects: `proj list`, `proj get`, `proj create`
- AppSets: `appset list`, `appset get`, `appset create`

Use `argocd <command> --help` when uncertain about available flags.
