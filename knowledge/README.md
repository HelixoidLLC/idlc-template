# knowledge/ — the project's external brain

This folder is the durable, version-controlled memory of the project. It is
written **for AI agents first, humans second**. Every session loads context
from here before acting and writes back to here before ending.

> All content in this template is **illustrative sample data** for an imagined
> knowledge-management product called **Lorekeeper** (team prefix `KMS`). Delete
> the samples and keep the structure when you adopt this in a real project.

## What lives where

| Folder | Holds | Answers |
|---|---|---|
| `tickets/` | One file per unit of work (feature, bug, task) | What are we building? |
| `research/` | Investigations that informed a decision | Why this approach? |
| `plans/` | Implementation plans, linked to a ticket | How will we build it? |
| `adr/` | Architecture Decision Records (append-only) | What did we decide, and why? |
| `architecture/` | High-level design docs | How is the system structured? |
| `reviews/` | Post-implementation audits | What went right/wrong? |
| `handoffs/` | Mid-task session handoffs | Where do I resume? |
| `decisions/` | Dated prioritization / process decisions | Why did we re-order the work? |
| `bugs/` | Diagnosed defects with root cause | What broke and why? |
| `guides/` | How-to docs for recurring tasks | How do I do X? |
| `prompts/` | Reusable, curated prompts | How do I ask the agent for X? |
| `artifacts/` | Spike findings, benchmarks, eval outputs | What did the experiment show? |
| `validation/` | Test/eval evidence backing a claim | Is it actually true? |
| `testing/` | Per-ticket test plans and suites | How is it tested? |
| `product/` | Business intent — PRDs, journeys, personas, metrics | Why are we building this? |
| `ontology/` | Shared vocabulary, per domain | What do our terms mean? |
| `workflows/` | Reusable agent+human process definitions | How does work move? |
| `governance/` | Rules that keep the other layers from drifting | How does this stay healthy? |

## Root files

- `QUEUE.md` — a short, ordered window over the head of the backlog. Order only.
- `idlc.yaml` — the lifecycle configuration: stages, statuses, and artifact gates.

## Naming conventions

- Dated artifacts: `YYYY-MM-DD-{TICKET}-{slug}.md` (e.g. `2026-07-17-KMS-0042-semantic-search-implementation.md`).
- Tickets: `{PREFIX}-{####}.md` (e.g. `KMS-0042.md`).
- Ontology terms are always **domain-qualified**: `capture.document`, never bare `document`.

## The one rule

Stale docs are worse than no docs. Update the relevant file when work completes,
before you close the session. If it isn't written down, the next session starts blind.
