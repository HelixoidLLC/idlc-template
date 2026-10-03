---
disable-model-invocation: true
name: ontology-builder
description: Build or extend the project's domain vocabulary and glossary following the IDLC Knowledge Architecture Policy. Use when the user wants to define domain terms, create or grow an ontology/glossary, extract concepts from architecture boundaries and code, or resolve cross-domain term collisions. Produces output at the ontology's current maturity level (flat glossary through per-term files).
---

# Ontology Builder v3

Build or extend the project's domain vocabulary following the IDLC Knowledge Architecture Policy.

> Policy reference: `design_idlc_brainstorming/ontology/IDLC_Knowledge_Architecture_Policy.md`

---

## Before you start

Determine three things:

1. **Current maturity level** — does the project have a flat `ontology/glossary.md`, per-domain files, or nothing yet?
2. **Which domains exist** — scan `knowledge/architecture/domains/` and `knowledge/ontology/domains/` (or equivalent)
3. **Scope** — are we adding terms for a specific domain, or doing an initial pass across all domains?

```bash
Glob: "knowledge/ontology/**/*.md"
Glob: "knowledge/architecture/domains/**/README.md"
Glob: "knowledge/architecture/domains/**/boundaries.md"
```

If nothing exists, start at Level 0 (single flat file). Do not jump to Level 3 unless the project already has 20+ terms per domain.

---

## Maturity levels

| Level | Structure | When to use |
|---|---|---|
| 0 | `ontology/glossary.md` — all domains, flat | < 30 total terms, single team |
| 1 | `ontology/{domain}.md` — one file per domain | Multiple domains, 5+ terms each |
| 2 | Level 1 + `ontology/mappings/{a}--{b}.md` | Cross-domain collisions exist |
| 3 | `ontology/domains/{domain}/glossary/` — one file per term | 20+ terms per domain, need change history |

Produce output at the **current level** unless the user explicitly asks to upgrade.

---

## Discovery

Extract candidate terms from:

```bash
# Architecture boundaries — what each domain owns
Read: knowledge/architecture/domains/{domain}/boundaries.md

# Existing code — what concepts are actually used
Grep: "struct|interface|type|class|enum" in src/
Grep: "domain event names" (past-tense nouns like OrderCreated, InvoiceIssued)

# Existing docs and tickets
Glob: "knowledge/**/*.md"
Glob: "docs/**/*.md"
```

For each domain, collect: nouns that appear repeatedly in cross-boundary contexts, domain events emitted to other domains, entities passed through ports/APIs, concepts that multiple teams ask about.

---

## What not to document

Reject these from the ontology — they belong in code, not vocabulary:

- Function names, method signatures, column names, internal variable names
- Anything behind a feature flag or in an A/B test (put in `product/experiments/`)
- Internal processing states that never cross a domain boundary
- Obvious structural things a developer wouldn't misunderstand (`UserRepository`, `Logger`, `Config`)
- Two domain terms that are genuinely identical — merge them, don't create a mapping

**The test**: would a different team or an agent misunderstand or duplicate this concept without an ontology entry? If not, skip it.

---

## Term structure

At Level 0–1, write each term as a markdown section with a key-value block and prose:

```markdown
## {domain}.{term}

- id: {domain}.{term}
- status: active
- owner: {team}

{One sentence definition.}
Not the same as `{other-domain}.{similar-term}` — {brief reason why they differ}.
```

At Level 2, add `maps_to` when cross-domain collision exists:

```markdown
- maps_to: {other-domain}.{term} (closeMatch|exactMatch|broadMatch|narrowMatch|relatedMatch)
```

At Level 3, use full YAML front matter per file:

```yaml
---
id: {domain}.{term}
context: {domain}
preferred_label: {Term}
aliases:
  - {Alias}
owner: {team}
status: active
maps_to:
  - term: {other-domain}.{term}
    relation: closeMatch
---
```

Every term body must include:
- **Definition** — one precise sentence, no weasel words
- **Not this** — at least one explicit exclusion linking to a related term that people might confuse it with
- **Used by** — ports, components, or workflows that reference this term

---

## Collision detection

Before writing any term, check whether the label already exists under another domain:

```bash
Grep: "preferred_label: {Term}" in knowledge/ontology/
Grep: "## {domain}.{term}" in knowledge/ontology/
```

If the same label exists in another domain:
- Document both (they are legitimately different)
- Add `maps_to` with the correct relation type
- If they are identical in meaning and owned by one team, propose merging instead

---

## Cross-domain mappings (Level 2+)

Create `knowledge/ontology/mappings/{domain-a}--{domain-b}.md` when:
- The same word appears in two domains
- Two teams have disagreed about a term
- A port contract requires translating between two domain models

The mapping file must contain:
- The relation type (`closeMatch`, `exactMatch`, etc.)
- What each domain owns that the other does not
- The translation rule: how to cross the boundary in code (which port to call, which field to pass)

---

## Output

Depending on the current level, write to:

- **Level 0**: `knowledge/ontology/glossary.md` (append or create)
- **Level 1**: `knowledge/ontology/{domain}.md` (append or create)
- **Level 2**: Level 1 files + `knowledge/ontology/mappings/{a}--{b}.md`
- **Level 3**: `knowledge/ontology/domains/{domain}/glossary/{term}.md`

Also update `knowledge/ontology/catalog/term-index.md` with any new entries (create the file if it does not exist).

---

## Deliverables

1. **Domain scan** — list of domains found and their current ontology coverage
2. **Candidate terms** — extracted from code/docs with rationale for inclusion/exclusion
3. **Term files** — written at the appropriate maturity level
4. **Collision report** — any terms found in multiple domains, with proposed mappings
5. **Upgrade recommendation** — whether the current level is still appropriate given the term count
