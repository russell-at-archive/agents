# Writing Git Commits: Troubleshooting

## Common Mistakes


| Mistake                        | Fix                                          |
| ------------------------------ | -------------------------------------------- |
| `fix: fixed the login bug`     | `fix(auth): prevent null dereference on login` |
| `update stuff`                 | Use a type prefix                            |
| `feat: various improvements`   | One commit per improvement                   |
| Mixing feat and refactor       | Two separate commits                         |
| Subject line over 72 chars     | Shorten; move detail to body                 |
| Body repeats the subject       | Body explains why, not what                  |
| `BREAKING CHANGE` without `!`  | Add `!` to type/scope                        |

## Red Flags — Stop and Correct


- About to write `update`, `changes`, `misc`, or `wip` as the description
- Subject line describes multiple changes (contains "and")
- No type prefix
- Using past tense in the description
- Body is a list of files changed
- Staged changes include unrelated files
