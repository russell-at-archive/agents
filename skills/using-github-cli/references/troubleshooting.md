# Troubleshooting

## Red Flags


Stop and correct if any of these appear:

- Running interactive `gh` prompts in automation context
- Using `gh` where `gt` already provides the required branch/stack action
- Mutating resources without explicit repo targeting in multi-repo contexts
- Parsing human text output when `--json` is available

## Common Mistakes


- **Missing auth check**: Run `gh auth status` before write operations.
- **Wrong repository**: Use `--repo <owner>/<repo>` when not in target repo.
- **Prompt-driven commands**: Replace prompts with explicit flags.
- **Fragile parsing**: Use `--json` and `--jq` instead of text scraping.
- **Overusing `gh` for stack actions**: Use `gt` for stack-native operations.

