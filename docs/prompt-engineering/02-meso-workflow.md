# Meso-Level Prompt Workflow: Structure & Logic

At the meso level, prompt engineering focuses on the structural organization and
logical flow of an individual request or "specification." This ensures the model
understands exactly what is required and how to reason through it.

## 1. The TCOF Layout

The "4-Block" structure is a standard for creating reliable, high-performance
prompts.

- **Task**: A single, concise sentence defining the primary objective (e.g.,
  "Summarize this technical document").
- **Context**: Relevant background information, who the audience is, and any
  reference material the model needs (e.g., "The audience is senior developers,
  and here is the API documentation").
- **Output Contract**: An explicit definition of the expected result's
  structure, tone, and length (e.g., "Return a JSON object with `summary` and
  `key_takeaways` fields").
- **Format/Constraints**: Strict boundaries and success criteria (e.g., "Must be
  under 200 words, do not use jargon, and include 3 bullet points").

## 2. Reasoning Scaffolds

Scaffolding techniques help the model break down complex problems into smaller,
more manageable steps.

- **Chain of Thought (CoT)**: Explicitly asking the model to "think
  step-by-step" before providing a final answer.
- **Tree of Thought (ToT)**: A multi-path reasoning strategy where the model
  explores different possible solutions and then evaluates which is the most
  effective.
- **Reasoning-First Prompts**: Forcing the model to output its logic first
  (often inside `<thinking>` tags) before providing its final response.

## 3. Thinking Management

Modern models have varying levels of "thinking" depth. Meso-level engineering
involves managing these capabilities.

- **Triggering Deep Reasoning**: Knowing when to use a "thinking" model (like o1
  or Claude 3.5 Sonnet) for complex tasks like architectural design or
  debugging.
- **Model Routing**: Using a faster, cheaper "router" model for simple tasks
  (like categorization or sentiment analysis) and only calling a more powerful
  model for tasks that require higher intelligence.
- **Prompt-Triggered Deliberation**: Using specific keywords (e.g., "Carefully
  evaluate all constraints") to trigger the model's extended thinking mode.

## 4. Output Contracts & Schema Enforcement

To integrate AI with other systems, the output must be reliable and
machine-readable.

- **JSON/XML Mode**: Forcing the model to respond exclusively in a structured
  format.
- **Schema Adherence**: Providing a JSON schema or XML structure that the model
  *must* follow.
- **Validation Loops**: Checking the AI's output against the defined contract
  and automatically re-prompting with errors if it fails to comply.
