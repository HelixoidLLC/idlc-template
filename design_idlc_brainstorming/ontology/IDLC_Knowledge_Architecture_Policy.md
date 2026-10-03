# IDLC Knowledge Architecture Policy
## Architecture, Ontology, Domains, and Product Requirements

---

## Purpose

This document exists for one reason: **preventing the same concept from being defined, named, or implemented in multiple conflicting ways across a codebase.**

That problem has a specific cause. When teams scale, the same word — `Customer`, `Order`, `Account` — gets defined differently in different parts of the system. Each team's definition is locally sensible. None of them agree. Agents and developers working across boundaries either invent a new version or silently use the wrong one. The result is duplicate implementations, integration bugs, and a shared vocabulary that nobody trusts.

The fix is not a global glossary. It is a shared vocabulary system where each domain owns its own definitions, collisions are made visible, and cross-domain translations are explicit.

> **Definitions are local. Discovery is global. Translation is explicit.**

---

## The Five-Layer Knowledge Model

Every piece of organizational knowledge belongs to exactly one of five layers. The layers form a chain from intent to execution:

```
Product Intent
    ↓
Ontology (Meaning)
    ↓
Architecture (Structure)
    ↓
Workflows (Execution)

Governance (Safety) - applied across the layers (not in the scope of this document)
```

Each layer answers a different question:

| Layer | Question answered |
|---|---|
| **Product** | Why are we building this? What does the user experience? |
| **Ontology** | What do concepts mean within each domain? |
| **Architecture** | How is the system structured and bounded? |
| **Workflows** | How does work and intent move through the organization? |
| **Governance** | How does the system stay healthy as it evolves? (not in the scope of this document) |

Mixing these layers into a single undifferentiated documentation space is the root cause of most knowledge system failures.

---

## Minimum Viable Start

The full structure in this document is the target state for a mature system. It is not a starting point. Attempting to implement everything at once produces a framework nobody maintains, which is worse than nothing.

The smallest version that delivers most of the value:

```
knowledge/
├── product/prds/          — one file per feature
├── ontology/glossary.md   — flat list of domain-qualified terms
├── architecture/domains/  — one README per domain with boundaries
└── architecture/ADRs/     — ADRs
```

This captures: intent, vocabulary, structure, and decision history. The reusable assets registry, cross-domain mappings, workflows, and governance layer can be added when the cost of not having them becomes concrete — not before.

Add a layer when you hit a specific pain point, not in anticipation of one:
- Add **reusable assets** when the same component gets rebuilt twice
- Add **cross-domain mappings** when two teams argue about the same word
- Add **workflows** when agent orchestration becomes inconsistent
- Add **governance** when terms start drifting without anyone noticing

---

## The Canonical Knowledge Folder Structure

```
knowledge/
├── product/
│   ├── prds/
│   ├── user-journeys/
│   ├── capabilities/
│   ├── business-rules/
│   ├── personas/
│   ├── roadmaps/
│   ├── success-metrics/
│   ├── experiments/
│   └── strategic-context/
│
├── ontology/
│   ├── catalog/
│   │   ├── term-index.md
│   │   ├── alias-index.md
│   │   └── deprecated-terms.md
│   ├── domains/
│   │   ├── {domain-a}/
│   │   │   ├── glossary.md
│   │   │   ├── entities.md
│   │   │   ├── events.md
│   │   │   └── workflows.md
│   │   └── {domain-b}/
│   ├── mappings/
│   │   └── {domain-a}--{domain-b}.md
│   └── reusable-assets/
│       ├── capabilities/
│       ├── interfaces/
│       ├── infrastructure/
│       ├── ux-components/
│       └── cross-cutting/
│
├── architecture/
│   ├── README.md
│   ├── ADRs/
│   └── domains/
│       ├── {domain-a}/
│       │   ├── README.md
│       │   ├── boundaries.md
│       │   ├── components.md
│       │   ├── ports.md
│       │   ├── adapters.md
│       │   └── ADRs/
│       └── {domain-b}/
│
├── workflows/
│   ├── feature-development/
│   ├── architecture-review/
│   ├── ai-assisted-prd-generation/
│   ├── onboarding/
│   ├── release-process/
│   └── incident-response/
│
└── governance/
    └── ... (not in the scope of this document)
```

---

## Layer 1: Product

