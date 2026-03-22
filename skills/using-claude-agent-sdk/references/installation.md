# Using Claude Agent SDK: Installation

## Contents

- Prerequisites
- Python installation
- TypeScript installation
- Verification
- Updating
- Official sources

---

## Prerequisites

- Python 3.10+ for the Python SDK.
- Node.js 18+ for the TypeScript SDK.
- Access to the Anthropic platform and an `ANTHROPIC_API_KEY`, or equivalent
  cloud-provider credentials if you are not using the direct Anthropic API.

---

## Python installation

Install the SDK from PyPI:

```bash
pip install claude-agent-sdk
```

If you want an isolated environment, install it inside a virtualenv or with
your preferred Python environment manager.

---

## TypeScript installation

Install the SDK from npm:

```bash
npm install @anthropic-ai/claude-agent-sdk
```

For a global development utility install:

```bash
npm install -g @anthropic-ai/claude-agent-sdk
```

---

## Verification

### Python

```bash
python -c "import claude_agent_sdk; print('ok')"
```

### TypeScript

```bash
npm ls @anthropic-ai/claude-agent-sdk
```

Also verify auth is configured before running real tasks:

```bash
echo "${ANTHROPIC_API_KEY:+set}"
```

---

## Updating

### Python

```bash
pip install --upgrade claude-agent-sdk
```

### TypeScript

```bash
npm install @anthropic-ai/claude-agent-sdk@latest
```

---

## Official sources

- [Claude Agent SDK for Python](https://platform.claude.com/docs/en/agent-sdk/python)
- [Claude Agent SDK for TypeScript](https://platform.claude.com/docs/en/agent-sdk/typescript)
