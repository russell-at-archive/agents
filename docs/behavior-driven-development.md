# Behavior-Driven Development (BDD)

Behavior-Driven Development (BDD) is a collaborative software development process that encourages communication between developers, QA, and non-technical business stakeholders. It is an evolution of Test-Driven Development (TDD) that focuses on the behavior of the software from the perspective of the user.

## Core Philosophy

BDD aims to bridge the communication gap between business and technology. It ensures that everyone involved in a project has a shared understanding of what is being built and why. The primary goal is to produce **executable specifications** that serve as both requirements and tests.

## The Three Amigos

The "Three Amigos" is a collaborative meeting involving at least three key perspectives:
- **Product Owner / Business Analyst:** Represents the "What" and "Why."
- **Developer:** Represents the "How" and feasibility.
- **QA / Tester:** Represents the "What about...?" and edge cases.

During these meetings, requirements are discussed and refined until they can be expressed as a set of unambiguous scenarios.

## Gherkin Syntax

BDD scenarios are written in a human-readable, domain-specific language called **Gherkin**. It uses a simple "Given/When/Then" structure:

- **Given:** The initial context or state of the system.
- **When:** The action or event that occurs.
- **Then:** The expected outcome or consequence.

### Example Scenario

```gherkin
Feature: ATM Withdrawal

  Scenario: Successful withdrawal with sufficient funds
    Given I have $100 in my account
    And my ATM card is valid
    When I request $20 from the ATM
    Then the ATM should dispense $20
    And my new account balance should be $80
```

## The BDD Loop

1.  **Discovery:** The "Three Amigos" discuss and define requirements as scenarios.
2.  **Formulation:** Scenarios are written in Gherkin and stored as "feature files."
3.  **Automation:** Developers write "step definitions" that map the Gherkin steps to automated tests.
4.  **Implementation:** The code is written until the automated test passes.

## Benefits of BDD

- **Improved Communication:** Ensures that business and technical teams are aligned.
- **Shared Understanding:** Eliminates assumptions and ambiguity through concrete examples.
- **Living Documentation:** The feature files serve as a constantly updated manual of the system's behavior.
- **Reduced Waste:** Prevents the building of features that do not meet the actual business need.

## When to use BDD

- **Projects with High Business Complexity:** When the rules are intricate and require frequent clarification.
- **Multi-Functional Teams:** When collaboration between different roles is critical.
- **User-Facing Features:** When the focus is on the end-user experience.
