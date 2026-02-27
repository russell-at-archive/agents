# Examples

## Feature PR

```markdown
# feat(auth): add password reset request endpoint

> Closes #42
> Stack parent: `feat/TASK-003-user-registration`

---

## Summary

- Users had no way to recover a forgotten password, causing
  account lockouts that required manual support intervention
- Adds `POST /auth/password-reset/request` endpoint that
  accepts an email, validates the account exists, and sends
  a time-limited reset token via email
- Token expiry is 1 hour; re-requesting a reset invalidates
  any prior token for that account

## Type of Change

- [x] `feat` — new capability

## Approach and Alternatives Considered

Added the reset token as a separate `password_reset_tokens`
table rather than a column on the `users` table, so tokens
can be invalidated independently and the audit log is
preserved after use.

**Alternatives rejected:**

- JWT-signed token in URL: rejected because we cannot
  invalidate a JWT without a denylist, adding complexity
- Column on users table: rejected because it mixes identity
  data with session data and makes audit queries harder

## Test Plan

\`\`\`bash
npm test -- --testPathPattern=password-reset
npm run lint
\`\`\`

**Tested scenarios:**

- [x] Valid email returns 202 and sends email
- [x] Unknown email returns 202 (no account enumeration)
- [x] Requesting twice invalidates the first token
- [x] Expired token returns 410

## How to Verify

1. Start the dev server: `npm run dev`
2. POST to `/auth/password-reset/request` with a valid
   test account email
3. Check the dev mail catcher at `localhost:8025` for
   the reset email
4. Confirm the token link expires after 1 hour by
   checking `expires_at` in the `password_reset_tokens`
   table

## Definition of Done

- [x] Acceptance criteria from linked task pass
- [x] Validation commands pass (lint, typecheck, tests)
- [x] PR title follows Conventional Commits format
- [x] Approach and alternatives documented above
- [x] No unresolved review comments
- [x] Stacked correctly against parent branch
```

---

## Bug Fix PR

```markdown
# fix(checkout): prevent duplicate order submission on retry

> Closes #87
> Stack parent: `main`

---

## Summary

- Double-clicking the submit button or slow network retries
  were creating duplicate orders in ~0.3% of sessions
- Added idempotency key on the order creation endpoint using
  a client-generated UUID stored in session storage
- Duplicate requests within 5 minutes return the original
  order rather than creating a new one

## Type of Change

- [x] `fix` — bug correction

## Approach and Alternatives Considered

Implemented server-side idempotency using the
`Idempotency-Key` header pattern (same as Stripe) rather
than disabling the button client-side, because disabling
only addresses the double-click case and not network
retries.

**Alternatives rejected:**

- Disable button after first click: too narrow, does not
  handle network retry scenarios
- Unique constraint on (user_id, cart_hash): too fragile,
  cart hash changes if prices update mid-session

## Test Plan

\`\`\`bash
npm test -- --testPathPattern=order-idempotency
npm run lint
\`\`\`

**Tested scenarios:**

- [x] Same key twice returns original order, status 200
- [x] Different key creates new order, status 201
- [x] Key expires after 5 minutes, new order created

## How to Verify

1. Open checkout in two browser tabs simultaneously
2. Submit from both tabs within 1 second
3. Confirm only one order appears in the orders table

## Definition of Done

- [x] Acceptance criteria from linked task pass
- [x] Validation commands pass (lint, typecheck, tests)
- [x] PR title follows Conventional Commits format
- [x] Approach and alternatives documented above
- [x] No unresolved review comments
- [x] Stacked correctly against parent branch
```

---

## Refactor PR

```markdown
# refactor(config): extract environment config into loader module

> Refs #103
> Stack parent: `main`

---

## Summary

- Environment variables were read inline across 14 files
  with no validation, making misconfiguration silent
- Extracted all env access into a single `config/loader.ts`
  module that validates at startup and throws descriptive
  errors for missing required values
- No behavior change — all existing values and defaults
  preserved

## Type of Change

- [x] `refactor` — code restructure, no behavior change

## Approach and Alternatives Considered

Single validated loader called once at startup, rather than
lazy access per callsite. This catches misconfiguration
immediately on deploy rather than when a code path first
executes.

**Alternatives rejected:**

- Zod schema validation: adds a dependency; `process.env`
  shape is simple enough that manual validation is
  sufficient here
- Per-module config objects: would scatter validation
  across files and defeat the purpose of centralizing

## Test Plan

\`\`\`bash
npm run typecheck
npm test
npm run lint
\`\`\`

**Tested scenarios:**

- [x] Missing required var throws on startup with
  descriptive message
- [x] All existing integration tests pass unchanged

## How to Verify

1. Remove a required env var from `.env.test`
2. Run `npm run dev` — confirm it throws immediately
   with a clear error naming the missing variable

## Definition of Done

- [x] Acceptance criteria from linked task pass
- [x] Validation commands pass (lint, typecheck, tests)
- [x] PR title follows Conventional Commits format
- [x] Approach and alternatives documented above
- [x] No unresolved review comments
- [x] Stacked correctly against parent branch
```
