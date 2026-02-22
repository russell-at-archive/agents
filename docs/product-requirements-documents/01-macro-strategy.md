# PRD Macro: The Intent Manifesto

Product Requirements Documents (PRDs) are the bridge between a **problem in the world** and a **solution in the code**. In modern, AI-augmented development, a PRD is no longer a static "feature list"—it is a record of **intent and expected outcomes**.

## The Problem: Feature Creep and "Ghost Requirements"

In traditional development, PRDs often fail because:
- **Output-Focused:** They list 20 features to build without explaining why they matter.
- **Static Decay:** They are written at the start of a project and never updated as the team learns.
- **Ambiguity:** They use vague language that leads to "ghost requirements"—assumptions that engineers make which don't align with the product vision.
- **Disconnected:** They live in a separate wiki, far from the code and the AI agents actually doing the work.

This leads to "Feature Creep"—building a bloated product that doesn't actually solve the user's problem.

## The Solution: Outcomes over Outputs

A modern PRD defines the **desired change in user behavior** or **business metric**. It treats features as **hypotheses** to be tested, not mandates to be followed.

### The Value of Intent-Driven Specs
1. **Strategic Alignment:** Every requirement is explicitly linked to a business goal or user pain point.
2. **AI-Ready Context:** By providing clear intent, you enable AI coding agents to make better implementation choices.
3. **Hypothesis-Driven:** You define success *before* you build, allowing you to pivot quickly if the features don't move the needle.
4. **Living Documentation:** The PRD is maintained in the repository, evolving alongside the code it describes.

## Core Principles

- **INVEST-Compliant:** Every story is Independent, Negotiable, Valuable, Estimable, Small, and Testable.
- **AI-Native:** Includes an "Entity Catalog" and "AI Context Block" to ground coding agents in the domain language.
- **Outcome-Based:** Success is measured by *impact* (e.g., "50% reduction in checkout time"), not *completion* (e.g., "Added a 'Save for Later' button").
- **Constraint-First:** Explicitly defines what is **out of scope** to prevent scope creep.
- **Traceability:** Requirements are mapped directly to technical tasks and test cases.

## The Rule of Thumb:
If you can't explain how a requirement moves a specific success metric, it doesn't belong in the PRD.
