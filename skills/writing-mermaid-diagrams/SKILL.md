---
name: writing-mermaid-diagrams
description: Produces correct Mermaid diagram definitions for all supported
  diagram types including flowchart, sequence, class, state, ER, Gantt,
  pie, gitGraph, mindmap, and 20+ others. Use when asked to create, write,
  fix, or explain Mermaid diagrams, diagram-as-code, or .mmd files.
---

# Writing Mermaid Diagrams

## Overview

Produces syntactically correct Mermaid diagram definitions using the
right diagram type, valid syntax, and clear labels. Covers all 25+
diagram types supported by Mermaid v11.x, from flowcharts to architecture
diagrams.

For the full syntax reference by diagram type, read
[references/overview.md](references/overview.md).

## When to Use

- Asked to create or fix a Mermaid diagram of any type
- User wants a diagram as code, a `.mmd` file, or a mermaid code block
- Translating a verbal or visual description into a Mermaid diagram
- Debugging a Mermaid parse error or rendering issue
- Choosing the right Mermaid diagram type for a given goal

## When Not to Use

- The request is for a non-Mermaid tool (PlantUML, Graphviz, draw.io)
- The user wants an image file without any diagram source code

## Prerequisites

- No external tools required at authoring time
- For local rendering: `@mermaid-js/mermaid-cli` (`mmdc`) or VS Code
  with the Mermaid Preview extension

## Workflow

1. Identify the goal and select the diagram type using the selection
   table in [references/overview.md](references/overview.md).
2. Read the syntax section for that type in
   [references/overview.md](references/overview.md).
3. Draft the diagram definition; apply core syntax rules (quoting,
   node IDs, special characters).
4. For theme, config, or integration questions, read the Configuration
   and Integration sections of
   [references/overview.md](references/overview.md).
5. For concrete working examples, read
   [references/examples.md](references/examples.md).
6. For parse errors or rendering failures, read
   [references/troubleshooting.md](references/troubleshooting.md).
7. Wrap the output in a fenced `mermaid` code block when embedding in
   Markdown.

## Hard Rules

- Every diagram must begin with its type keyword on the first line.
- Node IDs must use only `[A-Za-z0-9_]` — no spaces, hyphens, or
  punctuation.
- Labels containing `(`, `)`, `[`, `]`, `{`, `}`, or `|` must be
  wrapped in double quotes.
- Use `%%{init:...}%%` directives or YAML frontmatter for configuration
  — never inject raw HTML or JavaScript into diagram labels.
- Always add a language tag to fenced code blocks: ` ```mermaid `.

## Failure Handling

- If the diagram type is unclear, ask before drafting — the wrong type
  produces a misleading diagram.
- If a required feature is not supported by Mermaid, state the
  limitation and offer the closest alternative.
- If a parse error persists after one fix attempt, consult
  [references/troubleshooting.md](references/troubleshooting.md).

## Red Flags

- Node ID contains spaces, hyphens, or reserved words (`end`,
  `subgraph`, `class`, `style`, `direction`)
- Label contains unquoted special characters
- `classDef` or `style` applied to a node ID that does not exist
- `stateDiagram` used instead of `stateDiagram-v2`
- `themeVariables` values use CSS named colors instead of hex codes