`product/` holds business intent — why things are being built and what users are trying to do. Without it, agents and developers work from architecture and implementation context only, which means they optimise for mechanics and miss the point.

| Artifact | Contains |
|---|---|
| `prds/` | Requirements and feature definitions |
| `user-journeys/` | What users actually go through — friction, decisions, emotional state |
| `capabilities/` | Business-level functional concepts, not implementation details |
| `business-rules/` | Invariants the system must respect |
| `personas/` | Who the actors are |
| `roadmaps/` | Prioritisation and timeline context |
| `success-metrics/` | How outcomes are measured |
| `experiments/` | Hypotheses in progress — not yet canonical |
| `strategic-context/` | Why architecture decisions are being made |

---

## Layer 2: Ontology

`ontology/` is the shared vocabulary system. It defines what concepts mean inside each domain.

If `Customer` means something different in three services and nobody wrote it down, teams invent a fourth definition or quietly use the wrong one. Imprecise vocabulary compounds — it shapes what agents retrieve, what gets built, and what integrations assume. More teams and agents means higher cost.

The same word can legitimately mean different things in different domains:

- `billing.customer` — a billable party that owns billing accounts
- `support.customer` — the party recognised by the support workflow
- `crm.customer` — the organisational relationship record

None of these is wrong. Collapsing them into one global definition is. Keep definitions inside the domain that owns them; when two domains need to translate between their versions of the same concept, that translation goes in `mappings/`.

### Domain structure mirrors architecture

`ontology/domains/` and `architecture/domains/` use the same domain names. Same domain, two views: ontology says what terms mean, architecture says how the domain is built. An agent working in `order-management` retrieves from both:

```
knowledge/architecture/domains/order-management/*   → what it can touch
knowledge/ontology/domains/order-management/*       → what concepts mean
```

When two domains share a word, the `mappings/` file explains the translation. Use simple relation types: `exactMatch`, `closeMatch`, `broadMatch`, `narrowMatch`, `relatedMatch`.

### Term file schema

At higher maturity levels, each term gets its own file. Start with five fields and add more only when you need them:

```yaml
---
id: billing.customer
context: billing
preferred_label: Customer
aliases:
  - Billing Customer
owner: billing-team
---
```

Additional fields for later maturity: `status`, `maps_to`, `related`, `history`. Full schema is in the governance document.

### Reusable assets

Shared UI components, infrastructure adapters, and utilities live in `ontology/reusable-assets/`. A component like `invoice-card` can reference `billing.invoice`, but it does not define what an invoice is — that stays in the glossary.

---

## Growing the Ontology: Four Levels

The full structure described in this document is the target state. No team should start there. The principle — one canonical definition per concept per domain — matters from day one. The file structure can grow into it incrementally.

Migration between levels is always mechanical: splitting a flat file into domain files, then splitting domain files into per-term files. The term IDs and definitions do not change. Nothing is rewritten, only reorganized.

---

### Level 0 — Single flat file

One file for the whole project. All terms from all domains in one place.

```
knowledge/ontology/glossary.md
```

Use `## {domain}.{term}` as the header so every term is domain-qualified from the start. This is the one habit that cannot be retrofitted cheaply later.

```markdown
## billing.customer

- status: active
- owner: billing-team

A billable party that owns one or more billing accounts.
Not the same as `support.customer`, which tracks case history and SLA tier, not payments.

---

## support.customer

- status: active
- owner: support-team

The party recognized by the Support workflow. Carries ticket history and SLA classification.
Not the same as `billing.customer`, which tracks financial relationships.

---

## billing.invoice

- status: active
- owner: billing-team
- maps_to: commerce.order (broadMatch)

A financial document issued to a `billing.customer` for a billing period.
Not the same as `commerce.order` — an order precedes the invoice; the invoice is the settlement record.
```

**When to use**: fewer than 30 total terms across the project, single team, early exploration.

---

### Level 1 — One file per domain

Split the single file into one file per domain. The term format stays identical — only the file changes.

```
knowledge/ontology/
├── billing.md
├── support.md
└── identity.md
```

Inside each file, terms use `## {term}` as the header (domain is now implied by the filename). The key-value properties and prose stay the same.

```markdown
# Billing Glossary

## customer

- id: billing.customer
- status: active
- owner: billing-team
- maps_to: support.customer (closeMatch)

A billable party that owns one or more billing accounts.
Not the same as `support.customer`.
```

