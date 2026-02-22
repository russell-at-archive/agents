# Micro-Level Intent Implementation: Precision & Constraints

At the micro level, Intent Engineering is about the technical precision of the
intent specification. This level focuses on how to write the specific, actionable
details that ensure an agent's work is correct, secure, and idiomatic.

## 1. Defining the "Definition of Done" (DoD)

Micro intent must include a clear, unambiguous set of criteria that signify the
completion of a task.

- **Technical Requirements**: Specific technologies, versions, or patterns to
  use (e.g., "Use React Hooks for state management").
- **Verification Commands**: The exact shell commands to run for verification
  (e.g., `npm run test`, `cargo fmt --check`, `go vet`).
- **Success Conditions**: The expected output of those commands (e.g., "Exit code
  0, no failing tests, no linting warnings").

## 2. Granular Constraints & Guardrails

These are the "do not" instructions that prevent the agent from making common
mistakes or violating project standards.

- **Negative Constraints**: Specifically stating what *not* to do (e.g., "Do not
  use inline styles, do not use `any` in TypeScript").
- **Dependency Guardrails**: Restricting the use of external packages or
  requiring specific versions (e.g., "Only use built-in Node.js modules").
- **Security Guardrails**: Defining safe ways to handle secrets, user data, or
  network requests.

## 3. Few-Shot Intent Examples

Providing the agent with a "golden set" of intent/result pairs to illustrate
the desired quality and style.

- **Positive Examples**: Showcasing well-implemented solutions that perfectly
  meet the intent.
- **Negative Examples (Anti-patterns)**: Illustrating common mistakes or poor
  implementations and explaining why they fail the intent.
- **Style Alignment**: Using examples to demonstrate the expected coding style,
  commenting patterns, and documentation standards.

## 4. Automated Intent Verification

Designing technical systems that can automatically confirm if an intent has
been met.

- **Unit and Integration Tests**: Writing tests that specifically target the
  intent's goals.
- **Static Analysis**: Using linters, type-checkers, and security scanners to
  automatically verify constraints.
- **Intent-Aware Evals**: Creating custom LLM-based evaluation scripts that can
  judge the "spirit" of the implementation (e.g., "Does this code follow our
  organization's architectural patterns?").
- **Artifact Validation**: Checking for the existence and correctness of
  required files, documentation, or configuration.
