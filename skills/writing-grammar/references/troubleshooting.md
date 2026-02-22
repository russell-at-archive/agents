# Troubleshooting

## Problem: Grammar vs style is unclear

Symptoms:

- User asks to "improve writing" without constraints

Resolution:

- Default to grammar-only corrections
- Label non-grammar suggestions as optional style notes
- Ask for permission before broad stylistic rewrites

## Problem: Sentence meaning is ambiguous

Symptoms:

- Multiple plausible interpretations
- Pronoun referents cannot be resolved from local context

Resolution:

- Flag ambiguity as `critical`
- Offer two possible rewrites, each tied to an interpretation
- Note that semantic intent needs confirmation

## Problem: Technical tokens are being over-corrected

Symptoms:

- Proposed edits alter commands, identifiers, flags, or API names

Resolution:

- Treat code spans, command examples, and identifiers as immutable
- Correct only surrounding prose grammar
- If token itself is suspected typo, flag instead of silently changing

## Problem: No findings after review

Symptoms:

- Result states "no issues found"

Resolution:

- Verify sentence count and checklist completion
- Confirm cross-sentence consistency pass was done
- Report "no issues" only after explicit verification

## Problem: Mixed dialect signals

Symptoms:

- Document contains both US and UK spellings

Resolution:

- Follow repository or document convention if present
- If absent, pick one dialect, state the assumption, and normalize
  consistently