**When to move here**: more than one domain, more than 5 terms per domain, more than one team contributing definitions.

---

### Level 2 — One file per domain, with cross-domain mappings

Same file structure as Level 1, but add a dedicated mappings file when the same word appears in two domains and needs explicit translation documented.

```
knowledge/ontology/
├── billing.md
├── support.md
├── identity.md
└── mappings/
    └── billing--support.md
```

Add `maps_to` properties to terms that have cross-domain counterparts. The mappings file explains *why* and *how* — the translation rule, what each domain owns, and how to cross the boundary.

Extend the property set as needed:

```markdown
## customer

- id: billing.customer
- status: active
- owner: billing-team
- aliases: Billing Customer
- maps_to: support.customer (closeMatch)
- superseded_by: —
- history: Introduced Q2 2024 when invoice ownership moved into Billing.

A billable party that owns one or more billing accounts.
```

**When to move here**: cross-domain collisions exist and teams need to explicitly agree on translation rules.

---

### Level 3 — One file per term (full structure)

Split each domain file into individual term files. Each term gets its own file with full YAML front matter. This is the structure described in the rest of this document.

```
knowledge/ontology/domains/billing/
├── glossary/
│   ├── customer.md
│   ├── invoice.md
│   └── payment.md
├── entities.md
├── events.md
└── workflows.md
```

**When to move here**: a domain has more than 20 terms, or individual terms need their own change history and ownership.

---

### The one rule that must hold at every level

Every term must be domain-qualified at its canonical identifier: `billing.customer`, not `customer`. This is the single convention that makes every level upgrade mechanical rather than a rename-everything rewrite. Enforce it from day one regardless of which level you are at.

---

## Practical Example: Billing Domain Ontology

This example shows what a fully populated domain ontology looks like in practice.

### Folder structure

```
knowledge/ontology/domains/billing/
├── glossary/
│   ├── customer.md
│   ├── invoice.md
│   └── payment.md
├── entities.md
├── events.md
└── workflows.md

knowledge/ontology/mappings/
└── billing--support.md

knowledge/ontology/reusable-assets/
└── ux-components/
    └── invoice-card.md
```

---

### Term file: `glossary/customer.md`

```markdown
---
id: billing.customer
kind: domain-term
context: billing
preferred_label: Customer
aliases:
  - Billing Customer
hidden_aliases:
  - Client
status: active
owner: billing-team
related:
  - billing.account
  - billing.invoice
maps_to:
  - term: support.customer
    relation: closeMatch
  - term: crm.customer
    relation: relatedMatch
history_note: Introduced when invoice ownership moved into Billing in Q2 2024.
---

# Customer

## Definition
A billable legal or natural party that holds one or more Billing Accounts and can be issued invoices.

## Scope
Used only within the Billing bounded context. Does not carry user authentication state (that is `identity.user`) or support case history (that is `support.customer`).

## Not this
- `identity.user` — a user with login credentials; a Customer may exist with no login at all
- `support.customer` — the party recognized by the Support workflow; shares the same human but tracks different data
- `crm.customer` — the organizational relationship record; Billing does not own relationship metadata

## Examples
- A Customer can be invoiced monthly for a subscription.
- A Customer can have multiple Billing Accounts (e.g., separate cost centers).
- A Customer may be created before any login credentials exist (e.g., imported from a contract).

## Used by
- port: `invoice-submission`
- port: `payment-notification`
- component: `invoice-card` (reusable-assets)
```

---

### Term file: `glossary/invoice.md`

```markdown
---
id: billing.invoice
kind: domain-term
context: billing
preferred_label: Invoice
status: active
owner: billing-team
related:
  - billing.customer
  - billing.payment
  - billing.line-item
---

# Invoice

## Definition
A time-bounded financial document issued to a Customer itemizing charges owed for a billing period.

## Scope
Billing owns the full lifecycle of an Invoice: draft → issued → paid → void.
An Invoice is never created or mutated by any domain other than Billing.

## Not this
- An Invoice is not an Order (that is `commerce.order`). An Order precedes the Invoice; the Invoice is the financial record of what was settled.
- An Invoice is not a Receipt. A Receipt is issued after payment is confirmed; an Invoice is a request for payment.

## States
```
draft → issued → overdue → paid
                         ↘ void
```

## Used by
- port: `invoice-submission`
- port: `pdf-export`
- component: `invoice-card` (reusable-assets)
```

---

