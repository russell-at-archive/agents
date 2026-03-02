# Examples

## Run One Task Non-Interactively

```bash
codex exec --full-auto -C /path/to/repo \
  -o /tmp/codex-lint-fix.md \
  "Fix lint errors in src/auth only. Run tests for touched files. \
Return a short summary plus changed file list."
```

## Dispatch Independent Tasks in Parallel

Use unique output files per task.

```bash
codex exec --full-auto -C /path/to/repo \
  -o /tmp/codex-task-auth.md \
  "Add validation tests for auth handlers."

codex exec --full-auto -C /path/to/repo \
  -o /tmp/codex-task-api.md \
  "Document API error codes in docs/api-errors.md."

codex exec --full-auto -C /path/to/repo \
  -o /tmp/codex-task-ui.md \
  "Refactor button variants in ui/components/button.tsx."
```

## Send Prompt from stdin

```bash
cat <<'PROMPT' | codex exec --full-auto -C /path/to/repo -
# Task
Review Terraform module defaults.

## Constraints
- Change only terraform/modules/vpc.
- Do not run apply.

## Output
Return a risk list and suggested patch.
PROMPT
```

## Emit JSONL for Tooling

```bash
codex exec --full-auto -C /path/to/repo --json \
  "Summarize flaky tests and propose stabilization steps."
```

## Resume a Non-Interactive Session

```bash
codex exec resume --last --full-auto \
  "Continue and finish remaining test fixes. \
Write final summary to /tmp/codex-resume.md."
```

## Run Code Review Mode

```bash
codex review --base main \
  "Focus on regressions, missing tests, and security risks."
```

## Review Working Tree Changes

```bash
codex review --uncommitted \
  "Prioritize correctness and backward compatibility issues."
```
