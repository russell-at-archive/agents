# Product Requirement Document (PRD) Template (2025-2026)

```markdown
# [Feature Name] PRD

| Field | Value |
| :--- | :--- |
| **Status** | Draft / In Review / Approved / Deprecated |
| **Author** | [Name] |
| **Updated** | YYYY-MM-DD |
| **Reviewers** | [Names] |

## 1. Context & Problem
{Describe the "Why". What is the user pain point? What data supports this?}

## 2. Outcomes & Success Metrics
- **Goal**: {One sentence outcome}
- **KPI-1**: {Metric, baseline, target, timeframe}
- **KPI-2**: {Metric, baseline, target, timeframe}

## 3. Users & Use Cases
**Primary Persona**: {Description}

**User Story**:
As a [persona], I want [capability] so that [outcome].

## 4. Functional Requirements
- **FR-1**: {Requirement description}
- **FR-2**: {Requirement description}

## 5. Entity Catalog (AI Grounding)
| Entity | Properties | Description |
| :--- | :--- | :--- |
| [Object] | [Field1], [Field2] | [What it represents] |

## 6. AI Context Block
- **Logic Rules**:
  - [Rule 1: e.g., "Always validate user permissions before action"]
- **Strict Constraints**:
  - [Constraint 1: e.g., "Never expose internal IDs to UI"]
- **Agent Guidelines**:
  - [How AI should approach generating this code/tests]

## 7. Non-Functional Requirements (NFRs)
- **Performance**: {e.g., p95 latency < 300ms}
- **Security**: {e.g., PII must be encrypted at rest}
- **Scalability**: {e.g., must support 10k concurrent users}

## 8. Scope & Non-Goals
**In Scope**:
- [List items]

**Out of Scope**:
- [List items and reasoning]

## 9. Risks & Assumptions
- **Risk**: {Risk name} - **Mitigation**: {Plan}
- **Assumption**: {Assumption name} - **Validation**: {How to verify}

## 10. Rollout & Safety
- **Phased Release**: {Percentage/Group rollout plan}
- **Rollback Strategy**: {Procedure if KPI-X fails}

## 11. Acceptance Criteria
- **AC-1**: Given [Context], When [Action], Then [Outcome]

## 12. Changelog
| Version | Date | Author | Change |
| :--- | :--- | :--- | :--- |
| 0.1 | YYYY-MM-DD | [Name] | Initial Draft |
```
