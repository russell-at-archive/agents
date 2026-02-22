# Pi Configuration

Pi uses a **multi-layer configuration system** with two primary directories:
project-local `.pi/` and user-global `~/.pi/agent/`. Settings deep-merge
with project values taking precedence over global values.

---

## Directory Layers

| Layer         | Path              | Purpose                                       |
| ------------- | ----------------- | --------------------------------------------- |
| User-global   | `~/.pi/agent/`    | Credentials, settings, sessions, extensions   |
| Project-local | `.pi/` (in cwd)   | Project overrides, extensions, skills         |

---

## User-Global Directory (`~/.pi/agent/`)

| Path                        | Purpose                                          |
| --------------------------- | ------------------------------------------------ |
| `auth.json`                 | API keys and OAuth tokens (mode `0600`)          |
| `settings.json`             | Global user settings                             |
| `models.json`               | Custom model and provider definitions            |
| `keybindings.json`          | Keyboard shortcut overrides                      |
| `sessions/`                 | Session JSONL files, one sub-dir per working dir |
| `extensions/`               | Global extensions (TypeScript files)             |
| `skills/`                   | Global skills                                    |
| `prompts/`                  | Global prompt templates                          |
| `themes/`                   | Custom theme JSON files                          |
| `tools/`                    | Custom tools                                     |
| `git/`                      | Git-installed global packages                    |
| `npm/`                      | npm-installed global packages                    |
| `bin/`                      | Managed binaries (`fd`, `rg`)                    |
| `pi-debug.log`              | Debug log                                        |
| `AGENTS.md`                 | Global context injected into every session       |
| `SYSTEM.md`                 | Global system prompt override                    |
| `APPEND_SYSTEM.md`          | Appended to system prompt                        |
| `ssh-policy-global.json`    | Persistent global SSH grants (permissions ext)   |

---

## Project-Local Directory (`.pi/`)

Same structure as `~/.pi/agent/` except no `auth.json` and no `sessions/`.
All values here override the global equivalent.

---

## Settings (`settings.json`)

Both `~/.pi/agent/settings.json` and `.pi/settings.json` accept the same
keys. They deep-merge at startup; project settings win.

### Model & Thinking

| Key                    | Description                                         |
| ---------------------- | --------------------------------------------------- |
| `defaultProvider`      | Provider name (e.g. `anthropic`, `openai`)          |
| `defaultModel`         | Model ID                                            |
| `defaultThinkingLevel` | `off`, `minimal`, `low`, `medium`, `high`, `xhigh`  |
| `hideThinkingBlock`    | Hide thinking output in the TUI                     |
| `thinkingBudgets`      | Custom token budgets per thinking level             |
| `enabledModels`        | Glob patterns for Ctrl+P model cycling              |

### UI & Display

| Key                      | Description                                              |
| ------------------------ | -------------------------------------------------------- |
| `theme`                  | Theme name                                               |
| `quietStartup`           | Hide startup header                                      |
| `collapseChangelog`      | Condensed changelog on update                            |
| `doubleEscapeAction`     | `tree`, `fork`, or `none`                                |
| `treeFilterMode`         | `default`, `no-tools`, `user-only`, `labeled-only`, `all`|
| `editorPaddingX`         | Horizontal padding (0–3)                                 |
| `autocompleteMaxVisible` | Autocomplete dropdown item count (3–20)                  |
| `showHardwareCursor`     | Show terminal cursor                                     |

### Compaction

| Key                          | Default | Description                         |
| ---------------------------- | ------- | ----------------------------------- |
| `compaction.enabled`         | `true`  | Auto-compaction on context overflow |
| `compaction.reserveTokens`   | 16384   | Response buffer size                |
| `compaction.keepRecentTokens`| 20000   | Recent tokens preserved             |

### Retry

| Key                  | Default | Description               |
| -------------------- | ------- | ------------------------- |
| `retry.enabled`      | `true`  | Auto-retry on failures    |
| `retry.maxRetries`   | 3       | Maximum attempts          |
| `retry.baseDelayMs`  | 2000    | Base delay in ms          |
| `retry.maxDelayMs`   | 60000   | Max server-requested delay|

### Message Delivery

| Key             | Description                              |
| --------------- | ---------------------------------------- |
| `steeringMode`  | `one-at-a-time` \| `all`                 |
| `followUpMode`  | `one-at-a-time` \| `all`                 |
| `transport`     | `sse` \| `websocket` \| `auto`           |

### Shell & Images

| Key                   | Description                                     |
| --------------------- | ----------------------------------------------- |
| `shellPath`           | Custom shell path (e.g. Cygwin)                 |
| `shellCommandPrefix`  | Prefix prepended to every bash command          |
| `terminal.showImages` | Display images in the terminal                  |
| `images.autoResize`   | Resize images to 2000×2000                      |
| `images.blockImages`  | Block all images                                |

### Resources

| Key                   | Description                                              |
| --------------------- | -------------------------------------------------------- |
| `packages`            | npm/git packages to load resources from                  |
| `extensions`          | Local extension file paths or directories                |
| `skills`              | Local skill paths                                        |
| `prompts`             | Local prompt template paths                              |
| `themes`              | Local theme paths                                        |
| `enableSkillCommands` | Register skills as `/skill:name` commands (default true) |

---

## Custom Models (`models.json`)

Defines custom providers and per-model overrides.

```json
{
  "providers": {
    "ollama": {
      "baseUrl": "http://localhost:11434/v1",
      "api": "openai-completions",
      "apiKey": "ollama",
      "models": [{ "id": "llama3.1:8b" }]
    }
  }
}
```

