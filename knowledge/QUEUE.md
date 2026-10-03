# Priority Queue

> **Order only, short-term head only.** A small window (~20 entries max) over the
> head of the backlog, ordered by urgency — NOT a full ranking. Top = next up;
> finish or re-rank to make room before adding. One line per entry: `ID — hook`
> plus at most one ordering constraint. Status, priority, scope, and rationale
> live in the ticket itself. Everything not listed here is unordered.
> Reprioritizations: reorder this list AND write a dated file in
> `knowledge/decisions/` with evidence links. Git history of this file is the audit trail.

## Queue

1. KMS-0042 — semantic search over the knowledge base (the flagship; everything indexes through it)
2. KMS-0043 — stale search index after bulk import (data-integrity bug; blocks 0042 sign-off)
3. KMS-0051 — entity extraction pipeline (feeds the ontology graph; gate: KMS-0042 index schema frozen)
4. KMS-0055 — document card component (UI reuse; ride-along with 0042 result rendering)
5. KMS-0060 — curator review queue (depends on entity extraction landing)
6. KMS-0061 — cross-domain term collision report (nice-to-have; after ontology has >2 domains)

> Vision & milestones: `docs/agentic_infrastructure.md`
> Plan: `knowledge/plans/2026-07-17-KMS-0042-semantic-search-implementation.md`
> Latest decision: `knowledge/decisions/2026-07-18-search-before-graph.md`

## Parked (no active ticket)

- Multi-language document embeddings — waiting on evaluation of a multilingual model.
- Real-time collaborative editing of documents — out of scope for v1.
