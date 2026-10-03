# Search Glossary

> Domain: `search`. What search terms mean. Mirrors
> `architecture/domains/search/` (how search is built). The `search` domain owns
> everything about turning a query into ranked documents; it does NOT own what a
> document *is* — that is `capture.document`.

## embedding

- id: search.embedding
- status: active
- owner: search-team
- related: search.vector-index

### Definition
A 384-dimensional numeric vector representing the *meaning* of a document or query,
produced by the local `bge-small` model (see the KMS-0042 ADR).

### Not this
- `search.keyword-index` — captures exact tokens, not meaning.
- The document itself (`capture.document`) — an embedding is derived from it.

---

## vector-index

- id: search.vector-index
- status: active
- owner: search-team

### Definition
The on-disk HNSW structure holding all document embeddings, enabling
nearest-neighbor lookup in sub-millisecond time. Derived and disposable — rebuildable
from the documents at any time.

---

## relevance-score

- id: search.relevance-score
- status: active
- owner: search-team
- maps_to: capture.document (relatedMatch)

### Definition
The blended ranking signal: `0.7 × semantic_similarity + 0.3 × keyword_score`, each
normalized to [0,1]. Internal — the user sees ordered results, not the number.

### Not this
- A user-facing star rating or quality score. It ranks against a *query*; it says
  nothing about a document's intrinsic quality.

---

## result

- id: search.result
- status: active
- owner: search-team
- maps_to: capture.document (relatedMatch)

### Definition
A reference to a `capture.document` returned for a query, carrying its title, type,
excerpt, and `relevance-score`. A result points at a document; it is not the document.
