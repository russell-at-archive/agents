# TASK-{NNN}: {Imperative title}

> **Parent plan:** {spec/issue/PRD identifier}
> **Branch:** `{type}/TASK-{NNN}-{short-slug}`
> **Stack parent:** `{main|trunk|parent-branch}`
> **Depends on:** `{none|TASK-001,TASK-002}`
> **Risk level:** `{low|medium|high}`
> **Estimated scope:** `{~NNN lines, N files}`

## Objective

{2-4 sentences describing what will be delivered and why this task exists in
this position of the stack.}

## In Scope

- {explicit change 1}
- {explicit change 2}

## Out of Scope

- {adjacent change not allowed in this task}
- {another boundary to prevent scope bleed}

## Acceptance Criteria

- [ ] Given {context}, when {action}, then {observable outcome}.
- [ ] Given {context}, when {action}, then {observable outcome}.
- [ ] Given {edge/failure context}, when {action}, then {safe behavior}.

## Implementation Notes

- {critical constraint, invariant, or migration/ordering note}
- {contract assumptions this task must preserve}

## Files Expected to Change

**Create:**

- `{path}` - {purpose}

**Modify:**

- `{path}` - {purpose}

**Do not touch:**

- `{path}` - {reason}

## Validation Commands

```bash
# Run after implementation
{targeted test command}
{lint command}
{typecheck command if applicable}
{smoke/integration command if applicable}
```

## Definition of Done

- [ ] Acceptance criteria verified
- [ ] Validation commands pass
- [ ] No new lint/type/test regressions
- [ ] Branch opened against listed stack parent
- [ ] PR links to TASK-{NNN} and states verification steps
