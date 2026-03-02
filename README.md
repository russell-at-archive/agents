# Agents

This directory contains shared customizations for AI agents.
Currently just a collection of skills.

## Skills Index

Current skills available in this environment:

- [planning-speckit-worktrees-graphite](./skills/planning-speckit-worktrees-graphite/SKILL.md):
  Use when planning and delivering features that must follow GitHub Spec Kit
  planning, git worktrees for isolation, and Graphite stacked pull requests.
  Combines using-github-speckit, using-git-worktrees, and using-graphite-cli.
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
- [using-helm](./skills/using-helm/SKILL.md): Provides expert guidance for
  working with Helm, the Kubernetes package manager for templating, packaging,
  installing, and operating Kubernetes applications as charts and releases.
  Use when the user asks about Helm charts, `Chart.yaml`, `values.yaml`,
  templates, release commands, dependencies, OCI registries, or troubleshooting.
- [using-gitlab-cli](./skills/using-gitlab-cli/SKILL.md): Use when instructed
  to run GitLab CLI (`glab`) commands for merge request operations, issue
  management, pipeline runs, releases, repository settings, or GitLab API
  queries. Invoke before running any glab command.
- [using-graphite-cli](./skills/using-graphite-cli/SKILL.md): Use when
  instructed to perform any git operation; branching, committing, pushing,
  syncing, creating pull requests, or managing stacks. Must be invoked before
  using git or gh commands.
- [using-kubectl](./skills/using-kubectl/SKILL.md): Provides expert guidance
  for using kubectl to inspect, troubleshoot, and operate Kubernetes clusters
  safely. Use when requests involve kubectl commands such as get, describe,
  logs, exec, apply, diff, delete, rollout, port-forward, top, auth can-i, or
  context and namespace management.
- [using-ollama](./skills/using-ollama/SKILL.md): Use when you need to
  dispatch tasks to a local or remote Ollama instance for inference, code
  generation, analysis, or summarization. Invoke before running any ollama
  command.
- [writing-architecture-decision-records](./skills/writing-architecture-decision-records/SKILL.md):
  Use when creating or updating Architectural Decision Records, when a
  significant technical or architectural choice needs documenting, or when
  asked to write an ADR.
- [writing-conventional-commits](./skills/writing-conventional-commits/SKILL.md):
  Use when writing any git commit message. Enforces Conventional Commits format
  for readable history, automated changelogs, and semantic versioning. Invoke
  before every commit.
- [writing-grammar](./skills/writing-grammar/SKILL.md): Apply a structured
  grammar checklist to a document line by line. Use when any document
  requires a thorough, consistent grammar review before publication or
  handoff.
- [writing-markdown](./skills/writing-markdown/SKILL.md): Use when writing or
  editing any markdown document, README, or .md file to ensure strict
  compliance with all markdownlint rules.
- [writing-pr-descriptions](./skills/writing-pr-descriptions/SKILL.md): Use
  when writing or updating a pull request description for any code change.
  Produces complete PR descriptions with summary, approach rationale, test
  plan, reviewer instructions, and definition of done. Invoke before opening
  or updating any PR.
- [writing-product-requirement-documents](./skills/writing-product-requirement-documents/SKILL.md):
  Use when creating a high-precision, AI-ready Product Requirements Document
  (PRD). Focuses on outcome-based goals, literal specificity for coding
  agents, and maintaining a living document.
- [writing-skills](./skills/writing-skills/SKILL.md): Creates a new agent
  skill directory with a compliant SKILL.md and supporting reference files.
  Use when asked to build, write, add, or create a skill.
- [writing-task-specs](./skills/writing-task-specs/SKILL.md): Use when breaking
  a feature plan into implementation tasks. Produces a task list where each
  task maps to exactly one branch and one PR. Invoke after a tech plan is
  approved and before any implementation begins.
