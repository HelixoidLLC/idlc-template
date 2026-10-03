# Persona: The Knowledge Curator

- id: persona.knowledge-curator
- status: active
- primary_for: product/prds/semantic-search.md

## Snapshot

**Name (archetype)**: Priya, "the Curator"
**Role**: Senior researcher who has unofficially become the keeper of the team's
shared knowledge base.
**Technical level**: High. Comfortable with markdown, git, and CLI tools.

## Goals

- Find whether a question has already been answered before starting new work.
- Keep the knowledge base trustworthy — accurate, deduplicated, well-tagged.
- Onboard new teammates by pointing them at the right existing docs.

## Frustrations

- Search that only matches exact words, so real knowledge stays hidden.
- Duplicate documents created because the author couldn't find the original.
- No visibility into which documents are stale or contradicted by newer ones.

## Behaviors

- Searches many times a day; treats the knowledge base as a primary tool, not an archive.
- Will happily fix tags and merge duplicates *if the tool surfaces them*.
- Distrusts any feature that sends the team's private knowledge to a third party —
  a hard "no" that shapes every product decision (see the local-first constraint).

## What she needs from the product

- Meaning-based recall (drives `prd.semantic-search`).
- A review queue for likely-duplicate or stale documents (future: KMS-0060).
- Confidence that nothing leaves the machine.

## Anti-persona (who this is NOT for)

Not the casual viewer who reads one linked doc a week — that user is served by good
links, not search tooling. Designing search for the casual viewer would under-serve Priya.
