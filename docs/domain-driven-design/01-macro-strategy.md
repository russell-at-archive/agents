# 01 Macro Level: Strategic DDD

At the macro level, Domain-Driven Design (DDD) is about **Strategic Design**.
It addresses the "big picture" by mapping out the problem space and the
solution space to ensure software aligns with business goals.

## 1. Problem Space: Subdomains

Before writing code, we must understand the business. Not all parts of a system
have the same value.

- **Core Subdomain:** The "secret sauce." This is where the business provides
  its unique value and where you should invest most of your effort.
- **Supporting Subdomain:** Necessary for the business to operate but doesn't
  provide a competitive advantage.
- **Generic Subdomain:** Problems that have already been solved by others
  (e.g., identity management, billing). Use off-the-shelf solutions.

## 2. Solution Space: Bounded Contexts

A **Bounded Context** is a semantic boundary where a specific model and its
**Ubiquitous Language** apply.

- Within a Bounded Context, a term like "Account" has one specific meaning.
- In a "Banking" context, it's a financial ledger. In a "Marketing" context,
  it's a lead or a customer profile.
- Explicitly defining these boundaries prevents model pollution and reduces
  cognitive load.

## 3. Ubiquitous Language

The team (developers and domain experts) must use a shared, unambiguous
language that is reflected in both conversations and code.

- If a domain expert calls it a "Policy," the code should use `Policy`, not
  `Agreement` or `Contract`.
- This language evolves as understanding deepens.

## 4. Context Mapping

Context Mapping visualizes the relationships between Bounded Contexts.
Common patterns include:

- **Partnership:** Two teams succeed or fail together.
- **Shared Kernel:** Two contexts share a small subset of the model.
- **Customer-Supplier:** One context (the upstream supplier) provides services
  to another (the downstream customer).
- **Anti-Corruption Layer (ACL):** A downstream context creates a translation
  layer to protect its model from an upstream context's mess.
- **Conformist:** The downstream context simply adopts the upstream model.

## 5. Strategic Alignment

Macro-level success is achieved when the software's architecture mirrors the
business's organizational structure and priorities.

---

[Next: Meso Workflow: The "What" and "How"](./02-meso-workflow.md)
