# Success Metric: Semantic search adoption & effectiveness

- id: metric.search-adoption
- status: active
- measures_prd: product/prds/semantic-search.md
- owner: knowledge-platform-product

## The one metric that matters

**Search success rate** — the share of searches where the user opens a result within
30 seconds (a proxy for "search found what I needed").

- **Baseline (keyword-only)**: 48%
- **Target (v1, 90 days post-launch)**: ≥ 70%

## Supporting metrics

| Metric | Baseline | Target | Why it matters |
|---|---|---|---|
| Search success rate | 48% | ≥ 70% | Did search actually help? |
| Searches per active user / week | 6 | ≥ 12 | Do people trust it enough to rely on it? |
| "Asked a human instead" incidents | ~15/wk | ≤ 5/wk | Did we replace the channel-ask workaround? |
| Duplicate documents created / month | 22 | ≤ 10 | Fewer dupes = search surfaced the original |

## Guardrail metrics (must NOT regress)

- Median search latency stays under 500ms (see `artifacts/KMS-0042-search-benchmark-results.md`).
- Zero documents transmitted off-device (local-first constraint — a breach is a stop-ship).

## How it's measured

- Success rate & latency: local, privacy-preserving usage counters (opt-in, aggregated).
- Duplicates: the curator review queue (KMS-0060) logs merges.
- "Asked a human": manual tally from the team channel during the launch window.

## Anti-goal

We are NOT optimizing for time-in-app. A knowledge tool that keeps you searching
longer is failing. Faster-to-answer beats more-engagement.
