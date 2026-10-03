# Knowledge-Capture Glossary

> Domain: `capture`. This is the Level 1 split — one file per domain. Terms use
> `## {term}` headers (the domain is implied by the folder). Mirrors
> `architecture/` — this file says what terms *mean*; architecture says how the
> domain is *built*.

## document

- id: capture.document
- status: active
- owner: knowledge-platform-team
- related: capture.workspace, capture.tag
- maps_to: search.result (relatedMatch)

### Definition
The canonical unit of knowledge: a markdown file with YAML front matter, stored on
disk. The file is the source of truth; all indexes are derived from it.

### Not this
- `search.result` — a *reference* to a document returned by a query, not the document.
- `search.embedding` — a numeric representation *of* a document, not the document.

### Examples
- A meeting note, a decision record, and a runbook are all `capture.document`s of
  different `doc_type`.

### Used by
- component: `document-card` (reusable-assets)
- port: `document-save`, `document-delete`

---

## workspace

- id: capture.workspace
- status: active
- owner: knowledge-platform-team

### Definition
A single isolated collection of documents on one machine. All search, indexing, and
graph state is scoped to exactly one workspace. Nothing crosses workspace boundaries.

### Not this
- A cloud tenant — Lorekeeper is local-first; a workspace lives on the user's disk.

---

## tag

- id: capture.tag
- status: active
- owner: knowledge-platform-team

### Definition
A free-form label attached to a document for manual grouping. Distinct from the
extracted entity graph — tags are author-assigned; entities are extracted.
