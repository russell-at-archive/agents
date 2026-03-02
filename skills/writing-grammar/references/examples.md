# Examples

## Example 1: Review-Only Request

Input:

```text
Please review this section for grammar only. Do not rewrite style.
```

Expected behavior:

- Run full checklist
- Report issues with exact quotes and corrections
- Exclude optional style notes

## Example 2: Grammar Rewrite Request

Input:

```text
Rewrite this paragraph to fix grammar while preserving meaning.
```

Expected behavior:

- Identify issues first
- Provide corrected paragraph with minimal edits
- Keep terminology and technical meaning unchanged

## Example 3: Ambiguous Dialect

Input:

```text
Proofread this doc. Use standard spelling.
```

Expected behavior:

- Assume `US` spelling unless project conventions indicate otherwise
- State assumption in output (`Dialect: US (assumed)`)
- Apply assumption consistently

## Example Output

```markdown
## Grammar Review Results

**Document:** deployment-runbook.md
**Sentences reviewed:** 42
**Rules applied:** all 15 rules from checklist.md
**Dialect:** US

### Findings

| # | Location | Severity | Quoted text | Rule | Correction |
| - | -------- | -------- | ----------- | ---- | ---------- |
| 1 | L18 | major | "A set of checks are required." | Rule 2 | "A set of checks is required." |
| 2 | L27 | minor | "create, validate, deploy" | Rule 14 | "create, validate, and deploy" |

### Verdict

2 grammar issues found (0 critical, 1 major, 1 minor).
```
