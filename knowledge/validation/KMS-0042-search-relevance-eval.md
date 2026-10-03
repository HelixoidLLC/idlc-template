---
type: validation
validation_kind: relevance-eval
ticket: KMS-0042
date: 2026-07-21
status: passed
tags: [validation, eval, search, relevance]
---

# KMS-0042 — Search relevance evaluation

Evidence that semantic search actually surfaces the right documents. This is the
gate that turns "it runs" into "it works". Real corpus, real judgments — no mocks.

## Method

- **Query set**: 30 queries written from user-interview language (conceptual, not
  keyword-exact). Each has 1–3 human-judged relevant documents in the corpus.
- **Metric**: Recall@5 (is a relevant doc in the top 5?) and MRR (mean reciprocal rank).
- **Baseline**: keyword-only (FTS5). **Candidate**: 70/30 semantic/keyword blend.

## Results

| Config | Recall@5 | MRR |
|---|---|---|
| Keyword only (baseline) | 0.53 | 0.41 |
| Semantic only | 0.80 | 0.62 |
| **Blend 70/30 (shipped)** | **0.90** | **0.71** |

## Marquee case (acceptance criterion)

- Query: `"prior work on onboarding"`
- Relevant doc: `"New-hire ramp-up notes"` (no shared keywords)
- Keyword-only rank: **not found** (>20)
- Blend rank: **2** ✅

## Failures worth noting

- Query `"who owns billing"` returned a doc about *invoice design*, not *ownership* —
  a relationship question the graph (KMS-0051) will answer better than search. Logged
  as motivation for the entity graph, not a search bug.

## Verdict

**PASSED.** The blend clears the baseline on both metrics and satisfies the marquee
acceptance criterion. Backs the review verdict for KMS-0042.
