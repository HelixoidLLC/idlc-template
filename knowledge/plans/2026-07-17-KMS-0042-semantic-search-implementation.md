# KMS-0042: Semantic Search Implementation Plan

**Ticket**: KMS-0042
**Research**: knowledge/research/2026-07-15-KMS-0042-semantic-search-approaches.md
**ADR**: knowledge/adr/2026-07-16-KMS-0042-adr-embedding-model-choice.md

## Overview

Add embedding-based semantic search over the knowledge base, blended with the
existing keyword index, meeting a 500ms p95 latency bar on a 10k-document corpus.

## Current state analysis

### What exists
- Keyword search via SQLite FTS5 (`search/keyword_index.py`).
- Documents are markdown with YAML front matter, loaded through `store/loader.py`.
- A `Document` model already carries `id`, `title`, `body`, `doc_type`.

### What's missing
- No embedding model integration.
- No vector index.
- No blended ranking; search is keyword-only.

## Desired end state

1. On document save, the document is embedded and upserted into an HNSW vector index.
2. On document delete, its vector is removed within one refresh cycle.
3. A query is embedded once, searched against the vector index, and its results are
   blended 70/30 (semantic/keyword) into a single ranked list.
4. Top-20 results returned within 500ms p95 on the benchmark corpus.

## What we're NOT doing

- LLM re-ranking (evaluate after v1).
- Cross-workspace search.
- Natural-language QA (KMS-0070).

## Implementation approach

1. **Model wrapper first** — `search/embedder.py`: load `bge-small` once, expose
   `embed(text) -> vector[384]`. Fail loudly if the model's dim ≠ 384 (per ADR).
2. **Vector index second** — `search/vector_index.py`: HNSW wrapper with
   `upsert(doc_id, vector)`, `remove(doc_id)`, `query(vector, k) -> [(doc_id, score)]`.
   Persist to disk; load on startup; rebuild command for recovery.
3. **Blended ranker third** — `search/ranker.py`: combine semantic + FTS5 scores,
   normalize each to [0,1], weight 0.7/0.3, return top-k.
4. **Wire into save/delete hooks** — index on `Document.save()`, remove on delete.
5. **API + UI** — extend the `/search` endpoint; render results in the top-nav bar.

## Testing strategy

- Unit: embedder dim guard, ranker blend math, index upsert/remove.
- Integration: real corpus, real index — no mocks (per project integrity rule).
- Eval: 30-query relevance set (`knowledge/validation/KMS-0042-search-relevance-eval.md`).
- Perf: benchmark p95 latency on 10k docs (`knowledge/artifacts/`).

## Rollout / risks

- **Risk**: stale index after bulk import — tracked as bug KMS-0043; must be fixed
  before sign-off.
- **Risk**: first-run model download blocks search — show a "preparing search" state.

## Success criteria (from the ticket)

- "prior work on onboarding" surfaces "New-hire ramp-up notes" in the top 5.
- 500ms p95 on 10k docs. Deletes reflected within one refresh cycle.
