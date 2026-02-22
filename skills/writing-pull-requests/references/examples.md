# Writing Pull Requests: Examples

## Contents

- Strong vs weak summary
- Complete example: bug fix PR
- Complete example: infra PR
- Reviewer prompt example

## Strong vs Weak Summary

### Weak

- "Updated API code and tests."
- "Refactored auth flow."

Problems: no user impact, no rationale, no review focus.

### Strong

- "Fixes intermittent 401s during token refresh by serializing refresh
  requests per session."
- "Moves token refresh to middleware so retry behavior is consistent across
  all protected routes."
- "Accepts a minor latency increase during refresh to eliminate duplicate
  refresh races and stale token writes."

## Complete Example: Bug Fix PR

```markdown
# fix(auth): prevent duplicate token refresh races

Closes #482

## Summary

- Fixes intermittent 401 responses caused by concurrent token refresh
  requests writing stale credentials.
- Introduces per-session refresh locking in auth middleware instead of route-
  local guards to centralize behavior.
- Trades small refresh-path latency for deterministic credential state and
  lower auth error rate.

## Approach and Alternatives Considered

Implemented a per-session async lock around refresh calls in middleware so all
protected endpoints share one refresh policy.

Alternatives rejected:

- Client-side debounce only: reduced frequency but did not prevent server-side
  races across tabs.
- Redis distributed lock: unnecessary operational overhead for a single-region
  deployment.

## Risk and Mitigation

- Risk: lock contention increases p95 latency during refresh spikes.
  Mitigation: timeout lock wait at 2s and emit metric
  `auth.refresh.lock_wait_ms`.

## Test Plan

```bash
pnpm test auth-refresh.spec.ts
pnpm test auth-middleware.spec.ts
pnpm lint
```

All listed commands passed locally on macOS with Node 20.

## How to Verify

1. Sign in on two browser tabs with the same account.
2. Force token expiry and trigger requests simultaneously.
3. Confirm no 401 responses and only one refresh call per session in logs.

## Definition of Done

- [x] Linked issue resolved
- [x] Tests and lint pass
- [x] Metrics added for lock wait observability
- [x] No unresolved TODOs
```

## Complete Example: Infra PR

```markdown
# chore(infra): rotate worker queue to encrypted storage class

Refs #919

## Summary

- Moves queue persistence volume to encrypted storage class to satisfy policy
  INF-12.
- Applies change via rolling replacement to avoid queue downtime.
- Adds dashboard panel for queue depth and worker restart counts during rollout.

## Risk and Mitigation

- Risk: transient backlog growth during pod replacement.
  Mitigation: roll one pod at a time and pause if queue depth exceeds 2x
  baseline.
- Risk: storage class misconfiguration in staging/production parity.
  Mitigation: validate class and PVC binding in staging before production apply.

## Rollback

Reapply previous Helm values file and restart workers in reverse order.
```

## Reviewer Prompt Example

Use when asked to "tighten this PR description":

1. Replace diff narration with problem and impact.
2. Add at least one rejected alternative.
3. Add deterministic verification steps with expected outcomes.
4. Add rollback notes for infra or schema changes.
