# Examples

## Starter Prompts

### Code review prompt

```text
Task: Review this module for correctness and security issues.
Context: Node.js API handler for auth and session creation.
Constraints: Do not suggest framework migrations.
Expected output: Top risks first, each with file-level evidence and fix.
```

### Refactor prompt

```text
Task: Propose a minimal refactor for readability.
Context: Existing TypeScript utility file.
Constraints: Preserve public API and behavior.
Expected output: Stepwise edit plan and updated code.
```

### Summarization prompt

```text
Task: Summarize this changelog for engineering leadership.
Context: Last 30 days of release notes.
Constraints: Keep under 10 bullets.
Expected output: user impact, risk items, and follow-up actions.
```

## Command Recipes

### Pull a missing model

```bash
ollama pull qwen2.5-coder
```

### Deterministic style run

```bash
echo "Explain this diff" | ollama run llama3.3 --temperature 0.1
```

### Structured JSON output

```bash
curl -s http://localhost:11434/api/generate -d '{
  "model": "llama3.3",
  "prompt": "Return JSON with keys risks and mitigations",
  "stream": false,
  "format": "json"
}'
```

### Parallel dispatch with unique outputs

```bash
cat src/auth/*.ts | ollama run llama3.3 \
  "Review auth for security flaws" \
  > /tmp/ollama-auth.md 2>&1

cat src/billing/*.ts | ollama run llama3.3 \
  "Review billing flow for edge cases" \
  > /tmp/ollama-billing.md 2>&1
```

## Integration Pattern

1. Dispatch task to Ollama with explicit constraints.
2. Read output file.
3. Verify against source files.
4. Accept, revise prompt, or reject result.
