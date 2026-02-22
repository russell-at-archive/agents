# Test-Driven Design (TDD): The Macro Manifesto

Test-Driven Design is not a testing methodology; it is a **design process**.
It is the discipline of writing a failing automated test before you write any
production code. This simple constraint fundamentally changes how you think
about your software's architecture, interfaces, and maintainability.

## Why TDD Matters

In modern software development, TDD provides the guardrails needed to move
fast without breaking things. It moves the verification step from the end of
the development lifecycle to the very beginning.

### The Problem: Legacy by Design

Without TDD, code often becomes difficult to test because it was never
designed to be testable. This leads to:

- **Tight Coupling:** Components that cannot be instantiated or tested in
  isolation.
- **Untestable Logic:** Complex business rules buried deep inside UI or
  infrastructure layers.
- **Fear of Change:** Developers being afraid to refactor because they don't
  know what might break.

### The Solution: The Test as the First Consumer

By writing the test first, you force yourself to design the API from the
perspective of its consumer. This naturally leads to:

- **Low Coupling:** You can't test a component in isolation if it's tightly
  coupled to its dependencies.
- **High Cohesion:** Each test focuses on a single behavior, driving smaller,
  more focused units of code.
- **Executable Documentation:** Tests provide living examples of how the code
  is intended to be used.

## The Three Pillars of TDD

1. **Red (The Specification):** Write a failing test that defines a small,
   desired behavior. This is your "requirement" expressed in code.
2. **Green (The Implementation):** Write just enough code to make the test
   pass. Focus on correctness, not elegance.
3. **Refactor (The Design):** Clean up the code and the test, removing
   duplication and improving readability while the tests stay green.

## Core Principles

- **Test Behavior, Not Implementation:** Focus on *what* the code does, not
  *how* it does it. This allows you to refactor the internal implementation
  without breaking the tests.
- **Small Steps:** Make the smallest possible change to move from Red to
  Green. This keeps your focus sharp and your feedback loop short.
- **Simple Design:** Only write the code necessary to satisfy the current
  tests (YAGNI - You Ain't Gonna Need It).
- **Zero-Tolerance for Red:** Never add a new feature or refactor while the
  tests are red. The test suite must always be in a known good state.
