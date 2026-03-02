# Examples

## Architecture Analysis

```bash
gemini --approval-mode plan -p "\
Task: Explain authentication architecture.\
Context: Node.js API with JWT and session fallback.\
Questions: Entry points, trust boundaries, token lifecycle, failure modes.\
Output: concise architecture map with file references.\
" src/auth/ src/middleware/ src/routes/
```

## Migration Impact Mapping

```bash
gemini --approval-mode plan -p "\
Task: Assess impact of replacing Redis cache client.\
Questions: Which modules import cache APIs, what breakages are likely,\
what test areas are required.\
Output: dependency graph + prioritized risk list.\
" src/ package.json
```

## Parallel Analysis Runs

```bash
gemini -p "Summarize domain model boundaries" src/domain/ \
  > /tmp/gemini-domain-boundaries.md 2>&1

gemini -p "Map cross-module imports for billing" src/ \
  > /tmp/gemini-billing-deps.md 2>&1

gemini -p "Identify risky runtime config assumptions" src/ config/ \
  > /tmp/gemini-config-risks.md 2>&1
```

## Structured Output for Tooling

```bash
gemini -o json -p "\
Task: list all modules depending on src/core/events.ts.\
Output: JSON array with fields module, import_path, risk_level.\
" src/
```

## Prompt Tightening Retry

When initial output is vague, tighten constraints:

```bash
gemini -p "\
Re-run with strict grounding:\
- cite concrete file paths for each claim\
- mark unknowns explicitly\
- do not infer missing files\
" src/
```
