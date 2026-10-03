---
type: prompt
purpose: "Extract domain entities and relationships from a knowledge document"
model: claude-opus-4-8
status: active
tags: [prompt, extraction, ontology, graph]
last_updated: 2026-07-19
---

# Prompt: Extract entities from a document

A curated, reusable prompt for the entity-extraction pipeline (KMS-0051). Keep the
prompt here so it is version-controlled and improvements are shared, not re-invented.

## When to use

Run against any knowledge document to populate the entity graph. Called by the
extraction pipeline; also usable ad hoc when debugging a bad extraction.

## Inputs

- `{document_body}` — the markdown body of the document.
- `{known_terms}` — the current domain glossary terms, to prefer canonical names.

## Prompt

```
You are extracting a knowledge graph from a single internal document.

Return ONLY valid JSON: a list of {subject, relation, object} triples.

Rules:
- Prefer canonical term names from this glossary when a match exists: {known_terms}
- Use domain-qualified names (e.g. "capture.document", not "document").
- Extract relationships that a teammate would want to navigate later
  (depends_on, supersedes, owned_by, relates_to). Skip trivia.
- If a subject is a person, use their handle, not their display name.
- Do NOT invent entities that are not supported by the text.

Document:
---
{document_body}
---
```

## Output contract

A JSON array of triples. Anything that is not valid JSON is a failure and must be
retried, not parsed leniently. See `validation/` for the extraction eval.

## Notes

- The "do NOT invent" line matters — early versions hallucinated relationships that
  weren't in the text. Keep it.
- Feeds `ontology/domains/*/entities.md` and the graph in the architecture doc.
