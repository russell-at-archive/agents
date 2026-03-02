# Delivery Standards

This document defines how work must be planned, tracked, and delivered.
It is the authoritative reference for all delivery-related agent skills.

## Research Basis

This standard consolidates two prior documents:

- `agent-delivery-best-practices.md`
- `agent-delivery-research-report.md`

It combines implementation rules with externally sourced best practices from:

- GitHub Spec Kit
- Graphite CLI documentation
- Git worktree documentation
- GitHub Projects, templates, and issue-linking guidance
- Conventional Commits and code review standards

## Philosophy

Small, focused changes are easier to review, safer to merge, and simpler
to revert. Every unit of work—from a single commit to a full feature—must
be scoped to the minimum change that delivers a complete, verifiable outcome.

This means:

- plan before implementation
- decompose features into independently deliverable tasks
- one task per branch, one branch per PR
- submit PRs as stacks so reviewers understand ordering and context
- validate locally before any submission

---

## Document Hierarchy

Planning artifacts flow from high-level intent to executable tasks.
Each level answers a different question.

| Document    | Question         | Owner       | When                         |
| ----------- | ---------------- | ----------- | ---------------------------- |
| PRD         | What and why     | Product     | Before engineering begins    |
| ADR         | Why architecture | Engineering | At major technical choices   |
| Tech Plan   | How to build     | Engineering | Before task breakdown        |
| Task List   | What to do/order | Engineering | After tech plan approval     |
| PR          | What changed/why | Author      | For each logical change      |

Do not skip levels. A task list without a tech plan produces
uncoordinated implementation. A PR without a linked task is untraceable.

### Skill mapping

| Artifact   | Skill                          |
| ---------- | ------------------------------ |
| PRD        | `writing-prds`                 |
| ADR        | `writing-adrs`                 |
| Tech Plan  | `using-github-speckit`         |
| Task List  | `writing-task-specs`             |
| Commit     | `writing-git-commits` |
| PR Stack   | `using-graphite-cli`           |

---

## Task Decomposition

### Principles

- One task = one logical concern = one branch = one PR.
- Tasks must be independently testable. If a task cannot be verified
  without completing another, merge the two or reorder them.
- Tasks must be completable in a single work session without waiting on
  external dependencies.
- Every task has explicit acceptance criteria before work begins.

### INVEST Criteria

Each task must satisfy INVEST:

| Letter | Meaning     | Check                               |
| ------ | ----------- | ----------------------------------- |
| I      | Independent | Not blocked by another in-progress  |
| N      | Negotiable  | Scope can be adjusted               |
| V      | Valuable    | Reviewer can verify outcome         |
| E      | Estimable   | Scope is clear enough to start      |
| S      | Small       | Fits one PR; target < 400 net lines |
| T      | Testable    | Acceptance criteria are verifiable  |

### Task Template

```markdown
## TASK-NNN: <imperative title>

**Branch:** <type>/<short-slug>
**Stack parent:** <parent-branch or trunk>
**Depends on:** TASK-NNN, ...  (or "none")

### Description

<2-4 sentences on what and why.>

### Acceptance Criteria

- [ ] Given <context>, when <action>, then <outcome>.
- [ ] Given <context>, when <action>, then <outcome>.

### Validation Commands

\`\`\`bash
<commands to verify the task is complete>
\`\`\`

### Definition of Done

- [ ] Acceptance criteria pass
- [ ] Validation commands pass
- [ ] No lint or type errors introduced
- [ ] PR submitted and linked to this task
```

### Sizing Guidelines

| Signal                         | Action                      |
| ------------------------------ | --------------------------- |
| Touches > 3 modules            | Split into smaller tasks    |
| Mixes feature + refactor       | Separate refactor first     |
| Purely mechanical rename       | Acceptable in one PR        |
| Needs design doc to explain    | Tech plan is incomplete     |
| Review > 30 minutes            | Split the PR                |

---

## Commit Standards

All commits must follow the **Conventional Commits** specification.
See `skills/writing-git-commits/SKILL.md` for the full reference.

### Quick Reference

```text
<type>(<scope>): <short description>

[optional body]

[optional footer]
```

**Types:**

| Type     | Use                                         | SemVer    |
| -------- | ------------------------------------------- | --------- |
| feat     | New capability                              | MINOR     |
| fix      | Bug correction                              | PATCH     |
| perf     | Performance improvement, no behavior change | PATCH     |
| refactor | Code restructure, no behavior change        | —         |
| test     | Add or correct tests only                   | —         |
| docs     | Documentation only                          | —         |
| chore    | Build system, tooling, config               | —         |
| ci       | CI/CD pipeline changes                      | —         |
| style    | Formatting, whitespace, no logic change     | —         |
| revert   | Revert a prior commit                       | PATCH     |

Breaking change: append `!` after type/scope, e.g. `feat!:`, and add
`BREAKING CHANGE:` footer.

### Commit Rules

- Subject line: 72 characters or fewer, imperative mood, no period
- One logical change per commit; do not mix unrelated changes
- Body: explain the *why*, not the *what* (code shows the what)
- Reference issues in footer: `Closes #123`, `Refs #456`

---

## Branch Naming

Branch names must communicate type and intent at a glance.

```text
<type>/<task-id>-<short-slug>
```

Examples:

```text
feat/TASK-012-user-auth-token
fix/TASK-034-null-pointer-on-logout
refactor/TASK-018-extract-config-loader
docs/TASK-002-api-reference
chore/TASK-007-upgrade-node-20
```

Rules:

- Lowercase, hyphens only (no underscores, no slashes in slug)
- Task ID in slug ties the branch to the task list
- Slug is 2-5 words, imperative or noun phrase
- Type prefix matches the primary commit type on the branch

---

