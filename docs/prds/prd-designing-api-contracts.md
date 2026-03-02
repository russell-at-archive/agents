# designing-api-contracts PRD

| Field | Value |
| :--- | :--- |
| **Status** | Draft |
| **Author** | Gemini CLI |
| **Updated** | 2026-03-02 |
| **Reviewers** | [User] |

## 1. Context & Problem
Teams often suffer from "Integration Hell" where frontend and backend implementations diverge because the interface was not finalized before coding. `docs/methodologies/contract-driven-development.md` provides the framework, but agents need a skill to formalize the negotiation and documentation of these contracts (OpenAPI, GraphQL) as a mandatory first step in integration.

## 2. Outcomes & Success Metrics
- **Goal**: To eliminate integration-related regressions by establishing a stable, machine-verifiable contract before any implementation work begins.
- **KPI-1**: 0% "Schema Mismatch" errors in CI during the integration phase.
- **KPI-2**: 50% reduction in "Blocked" time for frontend agents waiting for backend APIs.

## 3. Users & Use Cases
**Primary Persona**: Integration Engineer Agent

**User Story**:
As an agent, I want to define and verify the API contract first so that both consumer and provider can build and test in parallel with confidence.

## 4. Functional Requirements
- **FR-1**: **Consumer-Driven Requirement Capture**: Identify the specific fields and formats required by the UI or consumer.
- **FR-2**: **Contract Specification**: Draft OpenAPI (REST) or GraphQL schemas based on consumer needs.
- **FR-3**: **Mock Generation**: Automatically generate mock endpoints or responses from the contract.
- **FR-4**: **Contract Verification**: Run validation checks to ensure the drafted contract is syntactically correct and follows project standards.

## 5. Entity Catalog (AI Grounding)
| Entity | Properties | Description |
| :--- | :--- | :--- |
| **API Contract** | endpoints, schemas, headers | The formal specification (OpenAPI/GraphQL) of the interface. |
| **Mock Provider** | base_url, schema_link | A temporary service that returns example data based on the contract. |
| **Consumer Expectation** | field_name, data_type, required | A specific requirement from the client side of the API. |

## 6. AI Context Block
- **Logic Rules**:
  - Always define "Error" schemas (4xx, 5xx) as part of the contract.
  - Never allow "Any" or "Object" types in the schema; all fields must be explicitly typed.
- **Strict Constraints**:
  - Do not proceed to implementation until the contract is approved by the user or "consumer agent."
- **Agent Guidelines**:
  - Refer to `docs/methodologies/contract-driven-development.md` for the "Consumer-Driven" approach.

## 7. Non-Functional Requirements (NFRs)
- **Standardization**: Contracts must follow the project's naming conventions (e.g., camelCase vs snake_case).
- **Tooling Compatibility**: Contracts must be compatible with standard tools like Prism (for mocks) or Dredd (for verification).

## 8. Scope & Non-Goals
**In Scope**:
- Drafting, negotiating, and validating API contracts.
- Generating mock data for parallel development.

**Out of Scope**:
- Implementing the actual business logic of the API.
- Setting up the physical API gateway or infrastructure.

## 9. Risks & Assumptions
- **Risk**: Overly complex contracts can become hard to maintain. - **Mitigation**: Keep contracts atomic and versioned.
- **Assumption**: There is a clear separation between Consumer and Provider in the project architecture.

## 10. Rollout & Safety
- **Phased Release**: Use for new API endpoints first; migrate legacy endpoints only during major refactors.
- **Rollback Strategy**: If contract negotiation becomes a bottleneck for trivial 1-field changes, allow a "Fast Track" bypass.

## 11. Acceptance Criteria
- **AC-1**: Given a new "GET /users/:id" request, When the skill is run, Then it produces a valid OpenAPI YAML file with 200, 404, and 500 responses.
- **AC-2**: Given a drafted contract, When the skill is run, Then it provides a command to start a mock server using that contract.

## 12. Changelog
| Version | Date | Author | Change |
| :--- | :--- | :--- | :--- |
| 0.1 | 2026-03-02 | Gemini CLI | Initial Draft |
