# Hooks Reference

This document covers the extension hooks (event) system in detail: execution
model, chaining semantics, return value contracts, and the full lifecycle of
every hook. For extension authoring basics, see [extensions.md](extensions.md).

## Table of Contents

- [Execution Model](#execution-model)
  - [Handler Registration](#handler-registration)
  - [Handler Execution Order](#handler-execution-order)
  - [Chaining Semantics](#chaining-semantics)
  - [Error Handling](#error-handling)
  - [Async Behavior](#async-behavior)
- [Hook Categories](#hook-categories)
- [Lifecycle Flow](#lifecycle-flow)
- [Hook Reference](#hook-reference)
  - [Session Hooks](#session-hooks)
  - [Input Hooks](#input-hooks)
  - [Agent Lifecycle Hooks](#agent-lifecycle-hooks)
  - [Context Hooks](#context-hooks)
  - [Tool Hooks](#tool-hooks)
  - [Model Hooks](#model-hooks)
  - [User Bash Hooks](#user-bash-hooks)
  - [Resource Hooks](#resource-hooks)
- [Chaining Details by Hook Type](#chaining-details-by-hook-type)
- [Context Availability](#context-availability)

## Execution Model

### Handler Registration

Handlers are registered during extension loading via `pi.on(event, handler)`.
Multiple handlers can be registered for the same event, both within a single
extension and across extensions.

```typescript
pi.on("tool_call", async (event, ctx) => { /* handler 1 */ });
pi.on("tool_call", async (event, ctx) => { /* handler 2 */ });
```

### Handler Execution Order

Handlers execute **sequentially** in a deterministic order:

1. Extensions are loaded in discovery order:
   - Project-local extensions (`.pi/extensions/`) first
   - Global extensions (`~/.pi/agent/extensions/`) second
   - Explicitly configured paths (`-e` flag, `settings.json`) last
2. Within each extension, handlers run in registration order
  (the order `pi.on()` was called)
3. Within each extension's handlers for an event, they run sequentially
  (not in parallel)

This ordering is important because some hooks chain state between handlers.

### Chaining Semantics

Hooks fall into four chaining categories:

| Category | Behavior | Examples |
| -------- | -------- | -------- |
| **Fire-and-forget** | All handlers run. Return values ignored. | `session_start`, `agent_start`, `agent_end`, `turn_start`, `turn_end`, `message_start`, `message_update`, `message_end`, `tool_execution_start`, `tool_execution_update`, `tool_execution_end`, `session_switch`, `session_fork`, `session_compact`, `session_tree`, `session_shutdown` |
| **Cancellable** | Handlers run until one returns `{ cancel: true }`. Remaining handlers are skipped. | `session_before_switch`, `session_before_fork`, `session_before_compact`, `session_before_tree` |
| **Short-circuit** | First handler to return a decisive result wins. Remaining handlers are skipped. | `tool_call` (on `{ block: true }`), `user_bash` (on any result), `input` (on `{ action: "handled" }`) |
| **Accumulating** | Each handler sees the output of the previous. The final accumulated state is used. | `context`, `before_provider_request`, `tool_result`, `input` (transforms), `before_agent_start` |

### Error Handling

- If a handler throws, the error is caught and emitted via `ExtensionRunner.emitError()`
- Execution continues with the next handler (errors do not stop the chain)
- Exception: `tool_call` handlers that throw cause the tool to be **blocked**
  (fail-safe behavior). The thrown error becomes the block reason.

```typescript
// This BLOCKS the tool (thrown errors are treated as blocks)
pi.on("tool_call", async (event) => {
  throw new Error("Extension crashed");
  // Tool receives: "Extension failed, blocking execution: Extension crashed"
});
```

### Async Behavior

All handlers are awaited. Long-running handlers block the pipeline they are in.
Handlers should complete quickly to avoid stalling the agent loop. For 
background work, spawn tasks and track them externally.

## Hook Categories

### Observation Hooks (fire-and-forget)

These hooks notify extensions about state changes. Return values are ignored.

- `session_start` -- Session loaded
- `session_switch` -- Session changed (after new/resume)
- `session_fork` -- Session forked
- `session_compact` -- Compaction completed
- `session_tree` -- Tree navigation completed
- `session_shutdown` -- Process exiting
- `agent_start` -- Agent loop started
- `agent_end` -- Agent loop ended
- `turn_start` -- Turn started
- `turn_end` -- Turn ended
- `message_start` -- Message lifecycle started
- `message_update` -- Assistant streaming token
- `message_end` -- Message lifecycle ended
- `tool_execution_start` -- Tool execution began
- `tool_execution_update` -- Tool streaming progress
- `tool_execution_end` -- Tool execution finished
- `model_select` -- Model changed

### Gate Hooks (cancellable/blocking)

These hooks can prevent an operation from proceeding.

- `session_before_switch` -- Can cancel session switch
- `session_before_fork` -- Can cancel fork
- `session_before_compact` -- Can cancel compaction or provide custom result
- `session_before_tree` -- Can cancel tree navigation or provide custom summary
- `tool_call` -- Can block a tool from executing
- `input` -- Can handle input and prevent agent processing

### Transform Hooks (accumulating)

These hooks modify data flowing through the pipeline.

- `context` -- Modify messages before LLM call
- `before_provider_request` -- Modify the raw provider payload
- `tool_result` -- Modify tool output before LLM sees it
- `input` -- Transform user input text/images
- `before_agent_start` -- Inject messages and/or modify system prompt

## Lifecycle Flow

```
SESSION STARTUP
===============
session_directory ─► session_start ─► resources_discover


USER INPUT PIPELINE
===================
User types prompt
       │
       ▼
Extension commands checked (/cmd)
  ├─ Found? ─► command handler runs, input event skipped
  └─ Not found? ─► continue
       │
       ▼
input hook
  ├─ { action: "handled" } ─► stop (no agent processing)
  ├─ { action: "transform" } ─► text/images modified, continue
  └─ { action: "continue" } ─► continue unchanged
       │
       ▼
Skill/template expansion (/skill:name, /template)
       │
       ▼
before_agent_start hook
  ├─ Can inject custom messages (added before user prompt)
  └─ Can modify system prompt for this turn
       │
       ▼
agent_start


AGENT LOOP (repeats per turn)
==============================
turn_start
    │
    ▼
context hook
  └─ Modify AgentMessage[] before LLM conversion
    │
    ▼
AgentMessage[] ─► convertToLlm() ─► Message[]
    │
    ▼
before_provider_request hook
  └─ Modify raw provider payload (JSON body)
    │
    ▼
LLM streaming begins
    │
    ├─ message_start (assistant)
    ├─ message_update (repeated, token-by-token)
    └─ message_end (assistant)
    │
    ▼
Tool calls in response?
    │
    ├─ No ─► turn_end ─► check for steering/follow-up ─► agent_end
    │
    └─ Yes (for each tool call):
         │
         ▼
       tool_call hook
         ├─ { block: true } ─► tool skipped, error returned to LLM
         └─ not blocked ─► continue
              │
              ▼
            tool_execution_start
            tool_execution_update (repeated, streaming)
            tool_execution_end
              │
              ▼
            tool_result hook
              └─ Can modify content, details, isError
              │
              ▼
            message_start (toolResult)
            message_end (toolResult)
              │
              ▼
            Check steering messages (user interrupt?)
              ├─ Yes ─► skip remaining tools, inject steering
              └─ No ─► next tool call
         │
         ▼
       turn_end ─► next turn (loop back to context hook)


SESSION OPERATIONS
==================
/new or /resume:  session_before_switch ─► session_switch
/fork:            session_before_fork ─► session_fork
/compact:         session_before_compact ─► session_compact
/tree:            session_before_tree ─► session_tree
exit:             session_shutdown
model change:     model_select
! or !! command:  user_bash
```

## Hook Reference

### Session Hooks

#### session_directory

| Property | Value |
|----------|-------|
| When | CLI startup only, before session manager creation |
| Context | **None** -- this is the only hook that receives no `ctx` argument |
| Can cancel | No |
| Return | `{ sessionDir?: string }` |
| Chaining | Last writer wins (if multiple extensions return `sessionDir`, the last one is used) |
| Skipped when | `--session-dir` CLI flag is provided |

```typescript
pi.on("session_directory", async (event) => {
  // event.cwd - current working directory
  return { sessionDir: `/custom/sessions/${event.cwd}` };
});
```

#### session_start

| Property | Value |
|----------|-------|
| When | Session loaded (initial load, after switch, after fork) |
| Context | `ExtensionContext` |
| Can cancel | No |
| Return | Ignored |

Common use: restore extension state from session entries.

#### session_before_switch

| Property | Value |
|----------|-------|
| When | Before `/new` or `/resume` |
| Context | `ExtensionContext` |
| Can cancel | Yes, via `{ cancel: true }` |
| Return | `{ cancel?: boolean }` |
| Short-circuits on | `cancel: true` |

```typescript
pi.on("session_before_switch", async (event, ctx) => {
  // event.reason: "new" | "resume"
  // event.targetSessionFile: string | undefined (only for "resume")
  if (hasUnsavedWork()) return { cancel: true };
});
```

#### session_switch

| Property | Value |
|----------|-------|
| When | After session switch completes |
| Context | `ExtensionContext` |
| Can cancel | No |
| Return | Ignored |

```typescript
pi.on("session_switch", async (event, ctx) => {
  // event.reason: "new" | "resume"
  // event.previousSessionFile: string | undefined
});
```

#### session_before_fork

| Property | Value |
|----------|-------|
| When | Before `/fork` |
| Context | `ExtensionContext` |
| Can cancel | Yes |
| Return | `{ cancel?: boolean, skipConversationRestore?: boolean }` |

`skipConversationRestore: true` forks the session file but does not rewind agent messages to the fork point.

#### session_fork

| Property | Value |
|----------|-------|
| When | After fork completes |
| Context | `ExtensionContext` |
| Return | Ignored |

#### session_before_compact

| Property | Value |
|----------|-------|
| When | Before manual (`/compact`) or automatic compaction |
| Context | `ExtensionContext` |
| Can cancel | Yes |
| Return | `{ cancel?: boolean, compaction?: CompactionResult }` |
| Special | Can provide a custom compaction result, bypassing the built-in summarizer |

```typescript
pi.on("session_before_compact", async (event, ctx) => {
  // event.preparation - CompactionPreparation with token counts, entry ranges
  // event.branchEntries - current branch entries
  // event.customInstructions - optional instructions from /compact args
  // event.signal - AbortSignal

  // Option 1: cancel
  return { cancel: true };

  // Option 2: provide custom compaction
  return {
    compaction: {
      summary: "Custom summary of the conversation...",
      firstKeptEntryId: event.preparation.firstKeptEntryId,
      tokensBefore: event.preparation.tokensBefore,
    }
  };
});
```

#### session_compact

| Property | Value |
|----------|-------|
| When | After compaction completes |
| Context | `ExtensionContext` |
| Return | Ignored |

```typescript
pi.on("session_compact", async (event, ctx) => {
  // event.compactionEntry - the saved CompactionEntry
  // event.fromExtension - true if an extension provided the compaction result
});
```

#### session_before_tree

| Property | Value |
|----------|-------|
| When | Before `/tree` navigation |
| Context | `ExtensionContext` |
| Can cancel | Yes |
| Return | `{ cancel?: boolean, summary?: { summary: string, details?: unknown }, customInstructions?: string, replaceInstructions?: boolean, label?: string }` |

Can provide a custom branch summary instead of the built-in summarizer, or override summarization instructions.

#### session_tree

| Property | Value |
|----------|-------|
| When | After tree navigation completes |
| Context | `ExtensionContext` |
| Return | Ignored |

```typescript
pi.on("session_tree", async (event, ctx) => {
  // event.newLeafId - new position in tree
  // event.oldLeafId - previous position
  // event.summaryEntry - branch summary if generated
  // event.fromExtension - true if extension provided the summary
});
```

#### session_shutdown

| Property | Value |
|----------|-------|
| When | Process exit (Ctrl+C, Ctrl+D, SIGTERM, `ctx.shutdown()`) |
| Context | `ExtensionContext` |
| Can cancel | No |
| Return | Ignored |

Last chance for cleanup. Keep it fast -- the process is exiting.

### Input Hooks

#### input

| Property | Value |
|----------|-------|
| When | After extension commands are checked, before skill/template expansion |
| Context | `ExtensionContext` |
| Return | `InputEventResult` |
| Chaining | Transforms accumulate; `"handled"` short-circuits |

```typescript
type InputEventResult =
  | { action: "continue" }                              // pass through
  | { action: "transform"; text: string; images?: ImageContent[] }  // modify and continue
  | { action: "handled" };                              // stop processing
```

**Chaining behavior:**

1. Each handler receives the current text/images (possibly modified by previous handlers)
2. If a handler returns `{ action: "transform", text, images }`, subsequent handlers see the transformed values
3. If a handler returns `{ action: "handled" }`, no subsequent handlers run and the agent is not invoked
4. If a handler returns `{ action: "continue" }` or `undefined`, processing continues unchanged

```typescript
// Handler A: prefix rewriting
pi.on("input", async (event) => {
  if (event.text.startsWith("!quick ")) {
    return { action: "transform", text: `Respond briefly: ${event.text.slice(7)}` };
  }
});

// Handler B: sees transformed text from Handler A
pi.on("input", async (event) => {
  console.log(event.text); // "Respond briefly: ..." if Handler A transformed
});
```

**Event properties:**

- `event.text` -- Raw input (before skill/template expansion)
- `event.images` -- Attached images, if any
- `event.source` -- `"interactive"` (typed by user), `"rpc"` (API), or `"extension"` (via `sendUserMessage`)

### Agent Lifecycle Hooks

#### before_agent_start

| Property | Value |
|----------|-------|
| When | After user prompt is processed, before agent loop begins |
| Context | `ExtensionContext` |
| Return | `{ message?: CustomMessage, systemPrompt?: string }` |
| Chaining | Messages accumulate (all are injected). System prompts chain (each handler can modify the previous). |

```typescript
pi.on("before_agent_start", async (event, ctx) => {
  // event.prompt - the user's prompt text
  // event.images - attached images
  // event.systemPrompt - current system prompt (may be modified by earlier handlers)

  return {
    // Injected as a custom message before the user's prompt
    message: {
      customType: "context-injection",
      content: "Current time: " + new Date().toISOString(),
      display: false,  // hidden from TUI
    },
    // Replaces the system prompt for this turn
    systemPrompt: event.systemPrompt + "\n\nAdditional instructions...",
  };
});
```

**Message injection details:**

- All messages from all handlers are collected and injected
- They appear in the conversation before the user's prompt
- They are persisted in the session
- `display: true` shows them in the TUI; `display: false` hides them

**System prompt chaining:**

- Each handler receives the system prompt as modified by previous handlers in `event.systemPrompt`
- The final system prompt (after all handlers) is used for the LLM call
- The modification applies only to this turn; the base system prompt is not permanently changed

#### agent_start

| Property | Value |
|----------|-------|
| When | Agent loop started (one per user prompt) |
| Context | `ExtensionContext` |
| Return | Ignored |

#### agent_end

| Property | Value |
|----------|-------|
| When | Agent loop ended |
| Context | `ExtensionContext` |
| Return | Ignored |

```typescript
pi.on("agent_end", async (event, ctx) => {
  // event.messages - all messages produced during this agent run
  //   (user prompt, assistant responses, tool results)
});
```

#### turn_start

| Property | Value |
|----------|-------|
| When | Start of each turn (one LLM call + its tool executions) |
| Context | `ExtensionContext` |
| Return | Ignored |

```typescript
pi.on("turn_start", async (event) => {
  // event.turnIndex - 0-based turn counter within this agent run
  // event.timestamp - millisecond timestamp
});
```

#### turn_end

| Property | Value |
|----------|-------|
| When | End of each turn |
| Context | `ExtensionContext` |
| Return | Ignored |

```typescript
pi.on("turn_end", async (event) => {
  // event.turnIndex - which turn just ended
  // event.message - the assistant message for this turn
  // event.toolResults - ToolResultMessage[] produced during this turn
});
```

#### message_start / message_update / message_end

| Property | Value |
|----------|-------|
| When | Message lifecycle (user, assistant, toolResult messages) |
| Context | `ExtensionContext` |
| Return | Ignored |

`message_update` fires only for assistant messages during streaming. It provides token-level granularity:

```typescript
pi.on("message_update", async (event) => {
  // event.message - current partial assistant message
  // event.assistantMessageEvent - the streaming event:
  //   text_start, text_delta, text_end,
  //   thinking_start, thinking_delta, thinking_end,
  //   toolcall_start, toolcall_delta, toolcall_end
});
```

### Context Hooks

#### context

| Property | Value |
|----------|-------|
| When | Before each LLM call, after `transformContext` in the agent loop |
| Context | `ExtensionContext` |
| Return | `{ messages?: AgentMessage[] }` |
| Chaining | Accumulating -- each handler receives messages as modified by previous handlers |

This hook operates on `AgentMessage[]` (the agent's internal message format, which includes custom message types). The messages are deep-cloned before being passed to handlers, so mutations are safe.

```typescript
pi.on("context", async (event, ctx) => {
  // event.messages - deep copy of current context messages

  // Filter, inject, reorder, or replace messages
  const filtered = event.messages.filter(m => !isRedundant(m));
  return { messages: filtered };
});
```

**Where it sits in the pipeline:**

```
AgentMessage[] (full conversation)
    │
    ▼
transformContext (agent-loop level, handles compaction)
    │
    ▼
context hook (extension level) ◄── YOU ARE HERE
    │
    ▼
convertToLlm() (AgentMessage[] → Message[])
    │
    ▼
Provider serialization
    │
    ▼
before_provider_request hook
    │
    ▼
HTTP request to LLM
```

**Important:** Modifications here affect what the LLM sees but do not alter the persisted session. The original messages remain in the session manager.

#### before_provider_request

| Property | Value |
|----------|-------|
| When | After provider serialization, before HTTP request |
| Context | `ExtensionContext` |
| Return | Replacement payload (any type), or `undefined` to keep unchanged |
| Chaining | Accumulating -- each handler receives the payload as modified by previous handlers |

The payload is the raw JSON body that will be sent to the provider (OpenAI, Anthropic, etc.). Its shape depends on the provider's API.

```typescript
pi.on("before_provider_request", async (event, ctx) => {
  // event.payload - provider-specific request body
  // Anthropic: { model, messages, system, max_tokens, ... }
  // OpenAI: { model, input, instructions, ... }

  // Inspect:
  console.log(JSON.stringify(event.payload, null, 2));

  // Modify (return replaces the payload):
  return { ...event.payload, temperature: 0 };

  // Or return undefined to leave unchanged
});
```

**Use cases:**

- Debugging: log exactly what is sent to the provider
- Override parameters: force temperature, top_p, etc.
- Inject provider-specific options not exposed by the agent config
- Cache inspection: verify prompt caching behavior

### Tool Hooks

#### tool_call

| Property | Value |
|----------|-------|
| When | Before each tool executes |
| Context | `ExtensionContext` |
| Return | `{ block?: boolean, reason?: string }` |
| Chaining | Short-circuits on `{ block: true }` -- remaining handlers are skipped |
| Error behavior | **Thrown errors block the tool** (fail-safe) |

```typescript
pi.on("tool_call", async (event, ctx) => {
  // event.type: "tool_call"
  // event.toolName: "bash" | "read" | "write" | "edit" | "grep" | "find" | "ls" | string
  // event.toolCallId: unique ID for this call
  // event.input: tool parameters (type depends on toolName)

  if (event.toolName === "bash" && event.input.command?.includes("rm -rf /")) {
    return { block: true, reason: "Refusing to delete root filesystem" };
  }
});
```

**What happens when a tool is blocked:**

1. The tool's `execute()` is never called
2. An error is thrown with the block reason
3. The agent loop catches this and creates a `toolResult` message with `isError: true`
4. The LLM sees the error and can adjust its approach

**Type narrowing with `isToolCallEventType`:**

Built-in tools have typed inputs. Use the type guard for safe narrowing:

```typescript
import { isToolCallEventType } from "@mariozechner/pi-coding-agent";

pi.on("tool_call", async (event) => {
  if (isToolCallEventType("bash", event)) {
    event.input.command;   // string
    event.input.timeout;   // number | undefined
  }
  if (isToolCallEventType("write", event)) {
    event.input.path;      // string
    event.input.content;   // string
  }
  if (isToolCallEventType("edit", event)) {
    event.input.path;      // string
    event.input.oldText;   // string
    event.input.newText;   // string
  }
  if (isToolCallEventType("read", event)) {
    event.input.path;      // string
    event.input.offset;    // number | undefined
    event.input.limit;     // number | undefined
  }
});
```

#### tool_result

| Property | Value |
|----------|-------|
| When | After each tool executes (both success and error) |
| Context | `ExtensionContext` |
| Return | `{ content?: (TextContent \| ImageContent)[], details?: unknown, isError?: boolean }` |
| Chaining | Accumulating -- each handler sees the result as modified by previous handlers |

```typescript
pi.on("tool_result", async (event, ctx) => {
  // event.toolName: string
  // event.toolCallId: string
  // event.input: the tool's input parameters
  // event.content: (TextContent | ImageContent)[] - what the LLM will see
  // event.details: tool-specific details (for rendering/state)
  // event.isError: boolean

  // Return partial patches -- omitted fields keep their current values
  return {
    content: redactSecrets(event.content),  // modify what LLM sees
    // details and isError unchanged
  };
});
```

**Chaining behavior:**

1. Handler A runs, sees original result
2. If A returns `{ content: [...] }`, the event's `content` is updated
3. Handler B runs, sees updated content but original details/isError (unless A also changed those)
4. If B returns `{ isError: false }`, the error flag is cleared
5. Final accumulated result is sent to the LLM

**Type narrowing:**

```typescript
import { isBashToolResult, isEditToolResult } from "@mariozechner/pi-coding-agent";

pi.on("tool_result", async (event) => {
  if (isBashToolResult(event)) {
    event.details; // BashToolDetails | undefined
  }
  if (isEditToolResult(event)) {
    event.details; // EditToolDetails | undefined
  }
});
```

#### tool_execution_start / tool_execution_update / tool_execution_end

| Property | Value |
|----------|-------|
| When | During tool execution (observation only) |
| Context | `ExtensionContext` |
| Return | Ignored |

These are observation-only hooks. They fire from the agent loop level (not the extension wrapper), providing visibility into tool execution progress without the ability to modify it.

```typescript
pi.on("tool_execution_start", async (event) => {
  // event.toolCallId, event.toolName, event.args
});

pi.on("tool_execution_update", async (event) => {
  // event.toolCallId, event.toolName, event.args, event.partialResult
});

pi.on("tool_execution_end", async (event) => {
  // event.toolCallId, event.toolName, event.result, event.isError
});
```

**Difference from `tool_call`/`tool_result`:**

- `tool_call` and `tool_result` wrap the tool execution and can **block** or **modify** it
- `tool_execution_*` are observation-only notifications from the agent loop
- Both fire for the same tool execution, but at different levels of the stack

### Model Hooks

#### model_select

| Property | Value |
|----------|-------|
| When | Model changed via `/model`, `Ctrl+P` cycling, or session restore |
| Context | `ExtensionContext` |
| Return | Ignored |

```typescript
pi.on("model_select", async (event, ctx) => {
  // event.model - the newly selected Model
  // event.previousModel - the previous Model (undefined on first selection)
  // event.source - "set" (explicit), "cycle" (Ctrl+P), "restore" (session load)
});
```

### User Bash Hooks

#### user_bash

| Property | Value |
|----------|-------|
| When | User executes `!command` or `!!command` in the input |
| Context | `ExtensionContext` |
| Return | `{ operations?: BashOperations, result?: BashResult }` |
| Chaining | Short-circuits -- first handler to return a result wins |

```typescript
pi.on("user_bash", async (event, ctx) => {
  // event.command - the bash command string
  // event.excludeFromContext - true if !! prefix (not sent to LLM)
  // event.cwd - current working directory

  // Option 1: provide custom operations (e.g., run over SSH)
  return { operations: createSshOperations(sshConfig) };

  // Option 2: fully replace execution
  return {
    result: {
      output: "custom output",
      exitCode: 0,
      cancelled: false,
      truncated: false,
    }
  };
});
```

`!command` output is added to the LLM context. `!!command` output is shown to the user but excluded from context.

### Resource Hooks

#### resources_discover

| Property | Value |
|----------|-------|
| When | After `session_start`, and on `/reload` |
| Context | `ExtensionContext` |
| Return | `{ skillPaths?: string[], promptPaths?: string[], themePaths?: string[] }` |
| Chaining | All results are collected (paths from all handlers are merged) |

```typescript
pi.on("resources_discover", async (event, ctx) => {
  // event.cwd - current working directory
  // event.reason - "startup" | "reload"

  return {
    skillPaths: ["/path/to/custom/skills"],
    promptPaths: ["/path/to/custom/prompts"],
    themePaths: ["/path/to/custom/themes"],
  };
});
```

## Chaining Details by Hook Type

### Short-Circuit Hooks

These hooks stop processing as soon as a handler returns a decisive result.

```
Handler A ──► returns undefined ──► Handler B ──► returns { block: true } ──► STOP
                                                   (Handler C never runs)
```

**tool_call:**
- Runs handlers until one returns `{ block: true }` or throws
- If blocked: tool receives error, LLM sees the block reason
- If no handler blocks: tool executes normally

**user_bash:**
- Runs handlers until one returns any non-undefined result
- If result provided: used instead of default bash execution
- If no handler returns: default bash execution runs

**input (handled):**
- Runs handlers sequentially
- If any returns `{ action: "handled" }`: remaining handlers are skipped, agent is not invoked
- Transforms accumulate across handlers that return `{ action: "transform" }`

### Accumulating Hooks

These hooks pass state through the handler chain, each handler building on previous results.

```
Initial state ──► Handler A modifies ──► Handler B modifies ──► Final state used
```

**context:**
- Deep clone of messages passed to first handler
- Each handler can return `{ messages: [...] }` to replace the message array
- If handler returns nothing, messages pass through unchanged
- Final messages are converted to LLM format via `convertToLlm()`

**before_provider_request:**
- Provider payload passed to first handler
- Each handler can return a replacement payload or `undefined` to keep current
- Final payload is sent as the HTTP request body

**tool_result:**
- Tool's actual result passed to first handler
- Each handler can return partial patches (`content`, `details`, `isError`)
- Omitted fields keep their current value from the previous handler
- Final accumulated result is what the LLM sees

**before_agent_start:**
- Messages from all handlers are **collected** (not chained)
- System prompt is **chained** (each handler sees the previous handler's modification in `event.systemPrompt`)

### Cancellable Hooks (session_before_*)

```
Handler A ──► returns undefined ──► Handler B ──► returns { cancel: true } ──► CANCELLED
                                                   (Handler C never runs)
```

- Handlers run until one returns `{ cancel: true }`
- If cancelled, the operation does not proceed and no "after" event fires
- Non-cancel return values may provide additional data (e.g., `session_before_compact` can return a custom compaction result)

## Context Availability

| Hook | Context Type | Notes |
|------|-------------|-------|
| `session_directory` | **None** | CLI startup only, no context argument |
| All other hooks | `ExtensionContext` | Standard context with `ui`, `cwd`, `sessionManager`, etc. |
| Command handlers | `ExtensionCommandContext` | Extended with `waitForIdle()`, `newSession()`, `fork()`, `navigateTree()`, `switchSession()`, `reload()` |

**ExtensionContext** provides:
- `ctx.ui` -- UI interaction (dialogs, notifications, widgets)
- `ctx.hasUI` -- Whether UI is available (false in print/JSON mode)
- `ctx.cwd` -- Working directory
- `ctx.sessionManager` -- Read-only session access
- `ctx.modelRegistry` -- Model and API key access
- `ctx.model` -- Current model (may be undefined)
- `ctx.isIdle()` -- Whether agent is idle
- `ctx.abort()` -- Abort current agent operation
- `ctx.hasPendingMessages()` -- Whether messages are queued
- `ctx.shutdown()` -- Request graceful exit
- `ctx.getContextUsage()` -- Current token usage
- `ctx.compact()` -- Trigger compaction
- `ctx.getSystemPrompt()` -- Current system prompt

**ExtensionCommandContext** adds session control methods that are only safe in user-initiated commands (not in event handlers, where they could deadlock):
- `ctx.waitForIdle()` -- Wait for agent to finish
- `ctx.newSession()` -- Start new session
- `ctx.fork(entryId)` -- Fork from entry
- `ctx.navigateTree(targetId)` -- Navigate session tree
- `ctx.switchSession(path)` -- Switch to different session
- `ctx.reload()` -- Reload extensions/skills/prompts/themes
