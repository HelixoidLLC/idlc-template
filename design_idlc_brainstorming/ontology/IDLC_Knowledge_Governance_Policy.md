# IDLC Knowledge Governance Policy

> This document is a companion to the [IDLC Knowledge Architecture Policy](IDLC_Knowledge_Architecture_Policy.md). That document defines what the knowledge layers are and how they are structured. This document defines how those layers stay healthy over time.

---

## What Governance Is

The `governance/` folder is the **constitution of the knowledge system**. It defines the rules, ownership, and enforcement mechanisms that prevent semantic drift, duplicate concepts, and architectural fragmentation as the system evolves.

Governance is not bureaucracy. It is the immune response to entropy.

Without it:
- terms drift and accumulate synonyms across teams
- duplicate concepts emerge silently under different names
- domain ownership becomes unclear
- agents invent inconsistent implementations based on ambiguous context
- teams create parallel realities that eventually collide

---

## Governance Folder Structure

```
knowledge/governance/
├── naming-rules.md
├── domain-ownership.md
├── lifecycle-states.md
├── contribution-rules.md
├── forbidden-bare-terms.md
└── agent-constraints.md
```

---

## Naming Rules

**File**: `governance/naming-rules.md`

Defines conventions that apply across all domains and layers:

- **Term labels**: singular nouns (`Invoice`, not `Invoices`)
- **Event names**: past tense verb-noun (`InvoiceCreated`, not `CreateInvoice` or `InvoiceCreate`)
- **Domain prefixes**: all terms used outside their home context must be qualified (`billing.customer`, not `customer`)
- **Port names**: verb-noun describing purpose (`submit-invoice`, `receive-payment-notification`)
- **Adapter names**: technology-noun describing implementation (`stripe-payment`, `postgres-invoice-store`)
- **Workflow files**: kebab-case descriptive (`feature-development-standard.md`)

Violations of naming rules block PR merge.

---

## Domain Ownership

**File**: `governance/domain-ownership.md`

Defines who owns what, and what "ownership" means in practice:

- Each domain has exactly one owning team
- The owning team approves all changes to `ontology/domains/{domain}/` and `architecture/domains/{domain}/`
- The owning team is the decision-maker when the same word appears in multiple domains
- Cross-domain mappings require approval from both domain owners

Ownership does not mean isolation. It means accountability. A domain owner is responsible for ensuring their domain's terms remain precise, their architecture boundaries remain enforced, and their reusable assets remain documented.

---

## Lifecycle States

**File**: `governance/lifecycle-states.md`

Every term, reusable asset, and architectural component carries a `status` field. Valid states and transitions:

```
proposed → experimental → active → deprecated → archived
```

| Status | Meaning |
|---|---|
| `proposed` | Under review, not yet usable |
| `experimental` | Available but may change without notice |
| `active` | Canonical and stable — the default for agents to use |
| `deprecated` | Being phased out — use the superseding term instead |
| `archived` | Removed from use — historical record only |

Rules:
- Agents must only reference `active` terms and assets unless explicitly working on migration
- `deprecated` terms must include a `superseded_by` field pointing to the replacement
- `archived` terms are never deleted — they remain as historical record
- Terms cannot skip states (an `experimental` term cannot jump directly to `archived`)

---

## Contribution Rules

**File**: `governance/contribution-rules.md`

How new artifacts are added to the knowledge system:

### Adding a new domain term

1. Check `ontology/catalog/term-index.md` to confirm the term does not already exist in another domain
2. If it exists elsewhere, create a `mappings/` document before or alongside the new term
3. Create a term file in `ontology/domains/{domain}/glossary.md` or as a standalone file under `ontology/domains/{domain}/`
4. Include all required front matter fields: `id`, `kind`, `context`, `preferred_label`, `status`, `owner`
5. Add entry to `ontology/catalog/term-index.md`
6. If the term introduces a new entity or event, add to `entities.md` or `events.md`

### Adding a new domain

1. Create `architecture/domains/{new-domain}/` with all required files
2. Create `ontology/domains/{new-domain}/` simultaneously — the symmetry rule is enforced in CI
3. Add domain to `governance/domain-ownership.md` with assigned team
4. Create an ADR in `architecture/ADRs/` documenting why the new boundary was drawn

### Adding a reusable asset

1. Confirm no equivalent already exists in `ontology/reusable-assets/`
2. Create the asset file with required front matter: `id`, `kind`, `used_by`, `status`, `owner`
3. Reference the relevant domain terms — do not redefine them
4. Add entry to `ontology/catalog/term-index.md`

### Deprecating a term or asset

1. Change `status` to `deprecated`
2. Add `superseded_by` field pointing to the replacement
3. Add `history_note` explaining the reason for deprecation
4. Never delete the file

