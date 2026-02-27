# {type}({scope}): {short description}

> Closes #{task issue number}
> Stack parent: `{parent branch or main}`

---

## Summary

{3–5 bullets. What changed and why. The diff shows the
what — this section explains the reasoning and context.
Do not restate the code changes.}

- {Why this change was needed}
- {Key decision or trade-off made}
- {Anything non-obvious a reviewer should know}

## Type of Change

- [ ] `feat` — new capability
- [ ] `fix` — bug correction
- [ ] `refactor` — code restructure, no behavior change
- [ ] `perf` — performance improvement
- [ ] `test` — test coverage only
- [ ] `docs` — documentation only
- [ ] `chore` — tooling, config, dependencies
- [ ] `feat!` — breaking change

## Approach and Alternatives Considered

{Explain the implementation approach chosen and why.
List alternatives that were considered and rejected.
This is the primary audit record — future reviewers
(human and agent) rely on this to understand decisions.

Example:
"Implemented as a middleware function rather than inline
in the route handler so it can be reused across multiple
endpoints without duplication. Considered a decorator
pattern but rejected it because the codebase does not
use TypeScript decorators elsewhere."}

**Alternatives rejected:**

- {Alternative}: {Why it was rejected}
- {Alternative}: {Why it was rejected}

## Test Plan

{Describe exactly what was run to verify this change.
Be specific enough that a reviewer can reproduce.}

```bash
{commands run to verify the change}
```

**Tested scenarios:**

- [ ] {Happy path scenario}
- [ ] {Error handling scenario}
- [ ] {Edge case}

## How to Verify

{Step-by-step instructions for the reviewer to verify
the change works correctly. Do not make the reviewer
figure this out from the diff.}

1. {Setup step if needed}
2. {Action to take}
3. {What to observe — expected output, behavior, or
   state change}

## Definition of Done

- [ ] Acceptance criteria from linked task pass
- [ ] Validation commands pass (lint, typecheck, tests)
- [ ] PR title follows Conventional Commits format
- [ ] Approach and alternatives documented above
- [ ] No unresolved review comments
- [ ] Stacked correctly against parent branch
