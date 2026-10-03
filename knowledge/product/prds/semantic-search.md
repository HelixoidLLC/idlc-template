# PRD: Semantic search over the knowledge base

- id: prd.semantic-search
- status: active
- owner: knowledge-platform-product
- persona: product/personas/knowledge-curator.md
- addresses_journey: product/user-journeys/2026-07-08-researcher-finds-prior-work.md
- introduces_terms: search.embedding, search.relevance-score
- success_metric: product/success-metrics/search-adoption.md
- implemented_by_ticket: tickets/KMS-0042.md

## Problem

Teams accumulate knowledge faster than they can find it. Lorekeeper's keyword-only
search fails the moment a searcher's words differ from the author's — which is most
of the time across teams and over months. The result is duplicated work: people
re-answer questions the team already answered, because the answer is unfindable.

## Requirements

- A user can search the knowledge base and find documents by *meaning*, not just
  exact words.
- Results show document title, type, and a one-line excerpt.
- Exact keyword matches remain first-class — semantic search augments, not replaces.
- Search stays fully local — no document content leaves the user's machine.
- Results return fast enough to feel instant (under half a second).

## Out of scope

- Natural-language question answering (separate PRD, `prd.knowledge-qa`).
- Cross-workspace / cross-tenant search.
- LLM re-ranking of results (evaluate after launch).

## Constraints

- **Local-first is non-negotiable** — no hosted embedding API. (See the search ADR.)
- Must run on CPU-only consumer hardware.
- Must reuse, not replace, the existing keyword index.

## Acceptance criteria

- Given the query "prior work on onboarding", the document "New-hire ramp-up notes"
  appears in the top 5 results.
- Search returns within 500ms (p95) on a 10,000-document corpus.
- Deleting a document removes it from results within one refresh cycle.

## Open questions

- Should we expose the relevance score to the user, or keep it internal? Product to
  decide before the "more like this" follow-up.
