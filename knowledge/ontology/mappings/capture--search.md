---
domains:
  - capture
  - search
---

# Mapping: capture ↔ search

Explicit translations between the `capture` and `search` domains. This file exists
because both domains reference the same underlying documents but model them
differently and are owned by different teams.

## capture.document ↔ search.result

Relation: `relatedMatch`

They refer to the same underlying knowledge, but they are different things.

| | capture.document | search.result |
|---|---|---|
| Owns | The full content, front matter, lifecycle | A ranked reference for one query |
| Lives | On disk (source of truth) | In memory, per query, ephemeral |
| Carries | Everything | id, title, type, excerpt, relevance-score |
| Created when | A user saves a document | A query runs |

**Translation rule**: `search` never mutates a `capture.document`. When search needs
document content, it reads through the `capture` read port `get-document` using the
`document_id` carried on the result. Search does not reach into capture's storage.

## capture.document → search.embedding

Relation: `narrowMatch` (derivation)

An embedding is *derived from* a document but is not a document. When a
`capture.DocumentCreated` or `capture.DocumentUpdated` event fires, `search` produces
or refreshes the embedding. The document is canonical; the embedding is disposable.

**Boundary note**: `search` must handle `capture.DocumentsImported` (bulk) as well as
the per-document events — the gap between them was the root cause of bug KMS-0043.

## No equivalent

`search` has no concept of `capture.tag`. Tags are an authoring concept; search reads
document body + title, not tags, for the semantic signal. If that changes, it becomes
a payload change on the capture events, documented here.
