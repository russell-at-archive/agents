# Examples

## Start A New Stacked Branch

```bash
git status
git add path/to/file.ts
gt create feature/api-timeouts -m "feat(api): add timeout handling"
gt log --stack
```

## Add Follow-Up Branch On Top Of Current PR

```bash
git add path/to/ui.tsx
gt create feature/api-timeouts-ui -m "feat(ui): surface timeout state"
gt log --stack
```

## Update Existing Branch

```bash
git add path/to/file.ts
gt modify -m "fix(api): handle retry edge case"
gt log --stack
```

## Sync With Trunk Before Submission

```bash
gt sync --no-interactive
gt log --stack
```

## Submit Current Branch And Ancestors

```bash
gt submit \
  --no-interactive \
  --no-edit \
  --publish \
  --reviewers alice,bob
```

## Submit Entire Stack Including Descendants

```bash
gt submit \
  --stack \
  --restack \
  --no-interactive \
  --no-edit \
  --publish \
  --reviewers alice,bob
```

## Restack Only Downstack During Local Repair

```bash
gt restack --downstack
gt log --stack
```

## Conflict Recovery Flow

```bash
# after gt restack or gt sync stops on conflicts
git status
# edit files and resolve markers
git add path/that/was/conflicted.ts
gt continue
```

If the operation should be canceled:

```bash
gt abort
```
