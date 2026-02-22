# 02 Meso Level: Behavior Formulation

The meso level is where business requirements (macro) are translated into **executable specifications**. This phase is known as **Formulation**.

## 1. Gherkin Syntax: The "Ubiquitous Language" in Action
Gherkin is a Domain-Specific Language (DSL) that uses structured English to describe behaviors.

### Standard Structure:
- **Feature:** A high-level description of functionality.
- **Scenario:** A specific instance of behavior illustrating a rule.
- **Given:** The initial state (context).
- **When:** The action taken (event).
- **Then:** The expected outcome (assertion).

## 2. Declarative vs. Imperative Writing
A common mistake in BDD is writing **imperative** scenarios (describing UI interactions) instead of **declarative** ones (describing business behavior).

- **Bad (Imperative):**
  ```gherkin
  When I click the blue "Submit" button
  And I wait for the spinner to disappear
  Then the text "Success" should be visible in the #result div
  ```
- **Good (Declarative):**
  ```gherkin
  When I submit my application
  Then my application should be accepted
  ```
*Declarative scenarios are more stable, easier to read, and focus on **what** the user achieves, not **how** they do it.*

## 3. The "One Scenario, One Behavior" Rule
Each scenario should test exactly **one** business rule or edge case. If you find yourself using "And" too many times, consider splitting the scenario or moving some context into a **Background** step.

## 4. Scenario Outlines for Data-Driven Testing
When you need to test the same behavior with different inputs, use `Scenario Outline` with an `Examples` table to keep your feature files DRY (Don't Repeat Yourself).

```gherkin
Scenario Outline: Successful login with valid credentials
  Given I am on the login page
  When I log in with <username> and <password>
  Then I should see the dashboard

  Examples:
    | username | password |
    | admin    | p@ss123  |
    | user     | s3cr3t   |
```

## 5. Living Documentation
Because feature files are both readable and executable, they serve as the **single source of truth** for your system's behavior. This is known as "Living Documentation."

---
[Next: Micro Implementation: The "How"](./03-micro-implementation.md)
