# Agent Engineering Mandates

## General Standards

- **Contextual Precedence**: This file contains foundational mandates for all AI
  agents working in this workspace. These rules take precedence over general
  defaults.
- **Local Skill Preference**: Always prefer using the local skills defined in
  the `skills/` directory. If a skill exists for the current task, you MUST
  activate it, follow its instructions, and explicitly reference it by name in
  your strategy.

## Markdown Standards

- **Lint Compliance**: All markdown documents must pass `markdownlint-cli2` with
  zero errors.
- **Skill Usage**: The `writing-markdown` skill must be activated and followed
  for any creation or modification of markdown files.
