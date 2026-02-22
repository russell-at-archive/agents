# 02 Meso Level: Tactical Workflow and Architecture

The meso level of Domain-Driven Design (DDD) bridges the gap between
high-level strategy and low-level code. It defines the "shape" of the
software within a Bounded Context.

## 1. Discovery: Event Storming

A rapid, collaborative workshop designed to explore complex business
processes.

- **Goal:** Identify **Domain Events** (what happened in the past),
  **Commands** (what triggered it), and **Aggregates** (the boundaries for
  business rules).
- It breaks down silos and ensures a shared understanding of how the system
  works.

## 2. Isolating the Domain: Architecture

To keep the domain model pure and free from technical concerns (like
databases or web frameworks), we use architectural patterns:

- **Hexagonal Architecture (Ports and Adapters):** The domain sits at the
  center, surrounded by "ports" (interfaces). "Adapters" (implementations)
  connect the domain to infrastructure.
- **Clean Architecture:** Similar to Hexagonal, it emphasizes dependency
  inversion, ensuring dependencies only point inward toward the domain layer.

## 3. The Layers of a Bounded Context

Within a Bounded Context, logic is typically organized into layers:

- **Domain Layer:** Contains the core business logic, rules, and domain
  models.
- **Application Layer:** Orchestrates the flow of data. It handles use cases
  (e.g., "Place Order") but does not contain business logic.
- **Infrastructure Layer:** Handles technical concerns (persistence,
  communication, file systems).
- **Interfaces (UI/API) Layer:** The entry points into the application.

## 4. Modeling Concepts

Meso-level modeling introduces key tactical concepts:

- **Aggregates:** A cluster of domain objects that can be treated as a
  single unit for data changes. Every Aggregate has an **Aggregate Root**.
- **Entities:** Objects with a unique identity that persists over time.
- **Value Objects:** Immutable objects defined by their attributes, not
  identity (e.g., `Address`, `Money`).
- **Domain Services:** Logic that doesn't naturally fit into an Entity or
  Value Object.

## 5. Workflow: From Event to Model

A meso-level workflow often looks like this:

1. Conduct an **Event Storming** session.
2. Identify **Aggregates** based on consistency boundaries.
3. Define the **Application Services** (use cases) needed to interact with
   these aggregates.
4. Set up the **Ports and Adapters** for necessary infrastructure.

---

[Next: Micro Implementation: The "How" in Code](./03-micro-implementation.md)
