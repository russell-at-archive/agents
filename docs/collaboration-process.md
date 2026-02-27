# Collaboration Process

## Working Model

1. Intake

- You state outcome, constraints, deadline, and definition of done.
- I restate scope, risks, and assumptions in 5-10 lines before work
  starts.

2. Spec First

- We write a short spec before coding:
  - Problem
  - Non-goals
  - Acceptance criteria
  - Risks
  - Rollout/rollback
- No implementation starts until this is concrete.

3. Decompose

- Split into small, independently shippable slices.
- Each slice has:
  - Owner
  - Test plan
  - Observable output
  - Exit criteria

4. Build Loop

- For each slice: `plan -> implement -> verify -> summarize`.
- I make changes directly, run checks, and report:
  - What changed
  - Why
  - Evidence (tests/lint/output)
  - Remaining risk

5. Quality Gates

- Merge only if:
  - Acceptance criteria pass
  - Tests added/updated
  - Docs updated
  - No unknown critical risk
- If tradeoffs exist, I present options with recommendation.

6. Decision Discipline

- Major decisions get lightweight ADRs:
  - Context
  - Decision
  - Consequences
  - Revisit trigger

7. Release Discipline

- Every release includes:
  - Change summary
  - Monitoring checks
  - Rollback steps
  - Post-release validation window

8. Learning Loop

- After each feature, 10-minute retro:
  - What slowed us down
  - What broke
  - What to standardize
- Feed this into templates and checklists.

## How We Operate Day-to-Day

- You provide goals and priorities.
- I drive execution and keep you updated at each milestone.
- We prefer small PRs, explicit contracts, and measurable outcomes over
  big-bang changes.
