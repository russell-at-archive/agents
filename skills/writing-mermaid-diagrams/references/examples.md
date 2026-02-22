# Writing Mermaid Diagrams: Examples

## Contents

- [Flowchart: API Request Lifecycle](#flowchart-api-request-lifecycle)
- [Flowchart: Decision Tree with Styling](#flowchart-decision-tree-with-styling)
- [Sequence: Authentication Flow](#sequence-authentication-flow)
- [Sequence: Microservice Call Chain](#sequence-microservice-call-chain)
- [Class: Domain Model](#class-domain-model)
- [State: Order State Machine](#state-order-state-machine)
- [ER: E-commerce Schema](#er-e-commerce-schema)
- [Gantt: Sprint Plan](#gantt-sprint-plan)
- [GitGraph: Feature Branch Workflow](#gitgraph-feature-branch-workflow)
- [Mindmap: System Architecture](#mindmap-system-architecture)
- [Architecture: Cloud Infrastructure](#architecture-cloud-infrastructure)
- [C4: System Context](#c4-system-context)
- [Quadrant: Technology Prioritization](#quadrant-technology-prioritization)

---

## Flowchart: API Request Lifecycle

```mermaid
flowchart LR
  client([Client]) --> gateway[API Gateway]
  gateway --> auth{Authenticated?}
  auth -->|No| reject[/"401 Unauthorized"/]
  auth -->|Yes| rate{Rate Limited?}
  rate -->|Yes| throttle[/"429 Too Many Requests"/]
  rate -->|No| router[Router]
  router --> svcA[User Service]
  router --> svcB[Order Service]
  svcA & svcB --> cache[(Redis Cache)]
  svcA & svcB --> db[(PostgreSQL)]

  classDef error fill:#f66,stroke:#c00,color:#fff
  classDef success fill:#6f6,stroke:#060,color:#000
  class reject,throttle error
  class svcA,svcB success
```

**When to use:** Showing how a request travels through a system;
identifying branch points, services, and storage.

---

## Flowchart: Decision Tree with Styling

```mermaid
---
config:
  theme: base
  themeVariables:
    primaryColor: '#4a90d9'
    primaryTextColor: '#ffffff'
---
flowchart TD
  start([Start Deployment]) --> checks{All checks pass?}
  checks -->|No| fix[Fix Failures]
  fix --> checks
  checks -->|Yes| env{Environment?}
  env -->|staging| staging[Deploy to Staging]
  env -->|production| approval{Manual Approval}
  staging --> smokeTest{Smoke Tests Pass?}
  smokeTest -->|No| rollback[Rollback]
  smokeTest -->|Yes| done([Done])
  approval -->|Approved| prod[Deploy to Production]
  approval -->|Rejected| stop([Cancelled])
  prod --> done
  rollback --> stop
```

**When to use:** Deployment pipelines, approval workflows, branching
decision processes.

---

## Sequence: Authentication Flow

```mermaid
sequenceDiagram
  autonumber
  actor User
  participant Browser
  participant AuthService
  participant DB as UserDB

  User->>Browser: Enter credentials
  Browser->>+AuthService: POST /login {email, password}
  AuthService->>+DB: SELECT user WHERE email=?
  DB-->>-AuthService: UserRecord
  AuthService->>AuthService: bcrypt.compare(password, hash)
  alt Credentials valid
    AuthService-->>Browser: 200 OK + JWT
    Browser-->>User: Redirect to dashboard
  else Credentials invalid
    AuthService-->>-Browser: 401 Unauthorized
    Browser-->>User: Show error message
  end
```

**When to use:** Login flows, OAuth flows, any time-ordered interaction
between a user and backend services.

---

## Sequence: Microservice Call Chain

```mermaid
sequenceDiagram
  box Blue Public Layer
    participant GW as API Gateway
  end
  box Green Internal Services
    participant OS as OrderService
    participant IS as InventoryService
    participant NS as NotificationService
  end
  box Orange Data Layer
    participant DB as OrderDB
    participant Q as MessageQueue
  end

  GW->>+OS: POST /orders {items}
  OS->>+IS: CheckStock(items)
  IS-->>-OS: StockAvailable: true
  OS->>+DB: INSERT order
  DB-->>-OS: orderId: 42
  OS->>Q: Publish OrderCreated(42)
  OS-->>-GW: 201 Created {orderId: 42}
  Q-->>NS: OrderCreated event
  NS->>NS: Send confirmation email
```

**When to use:** Documenting async message flows, multi-service
interactions, or event-driven architectures.

---

## Class: Domain Model

```mermaid
classDiagram
  direction LR
  namespace orders {
    class Order {
      <<Entity>>
      +String id
      +OrderStatus status
      +Money total
      +place() void
      +cancel() void
    }
    class OrderItem {
      +String productId
      +int quantity
      +Money unitPrice
      +subtotal() Money
    }
    class OrderStatus {
      <<Enumeration>>
      PENDING
      CONFIRMED
      SHIPPED
      DELIVERED
      CANCELLED
    }
  }
  namespace customers {
    class Customer {
      <<Entity>>
      +String id
      +String email
      +String name
      +placeOrder(items) Order
    }
  }
  namespace shared {
    class Money {
      +int amount
      +String currency
      +add(other Money) Money
    }
  }

  Customer "1" --> "0..*" Order : places
  Order "1" *-- "1..*" OrderItem : contains
  Order --> OrderStatus : has
  Order --> Money : total
  OrderItem --> Money : unitPrice
```

**When to use:** Domain modeling, codebase documentation, class
hierarchy explanation.

---

## State: Order State Machine

```mermaid
stateDiagram-v2
  direction LR
  [*] --> Pending : order placed

  Pending --> Confirmed : payment succeeds
  Pending --> Cancelled : payment fails
  Pending --> Cancelled : user cancels

  Confirmed --> Processing : warehouse picks
  Confirmed --> Cancelled : user cancels (fee)

  Processing --> Shipped : carrier scans

  state Shipped {
    [*] --> InTransit
    InTransit --> OutForDelivery : local hub scan
    OutForDelivery --> Delivered : delivery confirmed
  }

  Shipped --> Delivered : auto-transition

  Delivered --> Refunded : return approved

  Cancelled --> [*]
  Delivered --> [*]
  Refunded --> [*]

  note right of Processing
    SLA: ship within 48h
    of confirmation
  end note
```

**When to use:** Documenting state machines, lifecycle management,
order/ticket/workflow status systems.

---

## ER: E-commerce Schema

```mermaid
erDiagram
  CUSTOMER {
    uuid id PK
    string email UK
    string name
    timestamp created_at
  }
  ADDRESS {
    uuid id PK
    uuid customer_id FK
    string street
    string city
    string country
    string postal_code
  }
  PRODUCT {
    uuid id PK
    string sku UK
    string name
    decimal price
    int stock
  }
  ORDER {
    uuid id PK
    uuid customer_id FK
    uuid shipping_address_id FK
    string status
    decimal total
    timestamp placed_at
  }
  ORDER_ITEM {
    uuid id PK
    uuid order_id FK
    uuid product_id FK
    int quantity
    decimal unit_price
  }

  CUSTOMER ||--o{ ADDRESS : "has"
  CUSTOMER ||--o{ ORDER : "places"
  ORDER }o--|| ADDRESS : "ships to"
  ORDER ||--|{ ORDER_ITEM : "contains"
  PRODUCT ||--o{ ORDER_ITEM : "included in"
```

**When to use:** Database schema documentation, data model reviews,
onboarding new engineers.

---

## Gantt: Sprint Plan

```mermaid
gantt
  title Sprint 24 — User Auth Feature
  dateFormat  YYYY-MM-DD
  axisFormat  %b %d
  excludes    weekends

  section Backend
    Design auth schema  : done, schema, 2024-03-04, 1d
    JWT implementation  : done, jwt, after schema, 3d
    Login endpoint      : active, login, after jwt, 2d
    Refresh token       : refresh, after login, 2d
    Unit tests          : tests, after refresh, 1d

  section Frontend
    Login page UI       : ui, 2024-03-07, 3d
    Auth state manager  : state, after ui, 2d
    E2E tests           : e2e, after state, 1d

  section Deployment
    Staging deploy      : milestone, staging, after tests, 0d
    Production release  : milestone, prod, after e2e, 0d
```

**When to use:** Sprint planning visualization, project roadmaps,
dependency tracking between parallel work streams.

---

## GitGraph: Feature Branch Workflow

```mermaid
gitGraph
  commit id: "Initial commit"
  commit id: "Add base config"

  branch develop
  checkout develop
  commit id: "Setup CI pipeline"

  branch feature/auth
  checkout feature/auth
  commit id: "Add JWT library"
  commit id: "Implement login endpoint"
  commit id: "Add refresh token"

  checkout develop
  merge feature/auth id: "Merge auth feature" tag: "auth-complete"

  branch hotfix/security
  checkout hotfix/security
  commit id: "Fix token expiry bug" type: HIGHLIGHT

  checkout main
  merge hotfix/security tag: "v1.0.1"

  checkout develop
  merge hotfix/security

  checkout main
  merge develop tag: "v1.1.0"
```

**When to use:** Explaining branching strategies, documenting release
processes, illustrating git workflows for teams.

---

## Mindmap: System Architecture

```mermaid
mindmap
  root((E-commerce Platform))
    Frontend
      Web App
        React SPA
        Next.js SSR
      Mobile
        iOS Native
        Android Native
    Backend
      API Gateway
        Rate Limiting
        Auth
      Microservices
        Order Service
        Inventory Service
        Notification Service
    Data
      PostgreSQL
        Orders DB
        Users DB
      Redis
        Session Cache
        Rate Limit Store
    Infrastructure
      AWS
        ECS Fargate
        RDS
        ElastiCache
      Monitoring
        Datadog
        PagerDuty
```

**When to use:** System overview, onboarding documentation, tech stack
exploration, brainstorming.

---

## Architecture: Cloud Infrastructure

```mermaid
architecture-beta
  group internet(internet)[Internet]
  group aws(cloud)[AWS us-east-1]
  group vpc(cloud)[VPC 10.0.0.0/16] in aws
  group public(cloud)[Public Subnet] in vpc
  group private(cloud)[Private Subnet] in vpc

  service users(internet)[Users] in internet
  service cf(internet)[CloudFront CDN] in aws
  service lb(internet)[ALB] in public
  service web1(server)[Web Server 1] in public
  service web2(server)[Web Server 2] in public
  service api(server)[API Server] in private
  service db(database)[RDS PostgreSQL] in private
  service cache(disk)[ElastiCache Redis] in private

  users:R --> L:cf
  cf:R --> L:lb
  lb:R --> L:web1
  lb:R --> L:web2
  web1:B --> T:api
  web2:B --> T:api
  api:R --> L:db
  api:R --> L:cache
```

**When to use:** Cloud infrastructure documentation, architecture
reviews, infrastructure-as-code planning.

---

## C4: System Context

```mermaid
C4Context
  title System Context — E-commerce Platform

  Person(customer, "Customer", "Online shopper browsing and purchasing products")
  Person(admin, "Store Admin", "Manages inventory, orders, and promotions")

  System(platform, "E-commerce Platform", "Catalog, orders, payments, fulfillment")

  System_Ext(stripe, "Stripe", "Payment processing and fraud detection")
  System_Ext(sendgrid, "SendGrid", "Transactional email delivery")
  System_Ext(shippo, "Shippo", "Shipping label generation and tracking")
  System_Ext(analytics, "Google Analytics", "User behavior tracking")

  Rel(customer, platform, "Browses, orders, tracks", "HTTPS")
  Rel(admin, platform, "Manages catalog and orders", "HTTPS")
  Rel(platform, stripe, "Processes payments", "REST API")
  Rel(platform, sendgrid, "Sends order emails", "REST API")
  Rel(platform, shippo, "Creates shipping labels", "REST API")
  Rel(platform, analytics, "Tracks page views", "JavaScript")

  UpdateLayoutConfig($c4ShapeInRow="3", $c4BoundaryInRow="1")
```

**When to use:** System boundary documentation, stakeholder
communication, identifying external dependencies.

---

## Quadrant: Technology Prioritization

```mermaid
quadrantChart
  title Platform Technology Evaluation Q1 2024
  x-axis Low Implementation Effort --> High Implementation Effort
  y-axis Low Business Impact --> High Business Impact
  quadrant-1 Do Now
  quadrant-2 Plan Carefully
  quadrant-3 Reconsider
  quadrant-4 Quick Wins

  Redis Cache: [0.3, 0.85]
  GraphQL API: [0.7, 0.80]
  Kubernetes: [0.85, 0.65]
  Feature Flags: [0.25, 0.70]
  Dark Mode: [0.2, 0.35]
  Microservices Split: [0.9, 0.75]
  CDN Integration: [0.35, 0.90]
  A/B Testing: [0.6, 0.60]
```

**When to use:** Prioritization discussions, technology radar,
effort-vs-impact analysis for roadmap planning.
