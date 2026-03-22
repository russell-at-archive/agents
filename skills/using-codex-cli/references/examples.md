# Examples

## Start an Interactive Session in a Specific Repo

```bash
codex -C /path/to/repo \
  -s workspace-write \
  "Investigate the failing auth tests and propose a fix."
```

## Run One Task Non-Interactively

```bash
codex exec --full-auto -C /path/to/repo \
  -o /tmp/codex-lint-fix.md \
  "Fix lint errors in src/auth only. Run the relevant tests and return a short summary."
```

## Use a Structured Prompt from stdin

```bash
cat <<'PROMPT' | codex exec --full-auto -C /path/to/repo -
# Task
Review Terraform module defaults.

## Context
- Relevant files: terraform/modules/vpc

## Constraints
- Change only terraform/modules/vpc.
- Do not run apply.
- Output: risk list plus suggested patch.

## Validation
terraform validate
PROMPT
```

## Emit JSONL for Tooling

```bash
codex exec --full-auto -C /path/to/repo --json \
  "Summarize flaky tests and propose stabilization steps."
```

## Enforce a Final Response Schema

```bash
codex exec --full-auto -C /path/to/repo \
  --output-schema /path/to/schema.json \
  "Return a machine-readable release checklist for the current branch."
```

## Resume a Non-Interactive Session

```bash
codex exec resume --last --full-auto \
  -o /tmp/codex-resume.md \
  "Continue from the previous session and finish the remaining test fixes."
```

## Resume or Fork an Interactive Session

```bash
codex resume --last -C /path/to/repo
codex fork --last -C /path/to/repo "Take a different approach focused on test isolation."
```

## Run Review Mode

```bash
codex review --base main \
  "Focus on regressions, missing tests, and security risks."

codex review --uncommitted \
  "Prioritize correctness and backward compatibility issues."
```

## Manage Login Non-Interactively

```bash
printenv OPENAI_API_KEY | codex login --with-api-key
codex login status
```

## Manage MCP Servers

```bash
codex mcp list
codex mcp get my-server
```

## Apply a Cloud Task Diff Locally

```bash
codex apply <task-id>
```
