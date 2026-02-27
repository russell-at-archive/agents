# Skills Gap Analysis

## Context

This document captures missing capabilities identified during review of the
current skills collection and maps them to proposed additions.

Source process: `docs/collaboration-process.md`.

## Existing Strengths

Current skills strongly cover:

- Planning artifacts (`writing-prds`, `writing-task-specs`, `writing-adrs`)
- Repository operations (`using-graphite-cli`, `using-github-cli`)
- Formatting and writing quality (`writing-markdown`, `writing-grammar`)
- Tool delegation (`using-codex-cli`, `using-gemini-cli`, `using-ollama`)

## Gaps Identified

1. No structured intake and discovery skill for early framing.
2. No reusable quality-gate execution workflow before merge.
3. No release-readiness skill with rollback and validation checks.
4. No retrospective skill to operationalize the learning loop.
5. No dedicated test-strategy skill tied to slice-level planning.
6. No orchestration skill for multi-skill trigger conflict resolution.

## Proposed Additions

1. `running-intake-discovery`
2. `running-quality-gates`
3. `running-release-readiness`
4. `running-retrospectives`
5. `designing-test-strategies`
6. `orchestrating-skill-selection`

## Expected Outcomes

- Faster alignment at kickoff with clearer constraints and assumptions.
- Consistent pre-merge evidence quality.
- Safer releases with explicit rollback readiness.
- Continuous process improvement driven by short retros.
- Better test coverage decisions before implementation begins.
- Less ambiguity when overlapping skills are triggered together.

## Linked PRDs

- `docs/prds/prd-running-intake-discovery.md`
- `docs/prds/prd-running-quality-gates.md`
- `docs/prds/prd-running-release-readiness.md`
- `docs/prds/prd-running-retrospectives.md`
- `docs/prds/prd-designing-test-strategies.md`
- `docs/prds/prd-orchestrating-skill-selection.md`
