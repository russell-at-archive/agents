# Writing Pull Requests: Troubleshooting

## Missing Inputs

### Symptom

No issue ID, no test evidence, or unclear change intent.

### Action

- Produce a draft with clearly marked placeholders.
- Add an "Open Questions" block listing exact missing artifacts.
- Do not claim completion or ready-for-review status.

## Contradictory Evidence

### Symptom

Description claims behavior change but tests or logs suggest otherwise.

### Action

- Prefer objective evidence over narrative claims.
- Rewrite claims as hypotheses and request confirmation.
- Flag the PR as needing validation before review.

## Oversized PR

### Symptom

Multiple unrelated concerns or very large blast radius.

### Action

- Recommend splitting by concern (feature, refactor, migration).
- If split is impossible, add explicit review map and risk segmentation.

## Weak Rationale

### Symptom

Approach section states only "implemented as requested".

### Action

- Require explicit trade-off and at least one rejected alternative.
- If no alternatives were considered, flag design risk transparently.

## High-Risk Changes Without Rollback

### Symptom

Schema, infra, auth, or permission changes without rollback plan.

### Action

- Block final readiness language.
- Add rollback commands or operational reversal steps.
- Add monitoring signals to detect regression quickly.

## Anti-Patterns

- Boilerplate text reused without matching the actual diff
- Checkboxes marked complete with no evidence
- Reviewer instructions that require code archaeology
- Hidden breaking changes omitted from summary

## Stop Conditions

Stop and request clarification when:

- validation evidence is absent for critical behavior claims
- security-sensitive changes lack threat or permission analysis
- operational changes lack deploy order and rollback path
