# Installation

## Overview

The `gemini` CLI is required for all `using-gemini-cli` tasks.

## Install

Install with Homebrew or npm.

Homebrew:

```bash
brew install gemini-cli
```

npm:

```bash
npm install -g @google/gemini-cli
```

## Verify

```bash
gemini --version
```

## Auth Setup

Interactive local setup:

```bash
gemini
```

Then choose an auth method in the UI, usually:

- Sign in with Google
- Use Gemini API key
- Vertex AI

For headless or CI usage, prefer environment-based auth:

Gemini API key:

```bash
export GEMINI_API_KEY="YOUR_GEMINI_API_KEY"
```

Vertex AI:

```bash
unset GOOGLE_API_KEY GEMINI_API_KEY
export GOOGLE_CLOUD_PROJECT="YOUR_PROJECT_ID"
export GOOGLE_CLOUD_LOCATION="YOUR_PROJECT_LOCATION"
export GOOGLE_APPLICATION_CREDENTIALS="/abs/path/key.json"
```

## Quick Probes

Use these before non-trivial runs:

```bash
gemini --version
gemini -p "Respond with: OK" --output-format json
```
