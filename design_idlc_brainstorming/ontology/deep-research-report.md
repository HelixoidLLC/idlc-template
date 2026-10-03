# A Markdown Ontology Structure for IDLC Projects

## Executive recommendation

The best simple design is **not** one global glossary with one “correct” definition for every word. For an IDLC project, the safest structure is a **collision-aware lexicon** where canonical term definitions live **inside each bounded context**, while a thin **global catalog** only indexes those terms, shows collisions, and points to the right local definition. That fits Domain-Driven Design because a bounded context is the place where a model and vocabulary stay internally consistent, and the same word can legitimately mean different things in different contexts. It also fits Microsoft’s DDD guidance that a service should generally not span more than one bounded context. Hexagonal architecture helps you keep business logic isolated from technology and document ports by purpose, but it does **not** by itself solve vocabulary collisions across domains. Cross-context translation belongs in explicit relationship or anti-corruption documents, not in a flattened global glossary. citeturn7view0turn6view3turn23view0turn6view4

For this use case, you probably do **not** need a heavyweight formal ontology stack. A lightweight controlled vocabulary model is enough. That is exactly the niche SKOS was designed for: a common data model for thesauri, taxonomies, and other knowledge organization systems, with machine-readable labels, notes, hierarchies, and mappings. citeturn29view0turn22view0turn22view2

## What DDD and hexagonal architecture require

DDD’s real requirement is not “one term for the whole company.” It is **one rigorous term per concept inside a bounded context**. Martin Fowler summarizes ubiquitous language as a common, rigorous language between developers and users, rooted in the domain model, precisely because software does not cope well with ambiguity. He also notes that large systems inevitably contain multiple vocabularies and that common words like “Customer” or “Product” often become polysemous across contexts. citeturn27view0turn7view0

That matters for your folder design. If you put all definitions for `Customer` in one global page, you are fighting DDD. Fowler’s guidance on homonyms is especially relevant here: when software needs precision, the team should model distinct concepts separately and avoid the bare homonym in the software representation, using names like `LiteraryWork` and `PhysicalCopy` instead of leaving both concepts as `Book`. In practice, that means your ontology should make it easy to document `billing.customer` and `support.customer` as separate canonical terms, even if people casually say “customer” in conversation. citeturn28view0

Hexagonal architecture adds a second rule. Cockburn’s original paper says the architecture is about the **inside versus outside** boundary, not left versus right layers. Ports represent purposeful conversations, and use cases should be written at the application boundary, independent of external technology. That means your documentation tree should distinguish **domain terms and models** from **ports**, **adapters**, and **external integrations**. A port document should describe a purposeful contract such as “submit invoice” or “receive payment notification,” while adapters document the concrete Stripe, REST, Kafka, PostgreSQL, or browser implementations that plug into that port. citeturn8view0turn23view0turn23view1

The implication is simple. **DDD owns semantic boundaries. Hexagonal architecture owns technology boundaries.** Your ontology structure should reflect both. Use bounded-context folders for term ownership, and use relationship or anti-corruption documents whenever two contexts need translation. Microsoft’s anti-corruption layer pattern explicitly describes that layer as the place that translates communications so one subsystem can avoid compromising the design of another. citeturn6view4

## Recommended repository structure

Keep the ontology as docs-as-code in a dedicated tree. If the repository already contains application code, put it under `docs/ontology/`. If the repository is documentation-only, the same structure can live at the repository root. Both Docusaurus and MkDocs assume a `docs` source area and organize Markdown hierarchically, so this layout works well for humans, site generators, and agent ingestion pipelines. citeturn14view0turn14view5

A practical structure looks like this:

```text
docs/
  ontology/
    README.md
    governance/
      README.md
      naming-rules.md
      term-schema.md
      review-process.md
      forbidden-bare-terms.md

    catalog/
      README.md
      term-index.md
      alias-index.md
      collision-index.md
      deprecated-index.md

    contexts/
      billing/
        README.md
        terms/
          customer.md
          invoice.md
          payment.md
        model/
          aggregates.md
          events.md
          policies.md
        ports/
          invoice-submission.md
          payment-notification.md
        adapters/
          stripe.md
          postgres.md
          rest-api.md
        decisions/
          ADR-0001-invoice-lifecycle.md

      support/
        README.md
        terms/
          customer.md
          ticket.md
          escalation.md
        model/
          aggregates.md
          events.md
        ports/
          ticket-intake.md
        adapters/
          zendesk.md
        decisions/
          ADR-0003-ticket-ownership.md

    relationships/
      README.md
      billing--support.md
      billing--crm.md

    shared/
      README.md
      seedwork/
        money.md
        email-address.md
      contracts/
        event-catalog.md
        api-contracts.md

    ux-system/
      README.md
      terms/
        modal.md
        toast.md
        data-table.md
      components/
        button.md
        invoice-card.md
        customer-summary.md
      patterns/
        filter-panel.md
        empty-state.md
      tokens/
        color-tokens.md
        spacing-tokens.md
```

