# Product Requirement Document (PRD) Examples

## Example: AI-Powered Feature PRD

### Context & Problem
Currently, users spend 15 minutes manually tagging transactions. This
leads to data entry fatigue and inconsistent reporting.

### Outcomes & Success Metrics
- **Goal**: Automate transaction tagging to save user time and improve
  data accuracy.
- **KPI-1**: Average manual tagging time per transaction (Baseline: 45s,
  Target: < 5s, Timeframe: 30 days post-launch).
- **KPI-2**: Tagging accuracy (Baseline: 85%, Target: > 95%, Timeframe:
  60 days post-launch).

### AI Grounding (Entity Catalog)
| Entity | Properties | Description |
| :--- | :--- | :--- |
| **Transaction** | id, amount, vendor, date, tag_id | Financial record needing classification |
| **Vendor** | id, name, category_hint | Merchant associated with a transaction |
| **Tag** | id, name, confidence_score | Classification label applied to transaction |

### AI Context Block (Agent Guidance)
- **Logic Rules**:
  - Always prefer the `vendor.category_hint` if `confidence_score` > 0.9.
  - Never auto-tag transactions marked "unverified" in the database.
- **Strict Constraints**:
  - Do not use PII (e.g., specific transaction notes) as input to the
    classification model.
- **Agent Guidelines**:
  - Implement a fallback mechanism if the primary classification service
    fails.
  - Write unit tests for at least 5 common edge-case transaction types
    (e.g., zero-amount, refunds).

### Acceptance Criteria
**AC-1**: Auto-tagging success
- **Given** a new transaction from a known vendor
- **When** the system processes the transaction
- **Then** the correct tag is applied with a high confidence score.

---

## Example: Outcome-Focused PRD

### Context & Problem
Checkout conversion is 60%. User feedback indicates the multistep form
is confusing on mobile.

### Outcomes & Success Metrics
- **Goal**: Simplify checkout to increase conversion on mobile devices.
- **KPI-1**: Checkout conversion rate (Baseline: 60%, Target: 70%,
  Timeframe: 14 days post-launch).

### Non-Goals
- **Out of Scope**: Desktop UI updates. Desktop conversion is already
  above 85%. Focus strictly on mobile.
- **Out of Scope**: Payment gateway migration. We will stick with Stripe.

### Rollout & Safety
- **Phased Release**: 10% of mobile traffic for the first 48 hours.
- **Rollback Strategy**: If `checkout_started` to `checkout_completed`
  conversion drops below 55% during rollout, trigger the kill-switch.