### Domain events: `events.md`

```markdown
# Billing Domain Events

Events emitted by the Billing domain. Consumers in other domains listen to these
via the async event bus. No other domain emits events under the `billing.` namespace.

| Event | Trigger | Payload |
|---|---|---|
| `billing.InvoiceCreated` | New invoice enters draft state | `invoice_id`, `customer_id`, `period` |
| `billing.InvoiceIssued` | Invoice sent to customer | `invoice_id`, `customer_id`, `due_date` |
| `billing.PaymentReceived` | Payment confirmed against invoice | `invoice_id`, `payment_id`, `amount` |
| `billing.InvoiceVoided` | Invoice cancelled before payment | `invoice_id`, `reason` |
| `billing.CustomerCreated` | New billing customer record created | `customer_id`, `account_id` |
```

---

### Cross-domain mapping: `mappings/billing--support.md`

```markdown
---
domains:
  - billing
  - support
---

# Mapping: billing ↔ support

## billing.customer ↔ support.customer

Relation: `closeMatch`

Both refer to the same underlying human or organization, but they track different
data and are owned by different teams.

| | billing.customer | support.customer |
|---|---|---|
| Owns | Billing accounts, invoices, payment history | Support tickets, case history, SLA tier |
| Created when | Contract signed or import from CRM | First support ticket opened |
| Can exist without the other | Yes — a customer can be billed with no support history | Yes — a support record can exist before billing is set up |
| Shared identifier | `external_id` field on both — populated from CRM | same |

**Translation rule**: When the Support domain needs to display billing status for a
customer, it passes `support.customer.external_id` to the Billing port
`get-billing-summary`. It does not access Billing's internal customer model directly.

## billing.invoice ↔ support (no equivalent)

The Support domain has no concept of Invoice. If a support agent needs to reference
an invoice, they use the invoice number as an opaque string — they do not model it
as a domain entity in Support.
```

---

### Reusable asset: `reusable-assets/ux-components/invoice-card.md`

```markdown
---
id: ux.invoice-card
kind: ux-component
status: active
owner: design-system-team
used_by:
  - billing.invoice
  - billing.customer
---

# InvoiceCard

A display component for rendering a summary of a single invoice.

## Props
| Prop | Type | Required | Description |
|---|---|---|---|
| `invoice_id` | string | yes | Stable identifier |
| `customer_name` | string | yes | Display name |
| `amount` | Money | yes | Amount with currency |
| `status` | InvoiceStatus | yes | One of: draft, issued, overdue, paid, void |
| `due_date` | date | no | Shown only when status is issued or overdue |

## What this component does NOT own
This component renders an invoice. It does not define what an invoice is.
The definition of `billing.invoice` lives in `ontology/domains/billing/glossary/invoice.md`.

## Usage
Used in: billing dashboard, customer account page, admin invoice list.
Do not use in the Support domain — Support does not model invoices.
```

---

A few things worth noting across these files: every term has a "Not this" section — that's as important as the definition itself. Events are documented alongside terms rather than buried in code. The billing--support mapping explains the translation rule in plain language, not just the relation type. And `invoice-card` explicitly says it renders an invoice but does not define one — that boundary matters.

---

## Practical Example: PRD

This example shows a complete PRD file. It uses the same flat key-value structure as the ontology examples at the top, then prose sections for the substance.

```
knowledge/product/prds/export-invoice-pdf.md
```

```markdown
# Export Invoice as PDF

- id: prd.export-invoice-pdf
- status: active
- owner: billing-product
- persona: product/personas/billing-admin.md
- addresses_journey: product/user-journeys/billing-admin-export.md
- introduces_terms: billing.pdf-export
- success_metric: product/success-metrics/invoice-export-adoption.md

## Problem

Billing admins currently copy invoice data into spreadsheets to produce PDF records
for clients and auditors. This takes 10–20 minutes per invoice and introduces
transcription errors.

## Requirements

- A billing admin can export any issued invoice as a PDF from the invoice detail page.
- The PDF includes: invoice number, billing period, line items with quantities and
  unit prices, subtotal, tax, total, currency, and customer billing address.
- Currency is rendered in the customer's configured locale (e.g., 1.234,56 € not $1,234.56).
- The export must complete within 3 seconds for invoices with up to 200 line items.
- The exported file must be named `invoice-{invoice_number}.pdf`.
- The action is recorded in the invoice audit trail.

## Out of scope

- Bulk export of multiple invoices in one action (separate PRD).
- Sending the PDF directly to the customer by email (separate PRD).
- Custom branding or white-labeling of the PDF template.

## Constraints

- Must comply with the invoice retention policy (`business-rules/invoice-retention.md`).
- PDF generation must not be performed on the API server — use an async job.
- The feature is gated behind the `invoice-pdf-export` feature flag during rollout.

## Acceptance criteria

- Given a billing admin views an issued invoice, they see an "Export PDF" button.
- When they click it, a PDF downloads within 3 seconds containing all required fields.
- The audit trail entry reads: "PDF exported by {user} on {date}".
- Exporting a draft invoice is not possible — the button is absent on draft invoices.

## Open questions

- Should the PDF be stored and retrievable later, or generated fresh on each export?
  Decision needed from billing-team before implementation starts.
```

