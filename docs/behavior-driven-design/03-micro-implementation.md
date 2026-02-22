# 03 Micro Level: Automation & Implementation

The micro level is where we bridge the gap between human-readable feature files and the underlying code. This phase is known as **Automation**.

## 1. Step Definitions: The Glue Code
Step definitions are the bridge between Gherkin steps and the actual automation code.

### Standard Pattern:
- **Given:** Sets up the initial state (often using mocks, factories, or API calls).
- **When:** Executes the action being tested.
- **Then:** Asserts the expected outcome.

### Best Practices:
- **Parameterize Steps:** Use capture groups or placeholder syntax to make steps reusable.
- **Use Page Objects/Controllers:** Keep your step definitions thin by delegating logic to higher-level abstractions like Page Objects (for UI) or Controllers (for APIs).
- **Avoid Implementation Details:** Step definitions should not contain low-level logic (e.g., CSS selectors, database queries). Delegate those to specific service or interaction layers.

## 2. The BDD-TDD Inner/Outer Loop
BDD is not a replacement for TDD (Test-Driven Development). Instead, they work together in an "Outer Loop / Inner Loop" pattern.

### The Outer Loop (BDD):
- Write a failing Gherkin scenario.
- Implement the step definitions (which will also fail).
- **Goal:** Verify the **overall behavior** of the system.

### The Inner Loop (TDD):
- Write a failing unit test for a specific piece of logic.
- Write the minimum code to pass the test.
- Refactor.
- **Goal:** Verify the **correctness of the implementation**.

*The Outer Loop (BDD) drive the design of the **feature**, while the Inner Loop (TDD) drives the design of the **code**.*

## 3. Automation Tools by Ecosystem
Choose a tool that fits your tech stack:
- **Cucumber:** (Java, Ruby, JS, etc.) The industry standard.
- **SpecFlow:** (.NET) Cucumber-style for C#.
- **Behave:** (Python) Gherkin-based automation for Python.
- **Cypress / Playwright:** Modern end-to-end testing frameworks that often have BDD plugins.

## 4. When to Automate (and When Not To)
Not all behaviors need to be automated at the meso/micro level.
- **Automate:** Core business rules, critical user journeys, and complex logic.
- **Manual/Unit Test:** UI styling, minor edge cases, and highly unstable external integrations.

---
[Return to README](./README.md)
