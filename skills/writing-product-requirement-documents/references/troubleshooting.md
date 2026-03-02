# Product Requirement Document (PRD) Troubleshooting

## Common Mistakes & Anti-Patterns

### 1. Solution First
- **Symptom**: The PRD describes the UI buttons or database schema
  before explaining the user problem.
- **Fix**: Re-read the "Context & Problem" section. Ensure it defines the
  "what" and "why" without prescribing the "how."

### 2. Vague Metrics
- **Symptom**: "Make the app faster," "improve UX," "delight users."
- **Fix**: Use measurable KPIs with baselines. (e.g., "p95 latency
  from 1200ms to 400ms").

### 3. Missing AI Grounding
- **Symptom**: AI coding agents struggle to implement correctly or
  hallucinate field names.
- **Fix**: Explicitly define the Entity Catalog and AI Context Block.

### 4. Spec Bloat
- **Symptom**: The PRD is 50+ pages and covers 20 different features.
- **Fix**: Use Non-Goals to cut scope. Split into multiple smaller PRDs
  if needed.

---

## Red Flags

- **Undefined Baselines**: If you don't know where you are starting
  (baseline), you can't measure success.
- **Over-Optimization**: Adding complex AI logic for a problem that can
  be solved with a simple regex.
- **Zero Acceptance Criteria**: No way to verify if the feature is
  "done."
- **Ignoring NFRs**: Failing to account for security, performance, or
  accessibility until after implementation.

---

## FAQ

**Q: Where should the PRD live?**
A: In the code repository (e.g., `docs/prds/`) as a Markdown file. This
ensures it version-controlled and accessible to AI agents.

**Q: Who should review the PRD?**
A: Engineering (for feasibility), Design (for UX), and Stakeholders (for
business value).

**Q: When is a PRD "done"?**
A: When it is approved by all key reviewers and contains enough detail
for an engineer (or AI agent) to begin implementation without guessing.
