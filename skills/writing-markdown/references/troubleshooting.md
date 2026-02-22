# Troubleshooting

## Tooling Failures

- `markdownlint-cli2: command not found`
  Action: try `markdownlint` fallback and report missing primary tool.
- `Cannot find config`
  Action: run from repository root or pass explicit file targets.
- parser error in markdown
  Action: repair malformed fences, lists, or tables first.

## Persistent Rule Failures

- `MD013` still failing after wrapping:
  Action: split long links using reference-style links.
- `MD040` still failing:
  Action: ensure every fenced block has a language token.
- `MD060` table failures:
  Action: normalize pipe spacing and column widths; keep semantics.

## Red Flags

Stop and correct if any occur:

- success reported without a final lint run
- lint output still contains errors
- edits changed document meaning beyond lint fixes
- tables were converted to lists without necessity
