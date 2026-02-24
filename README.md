# Agents

This directory contains shared customizations for AI agents.
Currently just a collection of skills.

## Skills Index

Current skills available in this environment:

- [using-codex-cli](./skills/using-codex-cli/SKILL.md): Use when you need to
  dispatch tasks to the Codex CLI tool for parallel execution, offloading
  long-running work, or leveraging OpenAI models. Invoke before running any
  codex command.
- [using-gemini-cli](./skills/using-gemini-cli/SKILL.md): Use when you need to
  dispatch tasks to the Gemini CLI for large-context analysis, codebase
  comprehension, summarization, or dependency mapping. Invoke before running
  any gemini command.
- [using-git-worktrees](./skills/using-git-worktrees/SKILL.md): Use when
  starting feature work that needs isolation from the current workspace or
  before executing implementation plans. Create isolated git worktrees with
  smart directory selection and safety verification.
- [using-github-cli](./skills/using-github-cli/SKILL.md): Use when instructed
  to run GitHub CLI (`gh`) commands for pull request operations, issue
  management, workflow runs, releases, repository settings, or GitHub API
  queries. Invoke before running any gh command.
- [using-github-speckit](./skills/using-github-speckit/SKILL.md): Use when
  asked to create a project plan, feature plan, or specification using GitHub
  Spec Kit, including prompts like "create a plan", "create a spec", "write a
  project spec", or "plan this feature". Enforce the Spec Kit command
  sequence and produce complete, review-ready planning artifacts.
- [using-gitlab-cli](./skills/using-gitlab-cli/SKILL.md): Use when instructed
  to run GitLab CLI (`glab`) commands for merge request operations, issue
  management, pipeline runs, releases, repository settings, or GitLab API
  queries. Invoke before running any glab command.
- [using-graphite-cli](./skills/using-graphite-cli/SKILL.md): Use when
  instructed to perform any git operation; branching, committing, pushing,
  syncing, creating pull requests, or managing stacks. Must be invoked before
  using git or gh commands.
- [using-ollama](./skills/using-ollama/SKILL.md): Use when you need to
  dispatch tasks to a local or remote Ollama instance for inference, code
  generation, analysis, or summarization. Invoke before running any ollama
  command.
- [writing-adrs](./skills/writing-adrs/SKILL.md): Use when creating or updating
  Architectural Decision Records, when a significant technical or
  architectural choice needs documenting, or when asked to write an ADR.
- [writing-grammar](./skills/writing-grammar/SKILL.md): Apply a structured
  grammar checklist to a document line by line. Use when any document
  requires a thorough, consistent grammar review before publication or
  handoff.
- [writing-markdown](./skills/writing-markdown/SKILL.md): Use when writing or
  editing any markdown document, README, or .md file to ensure strict
  compliance with all markdownlint rules.
