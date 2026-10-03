---
id: cap.text-embedding
kind: capability
status: active
owner: search-team
used_by:
  - search.embedding
  - search.vector-index
---

# Capability: Text Embedding

A shared, local capability that turns text into a fixed-length meaning vector. It is
infrastructure — multiple features can call it — but it does not define any domain
meaning of its own.

## Contract

```
embed(text: str) -> vector[384]
```

- Deterministic for a given model version + input.
- CPU-only, ~15ms per call (see the KMS-0042 benchmark).
- Model: `bge-small-en-v1.5`, 384-dim (frozen by the KMS-0042 ADR).

## Consumers

- `search.embedding` — embeds documents and queries for semantic search.
- Entity extraction (KMS-0051) — will reuse the same model for candidate matching.

## What this capability does NOT own

It produces vectors. It does not decide *how* they are ranked (that is
`search.relevance-score`) or *what* a document means (that is `capture.document`). It
is a pure function over text.

## Reuse note

New features that need "meaning of text" should call this capability rather than
loading their own embedding model — one loaded model, one dimension, one place to
change when the ADR is revised.
