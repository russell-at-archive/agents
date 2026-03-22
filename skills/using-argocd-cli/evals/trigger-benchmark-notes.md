# Trigger Benchmark Notes

## Summary

Two trigger benchmark runs were executed against
`evals/trigger-evals.json` using the local `skill-creator` evaluator.

- `trigger-benchmark.json`: baseline run after adding the trigger eval set
- `trigger-benchmark-v2.json`: rerun after strengthening the frontmatter
  description

Both runs produced the same result:

- 5/9 queries passed
- 0/4 positive Argo CD queries triggered
- 5/5 negative neighboring-skill queries correctly did not trigger

## Interpretation

The current skill metadata is highly conservative in this benchmark setup: it
avoids false positives against `argo`, `kubectl`, Helm, Kustomize, and
Crossplane prompts, but it also fails to activate on direct Argo CD prompts.

## Likely Next Step

The issue appears to be in triggerability rather than body quality. The next
iteration should focus on the frontmatter description and, if needed, compare
this skill against another known-good trigger eval to determine whether the
local evaluator is under-triggering command-oriented skills in general.

## Control Check

A control run against `using-kubectl-cli` with obviously positive `kubectl`
queries produced the same pattern:

- 3/6 queries passed
- 0/3 positive kubectl queries triggered
- 3/3 negative non-kubectl queries correctly did not trigger

That strongly suggests the local `run_eval.py` setup is currently
under-triggering CLI skills in general, not just `using-argocd-cli`.
