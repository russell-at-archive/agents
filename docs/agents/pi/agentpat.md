# GitHub Fine-Grained PAT for Agent Containers

Requirements for the GitHub Personal Access Token (PAT) used by pi agent
containers to clone repositories, implement features, and publish pull
requests for review.

---

## Token Type

Use a **fine-grained Personal Access Token**, not a classic PAT. Fine-grained
tokens are repository-scoped or organization-scoped, support granular
permission selection, and are auditable per-token in GitHub settings.

Classic PATs grant broad, coarse-grained access and should not be used for
automated agent workloads.

---

## Required Permissions

### Metadata — Read

Always required by GitHub for fine-grained PATs. Cannot be unchecked. Grants
read access to basic repository metadata.

---

### Contents — Read and write

Required for all git operations:

- Clone the repository
- Read source files, specs, task lists, and context files (`.pi/`, `AGENTS.md`)
- Create feature branches
- Push commits to feature branches

---

### Issues — Read and write

Required for the full issue workflow:

- Read issue body, title, labels, and comments
- Post progress updates and error notes as comments
- Add and remove labels (e.g. `in-progress`, `ready-for-review`, `failed`)
- Assign and unassign the issue

---

### Pull requests — Read and write

Required for the full PR workflow:

- Create pull requests against the base branch
- Write PR title and description per task spec instructions
- Add labels to PRs
- Request reviewers
- Read existing open PRs to detect conflicts on the same base branch
- Link PRs to issues via `Closes #N` in the PR body

---

### Checks — Read

Required to read CI check results after pushing a branch. The agent uses
check status to determine whether the build passed before marking the issue
ready for review.

---

### Commit statuses — Read

Required for repositories that use the legacy commit status API rather than
the Checks API for CI integration. Ensures the agent can inspect both status
systems.

---

### Actions — Read (conditional)

Required if the agent needs to inspect workflow run logs or trigger a workflow
re-run after a CI failure. Can be omitted if CI status is only read via the
Checks API.

---

## Permissions Summary

| Permission | Level | Purpose |
| --- | --- | --- |
| Metadata | Read | Required by GitHub, automatic |
| Contents | Read and write | Clone, branch, push |
| Issues | Read and write | Read task, comment, label |
| Pull requests | Read and write | Create PR, label, request reviewers |
| Checks | Read | Verify CI status after push |
| Commit statuses | Read | Legacy CI status checks |
| Actions | Read | Optional: inspect workflow runs |

---

## Permissions to Exclude

| Permission | Reason |
| --- | --- |
| Contents write to default branch | Branch protection enforces this; no need to grant it |
| Pull requests merge | Merging is a human or review-agent action, not an implementing agent action |
| Workflows write | Only needed if a task explicitly modifies `.github/workflows/` files |
| Secrets | Never grant to agent tokens |
| Administration | Never grant to agent tokens |

---

## Token Scope: Per-Repo vs Organisation

Fine-grained PATs can be scoped to specific repositories or to an entire
organisation.

| Scope | Tradeoffs |
| --- | --- |
| Per-repository | Tighter blast radius; more tokens to manage as the number of repos grows |
| Organisation-wide | Simpler to manage; broader impact if the token is compromised |

For autonomous agents that push code and open pull requests, the narrower
per-repository scope is the safer default.

---

## Credential Storage and Container Access

The token is stored on the host via the `gh` CLI:

```bash
gh auth login --with-token <<< "github_pat_xxxxxxxxxxxx"
```

This writes the token to `~/.config/gh/hosts.yml`. That file is bind-mounted
read-only into agent containers:

```text
~/.config/gh/  →  /root/.config/gh/  (read-only)
```

Inside the container, `git` is configured to use `gh` as its credential
helper so both `git` and `gh` CLI operations use the same token from the
same source:

```bash
git config --global credential.helper '!gh auth git-credential'
```

This configuration is baked into the container image, not set at runtime.

---

## Why Not OAuth

GitHub OAuth tokens (issued by `gh auth login` via browser) use a refresh
token that must be periodically rotated and written back to
`~/.config/gh/hosts.yml`. Because the mount is read-only, refresh writes
will fail inside the container. Concurrent containers sharing the same OAuth
token also risk a refresh token race — one container's refresh invalidates
the other's token at the provider level.

A fine-grained PAT has no refresh token. It is valid for its full configured
lifetime (up to one year) without any write-back requirement, making it safe
for read-only mounts and concurrent container runs.

---

## Related Docs

| Topic | Path |
| --- | --- |
| Container isolation architecture | [isolation.md](isolation.md) |
| Pi configuration reference | [configuration.md](configuration.md) |
