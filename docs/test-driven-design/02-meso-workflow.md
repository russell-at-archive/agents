# Test-Driven Design (TDD): The Meso Workflow Lifecycle

The workflow of TDD is a cyclical process that ensures you are building the
right thing and building it right. It's not just a single loop; it's often
two loops working in harmony.

## The Inner Loop: Red-Green-Refactor

The core of TDD is the **Red-Green-Refactor** cycle. This loop should happen
quickly, often in minutes.

1. **RED: Write a Failing Test**
   - Identify the next small behavior you want to implement.
   - Write a test that describes this behavior.
   - Run the test and ensure it fails with a predictable error (the
     "Expected Failure").

2. **GREEN: Make it Pass**
   - Write the simplest possible code to make the test pass.
   - Don't worry about clean code yet; "vandalize" the codebase if you must.
   - Run all tests and ensure they are all green.

3. **REFACTOR: Clean the Design**
   - Look for duplication, smells, and awkward interfaces.
   - Improve the design while the tests remain green.
   - This is where the *design* in Test-Driven Design actually happens.

## The Outer Loop: Double-Loop TDD

In larger systems, you often use **Acceptance Test-Driven Development
(ATDD)** as an outer loop to drive the inner TDD loop.

1. **Failing Acceptance Test (Outer Loop)**
   - Start with a high-level test that describes a user requirement (e.g.,
     a feature or a user story).
   - This test will fail because the feature doesn't exist yet.

2. **Inner TDD Loops**
   - Move into the inner loop (Red-Green-Refactor) to implement the
     individual units of code needed to satisfy the acceptance test.
   - You may complete many inner loops before the outer acceptance test
     turns green.

3. **Passing Acceptance Test**
   - Once all the inner tests pass and the behavior is complete, the outer
     acceptance test should turn green.
   - This confirms that you have fulfilled the user requirement.

## Tactical Phases of the Workflow

- **Phase 1: Discover through Testing:** Use the failing test to discover
  the necessary interfaces, parameters, and return types.
- **Phase 2: Establish the Baseline:** Ensure that you have a "stable" state
  (all green) before moving to the next requirement.
- **Phase 3: Evolve the Design:** Use the safety net of the tests to evolve
  your architecture from a simple, "monolithic" implementation to a
  decoupled, modular design.

## Mocking and Stubbing Strategies

When you encounter dependencies (e.g., databases, external APIs), use these
strategies to keep your tests fast and isolated:

- **Mocks:** Verify that a specific interaction occurred (e.g., "The email
  service was called once").
- **Stubs:** Provide canned responses to calls made during the test (e.g.,
  "The database returned these three records").
- **Fakes:** Working, but simplified, implementations (e.g., an in-memory
  database).
