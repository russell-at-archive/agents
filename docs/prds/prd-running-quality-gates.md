# running-quality-gates PRD

| Field | Value |
| :--- | :--- |
| **Status** | Draft |
| **Author** | Gemini CLI |
| **Updated** | 2026-03-02 |
| **Reviewers** | [User] |

## 1. Context & Problem
Currently, agents submit PRs that often contain avoidable errors (linting, type-checking, or failing tests), which increases the burden on human reviewers and slows down the delivery pipeline. `docs/delivery-standards.md` defines a "Definition of Done," but there is no automated skill to enforce these gates locally before the PR is even published.

## 2. Outcomes & Success Metrics
- **Goal**: To ensure that every PR submitted by an agent is "Review-Ready" by passing all local quality gates and satisfying the "Definition of Done."
- **KPI-1**: 95% "First-Pass Green" rate in CI for agent-submitted PRs.
- **KPI-2**: 30% reduction in "Nitpick" review comments related to formatting or basic logic errors.

## 3. Users & Use Cases
**Primary Persona**: Diligent Delivery Agent

**User Story**:
As an agent, I want to run a comprehensive suite of local checks so that I can be confident my PR is correct, clean, and ready for merge.

## 4. Functional Requirements
- **FR-1**: **Automated Tool Execution**: Run project-standard linting, type-checking, and formatting tools (e.g., ESLint, TSC, Prettier).
- **FR-2**: **Targeted Test Execution**: Identify and run only the tests relevant to the changed files to ensure fast feedback.
- **FR-3**: **Definition of Done (DoD) Validation**: Compare the current changes against the acceptance criteria specified in the task spec.
- **FR-4**: **PR Size Analysis**: Verify that the PR remains within the recommended bounds (< 400 lines, < 10 files) and flag "Mega PRs" for splitting.

## 5. Entity Catalog (AI Grounding)
| Entity | Properties | Description |
| :--- | :--- | :--- |
| **Quality Gate** | tool_name, command, failure_limit | A specific check (e.g., "Lint") that must pass before submission. |
| **Definition of Done** | task_id, criteria_list, status | The checklist derived from the original implementation task. |
| **PR Health Score** | line_count, file_count, test_coverage | A metric-based evaluation of the PR's reviewability. |

## 6. AI Context Block
- **Logic Rules**:
  - Never submit a PR if any "Critical" quality gate (Tests, Types) is failing.
  - Always summarize the gate results in the PR description as "Evidence of Quality."
- **Strict Constraints**:
  - Do not "auto-fix" linting errors without user confirmation if they change logic.
- **Agent Guidelines**:
  - Follow the "Acceptance Criteria" and "Validation" standards in `docs/delivery-standards.md`.

## 7. Non-Functional Requirements (NFRs)
- **Execution Speed**: The full suite of quality gates should complete in under 2 minutes for most PRs.
- **Verbosity**: Provide clear, actionable error messages for any failing gate.

## 8. Scope & Non-Goals
**In Scope**:
- Local verification of code quality and task completeness.
- Pre-submission analysis of PR size and complexity.

**Out of Scope**:
- Remote CI/CD pipeline management.
- Security vulnerability scanning (handled by specialized tools).

## 9. Risks & Assumptions
- **Risk**: Agents might "force" a submission despite failing gates. - **Mitigation**: Require a "Override Justification" if a gate is skipped.
- **Assumption**: The project has standard linting and testing scripts defined in `package.json` or equivalent.

## 10. Rollout & Safety
- **Phased Release**: Pilot with one "core" repository; expand to all projects once the "First-Pass Green" KPI is met.
- **Rollback Strategy**: If local gates are too slow, allow "Parallel Execution" or skip non-critical checks (e.g., formatting) for urgent hotfixes.

## 11. Acceptance Criteria
- **AC-1**: Given a PR with a typo in a variable name, When the skill is run, Then it identifies the linting error and blocks submission.
- **AC-2**: Given a PR that changes 1,500 lines, When the skill is run, Then it issues a warning that the PR is too large and suggests splitting it.

## 12. Changelog
| Version | Date | Author | Change |
| :--- | :--- | :--- | :--- |
| 0.1 | 2026-03-02 | Gemini CLI | Initial Draft |
