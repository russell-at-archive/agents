# Troubleshooting

## Fast Diagnosis Checklist

1. Confirm CLI and auth:
   `gt --version`, `gt auth`, `gt config`.
2. Confirm repo is Graphite-initialized:
   `gt trunk`, `gt log`.
3. Inspect working tree:
   `git status`.
4. Inspect stack topology:
   `gt log --stack`.

## Common Failures

| Symptom                 | Likely cause      | Action              |
| ----------------------- | ----------------- | ------------------- |
| Wrong PR parent         | ancestry drift    | `gt restack`        |
| Submit out-of-date refs | stale trunk/refs  | `gt sync`           |
| Rebase conflict         | patch collision   | resolve + continue  |
| Draft/no reviewer       | submit flags used | rerun with flags    |
| Branch missing in log   | untracked branch  | `gt track <branch>` |
| Local metadata drift    | rename/delete mix | run sync + restack  |

## Red Flags - Stop Before Proceeding

- About to run `git rebase`, `git push`, or `gh pr create` for stack work.
- About to use `--force` on `gt submit` without explicit user approval.
- Attempting to resolve an old halted operation without checking `gt continue`
  or `gt abort`.
- Stack graph looks incorrect but submitting anyway.

## Conflict Recovery Template

When `gt restack`, `gt sync`, or `gt submit --restack` hits conflicts:

1. Run `git status` to see conflicted files.
2. Resolve conflict markers in files.
3. Stage resolved files with `git add <file>`.
4. Continue with `gt continue`.
5. If recovery is wrong, stop with `gt abort`.

Do not launch new Graphite mutations until this flow is complete.

## Escalation Criteria

Escalate to the user when:

- trunk branch selection is unclear
- force push is required on a shared branch
- stack rewrite would invalidate existing review comments
- Graphite reports metadata drift that cannot be fixed by `gt sync` +
  `gt restack`
