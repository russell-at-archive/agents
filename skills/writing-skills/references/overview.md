# Creating Skills: Full Procedure

## Contents

- Progressive disclosure model
- Workflow loop
- Directory structure
- Frontmatter rules
- SKILL.md body rules
- Reference file rules
- Installation reference rules
- Eval guidance
- Naming conventions
- Authoring checklist

---

## Progressive Disclosure Model

Skills load in three tiers. Every content decision must be governed by
which tier it belongs in.

| Tier | Content | When loaded | Token cost |
| ---- | ------- | ----------- | ---------- |
| 1 — Metadata | `name` + `description` frontmatter | Always, at startup | ~100 tokens |
| 2 — Instructions | `SKILL.md` body | When skill activates | Full body, once |
| 3 — Resources | `references/`, `scripts/`, `assets/` | On demand, per file | Zero until read |

**Rule:** If an agent does not need a piece of information on every
activation, it belongs in Tier 3, not Tier 2.

---

## Workflow Loop

Use an iterative loop instead of one-shot authoring:

1. Understand the skill with concrete examples and trigger phrases.
2. Draft or revise the skill.
3. Add deferred detail only where it reduces `SKILL.md` size or improves
   reliability.
4. Create realistic eval prompts when the skill's behavior is worth
   testing.
5. Compare the skill against a baseline when possible.
6. Review output quality, timing, tokens, and trigger behavior.
7. Revise and repeat until the skill is good enough.

Do not force evals for purely subjective skills if they add ceremony
without producing useful signal.

---

## Directory Structure

```text
skills/<name>/
├── SKILL.md               # Required. Frontmatter + lean body.
├── references/           # Optional. Add only needed files.
│   └── installation.md   # Required for CLI-tool skills.
├── scripts/              # Optional. Executable scripts.
├── assets/               # Optional. Templates, schemas, data.
└── evals/                # Optional. Eval prompts and assertions.
```

Only `SKILL.md` is always required. Add support files only when they
earn their keep. The one exception is `references/installation.md`,
which is required for CLI-tool skills.

---

## Frontmatter Rules

Only `name` and `description` are required. Do not add optional fields
unless there is an explicit reason.

```yaml
---
name: skill-name
description: <third-person what>. Use when <trigger keywords>.
---
```

### `name` constraints

- Lowercase letters, numbers, and hyphens only
- 1–64 characters
- No leading or trailing hyphen
- No consecutive hyphens (`--`)
- Must exactly match the parent directory name

### `description` constraints

- Non-empty, maximum 1024 characters
- **Third person only** — the description is injected into the system
  prompt; first or second person causes inconsistency
- Must include **what the skill does** and **when to use it**
- Must include specific keywords that match real user requests

Template: `<What it does>. Use when <trigger conditions and keywords>.`

---

## SKILL.md Body Rules

The `SKILL.md` body is the control plane for the skill. Keep only:

- Activation guidance
- High-level workflow
- Hard guardrails
- Explicit pointers to deferred resources

Use the common section structure unless there is a strong reason not to:

1. **Overview**
2. **When to Use**
3. **When Not to Use**
4. **Prerequisites**
5. **Workflow**
6. **Hard Rules**
7. **Failure Handling**
8. **Red Flags**

### Body limits

- Keep it under 100 lines when possible; if it grows, move detail out.
- Under 5000 tokens (target)
- Prefer imperative instructions over narrative explanation
- Do not explain concepts the model already knows
- For CLI-tool skills, keep install commands out of the main body unless
  they are essential for activation. Put detailed installation guidance in
  `references/installation.md`.

### Content routing

| Content type | Destination |
| ------------ | ----------- |
| Activation rules | SKILL.md body |
| High-level workflow | SKILL.md body |
| Hard rules and guardrails | SKILL.md body |
| Links to reference files | SKILL.md body |
| Full procedure with all sub-steps | `references/*.md` as needed |
| Detailed examples | `references/*.md` as needed |
| Troubleshooting, mistakes, red flags | `references/*.md` as needed |
| API references, schemas | `references/` |
| Executable logic | `scripts/` |
| Templates, schemas, static data | `assets/` |
| Eval prompts and assertions | `evals/` |

