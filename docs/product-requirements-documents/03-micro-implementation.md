# PRD Micro: Implementation Standards

High-quality requirements are the bedrock of efficient engineering. In the era of AI coding agents, your PRD must be both **human-readable** and **machine-actionable**.

## The Modern PRD Template (2025-2026)

| Section | Focus |
| :--- | :--- |
| **Problem Statement** | The specific user pain or business gap. |
| **Outcomes & KPIs** | Measurable changes in behavior (e.g., +20% conversion). |
| **User Stories** | Value-driven requirements in the `As a... I want... So that...` format. |
| **Acceptance Criteria** | Explicit, testable rules for each user story. |
| **Entity Catalog** | Standardized definitions of the core domain objects. |
| **AI Context Block** | A specialized section for coding agents. |
| **Constraints & Scope** | Explicit list of what is "Out of Scope." |
| **Evaluation Framework** | How success will be measured post-launch. |

## INVEST-Compliant User Stories

A requirement is only complete if it is:
- **Independent:** Can be developed and delivered on its own.
- **Negotiable:** Focuses on the *what*, not the *how*.
- **Valuable:** Clearly provides benefit to the user or business.
- **Estimable:** Small and clear enough for an engineer to gauge effort.
- **Small:** Fits within a single development cycle.
- **Testable:** Has clear acceptance criteria.

## The AI Context Block (Entity Catalog)

To ensure coding agents use the correct terminology and logic, define your domain entities clearly:

```markdown
### AI Context: Order Processing Entity Catalog
- **Order:** A customer's request for one or more items. Must have a `status`.
- **Cart:** A temporary collection of items before an Order is created.
- **Transaction:** The financial record of a successful payment for an Order.
```

## AI-Feature Specifics: The Evaluation Framework (Evals)

If your requirement involves AI, you **must** define:
- **Model Evals:** Benchmarks for accuracy, latency, and reliability.
- **Hallucination Tolerance:** Acceptable level of error or uncertainty.
- **Graceful Degradation:** The manual fallback when the AI is unavailable.

## Best Practices for Clarity

1. **Active Voice:** Use "The system shall..." instead of "It should be possible for...".
2. **Literal Specificity:** Avoid words like "easy," "fast," or "intuitive." Instead, use "within 300ms," "one click," or "no more than two steps."
3. **Traceability:** Link every story to a specific business goal defined in the PRD's **Outcomes** section.
4. **Living Document:** Treat the PRD as a README for the feature. If the requirements change, update the PRD before the code.

## The Rule of Actionability:
If an engineer or AI agent can't generate a test case from your requirement, it's not specific enough.
