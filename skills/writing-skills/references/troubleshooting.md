# Creating Skills: Troubleshooting

## Contents

- Common mistakes and fixes
- Anti-patterns
- Red flags and stop conditions

---

## Common Mistakes and Fixes

| Mistake | Problem | Fix |
| ------- | ------- | --- |
| All content in SKILL.md | Body bloat on every activation | Move detail to `references/` |
| SKILL.md body over 100 lines | Degrades reasoning space | Split content into reference files |
| First-person description (`"I can..."`) | Prompt inconsistency | Rewrite in third person |
| No trigger keywords in description | Skill never activates | Add "Use when…" with specific terms |
| Vague description (`"helps with files"`) | Agent cannot select correctly | Be specific about what and when |
| Missing "When Not to Use" section | Scope bleeds into other skills | Explicitly name exclusions |
| Nested references (A → B → C) | Partial reads, missing context | All references one hop from SKILL.md |
| Reference file over 100 lines, no TOC | Agent misses sections | Add table of contents at top |
| Vague reference pointer (`"see references/"`) | Agent skips the file | Name the file and the condition |
| Skill covers two unrelated concerns | Hard to activate precisely | Split into two skills |
| Windows-style paths (`ref\guide.md`) | Breaks on Unix systems | Use forward slashes |
| Optional frontmatter fields by default | Breaks portability | Only `name` and `description` |
| `name` contains uppercase or underscores | Fails spec validation | Lowercase and hyphens only |
| Directory name does not match `name` field | Agent cannot locate files | Rename to match exactly |
| Explaining basics the model knows | Token waste | Trust the model; skip known context |
| Time-sensitive content (`"before Aug 2025"`) | Becomes wrong | Use a "Legacy" collapsed section |
| Inconsistent terminology | Agent misinterprets instructions | Pick one term per concept, use it throughout |
| No examples in `references/examples.md` | Agent guesses output format | Provide at least one input/output pair |
| No troubleshooting file | Agent repeats the same mistakes | Document known failure modes |

---

## Anti-Patterns

### The monolith

All procedure, examples, and troubleshooting live in SKILL.md. The body
is 600+ lines. Every activation loads everything.

**Fix:** Move full procedure to `references/overview.md`, examples to
`references/examples.md`, and failure modes to
`references/troubleshooting.md`. Keep SKILL.md to high-level steps and
links.

### The stub

SKILL.md has a workflow that says "follow best practices." Reference files
exist but contain no actual content. The agent has no actionable guidance.

**Fix:** Every reference file must contain concrete, actionable content.
The overview must have the full procedure. Examples must have real
input/output pairs. Troubleshooting must list observed failure modes.

### The catch-all

One skill covers "any coding task," "all git operations," or "everything
related to deployment." The description cannot be specific. The agent
activates it for everything or nothing.

**Fix:** Split by specific concern. One skill per repeatable, nameable
workflow. If you cannot write a specific "Use when…" sentence, the scope
is too broad.

### The nested chain

SKILL.md links to `advanced.md`, which links to `details.md`, which
contains the actual content. The agent reads SKILL.md, follows one hop,
then uses `head -100` on the next file and misses the content.

**Fix:** All reference files must link directly from SKILL.md. Maximum
one hop. Move any content from deep files up to the top-level reference.

### The mirror

The `references/overview.md` repeats the SKILL.md body almost verbatim.
Loading the reference adds no new information.

**Fix:** SKILL.md contains high-level steps and rules only. The reference
contains the full sub-step procedure, constraints, and edge cases the
body omits.

---

## Red Flags — Stop and Correct

Stop and fix before continuing if any of these are true:

- Skill name contains uppercase letters, underscores, or does not match
  the directory name
- Description is in first or second person
- Description has no "Use when…" clause
- SKILL.md body exceeds 100 lines
- A reference file is referenced from another reference file
- Two unrelated workflows are combined in one skill
- Any file path uses backslashes
- `references/overview.md` does not exist
- SKILL.md workflow section contains the full procedure inline instead of
  linking to a reference file
- Policy text is duplicated between `SKILL.md` and `references/*`
- The skill has not been added to `README.md`
