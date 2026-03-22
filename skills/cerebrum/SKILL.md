---
name: cerebrum
description: Manage notes and search in the "cerebrum" Obsidian vault. Use when asked to "send to cerebrum", "search cerebrum", or any operation targeting the cerebrum vault.
---

# Using Cerebrum (Obsidian)

## Overview

Specialized skill for interacting with the "cerebrum" Obsidian vault. It acts as a wrapper around the `using-obsidian-cli` skill, ensuring all operations are scoped to the correct vault.

## When to Use

- Explicitly asked to "send to cerebrum" or "search cerebrum"
- Asked to create, read, append, or search notes in the primary personal vault
- Managing knowledge, tasks, or daily logs in the "cerebrum" environment

## When Not to Use

- Operations targeting other vaults (e.g., "archive-infrastructure")
- General Obsidian CLI tasks not specific to "cerebrum" (use `using-obsidian-cli` instead)

## Prerequisites

- Obsidian app installed and `obsidian` CLI registered (see `using-obsidian-cli/references/installation.md`)
- The "cerebrum" vault must be recognized by Obsidian (`obsidian vaults`)

## Workflow

1. **Verify Vault:** Ensure the vault is available: `obsidian vaults`.
2. **Execute Command:** Always use `vault="cerebrum"` as the **first** argument.
   - **Send to Cerebrum (New Note):** `obsidian vault="cerebrum" create name="Note Name" content="Content"`
   - **Send to Cerebrum (Append):** `obsidian vault="cerebrum" append file="Note Name" content="New Content"`
   - **Search Cerebrum:** `obsidian vault="cerebrum" search query="your search term"`
   - **Read from Cerebrum:** `obsidian vault="cerebrum" read file="Note Name"`
3. **Daily Notes:** If adding to the daily log: `obsidian vault="cerebrum" daily:append content="- New item"`

## Hard Rules

- `vault="cerebrum"` MUST be the first argument in every command.
- Never modify files in this vault using direct file writes unless the CLI is unavailable or specifically requested.
- For search results, use `format=json` if you need to process the list of files.

## Red Flags

- Forgetting the `vault="cerebrum"` prefix
- Using `using-obsidian-cli` without specifying the vault when "cerebrum" is the implied target
