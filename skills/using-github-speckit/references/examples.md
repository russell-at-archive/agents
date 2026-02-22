# Examples

## Starter Prompts

Adapt these templates to the user's domain and constraints.

### `/constitution` starter

```text
/constitution Define project guardrails for <project>.
Cover priorities, constraints, quality standards,
and decision principles used for future specs and plans.
```

### `/specify` starter

```text
/specify Build <feature name> for <product/project>.
Goal: <user outcome>.
Constraints: <time, platform, compliance, performance>.
Success criteria: <measurable outcomes>.
Out of scope: <explicit exclusions>.
```

### `/clarify` starter

```text
/clarify Resolve unresolved requirements for <feature name>.
Focus on edge cases, non-functional constraints,
and conflicting assumptions. Propose defaults when missing.
```

### `/plan` starter

```text
/plan Create a technical implementation plan for <feature name>.
Include architecture, data model changes, API/UI impact,
tradeoffs, rollout strategy, and validation approach.
```

### `/tasks` starter

```text
/tasks Break the approved plan for <feature name> into ordered,
independently verifiable tasks. Include dependencies,
acceptance criteria, and validation steps per task.
```

## Good Versus Weak Task Example

Weak task:

- Add backend endpoint.

Strong task:

- Implement `POST /v1/reports` endpoint with schema validation,
  auth checks, and persistence.
- Acceptance criteria: invalid payload returns 400,
  unauthorized requests return 401, valid request persists record.
- Validation: `npm test -- report-endpoint`.