The problem statement comes before requirements deliberately. An agent given only a requirements list will implement exactly those requirements; the problem statement is what tells it whether the implementation actually solves anything. Out of scope is explicit for the same reason — without it, scope expands silently. Constraints and requirements are separate sections because they are different things: a constraint cannot be violated, a requirement must be satisfied. Open questions belong in the document itself, not in a Slack thread that nobody finds six weeks later.

---

## Layer 3: Architecture

`architecture/` defines domain boundaries and structure: what each domain owns, how components communicate, and what the integration contracts look like.

Following DDD, a bounded context is the unit of domain ownership. Following hexagonal architecture, ports define the contracts at domain boundaries and adapters document the concrete implementations behind them (Stripe, PostgreSQL, Kafka, REST).

Each domain folder contains:

| File | Contains |
|---|---|
| `README.md` | Domain purpose and ownership |
| `boundaries.md` | What this domain owns and what it does not touch |
| `components.md` | Internal building blocks |
| `ports.md` | Contracts at the domain boundary |
| `adapters.md` | Concrete implementations of those ports |
| `ADRs/` | Architecture decisions scoped to this domain |

System-level ADRs that span multiple domains go in `architecture/ADRs/`. ADRs are append-only — accepted decisions stay in the record even when superseded.

Architecture does not contain workflow definitions, glossary terms, product requirements, or business rules. Mixing them in makes the folder useless for retrieval.

---

## Layer 4: Workflows

The `workflows/` folder describes the execution processes that consume product, ontology, and architecture context — the sequencing of agent tasks, human checkpoints, and handoffs that turn a PRD into a shipped feature.

Workflows are separate from architecture because architecture is stable structural knowledge and workflows change as tooling and process evolve. Each workflow document specifies its inputs (PRD, domain context, architecture scope), the steps involved, human approval points, and outputs (ADRs, registered assets).

See the Four Artifact Types section for how workflows differ from PRDs and user journeys.

---

## What Not to Document

A knowledge system that requires constant maintenance for low-value entries gets abandoned. Keep these out of the ontology:

- **Implementation details** — function names, method signatures, column names, internal variable names. They live in code and change with refactors. Putting them in ontology creates a sync burden with no payoff.
- **Unstable experiments** — anything behind a feature flag or in an A/B test belongs in `product/experiments/`. Promote to an active term only after the concept is committed.
- **Transient internal states** — `ProcessingInQueue`, `AwaitingRetry` and similar states inside a service's own logic. Document the events that cross domain boundaries; leave internal state machines in code.
- **Obvious structural things** — `UserRepository`, `Logger`, `Config`. The test: would a different team or agent misunderstand or duplicate this without the entry? If not, skip it.
- **Spurious `exactMatch` mappings** — if two domain terms are genuinely identical in meaning and owned by one team, they should be one term. Mappings exist for concepts that are legitimately different but related, not to paper over accidental duplication.

---

## Layer 5: Governance

The `governance/` folder defines the rules that keep the other layers from drifting — naming conventions, domain ownership, term lifecycle, and what agents are allowed to do.

Covered in full in the companion document: **[IDLC Knowledge Governance Policy](IDLC_Knowledge_Governance_Policy.md)**.

---

## The Four Artifact Types

These four get confused regularly. Each answers a different question.

| Artifact | Answers | Changes when |
|---|---|---|
| **PRD** | What must the system do? | Requirements change |
| **User Journey** | What does the user experience? | User research changes |
| **Architecture** | How is the system structured? | System boundaries change |
| **Workflow** | How does work move through people and agents? | Process or tooling changes |

