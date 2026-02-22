# ADR Meso: The Decision Workflow

This document outlines the tactical process of creating, reviewing, and managing ADRs within a project's development lifecycle.

## The ADR Lifecycle

Every architectural decision moves through a set of predefined states.

### 1. Proposed
When a developer or architect identifies a need for a decision, they create a new ADR file with the status `Proposed`.
- **Purpose:** To socialize an idea and get feedback.
- **Action:** Open a Pull Request (PR) with the new ADR file.

### 2. Accepted
After the PR is reviewed and the team reaches consensus, the status is updated to `Accepted` and the PR is merged.
- **Rule:** Once merged as `Accepted`, the ADR becomes the **Current Decision**.
- **Immutability:** Do not edit the content of an `Accepted` ADR. If you change your mind later, you write a new ADR.

### 3. Superseded
If a later decision changes or replaces an existing one, the old ADR's status is changed to `Superseded by ADR-NNNN`.
- **Action:** Link the new ADR in the status of the old one and vice versa.
- **Value:** This maintains a clear chain of command and history.

### 4. Deprecated
If a decision is no longer relevant (e.g., the feature was removed), the status is set to `Deprecated`.

## Collaborative Decision-Making (The PR Model)

ADRs are most effective when they are socialized. The Pull Request is the perfect place for this:
- **Visibility:** Everyone on the team sees the proposed change.
- **Debate:** Team members can comment on specific trade-offs or suggest alternative options.
- **Audit Trail:** The PR comments provide even more context about *how* the consensus was reached.

**Rule:** Never merge an ADR without at least one other team member's approval.

## When to Start a New ADR?

If you find yourself asking "Why did we do it this way?" or "What would happen if we switched to X?", that's a signal that an ADR is needed.

### Steps to Writing a New ADR:
1. **Identify the Problem:** What is the specific constraint or requirement we are trying to solve?
2. **Brainstorm Options:** List at least two (ideally three) viable options. Even if you have a favorite, listing others forces you to justify your choice.
3. **Compare Trade-offs:** Be honest about the negatives of your chosen option. Every architecture choice has a cost.
4. **Socialize:** Open the PR and ask for feedback.

## Managing the Log

The ADR log should be kept in a dedicated directory, typically `docs/adr/`.
- **Naming:** Files should be sequentially numbered (e.g., `0001-record-architecture-decisions.md`).
- **Index:** Keep a `README.md` in the `docs/adr/` folder that lists all ADRs and their current status for quick reference.
