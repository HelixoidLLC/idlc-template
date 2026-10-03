---
date: 2026-07-20T17:45:00Z
researcher: Claude Opus 4.8
git_commit: c3d4e5f
branch: KMS-0042-semantic-search
repository: lorekeeper
topic: "Handoff: semantic search indexer — save path done, delete path pending"
tags: [handoff, search, indexing, incomplete]
status: incomplete
ticket: KMS-0042
type: implementation_handoff
last_updated: 2026-07-20
last_updated_by: Claude Opus 4.8
---

# Handoff: KMS-0042 search indexer

**Status:** ⚠️ **INCOMPLETE** — save/index path works end-to-end; delete path and
bulk-import path are not wired yet.
**Next session:** finish the delete hook and the bulk-import hook, then run the eval.

## What was implemented ✅

- `search/embedder.py` — loads `bge-small` once, `embed(text) -> vector[384]`, with
  the ADR dim guard. Unit-tested.
- `search/vector_index.py` — HNSW wrapper: `upsert`, `query` working and persisted to
  `.lorekeeper/index/vectors.hnsw`. `remove` is **stubbed** (raises NotImplementedError).
- `search/ranker.py` — 70/30 blend implemented and unit-tested.
- Save hook wired: `Document.save()` now calls `vector_index.upsert()`. Verified by
  saving a doc and finding it via semantic query.

## What is NOT done ❌

1. **Delete path** — `vector_index.remove()` is a stub. `Document.delete()` does not
   call it. Deleted docs still appear in results. This is acceptance-criterion #3.
2. **Bulk import** — the import path in `store/importer.py` bypasses `Document.save()`,
   so imported docs are never embedded. (This later became bug KMS-0043.)
3. **Empty-corpus guard** — querying with zero indexed docs errors out.

## Where to resume

- Start in `search/vector_index.py:remove()` — HNSW soft-delete + periodic compaction.
- Then `store/importer.py` — route imports through the same upsert call as save.
- Then run `knowledge/validation/KMS-0042-search-relevance-eval.md` to confirm.

## Gotchas

- The index file is memory-mapped; `remove` must not run while a `query` is mid-flight
  — take the index write-lock (see `vector_index.py:_lock`).
- First run downloads the model (~130MB). CI caches it under `~/.cache/lorekeeper`.
