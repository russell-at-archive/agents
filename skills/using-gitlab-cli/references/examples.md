# Examples

## Contents

- Preflight
- Merge Requests
- Issues
- CI/CD
- Releases
- Variables
- Repositories
- API

## Preflight

```bash
glab auth status
glab repo view
glab repo view -R my-group/my-project
```

## Merge Requests

List open MRs as JSON:

```bash
glab mr list --state opened --output json
```

Create a draft MR non-interactively:

```bash
glab mr create \
  --source-branch feature/my-change \
  --target-branch main \
  --title "feat: add my change" \
  --description "Implements X and includes tests." \
  --draft \
  --yes
```

Merge only if the reviewed HEAD is unchanged:

```bash
glab mr merge 123 --sha abcdef123456 --remove-source-branch --yes
```

## Issues

```bash
glab issue list --state opened --output json
glab issue create --title "Bug: timeout in worker" --label bug --assignee "@me"
glab issue update 42 --label ui,ux --unlabel working
glab issue note 42 -m "Fix is in !123."
```

## CI/CD

Inspect pipelines or jobs:

```bash
glab ci list
glab ci view 789
glab ci trace 789
```

Run a branch pipeline with inputs and variables:

```bash
glab ci run -b main \
  --variables-env DEPLOY_ENV:staging \
  --input "replicas:int(3)" \
  --input "debug:bool(false)"
```

## Releases

```bash
glab release list
glab release create v1.4.0 --name "v1.4.0" --notes "Performance and CI fixes."
```

## Variables

Project variable from stdin:

```bash
cat token.txt | glab variable set SERVER_TOKEN --masked --protected
```

Group variable with environment scope:

```bash
cat token.txt | glab variable set GROUP_TOKEN -g mygroup --scope production
```

## Repositories

Clone another repo or a whole group:

```bash
glab repo clone gitlab-org/cli
glab repo clone -g my-group --paginate
```

Fork and clone:

```bash
glab repo fork namespace/repo --clone
```

## API

Read with pagination:

```bash
glab api projects/:id/merge_requests --paginate
```

Create through the API with typed fields:

```bash
glab api projects/:id/issues \
  -X POST \
  -F title='Bug: cache miss loop' \
  -F description='Observed after deploy 2026-03-01.'
```
