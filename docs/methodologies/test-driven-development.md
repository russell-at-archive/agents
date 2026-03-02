# Test-Driven Development (TDD)

Test-Driven Development (TDD) is a bottom-up software development process that relies on the repetition of a very short development cycle: first the developer writes an (initially failing) automated test case that defines a desired improvement or new function, then produces the minimum amount of code to pass that test, and finally refactors the new code to acceptable standards.

## Core Loop: Red-Green-Refactor

1.  **Red:** Write a small, failing test for a single unit of logic. The test should represent a single requirement or behavior.
2.  **Green:** Write the *minimum* amount of code necessary to make the test pass. The code does not need to be perfect or elegant at this stage; its only purpose is to satisfy the test.
3.  **Refactor:** Clean up the code and tests while keeping the behavior intact. This is the stage where you address design debt, improve readability, and eliminate duplication.

## TDD Styles: Detroit vs. London

There are two primary schools of thought in the TDD community:

### Detroit (Classicist / Inside-Out)
- **Focus:** State-based testing.
- **Approach:** You verify that a function or object returns the correct output for a given input.
- **Design:** Favors "emergent design" where the architecture grows naturally from the implementation of individual units.
- **Mocks:** Uses as few mocks as possible, preferring to use real objects whenever possible.

### London (Mockist / Outside-In)
- **Focus:** Interaction-based testing.
- **Approach:** You verify that an object interacts with its dependencies correctly.
- **Design:** Starts from the highest level of abstraction (e.g., an API endpoint) and works down to the database.
- **Mocks:** Heavily utilizes mocks and doubles to define the "contracts" between objects before they are implemented.

## Benefits of TDD

- **Technical Precision:** Ensures that every line of code is covered by at least one test.
- **Confidence to Refactor:** A comprehensive test suite allows you to change the internal structure of your code without fear of breaking existing functionality.
- **API Quality:** Writing the test first forces you to think about the "first consumer" of your code, leading to better interface design.
- **Documentation:** The tests serve as a form of living documentation that describes how the code is intended to work.

## When to use TDD

- **Complex Algorithms:** When the logic is intricate and error-prone.
- **Legacy Code:** When you need a safety net while modifying or extending existing systems.
- **Refactoring-Heavy Projects:** When you anticipate frequent changes to the internal design of the software.