Supported API types: `openai-completions`, `openai-responses`,
`anthropic-messages`, `google-generative-ai`.

API key and header values support three forms:

| Form                       | Example                           | Behavior                            |
| -------------------------- | --------------------------------- | ----------------------------------- |
| Literal string             | `"sk-ant-..."`                    | Used as-is                          |
| Environment variable       | `"ANTHROPIC_API_KEY"`             | Resolved from env at startup        |
| Shell command (prefix `!`) | `"!op read 'op://vault/key'"`     | Executed; stdout cached per session |

---

## Authentication (`auth.json`)

Stored at `~/.pi/agent/auth.json` with permissions `0600`. Access is
protected by `proper-lockfile` to handle concurrent Pi instances safely.

```json
{
  "anthropic": { "type": "api_key", "key": "sk-ant-..." },
  "openai": {
    "type": "oauth",
    "accessToken": "...",
    "refreshToken": "...",
    "expires": 1234567890
  }
}
```

OAuth tokens are automatically refreshed before each API call.

### Credential Resolution Order

1. `--api-key` CLI flag (runtime override)
2. `auth.json`
3. Environment variable (see table below)
4. Custom resolver defined in `models.json`

---

## Environment Variables

### Path Overrides

| Variable              | Purpose                                      |
| --------------------- | -------------------------------------------- |
| `PI_CODING_AGENT_DIR` | Override the `~/.pi/agent/` directory        |
| `PI_PACKAGE_DIR`      | Override the package asset directory         |
| `PI_SHARE_VIEWER_URL` | Override base URL for `/share`               |

### Feature Flags

| Variable                 | Purpose                                |
| ------------------------ | -------------------------------------- |
| `PI_OFFLINE`             | Disable startup network operations     |
| `PI_SKIP_VERSION_CHECK`  | Skip version check on startup          |
| `PI_TIMING`              | Show timing information                |
| `PI_CLEAR_ON_SHRINK`     | Terminal clear-on-shrink behavior      |
| `PI_HARDWARE_CURSOR`     | Show hardware cursor                   |

### API Key Fallbacks

| Variable                | Provider                         |
| ----------------------- | -------------------------------- |
| `ANTHROPIC_API_KEY`     | Anthropic                        |
| `OPENAI_API_KEY`        | OpenAI                           |
| `GEMINI_API_KEY`        | Google                           |
| `MISTRAL_API_KEY`       | Mistral                          |
| `GROQ_API_KEY`          | Groq                             |
| `CEREBRAS_API_KEY`      | Cerebras                         |
| `XAI_API_KEY`           | xAI                              |
| `OPENROUTER_API_KEY`    | OpenRouter                       |
| `HF_TOKEN`              | Hugging Face                     |
| `AZURE_OPENAI_API_KEY`  | Azure OpenAI                     |
| `AI_GATEWAY_API_KEY`    | Vercel AI Gateway                |
| `GOOGLE_CLOUD_PROJECT`  | Google Cloud Code Assist         |

---

## Key Bindings (`keybindings.json`)

Stored at `~/.pi/agent/keybindings.json`. Format: `modifier+key`.
Modifiers: `ctrl`, `shift`, `alt`.

```json
{
  "submit": "enter",
  "exit": "ctrl+d",
  "selectModel": "ctrl+l"
}
```

---

## Devcontainer Config Sharing

### Option 1 — Bind-mount the full agent directory (recommended)

Shares all settings, credentials, sessions, and extensions.

```json
{
  "mounts": [
    "source=${localEnv:HOME}/.pi/agent,target=/root/.pi/agent,type=bind,consistency=cached"
  ]
}
```

### Option 2 — Bind-mount individual files

```json
{
  "mounts": [
    "source=${localEnv:HOME}/.pi/agent/auth.json,target=/root/.pi/agent/auth.json,type=bind",
    "source=${localEnv:HOME}/.pi/agent/settings.json,target=/root/.pi/agent/settings.json,type=bind",
    "source=${localEnv:HOME}/.pi/agent/models.json,target=/root/.pi/agent/models.json,type=bind"
  ]
}
```

### Option 3 — Redirect via environment variable

```json
{
  "remoteEnv": {
    "PI_CODING_AGENT_DIR": "/workspace/.pi-config"
  },
  "mounts": [
    "source=${localEnv:HOME}/.pi/agent,target=/workspace/.pi-config,type=bind"
  ]
}
```

### Option 4 — Pass API keys only (no state sharing)

```json
{
  "remoteEnv": {
    "ANTHROPIC_API_KEY": "${localEnv:ANTHROPIC_API_KEY}"
  }
}
```

---

## Source Files (pi-mono)

| File                                                        | Purpose                          |
| ----------------------------------------------------------- | -------------------------------- |
| `packages/coding-agent/src/config.ts`                       | Path resolution                  |
| `packages/coding-agent/src/core/settings-manager.ts`        | Settings load and deep-merge     |
| `packages/coding-agent/src/core/auth-storage.ts`            | Credential storage, OAuth refresh|
| `packages/coding-agent/src/core/model-registry.ts`          | Custom models from `models.json` |
| `packages/coding-agent/src/core/resolve-config-value.ts`    | Shell/env var value resolution   |
| `packages/coding-agent/src/core/resource-loader.ts`         | Extensions, skills, themes       |
| `packages/coding-agent/src/core/session-manager.ts`         | Session JSONL storage            |
