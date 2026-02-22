# Agents

This directory contains shared customizations for AI agents.
Currently just a collection of skills.

## Skills Index

Current skills available in this environment:

- [planning-speckit-worktrees-graphite](./skills/planning-speckit-worktrees-graphite/SKILL.md):
  Use when planning and delivering features that must follow GitHub Spec Kit
  planning, git worktrees for isolation, and Graphite stacked pull requests.
  Combines using-github-speckit, using-git-worktrees, and using-graphite-cli.
- [structuring-git-commits](./skills/structuring-git-commits/SKILL.md):
  Structures repository changes into small, reviewable, and safe git commits.
  Use when asked to split work into atomic commits, decide commit boundaries,
  stage hunks, or order commits before pushing or opening a pull request.
- [using-argo-workflows-cli](./skills/using-argo-workflows/SKILL.md): Provides
  expert guidance for using the argo CLI to submit, monitor, manage, and debug
  Argo Workflows on Kubernetes. Use when requests involve argo submit, argo
  list, argo get, argo logs, argo retry, argo suspend, argo resume, argo
  terminate, argo stop, argo template, or argo cron commands.
- [using-argocd-cli](./skills/using-argocd-cli/SKILL.md): Provides expert
  guidance for using the argocd CLI to manage applications, repositories,
  clusters, and projects in Argo CD. Use when requests involve argocd login,
  argocd app sync, argocd app get, argocd app diff, argocd app rollback,
  argocd app wait, argocd repo add, argocd cluster add, argocd proj, or
  argocd appset commands.
- [using-aws-cli](./skills/using-aws-cli/SKILL.md): Provides expert guidance
  for using the AWS CLI to authenticate, inspect, and operate AWS resources
  safely. Use when requests involve aws configure, aws sso login, aws ec2,
  aws s3, aws iam, aws ecs, aws lambda, aws cloudformation, aws
  secretsmanager, aws ssm, aws sts, aws rds, aws route53, or aws ecr commands.
- [using-crossplane](./skills/using-crossplane/SKILL.md): Provides expert
  guidance for working with Crossplane — the Kubernetes-native control plane
  framework for infrastructure as code. Use when the user asks about Crossplane
  providers, ProviderConfig, managed resources, XRDs, Compositions, composite
  resources (XR), claims (XRC), composition functions, crossplane xpkg
  commands, crossplane beta render, crossplane beta trace, or debugging
  Crossplane resource reconciliation.
- [using-claude-cli](./skills/using-claude-cli/SKILL.md): Use when instructed
  to run Claude CLI (`claude`) commands for interactive coding sessions,
  non-interactive execution, resume flows, agent selection, permission
  controls, or MCP configuration. Invoke before running any claude command.
- [using-codex-cli](./skills/using-codex-cli/SKILL.md): Use when you need to
  dispatch tasks to the Codex CLI tool for parallel execution, offloading
  long-running work, or leveraging OpenAI models. Invoke before running any
  codex command.
- [using-devcontainer-cli](./skills/using-devcontainer-cli/SKILL.md):
  Provides expert guidance for using the DevContainer CLI (`devcontainer`)
  to build, run, and manage isolated development environments. Use when
  requests involve `devcontainer` commands such as `up`, `exec`, `build`,
  `run-user-commands`, or lifecycle hooks.
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
- [using-helm](./skills/using-helm/SKILL.md): Provides expert guidance for
  working with Helm, the Kubernetes package manager for templating, packaging,
  installing, and operating Kubernetes applications as charts and releases.
  Use when the user asks about Helm charts, `Chart.yaml`, `values.yaml`,
  templates, release commands, dependencies, OCI registries, or troubleshooting.
- [using-kubectl](./skills/using-kubectl/SKILL.md): Provides expert guidance
  for using kubectl to inspect, troubleshoot, and operate Kubernetes clusters
  safely. Use when requests involve kubectl commands such as get, describe,
  logs, exec, apply, diff, delete, rollout, port-forward, top, auth can-i, or
  context and namespace management.
- [using-kustomize](./skills/using-kustomize/SKILL.md): Provides expert
  guidance for working with Kustomize — a template-free, declarative Kubernetes
  configuration management tool that uses overlays and patches to customize YAML
  without forking. Use when the user asks about kustomization.yaml, kustomize
  build, overlays, bases, patches, configMapGenerator, secretGenerator, images
  transformer, components, helmCharts, replacements, or kubectl apply -k.
