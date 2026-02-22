# Structuring Git Commits: Examples

## Example 1: Feature with Mixed Refactor

Input change set:

- `src/auth/session.ts` has behavior updates and helper rename.
- `src/auth/session.test.ts` updates assertions.
- `docs/auth.md` adds new session notes.

Recommended commit plan:

1. `refactor(auth): rename session helper for clarity`
2. `feat(auth): enforce idle timeout on session validation`
3. `test(auth): cover idle timeout and renewal path`
4. `docs(auth): document idle timeout behavior`

Why this works:

- Structural rename is separated from behavior.
- Tests validate one behavior commit, not mixed edits.
- Docs stay independent and low risk.

## Example 2: Bug Fix with Incidental Formatting

Input change set:

- `src/cache/store.ts` fixes stale value eviction.
- Same file has broad formatter churn from a local tool.

Recommended commit plan:

1. Stage only bug-fix hunks with `git add -p`.
2. Commit the bug fix:
   - `fix(cache): evict stale values on read miss`
3. Decide with the user whether to keep or discard pure formatting churn.

Why this works:

- Bug context stays readable.
- Mechanical noise does not hide logic.
- Future `git blame` and reverts stay precise.

## Example 3: Dependency Update with Code Changes

Input change set:

- Lockfile and dependency versions updated.
- Source changes adapt to a new API.
- Tests adjusted for new API behavior.

Recommended commit plan:

1. `chore(deps): bump parser library to vX.Y`
2. `refactor(parser): adapt call sites to new parse result`
3. `test(parser): align fixtures with new parser behavior`

Why this works:

- Upgrade source is explicit.
- Behavior adaptation is reviewable on its own.
- Test drift is tied to the behavior update.
