# Real-world domains and scenarios

Every challenge must solve a problem a working developer could plausibly get as
a ticket. No abstract puzzles (no "reverse a string", "FizzBuzz", "foo/bar").
The concept being taught must come from the scenario, not be bolted on.

## Realism checklist

- **Believable product and stakeholder**: a fictional company with a clear
  business (for example "Cartly, an online store", "Medi-Q, a clinic booking
  app", "Fleetwise, a delivery routing platform"). One or two sentences of
  context: who needs this and why now.
- **Realistic data**: real-looking names, SKUs, timestamps (ISO 8601), currency
  amounts, emails, log lines, HTTP payloads. Light humor in test data is
  welcome, but keep it work-safe.
- **Realistic constraints**: the kinds of rules real systems have (rounding
  money, time zones, pagination limits, retries, validation messages, idempotency).
- **Realistic shape**: inputs and outputs look like what the code would receive
  in production (JSON objects, CSV rows, HTTP requests, events, DB records),
  simplified for the level.
- **Self-contained**: external systems (payment gateways, email, databases,
  third-party APIs) are replaced by in-memory fakes or interfaces the learner
  calls. The challenge must run offline.

## Scenario bank (by concept)

Use these as starting points, adapting them to the language, framework and level.

| Concept | Beginner scenario | Intermediate scenario | Advanced scenario |
|---|---|---|---|
| Conditionals / type narrowing | Classify support messages by channel (email string vs chat array) | Normalize webhook payloads from 3 providers into one event type | Versioned API payload migration (v1→v3) with validation errors |
| Loops / collections | Sum a shopping cart | Group orders by customer and compute lifetime value | Streaming aggregation of sales events with late-arriving data |
| String processing | Format a shipping label | Parse Apache/Nginx access log lines into records | Tokenize and evaluate a pricing-rule mini language |
| Dates and time | Is a coupon expired? | Business-day SLA deadline calculator (skip weekends/holidays) | Multi-time-zone meeting scheduler with DST transitions |
| Validation / errors | Validate a signup form | Validate and coerce CSV product imports with row-level error report | Schema-driven validator with nested paths and error aggregation |
| Money / numbers | Tip calculator for a restaurant POS | Invoice with discounts, tax and rounding rules | Currency-safe pricing engine in integer cents with promotions |
| Data structures | Recently viewed products list (max N, no duplicates) | LRU cache for product lookups | Priority-based job queue with retries and dead-letter handling |
| Recursion / trees | Count items in nested folders | Build a category breadcrumb from a parent-id list | Org-chart permissions inheritance with overrides |
| OOP / interfaces | Model a library book loan | Payment methods behind a common interface | Plugin system for notification channels with dependency injection |
| Functional patterns | Filter and map a product catalog | Composable data-cleaning pipeline | Event-sourced account balance with reducers and snapshots |
| Async / concurrency | Fetch user profile with a fake client | Retry with exponential backoff and timeout | Rate limiter (token bucket) shared by concurrent workers |
| HTTP APIs (frameworks) | Health-check endpoint returning JSON | CRUD endpoints for a to-do API with validation | Paginated, filterable orders API with idempotency keys |
| UI components (frameworks) | Character counter for a tweet box | Searchable, sortable data table | Multi-step checkout form with validation and state persistence |
| Persistence | Save and load app settings from JSON | Repository pattern over in-memory store with queries | Unit-of-work with optimistic locking over a fake DB |
| Security | Mask credit card numbers | Password policy checker and hashed comparison | JWT verification with expiry, issuer and key rotation (local keys) |
| Algorithms (applied) | Find the cheapest shipping option | Route deliveries to nearest warehouse | Bin-packing parcels into delivery vans under weight limits |
| Text / data formats | Convert a contact to vCard text | CSV ↔ JSON converter with escaping | Incremental diff of two product catalogs for a sync job |

## Choosing the scenario

1. Start from what the user asked (topic, concept or domain).
2. Pick the row/column that matches the concept and level, or create a new
   scenario following the realism checklist.
3. Make sure the framework (if any) is used the way it is used in real
   projects (for example React state and events, Express routes and
   middleware, Django views and models).
4. Name the challenge folder after the scenario in kebab-case, for example
   `cart-total-calculator`, `access-log-parser`, `orders-api-pagination`.
