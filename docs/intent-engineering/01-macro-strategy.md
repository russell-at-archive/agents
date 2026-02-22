# Macro-Level Intent Strategy: Outcome-Oriented Architecture

At the macro level, Intent Engineering is the process of architecting the goal
structure and alignment of AI systems. This level focuses on how an organization
defines its objectives so that an agent can operate autonomously toward them
without constant human intervention.

## 1. Defining the "What" and "Why"

Macro strategy begins by separating the desired outcome from the method of
attainment.

- **Outcome Specification**: Clearly defining the end state of the system or
  business process. Instead of "Write a function to...", the macro intent is
  "Ensure the checkout process has <1s latency and 0% failure rate."
- **Strategic Context**: Providing the reasoning behind the goal (the "Why").
  This allows the agent to make better trade-off decisions when it encounters
  unforeseen obstacles.

## 2. Success Rubrics & KPIs

Intent is meaningless without a way to measure its fulfillment.

- **Primary Success Metric**: The single most important indicator that the
  intent has been met.
- **Secondary Quality Indicators**: Additional metrics that ensure the outcome
  is not achieved through undesirable shortcuts (e.g., performance, security,
  readability).
- **Verification Protocols**: Defining the automated tests, lints, or human
  reviews that must pass before an intent is considered "Done."

## 3. Agentic Alignment & Guardrails

Designing the boundaries within which the AI agent can safely and effectively
operate.

- **Positive Intent**: What the agent *should* strive to achieve.
- **Negative Constraints (Guardrails)**: What the agent *must not* do. This
  might include avoiding specific libraries, staying within a budget, or
  adhering to strict security protocols.
- **Agency Delegation**: Deciding which decisions the agent can make
  autonomously and which require human approval (the "Human-in-the-loop" model).

## 4. Systems Thinking for Intent

Treating individual intents as parts of a larger, interconnected system.

- **Intent Hierarchy**: Breaking down broad mission statements into a tree of
  smaller, actionable intents.
- **Conflict Resolution**: Architecting the system to handle situations where
  two intents might conflict (e.g., speed vs. security).
- **Feedback Loops**: Designing mechanisms for the agent to report its progress
  and for the system to adjust its macro strategy based on real-world outcomes.
