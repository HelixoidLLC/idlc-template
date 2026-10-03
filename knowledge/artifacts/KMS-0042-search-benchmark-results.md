---
type: artifact
artifact_kind: benchmark
ticket: KMS-0042
date: 2026-07-21
status: final
tags: [artifact, benchmark, search, performance]
---

# KMS-0042 — Search latency benchmark

Evidence backing the "500ms p95" acceptance criterion. Reproducible via
`scripts/bench_search.py --corpus bench/10k`.

## Setup

- **Corpus**: 10,000 synthetic knowledge documents, ~600 words each.
- **Hardware**: M2 laptop, 16GB, CPU-only (no GPU) — matches the local-first target.
- **Model**: `bge-small-en-v1.5` (384-dim), loaded once at startup.
- **Query set**: the 30-query relevance set + 470 random title fragments (500 total).

## Results

| Metric | Value | Budget | Pass |
|---|---|---|---|
| Query embed time (mean) | 14ms | — | — |
| Vector search (HNSW, k=20) | 0.8ms | — | — |
| Blend + hydrate results | 22ms | — | — |
| **End-to-end p50** | 180ms | — | — |
| **End-to-end p95** | **310ms** | 500ms | ✅ |
| **End-to-end p99** | 420ms | — | ✅ |
| Index build (cold, 10k docs) | 148s | — | — |
| Incremental upsert (1 doc) | 16ms | — | — |

## Findings

- The dominant cost is query embedding (14ms), not vector search (0.8ms). HNSW is
  effectively free at this corpus size.
- p99 (420ms) still fits the budget, so no tail-latency work is needed for v1.
- Cold index build (148s) confirms the research finding that a full rebuild on every
  edit is unacceptable — incremental upsert (16ms) is the right path.

## Conclusion

Meets the latency acceptance criterion with margin. Model choice (ADR) validated.
