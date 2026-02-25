# Troubleshooting

## Red Flags


Stop and correct if any of these appear:

- Running interactive `glab` prompts in automation context
- Mutating resources without explicit project targeting
- Parsing human text output when JSON output is available

## Common Mistakes


- **Missing auth check**: Run `glab auth status` before write operations.
- **Wrong project**: Set project context or pass explicit repo/project flags.
- **Prompt-driven commands**: Replace prompts with explicit flags.
- **Fragile parsing**: Use JSON output and `jq` instead of text scraping.

