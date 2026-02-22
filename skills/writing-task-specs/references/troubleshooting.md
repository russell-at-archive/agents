# Writing Task Specs: Troubleshooting

## Missing Plan Quality

### Symptom

Source plan lacks concrete interfaces, constraints, or rollout assumptions.

### Action

- Pause decomposition.
- Request missing inputs as a short checklist.
- Avoid inventing architecture details.

## Scope Bleed

### Symptom

Task includes unrelated outcomes or broad refactor plus behavior change.

### Action

- Split by logical concern and rollback path.
- Move refactors into dedicated prep or follow-up tasks.
- Re-check each task for independent verification.

## Hidden Dependencies

### Symptom

A task requires contracts or artifacts not yet delivered.

### Action

- Add explicit `Depends on` links.
- Reorder stack to place producers before consumers.
- If dependency is external, document it as a blocker.

## Weak Acceptance Criteria

### Symptom

Criteria are non-measurable or implementation-focused.

### Action

- Rewrite into Given/When/Then with observable outputs.
- Include at least one edge or failure mode.
- Add thresholds for performance/security-sensitive behavior.

## Over-Sized Task

### Symptom

Estimated size or blast radius suggests multi-PR execution.

### Action

- Split along subsystem or contract boundaries.
- Preserve shippable value in each resulting task.
- Keep each task reviewable without opening sibling PRs.

## Validation Gaps

### Symptom

Commands are missing, flaky, or too broad to prove task completion.

### Action

- Add targeted tests tied to acceptance criteria.
- Keep lint/type checks required for touched modules.
- Remove commands that are known unrelated failures.

## Stop Conditions

Stop and request clarification when:

- dependency graph is cyclic or ambiguous
- acceptance criteria cannot be made measurable
- task boundaries conflict with required rollout sequencing
- security-critical behavior lacks explicit verification
