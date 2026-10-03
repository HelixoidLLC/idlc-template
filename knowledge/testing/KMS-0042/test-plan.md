---
type: test-plan
ticket: KMS-0042
status: complete
derived_from:
  - knowledge/tickets/KMS-0042.md
  - knowledge/plans/2026-07-17-KMS-0042-semantic-search-implementation.md
tags: [testing, test-plan, search]
last_updated: 2026-07-21
---

# Test Plan: KMS-0042 — Semantic search

Derived from the ticket's acceptance criteria and the plan — NOT from the
implementation. Tests flow from requirements so they catch what the code got wrong.

## Testable requirements (quoted from the ticket)

- R1: "prior work on onboarding" surfaces "New-hire ramp-up notes" in the top 5.
- R2: Search returns within 500ms p95 on the 10k-document corpus.
- R3: Deleting a document removes it from results within one refresh cycle.
- R4: Keyword-exact matches rank at or above semantic-only matches.

## Test matrix

| ID | Requirement | Type | Approach |
|---|---|---|---|
| T1 | R1 | Eval | 30-query relevance set; assert Recall@5 ≥ 0.85 (see validation/) |
| T2 | R2 | Perf | Benchmark p95 on 10k corpus (see artifacts/) |
| T3 | R3 | Integration | Index a doc, delete it, assert absent after refresh |
| T4 | R4 | Unit | Ranker: exact match must not rank below a semantic-only match |
| T5 | — | Unit | Embedder rejects a model whose dim ≠ 384 (ADR guard) |
| T6 | — | Adversarial | Query empty corpus → empty result set, not an error |
| T7 | — | Adversarial | Bulk-import path is indexed (regression guard for KMS-0043) |

## Edge / adversarial cases

- Query shorter than 3 chars → no query fires (debounce/min-length).
- Query with only stopwords → graceful empty or low-confidence result.
- Concurrent delete during query → no crash, no torn read (index write-lock).
- Unicode / emoji in document body → embeds without error.

## Exit criteria

All of T1–T7 pass; the KMS-0043 regression guard (T7) is green; latency (T2) and
relevance (T1) evidence is committed under `artifacts/` and `validation/`.
