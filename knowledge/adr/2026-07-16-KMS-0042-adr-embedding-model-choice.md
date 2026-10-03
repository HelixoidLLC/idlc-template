---
date: 2026-07-16T14:00:00Z
author: Claude & Igor
git_commit: b2c3d4e
branch: KMS-0042-semantic-search
repository: lorekeeper
type: adr
status: accepted
ticket: KMS-0042
tags: [architecture, decision, search, embeddings, local-first]
supersedes: none
superseded_by: none
last_updated: 2026-07-16
last_updated_by: Claude
---

# ADR: Use a local `bge-small` embedding model for semantic search

## Status

Accepted

## Context

KMS-0042 requires semantic search over the knowledge base. The
[research](../research/2026-07-15-KMS-0042-semantic-search-approaches.md)
settled on a local-embedding + HNSW approach. The remaining open decision is
*which* embedding model to run locally. Constraints:

- **Local-first**: documents must never leave the user's machine. No hosted API.
- **CPU-only**: we cannot assume a GPU on user hardware.
- **Latency budget**: embedding a query must fit inside the 500ms p95 end-to-end.
- **Footprint**: the model ships with the app; keep the download reasonable.
- **Quality**: must clear the 70/30 blend baseline on the 30-query eval set.

## Decision

Adopt **`bge-small-en-v1.5`** (384-dimensional embeddings, ~130MB, CPU-friendly)
as the default embedding model, loaded once at startup and reused for both
document and query embedding.

The embedding dimension (384) is frozen into the on-disk index schema. Changing
the model later requires an index rebuild and a new ADR.

## Alternatives considered

- **`bge-base` (768-dim)** — higher quality but ~2.3× slower per embed and doubles
  index size; the quality gain did not clear a meaningful margin on our eval set.
- **`all-MiniLM-L6-v2`** — smaller and faster, but scored below the blend baseline
  on conceptual queries. Rejected on quality.
- **Hosted embeddings** — rejected in research on the local-first constraint.

## Consequences

- **Positive**: fully local, ~15ms/embed on CPU, footprint acceptable, clears eval.
- **Negative**: 384-dim is baked into the index schema — a future model swap is a
  breaking change requiring a migration + rebuild.
- **Follow-up**: add a dimension-validation guard so a mismatched model fails loudly
  at load time instead of corrupting the index silently.

## Validation

Model choice is backed by the benchmark in
`knowledge/artifacts/KMS-0042-search-benchmark-results.md` and the relevance eval
in `knowledge/validation/KMS-0042-search-relevance-eval.md`.
