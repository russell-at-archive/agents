# Troubleshooting

## Red Flags

Stop and correct the workflow if any of these occur:

- Jumping from idea directly to `/tasks` without `/plan`
- Starting implementation when the request was planning only
- Missing measurable success criteria in `/specify`
- Plan has tasks but no architecture decisions or tradeoffs
- Tasks are too large to validate independently
- Multi-feature scope packed into one artifact set

## Recovery Playbook

1. Identify the earliest broken stage.
2. Return to that stage and repair artifacts.
3. Re-run downstream stages in order.
4. Re-check quality gates before reporting completion.

## Common Failure Cases

### Ambiguous Requirements

- Run `/clarify`.
- If ambiguity remains, state assumptions explicitly.
- Mark assumptions as review points, not facts.

### Missing Technical Direction

- Expand `/plan` with architecture and tradeoffs.
- Include at least one rejected alternative and reason.

### Low-Quality Tasks

- Split large tasks into independently testable slices.
- Add explicit dependencies and acceptance criteria.
- Add concrete validation commands where possible.

### Premature Implementation Pressure

- Deliver complete planning artifacts first.
- Ask for explicit approval to proceed to `/implement`.
