# Troubleshooting

## Common Mistakes


| Mistake                         | Fix                                            |
| ------------------------------- | ---------------------------------------------- |
| Skipping INVEST on any task     | Apply all 6 checks before finalizing           |
| Vague acceptance criteria       | Rewrite using Given/When/Then with specifics   |
| Missing stack parent            | Every task needs an explicit parent branch     |
| Task that requires another task to verify | Merge the two or reorder the stack   |
| No validation commands          | Tasks without runnable verification are incomplete |
| Task IDs not sequential         | Renumber before handing off                    |

## Red Flags — Stop and Correct


- A task title contains "and" (likely two concerns)
- A task has no acceptance criteria
- A task depends on one that is not yet in the list
- Stack parent does not exist in the plan
- Estimation says ">500 lines" (split it)
- A task cannot be explained in 2-4 sentences

