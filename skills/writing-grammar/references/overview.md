# Overview

Apply every rule from [checklist.md](checklist.md) to every sentence in
the target document. Use a deterministic pass order so the review is
repeatable and auditable.

## Methodology

### Step 1: Load the checklist

Read [checklist.md](checklist.md) before beginning. Do not start review
until all rules are available.

### Step 2: Sentence-by-sentence pass

For each sentence:

- Apply every rule in order.
- Record each violation immediately:
  - exact quote
  - rule name
  - severity (`critical`, `major`, `minor`)
  - corrected version
- Do not defer findings.

Severity guidance:

- `critical`: meaning becomes wrong or ambiguous
- `major`: clear grammar violation that harms readability
- `minor`: correctness issue with low comprehension impact

### Step 3: Cross-sentence consistency pass

Run a second pass across paragraph or section boundaries for:

- tense drift
- pronoun referent drift
- punctuation consistency
- dialect consistency (`US` vs `UK`)

### Step 4: Minimal-change rewrite rule

When suggesting corrections:

- prefer the smallest edit that fixes the issue
- keep original intent and technical meaning
- preserve formatting unless grammar requires punctuation changes
- avoid stylistic rewrites unless user asks

### Step 5: Verification

Before reporting:

- count total sentences reviewed
- confirm all rules were applied
- validate that each finding includes quote, diagnosis, and correction
- ensure optional style notes are clearly labeled as optional

## Output Contract

```markdown
## Grammar Review Results

**Document:** [filename]
**Sentences reviewed:** [n]
**Rules applied:** all [n] rules from checklist.md
**Dialect:** [US|UK|assumed]

### Findings

| # | Location | Severity | Quoted text | Rule | Correction |
| - | -------- | -------- | ----------- | ---- | ---------- |
| 1 | [line]   | major    | "..."       | [id] | "..."      |

### Optional Style Notes

- [Only include if user requested style guidance.]

### Verdict

[If findings]: [n] grammar issues found ([x critical, y major, z minor]).
[If none]: No grammar issues found after full checklist application.
```
