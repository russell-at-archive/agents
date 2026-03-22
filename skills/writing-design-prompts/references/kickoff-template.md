# Kickoff Template

Fill this in and send it as the first user message after the system prompt
is in place. The final line is non-negotiable — it prevents the LLM from
skipping Phase 0 and producing a design before interrogating you.

---

```markdown
## Project: [Name]

### What I'm building
[1–3 sentences: what does this do and why does it exist]

### The problem it solves
[What's broken or missing today? Who feels that pain and how often?]

### Users
[Who uses this? Technical level? Expected volume? Internal tool or
external product?]

### Hard constraints
[Non-negotiables: existing tech stack, budget, timeline, compliance
requirements, systems this must integrate with]

### What I've already decided
[Decisions already made that are off the table — and why]

### What I'm most uncertain about
[Where I'm confused, conflicted, or most want a second opinion]

### Definition of done
[What does success look like in 6–12 months? How will we know it worked?]

---

Please interrogate this. Do not design yet — tell me what else you need
to know, flag any assumptions you're already making, and ask your
questions before we proceed.
```

---

## Tips for Filling It In

- **Hard constraints** is the most important field. LLMs ignore constraints
  unless you make them explicit and restate them at each phase.
- **What I've already decided** prevents the LLM from wasting a phase
  re-litigating closed decisions.
- **What I'm most uncertain about** focuses Phase 3 (decision points) on
  your actual pain, not generic tradeoffs.
- Leave fields blank rather than filling them with vague placeholders —
  a blank field triggers a clarifying question; a vague answer gets
  treated as real input.
- If you don't have a definition of done, write "unknown — help me define
  it." That becomes Phase 1 work.
