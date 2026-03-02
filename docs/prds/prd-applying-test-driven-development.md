# applying-test-driven-development PRD

| Field | Value |
| :--- | :--- |
| **Status** | Draft |
| **Author** | Gemini CLI |
| **Updated** | 2026-03-02 |
| **Reviewers** | [User] |

## 1. Context & Problem
Agents often write code first and "backfill" tests later, leading to code that is hard to test and suites that miss critical edge cases. `docs/methodologies/test-driven-development.md` identifies the Red-Green-Refactor loop as the gold standard for quality, but agents need a skill that explicitly enforces this discipline to ensure 100% intentional test coverage.

## 2. Outcomes & Success Metrics
- **Goal**: To ensure that every line of implementation code is written in response to a specific, failing test case.
- **KPI-1**: 100% test coverage for all new business logic modules.
- **KPI-2**: 40% reduction in "bug-fix" loops during the PR review phase.

## 3. Users & Use Cases
**Primary Persona**: Quality-First Engineering Agent

**User Story**:
As an agent, I want to follow the Red-Green-Refactor loop so that I can produce verifiable, minimal, and high-quality code.

## 4. Functional Requirements
- **FR-1**: **Red Phase Enforcement**: Write a failing unit test that describes the next small increment of behavior.
- **FR-2**: **Green Phase Enforcement**: Implement the *minimum* amount of code necessary to pass the test.
- **FR-3**: **Refactor Phase Guidance**: Clean up the code (readability, design) while ensuring tests stay green.
- **FR-4**: **Bug Reproduction**: When a bug is reported, write a failing test that reproduces it *before* fixing.

## 5. Entity Catalog (AI Grounding)
| Entity | Properties | Description |
| :--- | :--- | :--- |
| **Unit Test** | suite_name, test_case, expected_outcome | An automated check for a single unit of logic. |
| **Failing Test (Red)** | error_message, failing_line | A test that correctly identifies a missing feature or bug. |
| **Minimal Implementation** | lines_of_code, pass_status | The smallest change required to satisfy the current "Red" test. |

## 6. AI Context Block
- **Logic Rules**:
  - Never write more implementation code than is required to pass the current failing test.
  - Always run the full suite after the "Refactor" phase to ensure no regressions.
- **Strict Constraints**:
  - Do not skip the "Red" phase, even for "obvious" fixes.
- **Agent Guidelines**:
  - Follow the "Detroit" or "London" styles as specified in `docs/methodologies/test-driven-development.md`.

## 7. Non-Functional Requirements (NFRs)
- **Speed**: The test suite must be fast enough to run continuously during the development loop.
- **Precision**: Test failures must clearly indicate what behavior is missing or broken.

## 8. Scope & Non-Goals
**In Scope**:
- Unit and integration testing logic.
- Red-Green-Refactor workflow execution.

**Out of Scope**:
- End-to-End (E2E) testing (unless specifically requested).
- Manual QA or exploratory testing.

## 9. Risks & Assumptions
- **Risk**: TDD can feel slow for very simple UI/styling tasks. - **Mitigation**: Focus TDD on business logic and complex state transitions; use standard validation for pure styling.
- **Assumption**: The project has a working test runner (Jest, PyTest, etc.) configured.

## 10. Rollout & Safety
- **Phased Release**: Mandatory for "Logic" and "Data" modules; optional for "Documentation" or "Chore" tasks.
- **Rollback Strategy**: If TDD overhead exceeds 2x the standard implementation time for simple tasks, adjust the "increment size."

## 11. Acceptance Criteria
- **AC-1**: Given a request to "Calculate tax," When the skill is run, Then it first writes a test with `tax(100) == 10` before adding any code to `tax.js`.
- **AC-2**: Given a reported bug "Tax is negative for zero income," When the skill is run, Then it produces a failing test case `tax(0) == 0` that demonstrates the negative result.

## 12. Changelog
| Version | Date | Author | Change |
| :--- | :--- | :--- | :--- |
| 0.1 | 2026-03-02 | Gemini CLI | Initial Draft |
