# Meso-Level Intent Workflow: Specification & Reasoning

At the meso level, Intent Engineering is about translating high-level strategy
into structured logic and managing the reasoning process of the AI agent as it
moves toward its goal.

## 1. Intent Transformation: From Vague to Structured

This stage involves taking a raw human request and transforming it into a
format the agent can reliably act upon.

- **Extraction**: Identifying the core intent hidden in conversational or
  informal language.
- **Contextualization**: Enhancing the intent with the necessary background data
  (e.g., existing codebase, business rules, or user preferences).
- **Formalization**: Converting the intent into a structured specification
  (e.g., JSON, YAML, or a domain-specific language) that explicitly defines
  inputs, outputs, and constraints.

## 2. Managing the Reasoning Scaffold

Meso-level intent involves guiding the agent's "thinking" process without
specifying the implementation details.

- **Decomposition**: Helping the agent break a complex intent into smaller,
  manageable sub-intents.
- **Verification Loops**: Designing steps where the agent must "show its work"
  or verify its progress against the success criteria before moving to the next
  stage.
- **State Management**: Keeping track of what has been achieved, what is in
  progress, and what remains to be done.

## 3. The Intent Specification Framework

A common framework for meso-level intent includes:

- **Goal**: The primary objective (e.g., "Implement a secure login system").
- **Context**: The relevant environment (e.g., "Using OAuth 2.0 and the
  existing user database").
- **Constraints**: What to avoid (e.g., "No external libraries without approval,
  password hashes must use Argon2").
- **Success Criteria**: How to verify (e.g., "Passes all security scans, 100%
  unit test coverage, no linting errors").

## 4. Iterative Refinement of Intent

Meso-level intent is not a static document; it is a dynamic process.

- **Feedback Integration**: Refining the intent based on early results or
  obstacles encountered by the agent.
- **Drift Detection**: Monitoring the agent's output to ensure it remains
  aligned with the original intent and hasn't "drifted" into unrelated tasks.
- **Intent Versioning**: Tracking changes to the intent specification as the
  project evolves.
