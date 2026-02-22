# Structuring Git Commits: Full Procedure

## Contents

- Principles
- Step-by-step workflow
- Boundary tests
- Ordering rules
- Pre-push quality gate

## Principles

- Optimize for reviewer comprehension, not commit count.
- Keep each commit reversible without collateral rollback.
- Isolate risk early so regressions are easy to bisect.
- Encode intent in structure: setup, behavior, tests, docs.

## Step-by-step Workflow

1. Collect context.
   - Run `git status --short` to map touched files.
   - Run `git diff` and, if needed, `git diff --name-only`.
2. Draft change groups.
   - Create tentative groups by intent, not file type.
   - Typical groups:
     - Mechanical prep (renames, move-only changes)
     - Core behavior change
     - Test updates
     - Documentation or examples
3. Refine groups at hunk level.
   - Use `git add -p` to isolate mixed files.
   - If a hunk mixes intents, edit the patch and split manually.
4. Validate each group with boundary tests below.
5. Sequence commits.
   - Put prerequisite refactors first.
   - Put behavior change before tests that assert it.
   - Put docs last unless docs are needed to explain migration steps.
6. Verify each candidate commit.
   - Inspect staged diff with `git diff --staged`.
   - Confirm the commit can stand on its own.
7. Final gate before pushing.
   - Ensure no unstaged leftovers that belong in prior commits.
   - Ensure sequence tells a coherent story from start to finish.

## Boundary Tests

Apply these tests to every proposed commit:

- Single-purpose test:
  - Can the change be summarized in one sentence without "and"?
- Revert test:
  - Could this commit be reverted independently?
- Review test:
  - Would a reviewer understand "why" from this diff alone?
- Build test:
  - Is the branch still in an acceptable state after this commit?
- Noise test:
  - Are formatting, generated files, or unrelated renames excluded?

If two or more tests fail, split the commit further.

## Ordering Rules

- Foundation before behavior:
  - Move/refactor/setup commits before functional deltas.
- Producer before consumer:
  - Add shared API or schema changes before dependent code.
- Assertions near behavior:
  - Keep tests close to the behavior change they validate.
- Lowest blast radius first:
  - Put broad, risky edits in isolated commits for easy bisect.

## Pre-push Quality Gate

Before opening review:

- Every commit is atomic and has clear intent.
- Commit sequence can be read top to bottom as a narrative.
- No "misc", "cleanup", or "final fixes" commits hide core logic.
- Remaining working tree state is intentional.