This tree is opinionated in one important way. **Definitions are local, discovery is global.** The `contexts/` folder is the source of truth for meaning. The `catalog/` folder is a generated discovery layer that helps a human or agent answer questions like “where is `Customer` defined?” or “does `Order` already exist somewhere else?” without pretending there is one project-wide meaning for every term. That is much closer to bounded-context thinking than a single master glossary. citeturn7view0turn6view3

The top-level folders each have a distinct job:

- `contexts/` contains one folder per bounded context, because the bounded context is where a specific domain model and vocabulary apply. citeturn7view0turn6view3
- `relationships/` holds context-map style documents and anti-corruption mappings, because translation between contexts should be explicit rather than implicit. citeturn7view0turn6view4
- `shared/` is deliberately narrow. Microsoft’s microservices guidance says to avoid sharing code or data schemas broadly across services, while Microsoft’s DDD guidance uses “seedwork” for a **small subset** of reusable elements rather than a broad framework. Treat this folder as “truly identical primitives only,” not as a dumping ground. citeturn24view0turn30view0
- `ux-system/` is separate because reusable UI components, patterns, and tokens have their own documentation lifecycle. Storybook is built around documenting components in isolation, and the Design Tokens specification is built around maintaining a single source of truth for design decisions across tools and platforms. citeturn20view1turn20view2turn20view0turn21view0turn21view2

## Recommended Markdown schema

Use **one concept per file** and give every file explicit metadata in YAML front matter. Docusaurus supports YAML front matter at the top of each Markdown file and even lets you extend its parser with custom logic. It also supports explicit document IDs, which is useful because a stable concept identifier should survive filename changes. citeturn25view0turn25view1

A good term file template looks like this:

```md
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
broader:
  - billing.party
related:
  - billing.account
maps_to:
  - term: support.customer
    relation: close
source_docs:
  - ../../contexts/billing/README.md
  - ../decisions/ADR-0004-customer-lifecycle.md
change_note: Introduced when invoice ownership moved into Billing.
history_note: Replaced legacy crm.account-holder term.
---

# Customer

## Definition
A billable legal or natural party that owns one or more Billing Accounts.

## Scope
Used only inside the Billing bounded context.

## Not this
Not the same as `support.customer`, which is the party recognized by the Support workflow.

## Examples
- A customer can be invoiced.
- A customer may have multiple billing accounts.

## Used by
- `invoice-submission`
- `payment-notification`
- `invoice-card`
```

The metadata fields above are deliberately borrowed from SKOS and DDD rather than invented from scratch. SKOS gives you a mature pattern for a controlled vocabulary: `prefLabel`, `altLabel`, `hiddenLabel`, `definition`, `scopeNote`, `historyNote`, `changeNote`, and semantic links such as `broader` and `related`. It also enforces a useful integrity rule: a resource should not have more than one preferred label per language, and preferred, alternative, and hidden labels should not clash. That maps cleanly to your case. In practical terms, each term file should have **one canonical label inside its context**, optional aliases, optional hidden aliases for deprecated spellings or search-only variants, and explicit semantic links. citeturn13view0turn12view0turn12view2turn5view3turn5view4

I would mirror SKOS’s URI idea with your own stable IDs, for example `billing.customer` or `support.customer`. SKOS uses URIs precisely so concepts can be referenced unambiguously across systems. You do not have to expose RDF to your developers, but you should copy the principle. In this design, the stable `id` is the machine-facing handle, while `preferred_label` is the human-facing display name. citeturn22view2turn29view0

For cross-context translation, keep the vocabulary simple and explicit. SKOS already gives you a lightweight mapping vocabulary with `exactMatch`, `closeMatch`, `broadMatch`, `narrowMatch`, and `relatedMatch`. You can use those same words in Markdown relationship docs and front matter values without adopting full RDF. That gives your team a shared semantics for “identical,” “nearly identical,” “broader,” and “associated but not equivalent.” citeturn26view0turn26view1turn26view2

## Handling collisions and reusable UX assets

The global catalog should make collisions **visible**, not try to erase them. A `catalog/collision-index.md` page should be generated from the term files and list any repeated preferred label across contexts, for example:

```text
Customer
- billing.customer
- support.customer
- crm.customer

Order
- commerce.order
- fulfillment.order
```

That index should also tell readers what to do with the bare term. If `Customer` has three meanings, the catalog should say something like “Use context-qualified terms outside local context.” This follows Fowler’s advice to avoid the bare homonym when precision matters in software representation. citeturn28view0

I would also generate an `alias-index.md` and a machine-readable `terms.json` manifest. The reason is practical. SKOS is explicitly designed so vocabularies can be exchanged as machine-readable data, and modern agent tooling works best when structured docs can be queried as manifests or indexes rather than scraped heuristically. Storybook’s MCP documentation is very direct on this point for UI work: agents query manifests to find matching components and then pull detailed usage docs. Your domain dictionary should behave the same way. Markdown remains the human-authored source of truth, while the generated manifest becomes the fast path for agents. citeturn22view0turn20view0

For reusable UX assets, keep **domain meaning** and **UI implementation** separate. Storybook is built to document UI components and pages in isolation, and its docs toolset is designed so agents can query component manifests, read props and stories, and reuse existing components instead of rebuilding them. The Design Tokens specification now provides a stable, vendor-neutral format for the visual primitives behind those components. That means your `ux-system/` area should own components, patterns, and tokens, while domain term files should only **reference** the relevant UX assets. A domain term like `billing.invoice` may reference `invoice-card`, but `invoice-card` should not be the place where the meaning of “invoice” is defined. citeturn20view0turn20view1turn20view2turn21view0turn21view1turn21view2

The same caution applies to shared domain artifacts. Keep `shared/seedwork` tiny. Microsoft’s DDD guidance describes seedwork as a small subset of reusable base elements, not a framework, and Azure’s microservices guidance explicitly warns against sharing code or data schemas too broadly because that creates tight coupling. In other words, share `Money` or `EmailAddress` only if the meaning is truly identical everywhere. Do **not** share `Customer` just because several contexts use the word. citeturn30view0turn24view0

## Publishing and automation

For folder landing pages, I recommend `README.md` in every folder, with a rule that you never mix `README.md` and `index.md` in the same directory. MkDocs will render `README.md` as the directory index, and Docusaurus treats `README` as a clean directory-level URL. That gives you the nicest behavior for both repository browsing and generated documentation sites. citeturn14view3turn25view1

If you want one default tooling choice, **Docusaurus is the better fit for this specific ontology use case** because it supports hierarchical Markdown docs, autogenerated sidebars from the filesystem, explicit document IDs, tags, and a customizable front matter parser. That combination is unusually convenient for semantic documentation. MkDocs is still a good option if you want the lightest possible stack, especially when you prefer an explicit `nav` in `mkdocs.yml`. Either way, keep the ontology structure generator-agnostic and let the publishing tool sit on top of it. citeturn14view0turn14view1turn25view0turn25view1turn14view4

I would avoid numeric folder prefixes like `01-`, `02-`, and `03-` in the canonical source tree. Both MkDocs and Docusaurus already provide navigation mechanisms. MkDocs lets you define site order in `nav`, and Docusaurus can autogenerate sidebar structure from the filesystem. Let navigation order live in the publishing layer, and keep path names semantic for humans and agents. citeturn14view1turn14view4

Finally, add a small validation step in CI. This is where your duplication problem actually gets solved. SKOS explicitly frames some of its rules as integrity conditions that tools can check against the data model, and Microsoft’s ADR guidance similarly emphasizes consistent templates plus append-only history. Apply the same discipline here. Your CI should fail when two files in the same context use the same `preferred_label`, when an alias collides with another term’s preferred label inside the same context, when a `maps_to` reference points to a missing term, or when a deprecated term is silently removed instead of being superseded with history. Accepted ADRs should remain append-only, and term changes should leave a visible trail with change and history notes. citeturn22view0turn9view2

## Final answer

If you want the **best and simplest** ontology structure for an IDLC project, use this rule:

**Make term definitions local to bounded contexts, make discovery global, make cross-context translation explicit, and keep UX assets in their own reusable catalog.**

That gives humans a documentation tree they can browse naturally, and it gives agents a clean, machine-readable path to answer the questions that matter most: “What does this term mean here?”, “Is this the same concept or a different one?”, and “Do we already have a component, port, adapter, or decision for this?” The combination of DDD bounded contexts, hexagonal separation of ports and adapters, SKOS-style term metadata, and a generated collision index is the cleanest way to prevent silent reimplementation of the same concept under multiple names. citeturn7view0turn23view0turn29view0turn20view0