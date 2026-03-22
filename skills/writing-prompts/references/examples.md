# Prompt Examples

## Example 1: Zero-shot → Structured output

**Before (vague):**
```
Summarize this customer feedback.
```

**After (structured):**
```
You are a customer experience analyst.

Summarize the following customer feedback in this exact JSON format:
{
  "sentiment": "positive | negative | neutral | mixed",
  "main_issue": "<one sentence or null>",
  "praise": "<one sentence or null>",
  "urgency": "low | medium | high"
}

If information for a field isn't present in the feedback, use null.

<feedback>
{{customer_feedback}}
</feedback>
```

**Why it's better:** Role establishes analytical framing. Explicit schema
with null as a valid value prevents fabrication. XML tag separates data
from instructions. The "if not present, use null" instruction creates an
abstention path.

---

## Example 2: Few-shot for classification

**Before:**
```
Classify the support ticket priority as low, medium, or high.
```

**After:**
```
Classify each support ticket as low, medium, or high priority.

Priority definitions:
- high: system down, data loss, or security issue
- medium: feature broken for multiple users or workaround needed
- low: cosmetic issue, enhancement request, or single-user annoyance

<example>
<ticket>The login button doesn't work on mobile Safari — affects all mobile
users trying to log in.</ticket>
<priority>high</priority>
</example>

<example>
<ticket>The export button is slightly misaligned in Firefox but still
works fine.</ticket>
<priority>low</priority>
</example>

<example>
<ticket>Bulk import errors out for CSVs with more than 10,000 rows. Users
can work around by splitting the file.</ticket>
<priority>medium</priority>
</example>

Now classify:
<ticket>
{{ticket_text}}
</ticket>

Respond with only the priority label: low, medium, or high.
```

**Why it's better:** Explicit criteria anchor the classification. Three
diverse examples show the boundaries between categories. Final instruction
constrains output format to a single word.

---

## Example 3: Chain-of-thought for reasoning

**Before:**
```
Should we accept this job applicant?
```

**After:**
```
You are a hiring manager screening candidates for a senior backend
engineer role. Requirements: 5+ years Python, experience with distributed
systems, strong system design skills.

Review the candidate profile below. Think through the following questions
before giving your recommendation:
1. Do they meet the hard requirements?
2. What are their strongest signals?
3. What are the gaps or concerns?
4. What would you want to verify in an interview?

Put your reasoning in <analysis> tags, then give a final recommendation
as one of: Strong Yes / Yes / Maybe / No.

<candidate>
{{resume_text}}
</candidate>
```

**Why it's better:** Structured thinking questions prevent jumping to
conclusions. `<analysis>` tag separates reasoning from decision, keeping
the output usable. Explicit recommendation scale prevents vague hedging.

---

## Example 4: Hardening against hallucination

**Before:**
```
Answer questions about our product using the documentation below.

{{docs}}
```

**After:**
```
You are a support assistant for Acme Inc. Answer questions using only the
documentation provided below. Do not use outside knowledge.

Rules:
1. If the answer is in the documentation, quote the relevant sentence
   before explaining it in plain language.
2. If the documentation doesn't address the question, say exactly:
   "I don't have information on that in the current docs. You may want to
   contact support at support@acme.com."
3. Never guess at product behavior that isn't explicitly documented.

<documentation>
{{docs}}
</documentation>

User question: {{question}}
```

**Why it's better:** "Only the documentation" + an explicit escalation
path for unknowns + the quote-first pattern all work together to prevent
the model from filling gaps with plausible-but-wrong information.

---

## Example 5: Self-refine pattern

```
## Step 1
Write a first draft of a LinkedIn post announcing our new AI feature.
The feature: automated invoice matching that cuts AP processing time by 60%.
Audience: CFOs and finance directors.
Tone: professional but energetic. Length: 150–200 words.

## Step 2
Review your draft and list exactly three ways it could be improved. Be
specific about what's weak and what a stronger version would do differently.

## Step 3
Rewrite the post incorporating all three improvements.

Output your Step 2 critique in <critique> tags and your final post in
<post> tags.
```

**Why it works:** Forces explicit critique before revision, so improvements
are targeted rather than random rewrites. Tags make it easy to extract
just the final post.
