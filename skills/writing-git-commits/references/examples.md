# Writing Git Commits: Examples

## Examples


### Feature with scope

```
feat(payments): add Stripe subscription billing
```

### Bug fix with body and issue reference

```
fix(auth): prevent session fixation on login

The session ID was not rotated after successful authentication,
allowing a pre-authenticated session token to be reused. The fix
forces session regeneration immediately after credential validation.

Closes #342
```

### Breaking change

```
feat(config)!: require explicit DATABASE_URL environment variable

BREAKING CHANGE: DATABASE_URL is now required at startup. Previously
a default SQLite path was used when the variable was absent. Update
your deployment configuration before upgrading.

Closes #291
```

### Chore with no scope

```
chore: upgrade eslint to v9
```

### Revert

```
revert: feat(cache): add Redis cluster support

Reverts commit a3b4c5d. The Redis cluster implementation caused
connection pool exhaustion under sustained load. Reverting until
a load test confirms the fix.
```
