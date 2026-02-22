# writing-adrs: Worked Examples

## Table of Contents

1. [Example 1: Technology Choice (Full ADR)](#example-1-technology-choice-full-adr)
2. [Example 2: Architecture Pattern Choice](#example-2-architecture-pattern-choice)
3. [Example 3: Superseding ADR](#example-3-superseding-adr)
4. [Title Dos and Don'ts](#title-dos-and-donts)
5. [Context Section Dos and Don'ts](#context-section-dos-and-donts)
6. [Consequences Dos and Don'ts](#consequences-dos-and-donts)

---

## Example 1: Technology Choice (Full ADR)

**File**: `docs/decisions/0007-use-postgresql-for-primary-data-store.md`

```markdown
# Use PostgreSQL for Primary Data Store

## Status

Accepted

## Context and Problem Statement

We need a relational database for the user accounts and transaction ledger
services. The system must handle 5,000 writes per second at peak with ACID
guarantees, support complex ad-hoc queries from the analytics team, and be
operable by a team with no dedicated DBA. Our current SQLite prototype cannot
scale beyond a single node.

## Decision Drivers

* Must sustain 5,000 writes/second with sub-50ms p99 latency
* ACID transactions required for financial ledger integrity
* Must support complex JOIN queries without a separate analytics layer
* Team has strong existing PostgreSQL expertise; learning cost matters
* Managed service preferred to reduce operational burden

## Considered Options

* PostgreSQL (managed via AWS RDS)
* MySQL (managed via AWS RDS)
* DynamoDB
* CockroachDB

## Decision Outcome

Chosen option: "PostgreSQL (managed via AWS RDS)", because it satisfies all
ACID and query requirements, aligns with existing team expertise, and RDS
eliminates operational overhead without introducing a new database paradigm.

### Positive Consequences

* Team can be productive immediately with no learning curve
* Full ACID semantics eliminate ledger consistency edge cases
* RDS handles backups, failover, and patching automatically
* Rich ecosystem of tooling (pgAdmin, pg_dump, logical replication)

### Negative Consequences

* Vertical scaling ceiling requires sharding or read replicas above ~50k writes/second
* RDS licensing cost higher than self-managed PostgreSQL (~$400/month for prod tier)
* Schema migrations require careful coordination with zero-downtime tooling (e.g., pgroll)

## Pros and Cons of the Options

### PostgreSQL (managed via AWS RDS)

* Good, because team has 4+ years of production experience
* Good, because full SQL and JSONB support covers both structured and semi-structured data
* Good, because RDS Multi-AZ provides 99.95% SLA without custom failover logic
* Bad, because RDS costs more than self-managed (~$400/month vs. ~$120/month EC2)

### MySQL (managed via AWS RDS)

* Good, because also a managed option with similar SLA
* Bad, because team has limited MySQL experience; tooling and syntax differences create friction
* Bad, because full-text search and JSONB support are weaker than PostgreSQL

### DynamoDB

* Good, because scales horizontally without sharding complexity
* Bad, because no JOIN support forces denormalization that conflicts with ledger requirements
* Bad, because team lacks NoSQL modeling experience; migration risk is high
* Bad, because ad-hoc analytics queries require DynamoDB Streams + secondary pipeline

### CockroachDB

* Good, because PostgreSQL-compatible wire protocol and global distribution
* Bad, because distributed SQL adds latency overhead (~20ms extra per transaction vs. single-region RDS)
* Bad, because team has no CockroachDB experience and community support is smaller

## Links

* [Relates to] [ADR-0003](0003-adopt-event-sourcing-for-ledger.md)
```

---

## Example 2: Architecture Pattern Choice

**File**: `docs/decisions/0012-use-saga-pattern-for-distributed-transactions.md`

```markdown
# Use Saga Pattern for Distributed Transactions

## Status

Accepted

## Context and Problem Statement

The checkout service must coordinate inventory reservation, payment processing,
and order creation across three independent microservices. These operations must
succeed or fail atomically from the user's perspective, but they span service
boundaries where two-phase commit is impractical. We need a failure-handling
strategy that does not couple services through a shared transaction coordinator.

## Decision Drivers

* Services must remain independently deployable
* Must handle partial failures with compensating actions (not 2PC rollback)
* Choreography must be auditable for customer support investigations
* Team must be able to implement and operate without specialized distributed
  systems expertise

## Considered Options

* Saga (choreography-based via events)
* Saga (orchestration-based via workflow engine)
* Two-phase commit (2PC)

## Decision Outcome

Chosen option: "Saga (orchestration-based via workflow engine)", because it
provides an explicit, auditable transaction log while keeping services
independently deployable, and Temporal's durable execution model eliminates
custom retry and timeout logic.

### Positive Consequences

* Single workflow definition is the authoritative source of truth for the transaction
* Temporal UI provides built-in visibility for customer support and incident investigation
* Compensating transactions are co-located with forward transactions in one file
* Retries and timeouts are handled by the platform, not application code

### Negative Consequences

* Temporal cluster is a new operational dependency (adds ~$150/month managed cost)
* Developers must learn Temporal's SDK and determinism constraints
* Workflow versioning requires care when modifying long-running workflows

## Pros and Cons of the Options

### Saga (choreography-based via events)

* Good, because no central coordinator; services react to events independently
* Bad, because transaction flow is implicit across N event handlers — hard to trace
* Bad, because compensating logic is scattered across services with no single audit trail

### Saga (orchestration-based via workflow engine)

* Good, because Temporal provides durable execution with exactly-once semantics
* Good, because the workflow file is a readable, explicit specification of the transaction
* Bad, because introduces Temporal as a new infrastructure dependency

### Two-phase commit (2PC)

* Good, because atomic across all participants by design
* Bad, because locks resources during the commit phase — unacceptable for payment latency
* Bad, because requires all three services to expose a 2PC coordinator interface
* Bad, because any coordinator failure blocks all participants

## Links

* [Relates to] [ADR-0007](0007-use-postgresql-for-primary-data-store.md)
* [Informed by] [ADR-0009](0009-adopt-microservices-architecture.md)
```

---

## Example 3: Superseding ADR

When a new decision replaces an old one, the **new** ADR links backward and the
**old** ADR's Status line is updated.

**New file**: `docs/decisions/0031-migrate-primary-store-to-aurora-postgresql.md`

```markdown
# Migrate Primary Data Store to Aurora PostgreSQL

## Status

Accepted

## Context and Problem Statement

...

## Links

* Supersedes [ADR-0007](0007-use-postgresql-for-primary-data-store.md)
```

**Update to old file** (`0007-...md`) — change Status line only:

```markdown
## Status

Superseded by [ADR-0031](0031-migrate-primary-store-to-aurora-postgresql.md)
```

---

## Title Dos and Don'ts

| Do | Don't |
|----|-------|
| `Use PostgreSQL for Primary Data Store` | `Database Decision` |
| `Adopt Event Sourcing for Audit Log` | `Should We Use Event Sourcing?` |
| `Deploy Services as Docker Containers` | `Containerization` |
| `Require OAuth 2.0 for All External APIs` | `API Authentication` |

---

## Context Section Dos and Don'ts

**Good** — forces without pre-justifying the decision:

> The analytics pipeline currently runs as a nightly batch job, causing a 12-hour
> lag between events and dashboard visibility. Business stakeholders require
> near-real-time reporting (under 5 minutes) without replacing the existing
> PostgreSQL source of truth.

**Bad** — decision is embedded in context:

> We need real-time analytics, so we decided to use Kafka Streams because it
> integrates well with our PostgreSQL database and provides the streaming we need.

---

## Consequences Dos and Don'ts

**Good** — concrete and honest:

> * Positive: Eliminates nightly batch job and its associated 2am alert page-outs
> * Negative: Kafka cluster adds ~$280/month and requires 2 weeks of team onboarding

**Bad** — vague and incomplete:

> * Positive: Better performance
> * Negative: More complexity
