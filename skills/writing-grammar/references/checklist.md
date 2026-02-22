# Grammar Checklist

Apply each rule to every sentence. Do not skip rules because they seem unlikely to apply.

---

## Rule 1: List Consistency

Every comma-separated list of three or more items must have "and" or "or" immediately before the final item.

**Fail:** "apples, oranges, bananas"
**Pass:** "apples, oranges, and bananas"

Also applies to parenthetical lists: "(create, list, switch, remove)" → "(create, list, switch, and remove)"

---

## Rule 2: Parallel Structure

All items in a list must use the same grammatical form — all nouns, all verb phrases, or all clauses. Mixed forms are a violation.

**Fail:** "The system shall log errors, notify users, and a report is generated."
**Pass:** "The system shall log errors, notify users, and generate a report."

---

## Rule 3: Subject-Verb Agreement

The verb must agree in number with its grammatical subject. Intervening phrases between subject and verb do not change the subject.

**Fail:** "A list of errors are returned."
**Pass:** "A list of errors is returned."

---

## Rule 4: Sentence Completeness

Every sentence must have a subject and a predicate. Flag fragments and comma splices.

**Fail (fragment):** "Each defined in a configuration file."
**Fail (comma splice):** "The file is read, the results are returned."
**Pass:** "The file is read and the results are returned."

---

## Rule 5: Article Usage

Use "a" before consonant sounds and "an" before vowel sounds. The rule applies to the spoken sound, not the spelling.

**Fail:** "a ADR", "an unique identifier", "a hour"
**Pass:** "an ADR", "a unique identifier", "an hour"

---

## Rule 6: Dangling and Misplaced Modifiers

Introductory phrases must modify the grammatical subject of the main clause. If the phrase refers to something other than the subject, it is dangling.

**Fail:** "After reviewing the spec, the errors were found." (the errors did not review the spec)
**Pass:** "After reviewing the spec, the team found the errors."

---

## Rule 7: Pronoun-Antecedent Agreement

Pronouns must agree in number and person with the noun they refer to. The antecedent must be unambiguous — if the pronoun could refer to more than one noun, rewrite. Also flag vague uses of "this," "it," or "which" where the referent is not immediately clear.

**Fail:** "The package reads the manifest and validates it before they are installed."
**Pass:** "The package reads the manifest and validates it before installation."

**Fail (vague):** "The spec was accepted and the ADR was written. This caused the work to begin."
**Pass:** "The spec was accepted and the ADR was written. Both approvals caused the work to begin."

---

## Rule 8: Tense Consistency

Tense must be consistent within a section. Do not shift between present and past without a clear reason.

**Fail:** "The workflow runs the spec phase, then it checked for ADRs."
**Pass:** "The workflow runs the spec phase, then checks for ADRs."

---

## Rule 9: Possessive Apostrophes

Use apostrophe-s for possessives. Do not use apostrophes for plurals. Do not confuse possessive forms with contractions — "its" is possessive; "it's" is a contraction. Apply the same logic to "your/you're" and "their/they're."

**Fail:** "the spec's are reviewed", "the workflows result", "its working", "your ready"
**Pass:** "the specs are reviewed", "the workflow's result", "it's working", "you're ready"

---

## Rule 10: Commonly Confused Words

Check every instance of the following for correct usage:

| Word | Common confusion |
|------|-----------------|
| affect / effect | affect is usually a verb; effect is usually a noun |
| its / it's | its = possessive; it's = it is |
| your / you're | your = possessive; you're = you are |
| their / there / they're | ownership / location / contraction |
| then / than | then = time or sequence; than = comparison |
| ensure / insure | ensure = make certain; insure = take out insurance |
| that / which | that = restrictive clause; which = non-restrictive clause |
| fewer / less | fewer for countable nouns; less for uncountable |
| between / among | between = two distinct things; among = three or more or an abstract group |
| compose / comprise | the parts compose the whole; the whole comprises the parts |
| complement / compliment | complement = enhance or complete; compliment = praise |
| principle / principal | principle = rule or belief; principal = chief, or the head of a school |
| lay / lie | lay = to place something (takes an object); lie = to recline (no object) |
| i.e. / e.g. | i.e. = that is (specifies); e.g. = for example (illustrates) |
| could of / would of / should of | always wrong; use could have, would have, should have |

---

## Rule 11: Pronoun Case

Use subject pronouns (I, he, she, they, who) when the pronoun is the subject of a verb. Use object pronouns (me, him, her, them, whom) when the pronoun is the object of a verb or preposition.

**Fail:** "The spec was reviewed by she and I.", "Who did you send it to?"
**Pass:** "The spec was reviewed by her and me.", "Whom did you send it to?"

Test: remove the other person and read the sentence aloud. "Reviewed by I" is clearly wrong; "reviewed by me" is correct.

---

## Rule 12: Semicolon Usage

A semicolon joins two independent clauses without a coordinating conjunction. Do not use a semicolon directly before a coordinating conjunction (and, but, or, so, yet). Do not use a semicolon where a comma is correct.

**Fail:** "The spec was accepted; and work began.", "The file is read; the results filtered, and returned."
**Pass:** "The spec was accepted; work began.", "The spec was accepted, and work began."
