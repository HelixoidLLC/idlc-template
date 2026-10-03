---
date: 2026-07-10T10:00:00Z
author: Claude & Igor
repository: lorekeeper
type: architecture
status: current
tags: [architecture, storage, search, local-first]
last_updated: 2026-07-16
last_updated_by: Claude
---

# Architecture: The Lorekeeper Knowledge Store

**L0 (one line):** A local-first store of markdown documents with a keyword index
and a vector index, surfaced through search and a document graph.

## L1 (one paragraph)

Lorekeeper keeps every piece of knowledge as a markdown file with YAML front matter
on the user's disk — the files are the source of truth. Two derived, disposable
indexes sit on top: a keyword index (SQLite FTS5) and a vector index (HNSW). Both
are rebuildable from the files at any time. Search blends the two. An entity graph
is extracted from documents to power "related concepts". Nothing leaves the machine.

## L2 (detail)

### Components

| Component | Responsibility |
|---|---|
| `store/` | Load/save markdown docs; the files are canonical |
| `search/keyword_index.py` | FTS5 keyword index (derived, rebuildable) |
| `search/vector_index.py` | HNSW vector index (derived, rebuildable) |
| `search/ranker.py` | Blends keyword + semantic scores (see KMS-0042) |
| `graph/` | Extracted entity/relationship graph for "related concepts" |
| `api/` | Local HTTP API the UI talks to |

### Data flow

```
document.md (source of truth)
     │  on save
     ├──▶ keyword_index (FTS5)
     ├──▶ vector_index (HNSW)   ← KMS-0042
     └──▶ entity extraction ──▶ graph   ← KMS-0051
```

### Key properties

- **Local-first**: no network dependency for core features. This is a hard constraint,
  reflected in every search ADR.
- **Derived indexes are disposable**: if an index is corrupt, delete and rebuild from
  the markdown files. The files are never derived.
- **Append-only decision trail**: ADRs and events accumulate; they are not rewritten.

### Related decisions

- `adr/2026-07-16-KMS-0042-adr-embedding-model-choice.md` — why `bge-small`.
- Symmetry with ontology: each architectural domain (`search`, `knowledge-capture`)
  has a matching `ontology/domains/{domain}/` describing what its terms mean.
