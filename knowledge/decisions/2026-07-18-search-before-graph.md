# 2026-07-18 — Search before graph: sequence the roadmap

**Decision (Igor + Claude):** ship semantic search (KMS-0042) before the entity
graph (KMS-0051), even though both were pitched as "the v1 differentiator". Reorder
the queue accordingly.

## Rationale

- **User pain is concentrated on recall, not relationships.** 7 of 9 user interviews
  named "I can't find what we already wrote" as the top problem. Only 2 asked for
  "related concepts". Search addresses the majority pain directly.
- **The graph depends on search infrastructure.** Entity extraction (KMS-0051) reuses
  the embedding model and the document loader that KMS-0042 introduces. Building
  search first means the graph inherits working infrastructure instead of duplicating it.
- **Search is measurable now.** We have a 30-query relevance eval set. The graph's
  value ("did this surface a useful connection?") is harder to measure and would slow
  a v1 sign-off.

## Changes to the queue

1. KMS-0042 (semantic search) → position 1.
2. KMS-0051 (entity extraction) → position 3, gated on "0042 index schema frozen".
3. KMS-0061 (cross-domain collision report) → deferred until the ontology has >2 domains.

## Evidence

- Interview notes: `product/user-journeys/2026-07-08-researcher-finds-prior-work.md`
- Research recommendation: `research/2026-07-15-KMS-0042-semantic-search-approaches.md`
- Ticket: `tickets/KMS-0042.md`

## Revisit when

Entity extraction becomes a blocker for a customer commitment, or search adoption
plateaus and relationship-navigation is the hypothesized lever.
