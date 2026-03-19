# Using Linear CLI: Installation

## Install Command

Install the `linear` CLI globally using `npm`:

```bash
npm install -g @schpet/linear-cli
```

Alternatively, use `npx @schpet/linear-cli <args>` if global installation is restricted.

## Verification

Check the version and ensure the binary is in your `PATH`:

```bash
linear --version
```

## Authentication

Run the login command to configure your API key:

```bash
linear auth login
```

- Follow the prompt to open your browser and generate an API key.
- Paste the key back into the terminal.
- For automation, use the `LINEAR_API_KEY` environment variable or `linear auth login --key <key>`.

## Multi-Workspace Setup

The CLI supports multiple workspace credentials:

```bash
linear auth login -w personal
linear auth login -w archive
linear auth list
linear auth default archive
```
