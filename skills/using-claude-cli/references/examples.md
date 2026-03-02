# Examples

## Run A One-Shot Analysis

```bash
claude -p "\
Task: Summarize auth architecture.\
Context: Node API with JWT + refresh tokens.\
Output: Risks, trust boundaries, and test gaps with file paths.\
" src/auth src/middleware
```

## Produce JSON Output For Tooling

```bash
claude -p "List risky TODOs in src/ with severity and file path" \
  --output-format json
```

## Stream Results For A Supervisor Process

```bash
claude -p "Review open migration tasks and propose order" \
  --output-format stream-json \
  --verbose
```

## Continue Previous Session In Current Directory

```bash
claude --continue
```

## Resume From Session Picker Or Explicit ID

```bash
claude --resume
claude --resume 550e8400-e29b-41d4-a716-446655440000
```

## Constrain Tools And Permission Mode

```bash
claude -p "Run unit tests and fix TypeScript errors only" \
  --permission-mode plan \
  --allowedTools "Bash(npm test:*) Bash(npm run typecheck:*) Edit Read"
```

## Use A Specific Agent And Model

```bash
claude -p "Review this diff for regressions" \
  --agent reviewer \
  --model sonnet
```

## Expand Accessible Workspace

```bash
claude -p "Compare shared docs and update local summary" \
  --add-dir ../shared-docs
```
