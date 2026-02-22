# Writing Pull Requests: Expert Procedure

## Contents

- Purpose and standards
- Required PR structure
- Section-by-section guidance
- PR type adaptations
- Risk and rollout disclosures
- Quality gate checklist

## Purpose and Standards

A strong PR description does three jobs:

1. Accelerate review by giving context before the reviewer opens files.
2. Preserve decision rationale for future maintainers.
3. Make verification reproducible without tribal knowledge.

Core standard: describe intent, decisions, risks, and verification. Avoid
narrating the diff.

## Required PR Structure

Use this baseline order unless repo conventions differ:

1. Title (Conventional Commit style when applicable)
2. Issue linkage (`Closes #NNN` or `Refs #NNN`)
3. Summary (3-5 bullets: problem, approach, impact)
4. Approach and alternatives considered
5. Risk and mitigation
6. Test plan (exact commands and outcomes)
7. Reviewer verification steps
8. Definition of done checklist

## Section-by-Section Guidance

### Title

- Keep it specific and outcome-oriented.
- Include scope only when it clarifies system boundaries.
- Avoid vague nouns like "updates" or "changes".

### Summary

- Lead with user or system problem.
- State chosen approach and key trade-off.
- End with expected impact (behavior, performance, ops).

### Approach and Alternatives

For non-trivial changes, record:

- Chosen implementation pattern
- At least one rejected alternative
- Why the rejected option was not selected

This section is mandatory for AI-assisted PRs.

### Risk and Mitigation

Classify each meaningful risk:

- Functional risk: behavior regressions
- Data risk: migrations, backfills, loss, ordering
- Operational risk: deploy sequencing, runtime cost, alerts
- Security risk: auth, permissions, secret handling, attack surface

For each risk, include detection and mitigation.

### Test Plan

Make tests reproducible:

- List exact commands run
- Include environment assumptions
- Report pass/fail and notable caveats

Do not claim tests that were not executed.

### Reviewer Verification

Provide minimal deterministic steps:

1. Setup/state assumptions
2. Action performed
3. Expected observable outcome

Prefer steps that validate behavior rather than implementation details.

### Definition of Done

Only check items that are actually complete.
Typical checks:

- Acceptance criteria met
- Lint/typecheck/tests green
- Docs or runbooks updated when needed
- Migrations and rollback documented
- No unresolved TODOs or blockers

## PR Type Adaptations

### Feature PR

Emphasize user value, acceptance scenarios, and rollout guardrails.

### Bug Fix PR

Explain root cause, failure mode, and why fix prevents recurrence.

### Refactor PR

Demonstrate behavioral parity and mention measurable maintainability gains.

### Infra/Platform PR

Document blast radius, change window, rollback, and observability signals.

## Risk and Rollout Disclosures

Include these when relevant:

- Breaking changes and required consumer actions
- Migration order and backward-compatibility window
- Feature flags, staged rollout, and monitoring checkpoints
- Manual fallback or rollback command path

## Quality Gate Checklist

Use before marking ready for review:

- Problem and business/technical impact are explicit
- Design choice and rejected alternatives are documented
- Risks are listed with mitigation and detection
- Validation is reproducible and honest
- Reviewer can verify without digging through every file
- Scope is one logical concern; if not, explain why
