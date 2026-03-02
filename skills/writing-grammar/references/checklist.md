# Grammar Checklist

Apply each rule to every sentence. Do not skip rules.

## Rule 1: Sentence Completeness

Each sentence must contain a clear subject and predicate.
Flag fragments and run-ons.

Fail: "Because the system was unavailable."
Pass: "The deployment failed because the system was unavailable."

## Rule 2: Subject-Verb Agreement

Verbs must agree with grammatical subjects, not nearby nouns.

Fail: "A set of checks are required."
Pass: "A set of checks is required."

## Rule 3: Pronoun Reference and Agreement

Pronouns must match number/person and have clear antecedents.

Fail: "The API and CLI were updated, and it was documented."
Pass: "The API and CLI were updated, and both were documented."

## Rule 4: Verb Tense and Aspect Consistency

Keep tense consistent within the same timeframe unless a shift is
intentional and signaled.

Fail: "The job starts, validated inputs, and completes."
Pass: "The job starts, validates inputs, and completes."

## Rule 5: Parallel Structure

Coordinate items must share grammatical form.

Fail: "The service logs errors, notifying operators, and alert emails."
Pass: "The service logs errors, notifies operators, and sends alert
emails."

## Rule 6: Modifier Placement

Modifiers must attach to the intended target.

Fail: "After reviewing the logs, the outage was diagnosed."
Pass: "After reviewing the logs, the team diagnosed the outage."

## Rule 7: Comma and Clause Boundaries

Use commas for introductory elements and coordinating independent
clauses. Avoid comma splices.

Fail: "The test failed, we retried it."
Pass: "The test failed, so we retried it."

## Rule 8: Semicolons and Colons

Use semicolons only between related independent clauses.
Use colons to introduce explanations, lists, or amplifications.

Fail: "The release was delayed; because QA blocked it."
Pass: "The release was delayed because QA blocked it."

## Rule 9: Articles and Determiners

Use `a/an/the` and other determiners correctly by sound and specificity.

Fail: "a hour", "an unique case", "engineer fixed issue"
Pass: "an hour", "a unique case", "the engineer fixed the issue"

## Rule 10: Possessives, Contractions, and Apostrophes

Distinguish possessives from contractions and avoid apostrophe plurals.

Fail: "its deployed", "the policy's were updated"
Pass: "it's deployed", "the policies were updated"

## Rule 11: Word Form and Confusables

Verify commonly confused words and forms in context.

Check: `affect/effect`, `its/it's`, `your/you're`,
`their/there/they're`, `then/than`, `fewer/less`, `who/whom`,
`lie/lay`, `that/which`.

## Rule 12: Relative Clauses and Restrictive Meaning

Ensure restrictive clauses are not punctuated as nonrestrictive clauses.
Use `that` for restrictive clauses in US usage unless local style says
otherwise.

Fail: "Requests, that fail validation, are rejected."
Pass: "Requests that fail validation are rejected."

## Rule 13: Negation and Logical Clarity

Prevent ambiguous negation, especially in requirements.

Fail: "Do not allow users without admin rights only."
Pass: "Allow only users with admin rights."

## Rule 14: List Grammar and Conjunctions

List items should be parallel and explicitly connected. Use a conjunction
before the final item in a list of three or more.

Fail: "create, validate, deploy"
Pass: "create, validate, and deploy"

## Rule 15: Dialect and House-Style Consistency

Keep spelling and punctuation consistent with target dialect and project
style (`US`: color, license; `UK`: colour, licence).
