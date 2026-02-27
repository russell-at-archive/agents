# Prompt Engineering

## Purpose

Prompt engineering is the disciplined practice of designing inputs that
reliably produce useful, safe, and verifiable outputs from language
models.

It combines instruction design, context management, evaluation, and
iteration to improve outcome quality for real tasks.

## Core Concepts

- `Prompt`: The full model input, including instructions, context,
  examples, tool metadata, and constraints.
- `Prompt engineering`: The method of shaping that input for consistent
  behavior under changing data and workloads.
- `System quality`: Output usefulness, correctness, safety, latency,
  and cost are all part of prompt quality.

## Why It Matters

- Reduces output variance and ambiguity.
- Improves task success without model retraining.
- Makes behavior more auditable through explicit instructions.
- Lowers cost by reducing retries and unnecessary token usage.
- Enables faster product iteration through prompt-only changes.

## Prompt Structure

Most high-performing prompts contain:

1. Role and objective: Who the model is and what it must achieve.
2. Task definition: Specific action, format, and boundaries.
3. Context: Required facts, data, and assumptions.
4. Constraints: Style, policy, forbidden actions, and limits.
5. Output contract: Exact schema, sections, or fields to return.
6. Validation guidance: How to check and report uncertainty.

## Effective Techniques

- Be explicit about task success criteria.
- Provide concrete examples for ambiguous tasks.
- Specify output format with strict field names.
- Separate required inputs from optional context.
- Ask for concise reasoning summaries when needed.
- Instruct the model to state uncertainty instead of guessing.
- Use delimiters to isolate data from instructions.
- Set deterministic settings for repeatable workflows.

## Common Patterns

## Zero-Shot Instruction

Use direct instructions when the task is clear and standardized.

## Few-Shot Prompting

Provide 2-5 representative examples when format or reasoning style is
hard to infer.

## Structured Output Prompting

Require JSON or a fixed schema for downstream automation and validation.

## Retrieval-Augmented Prompting

Inject relevant external knowledge and cite source passages in output.

## Tool-Using Prompting

Define when to call tools, what arguments are allowed, and how to
recover from tool failures.

## Multi-Step Decomposition

Split complex work into stages with intermediate checks and explicit
handoff criteria.

## Failure Modes

- Under-specified objectives that allow broad interpretation.
- Conflicting constraints across system and user instructions.
- Overly long context that buries critical requirements.
- Missing edge-case guidance for error and null conditions.
- No output contract, causing brittle downstream parsing.
- Silent hallucination when evidence is weak or absent.

## Evaluation and Iteration

Treat prompts as versioned artifacts with measurable quality:

- Define a benchmark set of representative tasks.
- Score correctness, completeness, policy compliance, and format match.
- Track latency and token cost per successful run.
- Compare prompt variants with controlled A/B tests.
- Store failures with labels for targeted prompt revisions.

## Practical Workflow

1. Define task objective and acceptance criteria.
2. Draft minimal prompt with clear output contract.
3. Test on easy, typical, and adversarial examples.
4. Identify failure clusters and revise instructions.
5. Add examples or retrieval only where needed.
6. Version and monitor prompt performance in production.

## Lightweight Prompt Template

```text
Role:
You are [role]. Your objective is [objective].

Task:
[Exact action to perform].

Inputs:
- Required: [input list]
- Optional: [optional context]

Constraints:
- [Rule 1]
- [Rule 2]
- If uncertain, state uncertainty explicitly.

Output Format:
Return [format], with fields:
- [field_a]
- [field_b]

Validation:
- Check [condition 1]
- Check [condition 2]
- If a condition fails, return [failure behavior].
```

## Governance and Safety

- Separate policy instructions from task instructions.
- Define disallowed content and refusal behavior.
- Log prompts and outputs for audit and incident review.
- Review high-risk prompts with security and legal stakeholders.
- Revalidate prompts after model version changes.

## Summary

Prompt engineering is system design at the interface between human
intent and model behavior. Strong prompts are explicit, testable, and
continuously improved with measurement.
