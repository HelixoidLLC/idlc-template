---
date: 2026-07-15T11:20:00Z
researcher: Claude
git_commit: a1b2c3d
branch: KMS-0042-semantic-search
repository: lorekeeper
topic: "Approaches for semantic search over the knowledge base"
tags: [research, search, embeddings, vector-index, ranking]
status: complete
ticket: KMS-0042
last_updated: 2026-07-15
last_updated_by: Claude
---

# Research: Semantic search over the knowledge base

## Research question

How should Lorekeeper implement semantic search over ~10k markdown documents so
that conceptually related content surfaces even when the wording differs — while
staying local-first (no data leaves the user's machine) and fast (<500ms p95)?

## Summary

Three viable approaches were evaluated. Recommendation: **local embedding model +
on-disk vector index (HNSW), blended with the existing keyword index**. This keeps
data local, meets the latency bar, and reuses the keyword index we already ship.

## Options considered

### Option A — Hosted embedding API + managed vector DB
- **Pros**: best-in-class relevance, zero index maintenance.
- **Cons**: documents leave the machine (violates local-first constraint); network
  latency blows the 500ms budget; per-query cost. **Rejected** on the local-first
  constraint alone.

### Option B — Local embedding model + HNSW index (recommended)
- **Pros**: fully local; HNSW gives sub-millisecond nearest-neighbor lookup; the
  `bge-small` model is ~130MB and runs on CPU in ~15ms per document.
- **Cons**: index must be maintained incrementally; model download on first run.
- **Verdict**: meets every constraint. This is the recommendation.

### Option C — Keyword-only with query expansion (synonyms)
- **Pros**: no new dependencies; trivial to ship.
- **Cons**: synonym lists are brittle and never cover conceptual matches
  ("onboarding" ≈ "ramp-up" only if someone curated it). **Rejected** — does not
  actually solve the recall problem, just papers over it.

## Key findings

- The existing keyword index (SQLite FTS5) is a strong signal for exact matches and
  should be **kept and blended**, not replaced. Pure semantic search under-ranks
  exact matches, which users find jarring.
- A 70/30 blend (semantic/keyword score) topped the manual relevance judgments on a
  30-query test set. This becomes the eval baseline in `knowledge/validation/`.
- Incremental indexing is required: a full rebuild of 10k docs takes ~2.5 min,
  unacceptable on every edit. Index on document save; refresh on delete.

## Related terms introduced

- `search.embedding`, `search.vector-index`, `search.relevance-score` —
  see `knowledge/ontology/domains/search/glossary.md`.

## Recommendation → next step

Proceed to `/create_plan` for Option B. The one decision that needs an ADR before
planning is **which embedding model** — captured in
`knowledge/adr/2026-07-16-KMS-0042-adr-embedding-model-choice.md`.
