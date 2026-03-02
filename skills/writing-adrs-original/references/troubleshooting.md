# Troubleshooting

## Anti-Patterns to Avoid


| Anti-Pattern     | Symptom                          |
| ---------------- | -------------------------------- |
| Fairy Tale       | Only pros listed, no trade-offs  |
| Sales Pitch      | Marketing language, no evidence  |
| Free Lunch       | Consequences hide real costs     |
| Dummy Alt        | Fake options to justify choice   |
| Blueprint        | Implementation details, not why  |
| Mega-ADR         | Multiple decisions in one doc    |
| Sprint           | Only one option, no alternatives |
| Tunnel Vision    | Ignores ops, maintenance, scale  |

**The #1 mistake:** Turning an ADR into a design document.
An ADR records the **decision and rationale**, not the
implementation plan. If your Decision section has code
snippets, service definitions, or deployment diagrams,
you have a blueprint, not an ADR. Move implementation
details to a separate design document and reference it
from the "More Information" section.

## Common Mistakes


- **Skipping alternatives**: Always list at least 2 real
  options. "Do nothing" counts as a valid alternative.
- **Vague context**: The context should make the problem
  obvious to someone unfamiliar with the project.
- **Missing consequences**: Every decision has downsides.
  If you cannot name any, you have not thought hard enough.
- **No confidence level**: State whether this decision was
  made with high confidence or is a best guess under
  uncertainty. Low confidence flags future review needs.
- **Combining decisions**: One ADR per decision. If you
  find yourself writing "and we also decided...", split
  it into a separate ADR.
- **Stale statuses**: Update ADR status when decisions
  are superseded. Link old and new ADRs bidirectionally.

