# ADR Micro: Implementation Standards

This document provides concrete templates and technical standards for writing and managing Architecture Decision Records.

## 1. The MADR Template

We use the **Markdown Architectural Decision Records (MADR)** format for its readability and structure.

```markdown
# [Short Title, e.g., Use PostgreSQL for User Data]

- Status: [Proposed | Accepted | Rejected | Deprecated | Superseded by ADR-NNNN]
- Deciders: [List of decision makers]
- Date: [YYYY-MM-DD]

## Context and Problem Statement
Describe the problem you're trying to solve. Include context like:
- What is the business or technical requirement?
- What are the constraints (e.g., budget, time, legacy systems)?
- Why is this a problem now?

## Decision Drivers
List the key factors that will influence the choice (e.g., scalability, cost, team expertise).

## Considered Options
List the alternatives that were evaluated. For each option, include a brief description.
- Option 1: [Name]
- Option 2: [Name]
- Option 3: [Name]

## Decision Outcome
Name the chosen option and explain why it was selected. Reference specific decision drivers.
- **Chosen Option:** [Option Name]
- **Rationale:** [Explain why this option won.]

### Positive Consequences
What are the benefits of this decision? (e.g., "Increased developer velocity.")

### Negative Consequences
What are the trade-offs or risks? (e.g., "Added operational complexity.")

## Pros and Cons of the Options

### Option 1: [Name]
- **Pros:** [List pros]
- **Cons:** [List cons]

### Option 2: [Name]
- **Pros:** [List pros]
- **Cons:** [List cons]

## Links
Link to relevant documentation, PRs, or other ADRs.
```

## 2. Naming and Numbering Conventions

Consistency in file naming ensures the log remains searchable and chronological.

- **File Path:** `docs/adr/NNNN-short-hyphenated-title.md`
- **Numbering:** Use four-digit, zero-padded numbers (e.g., `0001`, `0012`).
- **Title:** Use a present-tense noun phrase that describes the *decision*, not the problem (e.g., `0001-record-architecture-decisions.md` instead of `0001-how-to-do-decisions.md`).

## 3. Tooling for ADRs

Several tools can help you manage and visualize your ADR log:

### `adr-tools` (CLI)
A simple shell-based CLI for creating and managing ADR files.
- **Install:** `brew install adr-tools` (on macOS)
- **Init:** `adr init docs/adr`
- **New ADR:** `adr new "Use PostgreSQL"`

### `log4brains`
A more advanced tool that turns your ADR folder into a searchable, static website.
- Great for larger teams who need to browse decisions across multiple repositories.

### CI/CD Integration
- **Linting:** Use `markdownlint` to ensure all ADRs follow the project's formatting standards.
- **Link Check:** Use a tool like `markdown-link-check` to ensure all links between ADRs remain valid.

## 4. The "Single Decision" Rule

An ADR should document **one** decision. If you find yourself making multiple unrelated choices, split them into separate ADRs and link them. This keeps each record focused and easy to review.