## PR Standards

### Structure

Every PR must have:

1. **Title** — `<type>(<scope>): <short description>` matching the
   branch commit
2. **Summary** — What changed and why (3-5 bullets max)
3. **Type of Change** — Checkbox from the PR template
4. **Linked Issue / Task** — `Closes #NNN` or `Refs #NNN`
5. **Test Plan** — What was run to verify the change
6. **Definition of Done** — All boxes checked before requesting review

### Size

| Guideline         | Target              |
| ----------------- | ------------------- |
| Lines changed     | < 400 net lines     |
| Files touched     | < 10 files          |
| Review time       | < 30 minutes        |
| Logical concerns  | Exactly one         |

These are guidelines, not hard limits. A 1-line change in 20 files
(e.g., a rename) is acceptable. A 300-line PR mixing 3 features is not.

### Stacking Rules

Use stacked PRs when work has dependencies. Each PR in a stack must:

- Be reviewable in isolation (the reviewer sees only its diff vs parent)
- Have a clear dependency reason (not just "it was easier to combine")
- Pass local validation independently

Submit the full stack with:

```bash
gt submit --stack --no-interactive --publish --reviewer <username>
```

### Definition of Done: PR

- [ ] Acceptance criteria from linked task pass
- [ ] Local validation (lint, typecheck, tests) pass
- [ ] PR title follows Conventional Commits format
- [ ] PR description complete (summary, type, task link, test plan)
- [ ] No unresolved review comments
- [ ] Stacked correctly (parent branch merged or PR is base-branch PR)

---

## Delivery Workflow Summary

```text
PRD → ADR (if needed) → Tech Plan → Task List
                                         │
                         ┌───────────────┘
                         │
                  For each task:
                         │
                  1. Create worktree (using-git-worktrees)
                  2. Create branch   (gt create <branch>)
                  3. Implement       (small, focused)
                  4. Commit          (Conventional Commits)
                  5. Validate        (lint, types, tests)
                  6. Submit PR       (gt submit --stack --publish)
                  7. Update PR body  (gh pr edit)
```

---

## Issue and Project Tracking

### GitHub Projects

Use GitHub Projects as the canonical execution board:

- Track issues, PRs, and draft ideas in a single project view.
- Use custom fields: owner, status, priority, size, milestone.
- Create multiple views: table (planning), board (execution),
  roadmap (milestone visibility).
- Automate status transitions where available.

### Issue Templates

Store issue templates in `.github/ISSUE_TEMPLATE/` on the default
branch. Every issue type (feature, bug, task) must have a template.
Templates enforce: problem statement, acceptance criteria, and task ID.

### PR Templates

Store the PR template in `.github/pull_request_template.md`. Every PR
body must include:

- Summary (what changed and why)
- Type of change (checkbox)
- Linked issue with closing keyword (`Closes #NNN`)
- Test plan (what was run)
- Definition of Done (checkboxes)

### Linking PRs to Issues

Use GitHub closing keywords in the PR body to auto-close issues on merge:

```text
Closes #123
Fixes #456
Refs #789
```

Use `Refs` when the PR contributes to but does not fully resolve an issue.

---

## Anti-Patterns

| Anti-Pattern              | Problem           | Fix                         |
| ------------------------- | ----------------- | --------------------------- |
| Mega PR                   | Risky, unreviable | Split by task               |
| Mixed concerns            | Hard to trace     | Separate PRs per concern    |
| Vague commits             | Poor history      | Use Conventional Commits    |
| No acceptance criteria    | Undefined done    | Define criteria first       |
| Skip tech plan            | Uncoordinated     | Always plan before tasks    |
| Implement in trunk        | No isolation      | Use worktrees               |
| Submit without validation | CI is first gate  | Run local checks first      |
| Draft PR w/o reviewer     | Sits unreviewed   | Use `--publish --reviewer`  |
| No task ID                | Untraceable       | Reference task in branch    |

---

## References

### Standards

- Conventional Commits: <https://www.conventionalcommits.org/en/v1.0.0/>
- Google Code Review Guidelines:
  <https://google.github.io/eng-practices/review/>
- Trunk-Based Development: <https://trunkbaseddevelopment.com/>

### Tools

- Spec Kit: <https://github.com/github/spec-kit>
- Graphite CLI tutorials: <https://graphite.com/docs/cli-tutorials>
- Graphite create and submit PRs: <https://graphite.com/docs/create-submit-prs>
- Git worktree docs: <https://git-scm.com/docs/git-worktree>
- GitHub Projects:
  <https://docs.github.com/en/issues/planning-and-tracking-with-projects>
- GitHub issue and PR templates:
  <https://docs.github.com/articles/about-issue-and-pull-request-templates/>
- Linking PRs to issues: <https://docs.github.com/articles/closing-issues-using-keywords/>

### Related Skills

- `skills/writing-task-specs/SKILL.md`
- `skills/planning-speckit-worktrees-graphite/SKILL.md`
- `skills/using-git-worktrees/SKILL.md`
- `skills/using-github-speckit/SKILL.md`
- `skills/using-graphite-cli/SKILL.md`
- `skills/writing-adrs/SKILL.md`
- `skills/writing-git-commits/SKILL.md`
- `skills/writing-prds/SKILL.md`

---

## Measurement and Governance

Track these metrics to verify process quality:

- planning completeness rate (`spec/plan/tasks` before implementation)
- median PR size (net lines and files changed)
- review turnaround time
- rework rate (reopened PRs and post-merge fixes)
- queue latency to merge

Use these metrics in weekly delivery reviews:

- If PR size or review time trends up, tighten decomposition rules.
- If rework trends up, strengthen acceptance criteria and local checks.
- If queue latency trends up, reduce stack depth and PR coupling.