---

## Forbidden Bare Terms

**File**: `governance/forbidden-bare-terms.md`

Some words are too ambiguous to use without domain qualification anywhere outside their home context. This list is maintained by governance and updated when new collisions are discovered.

Examples of permanently forbidden bare terms:
- `Customer` — must be `billing.customer`, `support.customer`, etc.
- `Order` — must be `commerce.order`, `fulfillment.order`, etc.
- `User` — must be `identity.user`, `billing.user`, etc.
- `Account` — must be `billing.account`, `identity.account`, etc.
- `Status` — must always be scoped to a domain and entity

Agents are instructed via `agent-constraints.md` to reject any task that uses bare terms from this list without domain qualification.

---

## Agent Constraints

**File**: `governance/agent-constraints.md`

Rules that govern how agents interact with the knowledge system and the codebase:

**Retrieval requirements**
- Before working in a domain, an agent must retrieve both `architecture/domains/{domain}/` and `ontology/domains/{domain}/`
- Before implementing a new concept, an agent must check `ontology/catalog/term-index.md` for existing terms
- Before creating a reusable component, an agent must check `ontology/reusable-assets/` for equivalents

**Cross-domain access rules**
- Agents must not cross domain boundaries at the persistence layer
- Domain A's implementation code may not directly import Domain B's internal models
- Cross-domain communication must go through documented ports

**Term creation rules**
- Agents must not create a new term if an `active` equivalent exists in any domain
- Agents must not use bare terms from `forbidden-bare-terms.md`
- New terms introduced by an agent task must be registered in ontology before the implementation PR is merged

**Deprecation rules**
- Agents must not reference `deprecated` or `archived` terms in new code
- If a deprecated term is encountered, the agent must flag it and propose migration to the superseding term

---

## CI Validation Requirements

The following checks run on every pull request that touches the `knowledge/` folder:

1. No two files in the same domain context share the same `preferred_label`
2. No alias within a context collides with a preferred label in the same context
3. All `maps_to` references point to existing term files
4. No term file is deleted — only superseded with `status: deprecated` and a `history_note`
5. All ADR files are append-only — modifications to accepted ADRs are rejected
6. Every new term file includes required fields: `id`, `kind`, `context`, `preferred_label`, `status`, `owner`
7. Every new domain folder appears in both `architecture/domains/` and `ontology/domains/`
8. `governance/domain-ownership.md` includes an entry for every domain folder

---

## Ontology Drift Detection

Drift is what happens when the ontology stops reflecting reality. Terms go stale, concepts get reimplemented under different names, and mappings diverge from what the code actually does. Drift is the primary way a knowledge system dies — not in a single failure but through gradual irrelevance.

### Signals of drift

**Stale terms** — an `active` term that has not been referenced in any architecture doc, workflow, or reusable asset for a significant period. The term may still be valid, or the thing it described may no longer exist.

**Shadow terms** — a concept appears repeatedly in implementation code or PRDs without a corresponding ontology entry. The team has invented a term and is using it without registering it.

**Duplicate assets** — the same functional capability has been implemented in two different domains without either team knowing the other existed. This is the most expensive form of drift.

**Diverged mappings** — a cross-domain mapping in `mappings/` describes a translation rule that no longer matches what the integration code actually does. The mapping became documentation fiction.

**Label collision without a mapping** — two terms in different domains share the same `preferred_label` but have no `maps_to` relationship documented. Either they were never noticed or the mapping was forgotten.

### Detection approach

Drift is not caught by CI alone — CI only validates structural correctness at the moment of contribution. Drift accumulates between contributions. Address it with a periodic review cadence:

- **Every PR**: CI checks (structural validation, required fields, no silent deletions)
- **Every sprint**: contributors flag any term they used but could not find in the ontology
- **Every quarter**: agent-assisted scan comparing `active` terms against codebase references — terms with zero references are candidates for `deprecated`
- **On integration incidents**: when a cross-domain integration breaks, check whether the relevant mapping document reflects how the integration actually works; update if not

The goal is not a perfect ontology. It is an ontology that is accurate enough to be trusted. An ontology that is known to have gaps is more useful than one that is assumed to be complete.

---

## Governance Change Process

Governance documents are themselves governed. Changes to `governance/` require:

1. A proposal PR with reasoning documented in the PR description
2. Review by at least two domain owners
3. An ADR in `architecture/ADRs/` if the change affects the folder structure or term schema
4. A 48-hour comment window before merge

Governance is append-preferred. Prefer adding new rules over changing existing ones. When a rule must change, document why the old rule was insufficient.

---

*This document governs the governance system itself. Treat it with the same discipline as the knowledge it protects.*