- [using-ollama](./skills/using-ollama/SKILL.md): Use when you need to
  dispatch tasks to a local or remote Ollama instance for inference, code
  generation, analysis, or summarization. Invoke before running any ollama
  command.
- [writing-architecture-decision-records](./skills/writing-architecture-decision-records/SKILL.md):
  Use when creating or updating Architectural Decision Records, when a
  significant technical or architectural choice needs documenting, or when
  asked to write an ADR.
- [writing-devcontainer-features](./skills/writing-devcontainer-features/SKILL.md):
  Produces correct, publishable Dev Container Features following the official
  devcontainers.org specification. Use when asked to write, create, fix,
  review, or publish a devcontainer feature, devcontainer-feature.json,
  install.sh entrypoint, feature test suite, or OCI feature distribution.
- [writing-dockerfiles](./skills/writing-dockerfiles/SKILL.md): Produces
  correct, secure, and efficient Dockerfiles following established best
  practices for base image selection, layer caching, multi-stage builds,
  security hardening, and signal handling. Use when asked to write, fix,
  review, or improve a Dockerfile or container image build configuration.
- [writing-git-commits](./skills/writing-git-commits/SKILL.md): Writes and
  validates git commit messages using Conventional Commits. Use when drafting
  or revising commit messages, selecting type/scope, or adding commit body and
  footer metadata after commit boundaries are already decided.
- [writing-github-actions](./skills/writing-github-actions/SKILL.md): Produces
  correct, secure, and maintainable GitHub Actions workflow and action YAML
  files. Use when the user asks about GitHub Actions, workflow files,
  .github/workflows, on triggers, jobs, steps, matrix strategy, reusable
  workflows, composite actions, secrets, OIDC, caching, artifacts, or CI/CD
  pipeline configuration for GitHub repositories.
- [writing-gitlab-cicd](./skills/writing-gitlab-cicd/SKILL.md): Produces
  correct, secure, and maintainable GitLab CI/CD pipeline configurations.
  Use when the user asks about `.gitlab-ci.yml`, pipeline stages, jobs, rules,
  variables, environments, artifacts, caching, includes, extends, anchors,
  merge request pipelines, parent-child pipelines, multi-project pipelines,
  GitLab runners, SAST, DAST, or any GitLab CI/CD configuration.
- [writing-grammar](./skills/writing-grammar/SKILL.md): Apply a structured
  grammar checklist to a document line by line. Use when any document
  requires a thorough, consistent grammar review before publication or
  handoff.
- [writing-makefiles](./skills/writing-makefiles/SKILL.md): Produces correct,
  portable, and maintainable GNU Makefiles following established best practices
  for targets, variables, pattern rules, functions, and self-documentation. Use
  when asked to write, fix, review, or improve a Makefile or .mk file.
- [writing-mermaid-diagrams](./skills/writing-mermaid-diagrams/SKILL.md):
  Produces correct Mermaid diagram definitions for all supported diagram
  types including flowchart, sequence, class, state, ER, Gantt, pie,
  gitGraph, mindmap, and 20+ others. Use when asked to create, write, fix,
  or explain Mermaid diagrams, diagram-as-code, or .mmd files.
- [writing-markdown](./skills/writing-markdown/SKILL.md): Use when writing or
  editing any markdown document, README, or .md file to ensure strict
  compliance with all markdownlint rules.
- [writing-product-requirement-documents](./skills/writing-product-requirement-documents/SKILL.md):
  Use when creating a high-precision, AI-ready Product Requirements Document
  (PRD). Focuses on outcome-based goals, literal specificity for coding
  agents, and maintaining a living document.
- [writing-pull-requests](./skills/writing-pull-requests/SKILL.md): Writes
  and updates high-quality pull request descriptions that speed review and
  improve auditability. Use when asked to draft, improve, or review a PR
  body, PR summary, reviewer guide, test plan, or merge request description.
- [writing-skills](./skills/writing-skills/SKILL.md): Creates a new agent
  skill directory with a compliant SKILL.md and supporting reference files.
  Use when asked to build, write, add, or create a skill.
- [writing-task-specs](./skills/writing-task-specs/SKILL.md): Use when breaking
  a feature plan into implementation tasks. Produces a task list where each
  task maps to exactly one branch and one PR. Invoke after a tech plan is
  approved and before any implementation begins.
