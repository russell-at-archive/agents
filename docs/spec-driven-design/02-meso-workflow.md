# SDD Meso: The Workflow Lifecycle & Repo Structure

This document outlines the tactical process of Spec-Driven Design, bridging the gap between high-level philosophy and the physical structure of the codebase.

## The Spec-Driven Lifecycle

Every feature or change follows a rigid, phase-gated lifecycle. Each phase corresponds to a specific directory within the `.specs/` folder, which serves as the **Source of Intent**.

```bash
.specs/
├── requirements/      # Phase 1: The "What" and "Why"
├── plans/             # Phase 2: The "How" (Architecture & Contracts)
├── tasks/             # Phase 3: The "Execution" (Atomic Units of Work)
└── constraints/       # Global: The "Guardrails" (Macro, Meso, Micro)
```

---

### Phase 1: Requirement Specification (`/requirements/`)
Before any planning, document the goal. Use a standard template to capture the **Job to be Done (JTBD)**.
- **Success Criteria:** How will we know this is done?
- **Negative Requirements:** What *must not* the solution do?
- **Out of Scope:** Explicitly define boundaries to prevent scope creep.

**Action:** Create a `.md` file in `.specs/requirements/` describing the intent.

### Phase 2: Technical Planning (`/plans/`)
Translate requirements into a technical blueprint. This is where architectural decisions and **Contracts** are locked.
- **API Contracts:** Define inputs, outputs, and schemas before implementation.
- **Data Models:** Sketch the schema or types.
- **Validation Strategy:** Define exactly how each requirement will be proved.

**Action:** Create a `.md` file in `.specs/plans/` mapping the architecture.

### Phase 3: Task Decomposition (`/tasks/`)
Break the plan into small, atomic chunks. Each task follows the **"Single Developer Turn"** rule:
- A task must be small enough to implement and validate in one session.
- A task must have a clear "Validation" command (e.g., `npm run test`).

**Action:** List these tasks in `.specs/tasks/` using the standardized task template.

### Phase 4: Implementation & Validation
Execute each task sequentially. For every change:
1. **Plan:** Review the specific task and the relevant plan.
2. **Act:** Apply surgical code changes strictly within the task scope.
3. **Validate:** Run the validation command specified in the task.

**Rule:** Never move to the next task until the current one is fully validated.

---

## Global Context: Constraint Architecture (`/constraints/`)

While features follow a linear lifecycle, **Constraints** provide the permanent "Safe Zone" for the entire repository.
- **Macro:** System-wide rules (Security, Language, Auth).
- **Meso:** Interaction rules (API boundaries, Service dependencies).
- **Micro:** Implementation rules (Naming conventions, Forbidden patterns).

**Expert Protocol:** Every agent turn begins by loading the **Constraint Registry** (`.specs/constraints/`) before reading feature-specific requirements.
