# Writing Task Specs: Examples

## Contents

- Example decomposition map
- Example task: data model change
- Example task: API behavior
- Example task: UI integration
- Weak vs strong acceptance criteria

## Example Decomposition Map

**Feature:** User invitation workflow for team spaces

**Planned tasks and order:**

1. `TASK-001` Add invitation table and indexes
2. `TASK-002` Add invitation domain service and expiry logic
3. `TASK-003` Add invitation create/accept API endpoints
4. `TASK-004` Add invite UI flow and error states
5. `TASK-005` Add telemetry and runbook updates

Reasoning: contracts and persistence precede API, API precedes UI,
operational hardening lands after feature behavior is stable.

## Example Task: Data Model Change

```markdown
# TASK-001: Add invitation persistence schema

> **Parent plan:** PRD-117
> **Branch:** `feat/TASK-001-invitations-schema`
> **Stack parent:** `main`
> **Depends on:** `none`

## Objective

Create the invitations table with status and expiry fields required by the
invitation workflow. This task is first because downstream service and API
behavior depend on these storage contracts.

## Acceptance Criteria

- [ ] Given migrations run, when schema inspection is executed, then
      `team_invitations` exists with `email`, `token_hash`, `status`, and
      `expires_at` columns.
- [ ] Given rollback is executed, when migration state is checked, then the
      table is removed without orphaned indexes.

## Validation Commands

```bash
pnpm db:migrate
pnpm db:rollback
pnpm db:migrate
```
```

## Example Task: API Behavior

```markdown
# TASK-003: Implement invitation create and accept endpoints

> **Parent plan:** PRD-117
> **Branch:** `feat/TASK-003-invitations-api`
> **Stack parent:** `feat/TASK-002-invitation-service`
> **Depends on:** `TASK-001,TASK-002`

## Acceptance Criteria

- [ ] Given an authorized admin and valid email, when `POST /invitations` is
      called, then returns `201` and persists a pending invitation.
- [ ] Given an expired invitation token, when `POST /invitations/accept` is
      called, then returns `410` with error code `INVITE_EXPIRED`.

## Validation Commands

```bash
pnpm test invitations-api.spec.ts
pnpm lint
pnpm typecheck
```
```

## Example Task: UI Integration

```markdown
# TASK-004: Build invite acceptance UI state flow

> **Parent plan:** PRD-117
> **Branch:** `feat/TASK-004-invite-ui`
> **Stack parent:** `feat/TASK-003-invitations-api`
> **Depends on:** `TASK-003`

## Acceptance Criteria

- [ ] Given a valid invitation link, when the page loads, then shows team name
      and enables accept action.
- [ ] Given the token is invalid or expired, when accept is attempted, then
      displays actionable recovery messaging and no retry loop.
```

## Weak vs Strong Acceptance Criteria

Weak:

- "Invitation flow works correctly."
- "Errors are handled."

Strong:

- "Given a reused token, when accept endpoint is called, then returns `409`
  with code `INVITE_ALREADY_USED`."
- "Given network timeout on accept, when user retries, then exactly one
  successful membership is created."
