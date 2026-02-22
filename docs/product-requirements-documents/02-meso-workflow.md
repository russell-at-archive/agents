# PRD Meso: The Intent Workflow

The PRD workflow is the tactical bridge between a **Product Vision** and an **Implementation Plan**. In an AI-native environment, this workflow is collaborative, iterative, and deeply integrated into the codebase.

## The Modern PRD Lifecycle

### 1. Discovery & Hypothesis
Before writing a single requirement, define the **Job to be Done (JTBD)**.
- **Problem Statement:** What pain are we solving?
- **Hypothesis:** "If we build X, then Y will happen, as measured by Z."
- **Stakeholder Alignment:** Get buy-in on the *outcomes*, not just the features.

### 2. Strategic Context Gathering
Gather all existing data and signals.
- **AI-Assisted Context:** Feed your AI agent existing customer feedback, data insights, and previous PRDs.
- **Entity Identification:** Define the core objects (Users, Orders, Tokens, etc.) early to ensure consistent language.

### 3. Drafting with AI Grounding
Use AI to generate the boilerplate, but focus your manual effort on the **logic and trade-offs**.
- **Draft User Stories:** Focus on the *value* to the user.
- **Define Non-Functional Requirements (NFRs):** Latency, security, and accessibility.
- **Build the AI Context Block:** Create a specialized section that explains the domain to a coding agent.

### 4. Refinement & Constraint Definition
Clearly state what is **not** being built.
- **Scope Boundaries:** Set strict limits to prevent scope creep.
- **Risk Identification:** Call out technical, business, and legal risks.
- **Fallback Planning:** For AI-driven features, define what happens when the model fails.

### 5. Validation & Implementation
The PRD is a "living" contract that evolves.
- **Traceability Matrix:** Map stories to technical task IDs (e.g., Jira, GitHub Issues).
- **Test Alignment:** Ensure acceptance criteria are used to generate automated tests.
- **Finality through Validation:** A feature is "done" only when it satisfies the success metrics defined in the PRD.

## The AI-Integrated Workflow (2025-2026)

1. **Context-Rich Initiation:** Instead of starting with a blank page, provide your AI agent with the macro-strategy and any existing relevant documentation.
2. **Collaborative Refinement:** Ask the AI to identify potential edge cases, risks, or contradictions in your requirements.
3. **Automated Traceability:** Use your AI tool to generate a task list directly from the PRD, keeping the intent and the code perfectly synced.

## The Goal: High-Signal Clarity
Every step in the workflow should increase the signal-to-noise ratio, ensuring that every line of code written is in service of a validated user outcome.
