---
name: writing-grammar
description: Apply a structured grammar checklist to a document line by
  line. Use when any document requires a thorough, consistent grammar
  review before publication or handoff.
tier: lightweight
allowed-tools:
  - Read
---

# Grammar Review Skill

Apply every rule in [checklist.md](./references/checklist.md) to every
sentence in the target document. Do not scan for problems — work through
the document line by line, applying each rule explicitly.

## Methodology

### Step 1: Load the checklist

Read [checklist.md](./references/checklist.md) before beginning. Every
rule must be applied to every sentence. Reading the checklist is not
optional.

### Step 2: Sentence-by-sentence pass

For each sentence:

- Apply every checklist rule in sequence
- Record any violation immediately with the exact quoted text, the rule
  violated, and the correction
- Do not defer findings to a later pass

### Step 3: List consistency pass

After the sentence pass, make a dedicated second pass checking only
comma-separated lists throughout the entire document. Verify every list
of three or more items has "and" or "or" before the final item. This
pass exists because list errors are easy to miss when attention is
focused on sentence-level structure.

### Step 4: Self-verification

Before reporting results:

- Count the total number of sentences reviewed
- Confirm every checklist rule was applied, not just the rules that
  produced findings
- A result of "no errors found" is only valid if all rules were applied
  to all sentences — it must be earned, not assumed

## Output Format

```markdown
## Grammar Review Results

**Document:** [filename]
**Sentences reviewed:** [n]
**Rules applied:** all [n] rules from checklist.md

### Findings

| # | Location  | Quoted text         | Rule violated | Correction       |
| - | --------- | ------------------- | ------------- | ---------------- |
| 1 | [section] | "exact quoted text" | [rule name]   | "corrected text" |

### Verdict

[If errors found]: [n] errors found. Correct before handoff.
[If no errors]: No errors found. All [n] rules applied to all sentences.
```