---

### PRD

A PRD specifies what the system must do — requirements, constraints, acceptance criteria. It is written once, frozen on approval, and does not describe how the system is built or how the user feels while using it.

> *"Users must be able to export invoices as PDFs. The PDF must include localised currency and an audit trail. Export must complete within 3 seconds."*

---

### User Journey

A user journey narrates what the user actually goes through to accomplish a goal — friction, wrong turns, emotional state, decision points. It is not a requirements list.

> *"User realises they need to send the invoice → opens billing app → searches for client → cannot find them by company name → tries email → finds record → generates PDF → downloads → notices currency is wrong → edits record → regenerates → sends"*

A PRD that passes review can still produce an experience that fails users. Journeys catch that. They are also not workflows — a journey describes what a person does, not what the system orchestrates.

---

### Architecture

Architecture defines domain boundaries: what each domain owns, how components talk to each other, what the integration contracts look like.

> *"The Billing domain owns invoice lifecycle. Payments communicate via async events. The Identity domain cannot directly access Billing's persistence layer."*

It does not define vocabulary, describe user experience, or prescribe execution steps.

---

### Workflow

A workflow is the sequence of agent tasks, human checkpoints, and handoffs that turns a PRD into a shipped feature. Unlike a PRD, it is reusable — it runs every time that process runs, not once per feature.

> *1. Retrieve billing domain ontology and architecture boundaries*
> *2. Check reusable assets for existing PDF capabilities*
> *3. Generate implementation proposal*
> *4. Human architecture review*
> *5. Generate test suite*
> *6. Register any new reusable components*

Workflows change as tooling and process evolve. They do not belong inside architecture documents or PRDs.

---

### Not sure which it is?

1. Does it describe what users experience? → User Journey
2. Does it specify what the system must do? → PRD
3. Does it define domain boundaries and structure? → Architecture
4. Does it sequence the steps that turn intent into execution? → Workflow

If it tries to answer more than one, split it.

---

## How Artifacts Link to Each Other

Artifacts reference each other through explicit fields in their front matter or body. Links have direction — generally from intent toward execution. A PRD informs architecture; architecture does not define requirements. When a link goes the wrong direction it is a sign that something has been put in the wrong layer.

### Directionality

```
product/          →  informs  →  ontology/
product/          →  informs  →  architecture/
ontology/         →  scopes   →  architecture/
product/ + ontology/ + architecture/  →  inputs to  →  workflows/
workflows/        →  produces →  architecture/ADRs/
workflows/        →  produces →  ontology/reusable-assets/
```

### Link types by artifact

