# CA Meso: The Constraint Lifecycle

This document defines the tactical workflow for identifying, documenting, and enforcing constraints across systems and teams.

## The Lifecycle of a Constraint

Constraints follow a structured lifecycle to ensure they are actionable and un-bypassable.

### Phase 1: Identification & Discovery
Before building a feature, ask: "What is the **absolute worst** thing that could happen here?"
- **Data Corruption:** "What if this field is null?"
- **Security Breach:** "What if an unauthorized user calls this?"
- **Resource Exhaustion:** "What if this loop runs infinitely?"

**Action:** Document these as "Negative Requirements" (e.g., "The system must not...") in your feature requirements.

### Phase 2: Design & Formulation
Turn your negative requirements into formal constraints. A good constraint is:
- **Specific:** "The `user_id` must be a valid UUID."
- **Immutable:** "The `created_at` timestamp cannot be modified after creation."
- **Verifiable:** "We can prove this by running X test."

**Action:** Include a "Constraints" section in your Technical Plan.

### Phase 3: Selection of Enforcement Mechanism
Choose the most appropriate layer to enforce the constraint. **Rule of Thumb:** Enforce as close to the source as possible, but as high as necessary for global safety.
- **Layer 1: Type System (Micro)** - Use types to make invalid states un-representable.
- **Layer 2: Logic/Assertions (Micro)** - Use `assert` or `invariant()` for runtime checks.
- **Layer 3: Infrastructure (Macro)** - Use VPCs, IAM roles, or DB triggers.

**Action:** Map each constraint to its enforcement mechanism in the Technical Plan.

### Phase 4: Validation & Monitoring
A constraint that isn't validated doesn't exist.
- **Unit Tests:** Verify that "bad" inputs are rejected.
- **Static Analysis:** Use linting or custom rules to prevent "bad" patterns.
- **Production Monitors:** Use alerts for runtime invariant violations.

## Directory Structure: The Constraint Registry

To maintain visibility, keep a central or project-level registry of constraints:

```bash
.specs/
└── constraints/
    ├── macro/       # Global/System-wide (e.g., security, networking)
    ├── meso/        # Interaction/Contract (e.g., API schemas, service dependencies)
    └── micro/       # Logic/Implementation (e.g., domain invariants, type definitions)
```

## Collaborating with AI Agents

When tasking an AI agent, **Front-load the Constraints**. Before giving the goal, provide the "Guardrails":
- **Negative Prompts:** "Do NOT use the `axios` library; use the existing `ApiClient`."
- **Safety Invariants:** "Ensure the `apiKey` is never logged, even in debug mode."
- **Architectural Rules:** "All new services must implement the `HealthCheck` interface."

By providing these upfront, you reduce the need for iterative corrections and ensure the AI stays within the system's "safe zone."
