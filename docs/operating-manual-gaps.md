# Operating Manual Gaps & Open Questions

This document captures the operational and logistical gaps identified during the first review of the `docs/operating-manual.md`. These questions must be resolved to ensure the "Agent OS" functions as a cohesive, high-velocity system.

---

## Phase 1 & 2: Intent & Specification (Handover)

### Approval Authority
- **Question**: When a "Product Agent" finishes a PRD, who has the authority to "Approve" it?
- **Gap**: We need a protocol for whether a human user must always approve, or if a "Lead Engineer Agent" can approve a PRD that satisfies all `specification-engineering.md` criteria.

### Intent Persistence
- **Question**: Where is the "Intent Contract" stored?
- **Gap**: If stored only in session context, the "Source of Truth" may lose the original constraints. We need a standard (e.g., `docs/intake/NNN-intent.md`) for persisting the intent contract.

---

## Phase 3: Technical Design (Visualization & Verification)

### Modeling Tools
- **Question**: How should "Context Map Visualizations" (DDD) be represented in a Markdown-only environment?
- **Gap**: Standardize on **Mermaid.js**, **ASCII art**, or **bulleted hierarchies** to ensure architectural consistency across agents.

### Contract Verification
- **Question**: What is the "Gold Standard" tool for API contract verification?
- **Gap**: Mandate specific tools (e.g., **Spectral** for linting, **Prism** for mocking) that an "Integration Engineer Agent" must use to validate the contract before implementation.

---

## Phase 4 & 5: Planning & Implementation (Logistics)

### Worktree Path Strategy
- **Question**: Where exactly are worktrees created (e.g., `../worktrees/<branch-name>`)?
- **Gap**: A clear path policy is needed to prevent multiple agents from colliding in the same sibling directory or leaking artifacts into the root.

### Shared Environment State
- **Question**: How is the overhead of `npm install` or `cargo build` managed in a worktree-heavy workflow?
- **Gap**: Define whether we assume a shared cache/store (e.g., **pnpm**, **sccache**) or if each worktree incurs the full setup cost.

---

## Phase 6: Validation & Review (Peer Review Triggers)

### Automated Peer Review
- **Question**: Does the "Reviewing Agent" trigger automatically upon `gt submit`, or must it be explicitly invoked?
- **Gap**: Define the trigger mechanism for peer review to prevent PRs from sitting unreviewed in the stack.

### Failure Protocol
- **Question**: If `running-quality-gates` fails, what is the autonomous fix limit?
- **Gap**: Define when an agent should attempt an autonomous fix vs. when it must stop and wait for a user "Directive."

---

## Phase 7: Learning Loop (Self-Modification)

### Skill Persistence & Modification
- **Question**: How is the "Update OS" step performed when a process failure is identified?
- **Gap**: Define whether agents can modify the `.agents/skills/` directory directly or if they must produce a **"Process Improvement PR"** for human approval.

### Retro Storage
- **Question**: Where do retrospectives live?
- **Gap**: Mandate a storage location (e.g., `docs/retrospectives/`) so the system does not "forget" previous failures across sessions.

---

## Summary of Missing Tool/Role Map

| Phase | Gap / Tool Needed | Responsible Agent Role |
| :--- | :--- | :--- |
| **Design** | Mermaid.js vs ASCII for DDD maps | Senior Architecture Agent |
| **Design** | OpenAPI Linting (Spectral/Prism) | Integration Engineer Agent |
| **Execution** | Worktree Root Path Policy | Software Engineering Agent |
| **Validation** | Review Trigger Mechanism | Delivery Agent |
| **Learning** | Process Improvement PR Template | Self-Improving Engineering Agent |
