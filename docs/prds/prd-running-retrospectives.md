# running-retrospectives PRD

| Field | Value |
| :--- | :--- |
| **Status** | Draft |
| **Author** | Gemini CLI |
| **Updated** | 2026-03-02 |
| **Reviewers** | [User] |

## 1. Context & Problem
Without a feedback loop, the development process remains static. Bottlenecks in planning, implementation, or review go unaddressed, and agents repeat the same procedural mistakes. `docs/collaboration-process.md` mandates a "Learning Loop," but agents need a skill to systematically analyze their own performance and the project's friction points to improve the collective "Agent OS."

## 2. Outcomes & Success Metrics
- **Goal**: To continuously optimize the delivery pipeline by identifying and resolving process bottlenecks through structured post-delivery analysis.
- **KPI-1**: 15% reduction in "Lead Time to Merge" over 3 months.
- **KPI-2**: 100% of "Critical Failures" result in a concrete update to a checklist, template, or skill.

## 3. Users & Use Cases
**Primary Persona**: Self-Improving Engineering Agent

**User Story**:
As an agent, I want to reflect on the recently completed feature so that I can identify what slowed us down and how we can prevent it next time.

## 4. Functional Requirements
- **FR-1**: **Performance Data Aggregation**: Collect metrics on lead time, review cycles, and rework rate for the feature.
- **FR-2**: **Bottleneck Identification**: Identify specific stages (e.g., "Clarification," "Integration") where significant delays occurred.
- **FR-3**: **Root Cause Analysis (RCA)**: Perform a "5 Whys" analysis on any major bugs or delivery failures.
- **FR-4**: **Actionable Improvement Generation**: Propose specific changes to `README.md`, `GEMINI.md`, or skill instructions based on retro findings.

## 5. Entity Catalog (AI Grounding)
| Entity | Properties | Description |
| :--- | :--- | :--- |
| **Retrospective** | feature_id, metrics, findings | The structured analysis of a completed delivery cycle. |
| **Process Bottleneck** | stage, delay_duration, cause | A specific step in the SDLC that is hindering velocity. |
| **Improvement Action** | target_file, change_summary | A concrete task to update the system based on retro feedback. |

## 6. AI Context Block
- **Logic Rules**:
  - Always focus on *process* improvements, not individual agent or user "blame."
  - Ensure every retrospective concludes with at least one "Actionable Improvement."
- **Strict Constraints**:
  - Do not update global skills without user approval; summarize proposed changes first.
- **Agent Guidelines**:
  - Follow the "Learning Loop" principles in `docs/collaboration-process.md`.

## 7. Non-Functional Requirements (NFRs)
- **Objectivity**: Analysis must be based on data (git logs, PR timestamps) rather than subjective "vibes."
- **Conciseness**: Retrospective summaries should be readable in under 2 minutes.

## 8. Scope & Non-Goals
**In Scope**:
- Post-delivery analysis of features and projects.
- Identifying process friction and proposing system updates.

**Out of Scope**:
- Personal performance reviews of human collaborators.
- Financial or budget-level retrospectives.

## 9. Risks & Assumptions
- **Risk**: Retros can become "check-the-box" exercises without meaningful change. - **Mitigation**: Track the implementation of "Improvement Actions" as a secondary KPI.
- **Assumption**: There is enough metadata (git logs, PR history) to perform a quantitative analysis.

## 10. Rollout & Safety
- **Phased Release**: Conduct retros for "Major Features" (>2 weeks) first; move to "Minor Features" as the process matures.
- **Rollback Strategy**: If the retro process itself adds more overhead than the value it provides, simplify the template to a 3-bullet summary.

## 11. Acceptance Criteria
- **AC-1**: Given a feature that took 3x longer than estimated, When the skill is run, Then it identifies "Lack of initial API spec" as the primary bottleneck.
- **AC-2**: Given a major production bug, When the skill is run, Then it proposes an update to `prd-running-quality-gates.md` to include a specific new check.

## 12. Changelog
| Version | Date | Author | Change |
| :--- | :--- | :--- | :--- |
| 0.1 | 2026-03-02 | Gemini CLI | Initial Draft |
