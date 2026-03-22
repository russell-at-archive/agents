# Using GitHub Spec Kit: Installation

## Contents

- Prerequisites
- One-shot usage with `uvx`
- Persistent install with `uv tool`
- Verification
- Updating
- Official sources

---

## Prerequisites

- `uv` installed.
- Python 3.11+.
- Git.
- A supported AI coding agent such as Claude Code, GitHub Copilot, Gemini CLI,
  or another agent supported by Spec Kit.

---

## One-shot usage with `uvx`

Use this when you want the latest CLI without installing a persistent
`specify` binary:

```bash
uvx --from git+https://github.com/github/spec-kit.git specify init --here
```

You can also initialize a new project directory:

```bash
uvx --from git+https://github.com/github/spec-kit.git specify init <project-name>
```

---

## Persistent install with `uv tool`

Use this when you want `specify` on `PATH`:

```bash
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
```

After install, initialize the current repository:

```bash
specify init --here --ai <agent>
```

---

## Verification

```bash
specify check
```

If you used `uvx` only, verify by running a dry command such as:

```bash
uvx --from git+https://github.com/github/spec-kit.git specify init --help
```

---

## Updating

### Persistent install

```bash
uv tool install specify-cli --force --from git+https://github.com/github/spec-kit.git
```

### One-shot usage

No upgrade step is required. `uvx` fetches the current version when you run
the command again.

---

## Official sources

- [Spec Kit installation guide](https://github.github.com/spec-kit/installation.html)
- [Spec Kit upgrade guide](https://github.github.com/spec-kit/upgrade.html)