**product/prds/** links to:
- `product/user-journeys/` — the journey this PRD addresses (`addresses_journey:` field)
- `product/personas/` — the actors involved (`actors:` field)
- `product/business-rules/` — constraints that apply (`constrained_by:` field)
- `ontology/domains/{domain}/` — domain terms this feature introduces or depends on (documented in the body or `introduces_terms:` field)

**product/user-journeys/** links to:
- `product/personas/` — who the journey belongs to
- `product/prds/` — PRDs that implement parts of the journey (bidirectional — a journey can reference a PRD and a PRD can reference a journey)

**ontology/domains/{domain}/glossary** term files link to:
- other terms within the same domain (`related:` field)
- terms in other domains (`maps_to:` field with explicit relation type)
- `ontology/reusable-assets/` — UI components or capabilities that implement the concept (`implemented_by:` reference in body)
- `architecture/domains/{domain}/` — the boundary that owns this term (`context:` field is the link mechanism)

**ontology/mappings/{domain-a}--{domain-b}.md** links to:
- specific term files in both domains (the document itself is the explicit translation between two terms)

**ontology/reusable-assets/** files link to:
- `ontology/domains/{domain}/` — domain terms this asset is used by (`used_by:` field)
- NOT to other reusable assets (reuse composition happens in code, not in documentation)

**architecture/domains/{domain}/boundaries.md** links to:
- `ontology/domains/{domain}/` — domain terms that define what this boundary owns (by reference in body)
- `architecture/ADRs/` — ADRs that justify the boundary decisions

**architecture/domains/{domain}/ports.md** links to:
- `ontology/domains/{domain}/` — domain terms used in the port contract
- `architecture/domains/{domain}/adapters.md` — concrete implementations of this port

**workflows/** documents link to:
- `product/prds/` — the PRD that triggers this workflow execution (`inputs:` section)
- `ontology/domains/{domain}/` — domain context retrieved before execution (`context:` section)
- `architecture/domains/{domain}/` — architectural scope and constraints (`scope:` section)
- `architecture/ADRs/` — ADRs produced as outputs (`outputs:` section)
- `ontology/reusable-assets/` — assets registered or checked as outputs (`outputs:` section)

### What must NOT link to what

| Forbidden link | Why |
|---|---|
| PRD → Workflow | PRDs define intent; they must not prescribe execution process |
| Ontology term → defines a UI component | Terms reference components; components do not define terms |
| Architecture → PRD requirements | Architecture records structure; it may reference strategic context but not requirements |
| Reusable asset → defines domain meaning | Assets implement meaning; they do not own it |
| Workflow → modifies ontology directly | Workflow outputs register new assets through the normal contribution process |

### Practical example: a new "export invoice as PDF" feature

```
product/prds/export-invoice-pdf.md
    addresses_journey: product/user-journeys/billing-admin-export.md
    actors: product/personas/billing-admin.md
    introduces_terms: billing.pdf-export

ontology/domains/billing/glossary/pdf-export.md
    id: billing.pdf-export
    context: billing
    related: billing.invoice

architecture/domains/billing/components.md
    ← updated to include PDF export component

ontology/reusable-assets/capabilities/pdf-generation.md
    used_by: billing.pdf-export
    ← checked/registered during workflow execution

workflows/feature-development/standard-flow.md
    inputs: product/prds/export-invoice-pdf.md
    context: ontology/domains/billing/
    scope: architecture/domains/billing/
    outputs: architecture/ADRs/ADR-0042-pdf-export-approach.md
             ontology/reusable-assets/capabilities/pdf-generation.md
```

Every connection is explicit, traceable, and directional.

---

## The Symmetry Rule

The most important structural rule:

> **Architecture and ontology must mirror each other by domain.**

```
knowledge/architecture/domains/{domain}/   → how it is built
knowledge/ontology/domains/{domain}/       → what it means
```

Same domain spine. Different knowledge lenses. This symmetry is what allows agents to retrieve complete domain context without searching across unrelated folders.

When a new domain is created, entries must be added to **both** `architecture/domains/` and `ontology/domains/` simultaneously. A domain that exists in architecture but not in ontology has undefined meaning. A domain that exists in ontology but not in architecture has no structural boundary.

---

## Retrieval Priority

When assembling context for a task in a specific domain, retrieve in this order and stop when you have enough to act:

1. Local domain ontology — what terms mean here
2. Local architecture context — what can be touched, what the boundaries are
3. Existing reusable assets — what already exists and should not be rebuilt
4. Cross-domain mappings — only if the task crosses a domain boundary

The global catalog is a fallback for discovery, not a primary source. Most specific context wins.

---

## The Shared / Seedwork Rule

Keep shared content deliberately small.

The `ontology/reusable-assets/` folder and any shared primitives should contain only things that are **truly identical across all contexts**. Good candidates:
- `Money` (amount + currency)
- `EmailAddress`
- `PhoneNumber`
- `DateRange`

Bad candidates:
- `Customer` (different meaning per domain)
- `Order` (different lifecycle per domain)
- `Status` (different state machine per domain)

Sharing things that are not truly identical creates tight coupling and semantic confusion. When in doubt, duplicate with domain qualification rather than share with ambiguity.

---

## Core Principles

1. Every important concept belongs to a domain.
2. The same word can mean different things in different domains — that is expected, not a bug.
3. Definitions stay local to the domain that owns them.
4. Shared assets do not define business meaning — they implement it.
5. Architecture and ontology mirror each other by domain.
6. Agents retrieve local domain context first, global context only as fallback.
7. The system must stay lightweight enough that engineers actually maintain it.

| Layer | Question | Companion document |
|---|---|---|
| Product | Why are we building this? | — |
| Ontology | What does this concept mean here? | — |
| Architecture | How is the system structured? | — |
| Workflows | How does work move? | — |
| Governance | How does the system stay healthy? | [Governance Policy](IDLC_Knowledge_Governance_Policy.md) |

---

*This document should be treated as a living policy. Proposed changes go through the architecture review workflow and require an ADR if they modify the folder structure, term schema, or artifact link model.*
