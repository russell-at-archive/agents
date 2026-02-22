# Micro-Level Prompt Implementation: Syntax & Precision

At the micro level, prompt engineering is about the specific linguistic "levers"
and syntax used to fine-tune the model's immediate response. This level of
detail is what separates a good prompt from a truly exceptional one.

## 1. Few-Shot Examples

Few-shot prompting is the most effective way to lock in a specific style,
format, or tone.

- **Gold-Standard Examples**: Providing 1–3 perfect examples of an input and its
  corresponding ideal output.
- **Negative Examples**: Clearly showing what *not* to do (e.g., "Input: [bad
  result] -> Error: [reasoning]").
- **Diverse Scenarios**: Including examples that cover edge cases (e.g., a short
  input, a very long input, and a missing input).

## 2. Structural XML Delimiters

Using clear tags and separators helps the model distinguish between
instructions, user data, and system-level constraints.

- **Using Tags**: Wrapping content in `<context>`, `<task>`, and
  `<instructions>` tags to provide a clear structure.
- **Clear Separators**: Using symbols like `###`, `---`, or `"""` to break up
  different sections of the prompt.
- **Data-Instruction Separation**: Explicitly labeling what is "USER DATA"
  versus "SYSTEM COMMANDS" to prevent the model from getting confused or being
  "tricked" by prompt injection.

## 3. Success Rubrics (The "Done" Definition)

Instead of asking for a "good" or "high-quality" response, define what success
looks like as a checklist.

- **Success Criteria**: "The response is successful if it: 1) Is valid JSON, 2)
  Includes at least 3 citations, and 3) Does not mention competitor [X]."
- **Rubric Scoring**: Giving the model a set of criteria to evaluate its own
  work (e.g., "Rate your response's clarity from 1–10").
- **Constraints as Filters**: Using phrases like "Never use the word 'delve'" or
  "Avoid passive voice."

## 4. Verbosity & Token Control

Managing the "budget" of the response ensures it stays focused and avoids "AI
fluff."

- **Word/Token Counts**: Specifying a maximum or target length (e.g., "Limit
  your response to 50 words").
- **Conciseness Levers**: Using commands like "Be as concise as possible" or
  "Omit unnecessary preamble."
- **Direct-to-Output**: Instructing the model to "Provide the answer immediately
  without any intro or outro text."

## 5. Role & Persona Prompting

Giving the model a specific persona or expertise helps it adopt the correct tone
and knowledge level.

- **Expertise Level**: "Act as a Senior Cloud Architect with 20 years of
  experience in AWS."
- **Target Audience**: "Explain this concept as if you were talking to a
  five-year-old."
- **Tone Mapping**: "Adopt a professional, yet friendly and conversational
  tone."
