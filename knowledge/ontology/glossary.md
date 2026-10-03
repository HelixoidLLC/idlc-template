# Ontology — flat glossary (Level 0)

> **This is the Level 0 starting point.** One file, all domains, every term
> domain-qualified with a `## {domain}.{term}` header. When a domain grows past
> ~5 terms or a second team starts contributing, split it into
> `ontology/domains/{domain}/glossary.md` — the term IDs never change, only the file.
>
> The one rule that must hold at every level: **every term is domain-qualified at
> its canonical id** (`capture.document`, never bare `document`). This is the single
> convention that makes every upgrade mechanical instead of a rename-everything rewrite.

---

## capture.document

- status: active
- owner: knowledge-platform-team

The canonical unit of knowledge in Lorekeeper: a markdown file with YAML front
matter, stored on disk as the source of truth.
Not the same as `search.result` — a result is a *reference* to a document produced
by a query, not the document itself.

---

## capture.workspace

- status: active
- owner: knowledge-platform-team

A single user's or team's isolated collection of documents on one machine.
Search, indexing, and the entity graph are all scoped to one workspace.

---

## search.embedding

- status: active
- owner: search-team

A fixed-length numeric vector (384-dim) representing the *meaning* of a document or
query, produced by the local embedding model.
Not the same as `search.keyword-index` — an embedding captures meaning; the keyword
index captures exact tokens.

---

## search.relevance-score

- status: active
- owner: search-team
- maps_to: capture.document (relatedMatch)

The blended score (70% semantic, 30% keyword) used to rank a document against a
query. Internal ranking signal, not a user-facing rating.

---

## curation.duplicate

- status: proposed
- owner: knowledge-platform-team

Two documents judged to describe the same knowledge, surfaced to a curator for
merge. "Judged" = above a similarity threshold on their embeddings.
Not the same as an exact-copy file — a duplicate can be worded completely differently.
