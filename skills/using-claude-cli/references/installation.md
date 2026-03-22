# Installing And Verifying Claude Code

## Install

Preferred npm install:

```bash
npm install -g @anthropic-ai/claude-code
```

Alternative installer:

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

## Verify

Check that the CLI is present and readable:

```bash
claude --version
claude --help
```

## Authentication

Inspect auth state:

```bash
claude auth status
```

Sign in or out:

```bash
claude auth login
claude auth logout
```

Some environments also use `claude setup-token` for long-lived CLI auth.

## Maintenance

Update:

```bash
claude update
```

Run health diagnostics:

```bash
claude doctor
```

## First-session guidance

After install, common next steps are:

1. Authenticate with `claude auth login`.
2. Run `claude` in a trusted repository.
3. Use `/init` if the project does not already have `CLAUDE.md`.
4. Use `/status` or `/permissions` if behavior seems inconsistent with the
   local environment.
