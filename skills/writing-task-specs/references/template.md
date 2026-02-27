# TASK-{NNN}: {Imperative title — e.g. "Add rate limiting to auth endpoint"}

> **Parent spec:** #{PRD issue number} — {Feature Name}
> **Branch:** `{type}/{TASK-NNN}-{short-slug}`
> **Stack parent:** `{parent branch or main}`
> **Depends on:** TASK-{NNN} *(or "none")*

---

## Description

{2–4 sentences. What needs to be built and why. Tie this
to the parent spec. Avoid implementation details — describe
the outcome, not the approach.

Example: "Users currently have no way to recover a forgotten
password. This task adds the password reset request flow:
the endpoint that accepts an email, validates it, and sends
a reset link. Part of FR-3 in the authentication PRD."}

## Acceptance Criteria

Each criterion must be independently verifiable. Write in
Given/When/Then format.

- [ ] Given {precondition},
      when {action},
      then {observable outcome}.
- [ ] Given {error condition},
      when {action},
      then {expected behavior — error message, status code,
      fallback}.
- [ ] Given {edge case},
      when {action},
      then {outcome}.

## Files to Change

*List files the Coder agent is expected to create or
modify. This prevents unintended scope expansion.*

**Create:**

- `{path/to/new/file}` — {brief purpose}

**Modify:**

- `{path/to/existing/file}` — {what changes and why}

**Do not touch:**

- `{path/to/file}` — {reason, e.g. "owned by TASK-042",
  "out of scope for this task"}

## Testing Requirements

{Describe what tests must be written or updated. Be
specific about test type and coverage expectation.}

- [ ] Unit test: {what behavior to cover}
- [ ] Integration test: {what scenario to cover}
- [ ] Edge case: {what to verify}

## Validation Commands

```bash
# Run after implementation to verify the task is complete.
# All commands must pass before opening a PR.

{command to run tests for affected module}
{command to run linter}
{command to run type checker if applicable}
{command to verify specific behavior if testable via CLI}
```

## Definition of Done

- [ ] All acceptance criteria pass
- [ ] All validation commands pass
- [ ] No new lint or type errors introduced
- [ ] Tests written and passing
- [ ] PR opened and linked to this issue (`Closes #{NNN}`)
- [ ] PR description complete (summary, approach, test plan)
