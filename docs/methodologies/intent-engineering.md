# Intent Engineering

## Purpose

Intent engineering is the practice of translating user goals into
machine-actionable intent representations that systems can route,
execute, and verify reliably.

It focuses on the "what" and "why" behind a request, not only the
surface wording.

## Core Concepts

- `Intent`: The desired outcome, constraints, and success condition of a
  request.
- `Intent representation`: A structured form of intent, such as fields,
  schemas, or state objects.
- `Intent engineering`: Methods for capturing intent accurately, mapping
  it to actions, and handling ambiguity safely.

## Why It Matters

- Reduces failures caused by literal text matching.
- Improves reliability across paraphrases and noisy input.
- Enables robust automation through structured intent contracts.
- Supports safer behavior by exposing constraints explicitly.
- Makes systems easier to evaluate with intent-level metrics.

## Intent vs Prompt Engineering

- Prompt engineering optimizes model instructions and output behavior.
- Intent engineering defines target outcomes and execution semantics.
- Prompt quality affects response style and format.
- Intent quality affects task selection, tool routing, and completion.

They are complementary: strong intent design improves prompt strategy,
and strong prompts improve intent extraction and execution.

## Intent Representation

Common components of an intent object:

- Goal: Desired end state.
- Entities: Key nouns, ids, and resources.
- Constraints: Time, policy, budget, and scope limits.
- Priority: Urgency and tradeoff preferences.
- Context: Relevant history and assumptions.
- Success criteria: Observable completion conditions.
- Fallback behavior: Safe default when confidence is low.

## Lifecycle

1. Capture: Collect raw user input and contextual signals.
2. Interpret: Infer candidate intent and confidence score.
3. Clarify: Ask targeted questions when ambiguity is material.
4. Normalize: Map intent into a canonical schema.
5. Plan: Select tools, workflows, and dependencies.
6. Execute: Run actions with guardrails and policy checks.
7. Verify: Validate outcomes against success criteria.
8. Learn: Feed failures back into intent models and rules.

## Design Techniques

- Define a strict intent schema before implementation.
- Keep schema fields atomic and testable.
- Separate observed facts from inferred assumptions.
- Encode hard constraints as machine-enforced rules.
- Include confidence thresholds and clarification triggers.
- Model negative intents, refusals, and out-of-scope cases.
- Track provenance of inferred fields for debugging.

## Failure Modes

- Conflating user wording with true underlying goal.
- Executing on low-confidence intent without clarification.
- Overloading one intent type with unrelated behaviors.
- Missing disambiguation for entities with similar names.
- Ignoring hidden constraints such as policy or timing.
- No post-execution verification against intent criteria.

## Evaluation Metrics

- Intent classification accuracy by domain.
- Slot or field extraction accuracy for structured entities.
- Clarification rate and clarification success rate.
- Task completion rate against declared success criteria.
- False-action rate from incorrect intent routing.
- Time-to-completion for high-frequency intents.

## Lightweight Intent Spec Template

```text
Intent Name:
[short identifier]

Goal:
[target outcome]

Inputs:
- Required: [field list]
- Optional: [field list]

Constraints:
- [policy, time, budget, scope]

Execution Plan:
- Tools/workflows: [list]
- Preconditions: [checks]

Success Criteria:
- [observable result 1]
- [observable result 2]

Fallback:
- If confidence < [threshold], [clarify or refuse behavior].
```

## Governance and Operations

- Version intent schemas and migration rules.
- Log intent inference, action plan, and verification outcome.
- Add audit trails for high-risk intents.
- Review policy-sensitive intents with legal and security teams.
- Rebaseline metrics after major model or workflow changes.

## Summary

Intent engineering turns user requests into dependable execution
contracts. It improves correctness, safety, and automation quality by
making goals and constraints explicit, testable, and operational.
