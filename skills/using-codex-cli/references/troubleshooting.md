# Troubleshooting

## Common Failures

### Codex waits for input unexpectedly

Cause: missing `--full-auto` in non-interactive flows.

Fix:

```bash
codex exec --full-auto -C /path/to/repo "task prompt"
```

### Wrong repository or missing files

Cause: command ran from the wrong directory or without explicit `-C`.

Fix:

```bash
codex exec --full-auto -C /absolute/path/to/repo "task prompt"
```

### Output file overwritten

Cause: concurrent tasks shared the same `-o` path.

Fix: always use one output file per task (`/tmp/codex-<task>.md`).

### Session could not continue

Cause: wrong id or ambiguous session selection.

Fix:

```bash
codex exec resume --all
codex exec resume --last "continue prompt"
```

### Git repo check failure

Cause: task executed outside a repository.

Fix:

```bash
codex exec --skip-git-repo-check --full-auto -C /path "task prompt"
```

Use this only when the task truly does not need git context.

## Prompt Quality Issues

- Symptom: output is generic or off-target.
- Cause: incomplete context or unclear constraints.
- Fix: restate scope, files, forbidden edits, and expected output format.

## Safety Escalation

- Never use `--dangerously-bypass-approvals-and-sandbox` by default.
- If user requests it, confirm they explicitly want unsandboxed execution.
- Prefer scoped alternatives first:
  - `--full-auto`
  - `-s read-only`
  - `--add-dir <path>`

## Validation Checklist Before Reporting Success

- Confirm command used the intended root via `-C`.
- Confirm output file exists when `-o` is used.
- Confirm requested checks/tests were run.
- Confirm final response matches requested format.
