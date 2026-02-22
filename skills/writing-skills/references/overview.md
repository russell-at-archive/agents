# Creating Skills: Full Procedure

## Contents

- Progressive disclosure model
- Directory structure
- Frontmatter rules
- Required SKILL.md sections
- Reference file rules
- Naming conventions
- README index entry
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

## Directory Structure

```text
skills/<name>/
├── SKILL.md                # Required. Frontmatter + lean body.
├── references/
│   ├── overview.md         # Full procedure and constraints
│   ├── examples.md         # Concrete input/output examples
│   └── troubleshooting.md  # Recovery paths, mistakes, red flags
├── scripts/                # Optional. Executable scripts.
└── assets/                 # Optional. Templates, schemas, data.
```

Create at minimum: `SKILL.md`, `references/overview.md`,
`references/examples.md`, `references/troubleshooting.md`.

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

## Required SKILL.md Sections

Every SKILL.md must contain these sections in this order:

1. **Overview** — one paragraph: purpose, core principle, and a link to
   `references/overview.md` for the full procedure
2. **When to Use** — explicit positive trigger conditions
3. **When Not to Use** — explicit negative triggers and scope exclusions
4. **Prerequisites** — required binaries, auth, env vars, permissions
5. **Workflow** — numbered high-level steps; link to reference files
   for detail; do not embed the full procedure here
6. **Hard Rules** — non-negotiable constraints and safety guardrails
7. **Failure Handling** — responses to auth failure, missing binaries,
   pre-check failure; when to ask the user
8. **Red Flags** — conditions requiring the agent to stop and correct

### Body limits

- Under 100 lines (hard)
- Under 5000 tokens (target)
- Prefer imperative instructions over narrative explanation
- Do not explain concepts the model already knows

### Content routing

| Content type | Destination |
| ------------ | ----------- |
| Activation rules | SKILL.md body |
| High-level workflow | SKILL.md body |
| Hard rules and guardrails | SKILL.md body |
| Links to reference files | SKILL.md body |
| Full procedure with all sub-steps | `references/overview.md` |
| Detailed examples | `references/examples.md` |
| Troubleshooting, mistakes, red flags | `references/troubleshooting.md` |
| API references, schemas | `references/` |
| Executable logic | `scripts/` |
| Templates, schemas, static data | `assets/` |

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

---

## Naming Conventions

| Style | Examples | Use |
| ----- | -------- | --- |
| Gerund (preferred) | `creating-skills`, `writing-commits` | First choice |
| Noun phrase | `skill-creation`, `commit-writing` | Acceptable |
| Action verb | `create-skills`, `write-commits` | Acceptable |
| Vague | `helper`, `utils`, `tools` | Never |

---

## README Index Entry

After creating the skill, add it to `README.md` in alphabetical order
under `## Skills Index`:

```markdown
- [creating-skills](./skills/creating-skills/SKILL.md): Creates a new
  agent skill directory with a compliant SKILL.md and supporting reference
  files. Use when asked to build, write, add, or create a skill.
```

Keep the description to 2–3 lines, matching the style of existing entries.

---

## Authoring Checklist

### Tier 1 — Metadata

- [ ] `name` is lowercase, hyphen-separated, matches directory name
- [ ] `description` is third-person, specific, includes trigger keywords
- [ ] `description` includes both what the skill does and when to use it
- [ ] Only `name` and `description` in frontmatter

### Tier 2 — SKILL.md body

- [ ] Body is under 100 lines
- [ ] All eight required sections are present in order
- [ ] Workflow links to reference files for detail; no embedded procedures
- [ ] Hard rules and safety constraints are explicit
- [ ] Reference links are explicit with file paths and trigger conditions
- [ ] No duplicated policy text between `SKILL.md` and `references/*`
- [ ] No over-explanation of things the model already knows
- [ ] Commands use non-interactive flags where applicable
- [ ] Markdown is lint-clean (80-char wrap, fenced code blocks with
      language tags, blank lines around headings and blocks)

### Tier 3 — Reference files

- [ ] `references/overview.md` exists with full procedure
- [ ] `references/examples.md` exists with concrete examples
- [ ] `references/troubleshooting.md` exists with mistakes and red flags
- [ ] All references are one hop from `SKILL.md`
- [ ] Reference files over 100 lines have a table of contents

### Portability

- [ ] All file paths use forward slashes
- [ ] No tool-specific API names in body prose
- [ ] Skill name contains no uppercase or underscores
