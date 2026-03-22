# Installation

## Install

Install Codex globally with npm:

```bash
npm install -g @openai/codex
```

## Update

Upgrade to the latest published version:

```bash
npm install -g @openai/codex@latest
```

## Verify

```bash
codex --version
codex --help
```

## Login

Interactive device or browser-based login:

```bash
codex login
```

API key login from stdin:

```bash
printenv OPENAI_API_KEY | codex login --with-api-key
```

Check auth state:

```bash
codex login status
```
