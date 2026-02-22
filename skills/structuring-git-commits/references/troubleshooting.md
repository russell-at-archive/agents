# Structuring Git Commits: Troubleshooting

## Common Mistakes

- Mistake: "One big commit is faster."
  - Impact: Review quality drops and regressions are harder to isolate.
  - Fix: Split by intent using hunk-level staging.
- Mistake: Tests committed far from behavior changes.
  - Impact: Intermediate history becomes misleading.
  - Fix: Pair tests with the behavior commit they validate.
- Mistake: "cleanup" commit includes real logic.
  - Impact: Risk is hidden from reviewers.
  - Fix: Extract behavioral hunks into explicit commits.
- Mistake: Generated files mixed with handwritten edits.
  - Impact: Signal-to-noise ratio collapses.
  - Fix: Separate generated artifacts or regenerate in a dedicated commit.

## Decision Tie-breakers

When two split options both seem valid:

- Prefer the option with simpler revert behavior.
- Prefer smaller diff surfaces per commit.
- Prefer order that keeps CI and local checks meaningful.
- If still tied, ask the user which review style they prefer:
  - "foundation-first" or "user-visible-first".

## Recovery Patterns

- Staging got messy:
  - Run `git restore --staged .` and restage by commit group.
- Wrong files are already committed:
  - Use `git reset --soft HEAD~1`, then restage into clean commits.
- Lost track of intent:
  - Write one-line intent labels for each planned commit before staging.

## Red Flags Requiring Pause

- Security-sensitive changes mixed with unrelated refactors.
- Migration scripts bundled with feature logic.
- Rename/move sweeps with behavior edits in the same commit.
- Commit plan requires explanations longer than the code changes.

When a red flag appears, pause and present a safer split plan before
continuing.
