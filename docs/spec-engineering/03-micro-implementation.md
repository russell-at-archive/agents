# Spec Engineering: The Micro Implementation

## 1. Practical Templates

High-quality specifications follow a structured format. Use these templates to
formalize your intent.

### Requirement Spec Template

```markdown
# [Feature Name] - Requirements

## Overview
Briefly describe the business goal and user value.

## User Journey
- Step 1: User does X
- Step 2: System does Y
- Step 3: User sees Z

## Acceptance Criteria (Evals)
- [ ] Criterion 1: [Measurement/Outcome]
- [ ] Criterion 2: [Measurement/Outcome]

## Edge Cases
- What happens if the network is down?
- What happens if the input is empty?
```

### Technical Design Spec Template

```markdown
# [Feature Name] - Technical Design

## Architectural Strategy
Summarize the high-level approach (e.g., "Add a new middleware to handle X").

## Impacted Files
- `src/middleware/auth.ts`
- `src/types/user.ts`

## Data Model / API Contracts
Define any changes to schemas or interfaces.

## Dependencies
- [Library A] - [Reason]
```

### Task Spec Template

```markdown
# Task: [Specific Action]

## Goal
Implement [Action] to fulfill [Requirement].

## Action Steps
1. Create file X with content Y.
2. Update file Z to import X.
3. Call function X from Z.

## Validation
- Run `npm test` and verify that [Test Name] passes.
- Manually verify [Behavior] in the browser.
```

---

## 2. Writing High-Quality Evals (Acceptance Criteria)

An "Eval" is a verifiable statement of success. Avoid vague terms like "fast,"
"easy to use," or "beautiful." Use measurable criteria instead.

- **Bad:** "The page should load quickly."
- **Good:** "The page must have a Lighthouse performance score > 90."
- **Bad:** "The login should be secure."
- **Good:** "Passwords must be hashed using Argon2id with a salt."

---

## 3. The Power of Edge Case Analysis

LLMs often overlook edge cases unless explicitly told to consider them. Before
starting implementation, ask the AI to **brainstorm edge cases** for your spec:

> "I'm writing a spec for a login feature. Brainstorm 5 edge cases I might have
> missed (e.g., rate-limiting, expired sessions, etc.)."

Then, add these to your **Requirement Spec**.

---

## 4. The Validation Loop

A task is not "Done" until it is **Verified**. Every specification must include
a section on how to validate the result.

- **Automated Tests:** Unit, integration, and end-to-end tests.
- **Static Analysis:** Linting and type-checking.
- **Visual Verification:** Screenshots, videos, or manual interaction.

If a task passes its validation but fails in the broader system, the
**Technical Spec** was likely underspecified.

---

## 5. Pro-Tips for Spec Engineering

- **Specify in Markdown:** It's the native language of LLMs and is easily
  readable by humans.
- **Use Clear Headings:** Structure your specs using H1, H2, H3 to help the AI
  navigate the hierarchy.
- **Link Related Specs:** Use relative links (`[link](./other-spec.md)`) to
  maintain a "web of intent."
- **Delete Dead Specs:** Once a task is merged and verified, its Task Spec can
  be deleted or archived. The **Product Spec** remains as the living
  documentation.

---

Congratulations! You are now equipped with the foundations of
**Spec Engineering**. The only way to truly master it is to **Apply it**. Start
with your next feature!
