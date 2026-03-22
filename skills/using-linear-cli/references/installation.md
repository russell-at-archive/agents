# Linear CLI: Installation

## Install

**Homebrew (macOS/Linux, recommended):**

```bash
brew install schpet/tap/linear
```

**npm (global):**

```bash
npm install -g @schpet/linear-cli
```

**Deno (via JSR):**

```bash
deno install -A --reload -f -g -n linear jsr:@schpet/linear-cli
```

**npx (no install, any environment):**

```bash
npx @schpet/linear-cli issue list
```

**Pre-built binaries** are available at
`https://github.com/schpet/linear-cli/releases/latest` for macOS, Linux, and
Windows.

## Verify

```bash
linear --version
```

## Authenticate

**Interactive (first time):**

```bash
linear auth login
```

Follow the prompt to open `linear.app/settings/account/security`, create a
personal API key (prefix: `lin_api_...`), and paste it into the terminal. Keys
are stored in the OS native keyring (macOS Keychain, Linux libsecret, Windows
Credential Manager).

**Non-interactive / CI:**

```bash
linear auth login --key "$LINEAR_API_KEY"
# or just set the env var — no login command needed:
export LINEAR_API_KEY=lin_api_...
```

**Multi-workspace:**

```bash
linear auth login            # first workspace becomes default
linear auth login            # add a second workspace
linear auth list             # see all workspaces (* = default)
linear auth default <slug>   # change the default
```

## Shell completions

```bash
linear completions           # outputs completion script (bash/zsh/fish)
```

Pipe to your shell's completions directory per its documentation.

## Configuration file (`.linear.toml`)

Run `linear config` to generate one interactively. The file is looked up from
`./linear.toml` up to `<repo-root>/.linear.toml` and
`$XDG_CONFIG_HOME/linear/linear.toml`.

Key fields:

```toml
team_id        = "ENG"         # default team key
workspace      = "mycompany"   # workspace slug
issue_sort     = "priority"    # "priority" or "manual"
vcs            = "git"         # "git" or "jj"
```

Any field can be overridden with an env var:
`LINEAR_TEAM_ID`, `LINEAR_WORKSPACE`, `LINEAR_ISSUE_SORT`, `LINEAR_VCS`.