Non-duplication rule:

- Do not copy policy text verbatim between `SKILL.md` and reference files.
- If content appears in `SKILL.md`, references should expand it, not mirror it.
- If content is moved to references, remove it from `SKILL.md`.

---

## Reference File Rules

### Depth

All reference files must link **directly from SKILL.md** — one hop only.
Nested chains (A → B → C) cause agents to partially read files with
`head -100`, producing incomplete context.

### Table of contents

Any reference file over 100 lines must have a table of contents
immediately after the title, before any content.

### Explicit signals

SKILL.md must name the specific file and the condition that triggers
reading it:

```markdown
# Good
For the full procedure and constraints, read
[references/overview.md](references/overview.md).
When the task involves examples, read
[references/examples.md](references/examples.md).

# Bad
See the references directory for more information.
```

## Installation Reference Rules

If a skill teaches use of a CLI tool, it must include
`references/installation.md` as a first-class reference file.

Minimum bar:

- Name at least one supported installation path.
- Prefer concrete commands such as `brew install`, `npm install -g`,
  `pip install`, `cargo install`, or the official release channel.
- If installation varies by platform, include the most common path and
  point to the official alternative.
- Distinguish install from auth/configuration. `gh auth login` is not an
  install step.
- `SKILL.md` should explicitly point to
  [references/installation.md](references/installation.md) when the
  binary is missing or first-time setup is relevant.

Not sufficient:

- "`gh` is installed and accessible"
- "Verify with `tool --version`"
- "Install if missing"

---

## Eval Guidance

Use evals when they add real signal.

Recommended cases:

- Skills with objective outputs
- Skills with deterministic file changes or tool usage expectations
- Skills being actively improved or benchmarked

Suggested artifacts:

- `evals/evals.json` for prompts and expectations
- `evals/files/` for any fixed input files
- A workspace outside the skill directory for run outputs if the eval loop
  produces many artifacts

When comparing versions, prefer paired runs:

- `with_skill`
- `without_skill`, or the prior skill revision

Evaluate both qualitative output quality and any objective assertions you
can defend.

---

## Naming Conventions

| Style | Examples | Use |
| ----- | -------- | --- |
| Gerund (preferred) | `creating-skills`, `writing-commits` | First choice |
| Noun phrase | `skill-creation`, `commit-writing` | Acceptable |
| Action verb | `create-skills`, `write-commits` | Acceptable |
| Vague | `helper`, `utils`, `tools` | Never |

---

## Authoring Checklist

### Tier 1 — Metadata

- [ ] `name` is lowercase, hyphen-separated, matches directory name
- [ ] `description` is third-person, specific, includes trigger keywords
- [ ] `description` includes both what the skill does and when to use it
- [ ] Frontmatter contains only fields that are justified by the skill

### Tier 2 — SKILL.md body

- [ ] Body is as short as possible
- [ ] Core sections are present unless omission is justified
- [ ] Workflow links to reference files for detail; no embedded manuals
- [ ] Hard rules and safety constraints are explicit
- [ ] Reference links are explicit with file paths and trigger conditions
- [ ] No duplicated policy text between `SKILL.md` and `references/*`
- [ ] No over-explanation of things the model already knows
- [ ] Commands use non-interactive flags where applicable
- [ ] CLI-tool skills link directly to `references/installation.md`

### Tier 3 — Reference files

- [ ] `references/installation.md` exists for CLI-tool skills
- [ ] All references are one hop from `SKILL.md`
- [ ] Reference files over 100 lines have a table of contents
- [ ] Every reference file exists for a specific reason, not by template

### Portability

- [ ] All file paths use forward slashes
- [ ] Skill name contains no uppercase or underscores
