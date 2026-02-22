# Test-Driven Design (TDD): Micro Implementation Standards

This guide provides practical patterns and implementation standards for
executing the TDD lifecycle in your daily work.

## The AAA Pattern (Arrange, Act, Assert)

The Arrange, Act, Assert (AAA) pattern is the standard way to structure a
single test for clarity and readability.

- **Arrange:** Set up the initial state and dependencies (the "Given").
- **Act:** Execute the behavior under test (the "When").
- **Assert:** Verify that the result matches the expected outcome (the "Then").

```typescript
// Example: Testing a Calculator's add method
test('should add two positive numbers correctly', () => {
  // Arrange
  const calculator = new Calculator();
  const a = 5;
  const b = 10;

  // Act
  const result = calculator.add(a, b);

  // Assert
  expect(result).toBe(15);
});
```

## Implementation Patterns

- **Obvious Implementation:** If the solution is simple, implement it
  directly.
- **Fake It (Till You Make It):** Return a hardcoded value to get the test to
  green quickly, then replace it with the real implementation in the next
  step.
- **Triangulation:** Write multiple tests for the same behavior with
  different inputs to "force" the general implementation.

```typescript
// Triangulation: Driving the implementation of an 'isEven' function
test('should return true for 2', () => {
  expect(isEven(2)).toBe(true); // Implementation: return true; (Fake It)
});

test('should return false for 3', () => {
  expect(isEven(3)).toBe(false); // Triangulation: force the real logic
});
```

## Handling Dependencies with Mocks and Stubs

When writing unit tests, you should isolate your code from its dependencies.

```typescript
// Example: Testing a UserService that uses a UserRepository
test('should register a user if it does not already exist', async () => {
  // Arrange (Mocking the dependency)
  const mockRepo = {
    findByEmail: jest.fn().mockResolvedValue(null),
    save: jest.fn().mockResolvedValue({ id: 1, email: 'test@example.com' })
  };
  const service = new UserService(mockRepo);

  // Act
  const user = await service.register('test@example.com', 'password');

  // Assert
  expect(mockRepo.findByEmail).toHaveBeenCalledWith('test@example.com');
  expect(mockRepo.save).toHaveBeenCalled();
  expect(user.id).toBe(1);
});
```

## Refactoring Patterns for TDD

- **Extract Method:** Move a block of code into its own function to improve
  readability and reduce duplication.
- **Rename Variable/Function:** Give names that express intent, not
  implementation.
- **Replace Conditional with Polymorphism:** Use subclasses or objects to
  handle different states instead of long `if/else` chains.

## Best Practices

- **One Assertion per Test (Ideally):** A test should fail for exactly one
  reason.
- **Fast Tests:** Unit tests should run in milliseconds. If they are slow,
  they are not unit tests.
- **Descriptive Naming:** Use test names that describe the expected behavior
  (e.g., `should_return_error_when_email_is_invalid` rather than `test_email`).
- **Independent Tests:** Tests should not depend on each other. You should be
  able to run them in any order.
