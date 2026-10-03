# Bug Report: Bulk-imported documents are missing from semantic search

**Date**: 2026-07-19
**Severity**: High
**Status**: Fixed
**Component**: Search indexer (`store/importer.py`, `search/vector_index.py`)
**Ticket**: KMS-0043 (blocks KMS-0042 sign-off)

## Description

After importing a folder of documents via `lorekeeper import ./docs`, the imported
documents appear in keyword search but not in semantic search. They only become
findable after a manual full index rebuild.

## Reproduction

1. Start with an empty knowledge base.
2. Run `lorekeeper import ./sample-docs` (50 markdown files).
3. Search semantically for a phrase that only appears conceptually in an imported doc.
4. **Expected**: the imported doc appears in results.
5. **Actual**: no imported docs appear until `lorekeeper index rebuild` is run.

## Root cause

The import path writes files and updates the FTS5 keyword index directly, but it
**bypasses `Document.save()`** — which is the only code path that calls
`vector_index.upsert()`. So imported documents are never embedded.

```python
# store/importer.py (before)
for path in paths:
    doc = Document.from_file(path)
    keyword_index.add(doc)      # keyword index updated...
    # ...but vector_index.upsert(doc) was never called
```

## Impact

- Any user who imports (rather than creates) documents gets silently incomplete
  semantic search — the worst kind of failure: it looks like it works.
- Blocks KMS-0042 acceptance criterion "deleting/adding a document is reflected".

## Fix

Route the import path through the same indexing call as save. Extract a single
`index_document(doc)` helper used by both `Document.save()` and the importer, so the
two paths cannot drift again.

```python
# store/indexing.py (after)
def index_document(doc: Document) -> None:
    keyword_index.add(doc)
    vector_index.upsert(doc.id, embedder.embed(doc.searchable_text()))
```

## Verification

- Added an integration test: import 50 docs, assert all 50 are semantically findable
  with no manual rebuild.
- Re-ran the KMS-0042 relevance eval on an imported corpus — passes.

## Prevention

- Single indexing entry point (`index_document`) removes the drift class entirely.
- Review note added to the KMS-0042 review as a resolved blocker.
