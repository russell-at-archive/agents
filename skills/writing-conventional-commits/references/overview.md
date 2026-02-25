# Overview

## Overview


All commit messages must follow the
[Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
specification. This produces a readable history, enables automated
changelog generation, and communicates the nature of every change
at a glance.

**Core principle:** One logical change per commit. The type tells
reviewers what kind of change it is; the description tells them what
changed; the body tells them why.

## Commit Format


```
<type>(<scope>): <short description>

[optional body]

[optional footer(s)]
```

### Required Fields

- **type** — category of change (see table below)
- **description** — imperative, lowercase, no period, ≤72 characters

### Optional Fields

- **scope** — component or module affected, e.g. `auth`, `api`, `db`
- **body** — explains *why*, not *what*; wrap at 72 characters
- **footer** — issue references, breaking change notices

## Commit Types


| Type       | Use                                          | SemVer Impact |
| ---------- | -------------------------------------------- | ------------- |
| `feat`     | New capability visible to consumers          | MINOR         |
| `fix`      | Corrects a defect                            | PATCH         |
| `perf`     | Improves performance, no behavior change     | PATCH         |
| `refactor` | Restructures code, no behavior change        | —             |
| `test`     | Adds or corrects tests only                  | —             |
| `docs`     | Documentation changes only                  | —             |
| `chore`    | Build system, tooling, dependency updates    | —             |
| `ci`       | CI/CD pipeline configuration                 | —             |
| `style`    | Whitespace, formatting, no logic change      | —             |
| `revert`   | Reverts a previous commit                    | PATCH         |

## Breaking Changes


Indicate breaking changes in two ways — both are required:

1. Append `!` after the type/scope: `feat!:` or `feat(api)!:`
2. Add `BREAKING CHANGE:` in the footer with a description

```
feat(api)!: remove deprecated /v1/users endpoint

BREAKING CHANGE: The /v1/users endpoint has been removed.
Migrate to /v2/users. See migration guide in docs/migrations.md.
```

## Description Rules


- Imperative mood: "add", "fix", "remove" — not "added", "fixes", "removed"
- Lowercase first letter
- No period at the end
- ≤72 characters
- Describe the change, not the file: "add login rate limiting" not
  "update auth.ts"

## Scope Guidelines


Use scope when the change is clearly bounded to one area:

```
feat(auth): add OAuth2 PKCE flow
fix(db): handle null on connection timeout
refactor(config): extract environment parsing
```

Omit scope for cross-cutting changes:

```
chore: upgrade all dependencies to latest
style: apply prettier formatting
```

## Body Guidelines


Write the body when the *why* is not obvious from the description:

```
fix(cache): evict stale entries on TTL expiry

Redis TTL was set but entries were not proactively removed on read.
This caused stale data to be served during the window between TTL
expiry and the next write cycle. The fix adds an explicit TTL check
on every cache read.
```

Skip the body for self-evident changes:

```
docs: fix typo in README installation section
chore: add .gitignore entry for .env.local
```

## Footer Guidelines


Reference issues with `Closes`, `Fixes`, or `Refs`:

```
Closes #123
Fixes #456
Refs #789
```

Multiple footers are allowed:

```
Closes #123
Reviewed-by: Jane Smith <jane@example.com>
```

## Pre-Commit Checklist


Before writing the commit message, verify:

- [ ] The change is a single logical concern
- [ ] Unrelated changes are staged in separate commits
- [ ] Type accurately reflects the nature of the change
- [ ] Scope (if used) names the correct component
- [ ] Description is imperative, lowercase, ≤72 characters
- [ ] Body (if present) explains why, not what
- [ ] Breaking changes have both `!` suffix and `BREAKING CHANGE:` footer
- [ ] Issue references are in the footer

## References


- Specification: <https://www.conventionalcommits.org/en/v1.0.0/>
- Related: `docs/delivery-standards.md`
- Related: `skills/decomposing-work/SKILL.md`

