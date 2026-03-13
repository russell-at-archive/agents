# Agent Engineering Mandates

## General Standards

- **Contextual Precedence**: This file contains foundational mandates for all AI
  agents working in this workspace. These rules take precedence over general
  defaults.
- **Local Skill Preference**: Always prefer using the local skills defined in
  the `skills/` directory. If a skill exists for the current task, you MUST
  activate it, follow its instructions, and explicitly reference it by name in
  your strategy.

## Architectural Decision Directive (Mandatory)

- **Firm Requirement**: All significant architectural decisions **MUST** be
  documented as Architecture Decision Records (ADRs) in `docs/adr/`.
- **Scope**: This directive applies to all agent interactions in this
  repository, including planning, implementation, review, and documentation
  tasks.
- **No Silent Decisions**: Agents **MUST NOT** introduce, accept, or finalize
  significant architectural changes without an ADR reference.
- **Required Agent Behavior**:
  - If an ADR exists, agents must link and follow it.
  - If no ADR exists for a significant architectural change, agents must create
    or request creation of a new ADR before proceeding.
  - If uncertainty exists about significance, treat the decision as significant
    and require an ADR.
  - If any facet of a decision is ambiguous, agents must ask the user for
    clarification before drafting or updating ADR documents.
- **Enforcement**: This rule is part of the definition of done for all agent work 
  in this repository.

