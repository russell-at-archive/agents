# Troubleshooting

## Common Mistakes


**Under-scoping file inputs:** Gemini thrives on breadth. Don't
restrict it to 2-3 files when it could read the whole module for
better context.

**Using Gemini for code generation:** Gemini excels at comprehension,
not execution. For writing code, use Codex or Claude subagents.

**Forgetting `-p` flag:** Without `-p`, Gemini launches interactive
mode and hangs waiting for input.

**Not capturing output:** In background mode, always redirect stdout
to a file or the output is lost.

**Asking narrow questions:** Gemini's value is synthesis across many
files. For "what does this function do?" just read the file directly.

