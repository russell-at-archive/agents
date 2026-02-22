# CA Micro: Implementation Patterns

This document provides concrete technical patterns and standards for enforcing constraints at the code level.

## 1. Making Invalid States Un-representable (Types)

The strongest constraint is a type system that prevents "bad" data from being represented. Use domain-specific types instead of generic primitives.

```typescript
// BAD: Primitives are too permissive.
type Email = string; // Could be "invalid-email"

// GOOD: Brand your types or use value objects.
type Email = string & { __brand: "Email" };

function createEmail(email: string): Email {
  if (!email.includes("@")) throw new Error("Invalid email");
  return email as Email;
}

// Result: Any function that takes an `Email` is guaranteed to have a valid one.
```

## 2. Invariants and Assertions (Logic)

For runtime constraints that cannot be checked by the type system, use explicit invariant checks. This is the "Fail Fast" principle.

```typescript
import { invariant } from "./utils/invariant";

function processPayment(amount: number, balance: number) {
  // Constraint: Cannot process payment if amount > balance.
  invariant(amount <= balance, "Insufficient funds");

  // Logic follows knowing the constraint holds...
}
```

## 3. Immutability as a Constraint

To prevent "action at a distance" and unpredictable side effects, enforce immutability.

```typescript
// Use `readonly` to prevent unintended modification.
interface UserAccount {
  readonly id: string;
  readonly createdAt: Date;
  balance: number; // Balance is allowed to change, ID and createdAt are not.
}
```

## 4. Opaque Types & Encapsulation

Limit how data can be interacted with to enforce meso-level interaction constraints.

```typescript
// In a module...
export type TransactionId = string & { __brand: "TransactionId" };

export function generateTransactionId(): TransactionId {
  // Only this module can "create" a TransactionId.
  return `tx_${Date.now()}` as TransactionId;
}

// In another module...
// This function takes a TransactionId, but cannot "create" one from a raw string.
function completeTransaction(id: TransactionId) { ... }
```

## 5. Negative Logic in Tests (Verification)

Your tests should focus heavily on the "Negative Space"—verifying that constraints **actually block** invalid behavior.

```typescript
describe("Account Constraints", () => {
  it("must not allow negative balances", () => {
    const account = createAccount();
    // Verification: Does the system reject the invalid state?
    expect(() => account.withdraw(100000)).toThrow("Insufficient funds");
  });

  it("must not allow ID modification", () => {
    const account = createAccount();
    // @ts-expect-error: Verification: Does the type system block this?
    account.id = "new-id";
  });
});
```

## Constraint Checklist for Implementation

Before submitting a PR, verify your implementation against these questions:
- [ ] Is there any state in this code that should be "impossible"? If so, is it blocked by types?
- [ ] Are all inputs validated at the boundary?
- [ ] Are all invariants explicitly checked with `assert` or `invariant`?
- [ ] Does this change violate any Macro (Global) or Meso (Contract) constraints?
- [ ] Are there tests for every "Negative Requirement" defined in the plan?
