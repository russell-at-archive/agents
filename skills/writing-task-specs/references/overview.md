# Writing Task Specs: Expert Procedure

## Contents

- Objective and operating principles
- Inputs and readiness checks
- Decomposition workflow
- Dependency and stack design
- Acceptance criteria standard
- Validation and definition of done
- Sizing model
- Final quality gate

## Objective and Operating Principles

Task specs convert approved plans into executable delivery units.

Primary outcomes:

1. Parallelizable execution without hidden coupling.
2. Fast review with minimal cross-PR context switching.
3. High confidence rollout via explicit validation and acceptance gates.

Operating principles:

- One task -> one branch -> one PR.
- One logical concern per task.
- Independent verifiability is mandatory.
- Dependency order must mirror stack order.

## Inputs and Readiness Checks

Before decomposition, confirm the source plan includes:

- Scope boundary (in scope, out of scope)
- Functional requirements or outcomes
- Non-functional constraints (performance, security, reliability)
- Interfaces touched (API, DB schema, jobs, UI, infra)
- Delivery constraints (release window, migrations, rollout model)

If these are incomplete, produce a short "missing inputs" list and pause.

## Decomposition Workflow

### Step 1: Identify delivery slices

Partition work by dependency and reviewer value:

- Foundational infrastructure/scaffolding
- Schema and contract changes
- Business logic
- Consumer layers (UI/API clients)
- Observability and operational hardening
- Tests and cleanup where independent

Avoid slicing by team ownership alone if it creates cross-task coupling.

### Step 2: Draft candidate tasks

For each slice, draft:

- Imperative title
- Why this slice exists
- Expected artifacts (files/systems touched)
- Primary risk category

Then test each candidate for independent implementability.

### Step 3: Apply task quality filters

Each task must pass all checks:

- Independent: can build and validate without unfinished sibling tasks.
- Valuable: produces a meaningful increment, not a placeholder.
- Estimable: clear enough to estimate scope and effort.
- Small: target under ~400 net changed lines and under ~10 files.
- Testable: objective pass/fail criteria exist.

If a candidate fails, split, merge, or reorder.

### Step 4: Encode dependencies and stack parent

For each task define:

- `Depends on`: task IDs, or `none`
- `Stack parent`: branch base for the PR

Rules:

- No circular dependencies.
- Prefer shortest valid stack depth.
- Put contract producers before consumers.
- Separate mechanical refactors from behavioral changes.

### Step 5: Write acceptance criteria

Use Given/When/Then with measurable outcomes only.

Good criterion shape:

- Given explicit precondition
- When a concrete action occurs
- Then an observable output/state change is produced

Avoid vague verbs: "works", "improves", "handles", "supports".

### Step 6: Attach validation commands

Commands must be copy-paste runnable and scoped to task changes.
Include:

- Targeted tests
- Lint/type checks relevant to touched code
- Optional smoke/integration checks when risk demands it

Do not include commands that are known to fail in the current repo state.

## Dependency and Stack Design

Recommended ordering pattern:

1. Data model / storage primitives
2. Domain logic
3. API or service integration
4. UI/consumer integration
5. Cross-cutting hardening and telemetry

For stacked PR delivery:

- Keep each PR reviewable without opening all descendants.
- Ensure parent PRs expose stable contracts used by children.
- Avoid long-lived speculative branches with unclear merge path.

## Acceptance Criteria Standard

Minimum bar per task:

- At least 2 criteria
- Covers happy path and at least one failure/edge path
- Includes user/system-observable outputs

Performance/security-sensitive tasks should add explicit thresholds, such as:

- latency target
- error budget bound
- auth/permission behavior

## Validation and Definition of Done

Each task must include a definition-of-done checklist with:

- Acceptance criteria verified
- Validation commands passed
- No new lint/type/test regressions
- Branch and PR opened against correct stack parent
- PR links back to task ID

## Sizing Model

Split tasks when any signal appears:

- Multiple subsystems changed with different rollback paths
- Reviewer needs to understand unrelated context to approve
- Net change likely exceeds 400 lines without being mechanical
- Task cannot be described in one imperative sentence

Merge tasks when signals appear:

- Two tasks cannot be validated independently
- One task only creates placeholders with no shippable value
- Artificial split increases coupling and review overhead

## Final Quality Gate

Before handoff, verify:

- All tasks have unique IDs
- Dependency graph is acyclic
- Stack parent is defined for every task
- All acceptance criteria are measurable
- Validation commands are runnable
- Total task set covers full approved scope without spillover
