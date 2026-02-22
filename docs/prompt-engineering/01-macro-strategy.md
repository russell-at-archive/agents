# Macro-Level Prompt Strategy: System & Architecture

At the macro level, prompt engineering is not about writing a single
instruction; it's about engineering the environment and system architecture in
which the AI operates. This level focuses on how data flows into the model and
how the model interacts with other systems.

## 1. Context Engineering over Prompting

The focus has shifted from finding the "perfect" sentence to managing the entire
**context window**.

- **Context Caching**: Identifying static parts of a prompt (e.g., API
  specifications, large documentation sets) and "pinning" them in the model's
  memory to reduce latency and costs.
- **Window Management**: Strategically deciding what information to include in
  the context window and what to omit, ensuring the model isn't overwhelmed by
  irrelevant data (noise-to-signal ratio).

## 2. Retrieval-Augmented Generation (RAG)

Macro strategy involves connecting the model to external data sources.

- **Semantic Search**: Using vector databases to retrieve only the most relevant
  snippets of data based on the user's query.
- **Dynamic Context Injection**: Feeding the model real-time, external data
  (e.g., current weather, stock prices, or private company files) so its answers
  are grounded in facts rather than training data alone.

## 3. Agentic Workflows

Modern prompt engineering involves designing autonomous loops where the AI can
"think" and "act."

- **The PRAR Cycle**:
  - **Perceive**: Gather input and context.
  - **Reason**: Plan the steps needed to solve the problem.
  - **Act**: Use tools (APIs, code execution, web search) to perform actions.
  - **Reflect**: Review the results and self-correct if the goal wasn't met.
- **Multi-Agent Orchestration**: Designing a system where specialized models
  (e.g., a "Researcher" model and a "Writer" model) collaborate on a complex
  task.

## 4. Prompts as Code

Treating prompts with the same rigor as software development.

- **Version Control**: Storing prompts in Git to track changes, roll back if a
  new version performs worse, and collaborate with a team.
- **Automated Evaluations (Evals)**: Building "golden sets" (pairs of prompts
  and their ideal answers) and running automated tests to ensure a prompt change
  doesn't break existing functionality.
- **Prompt Templates**: Using variables (e.g., `{{user_name}}`,
  `{{task_description}}`) to create reusable, programmatically-controlled prompt
  structures.
