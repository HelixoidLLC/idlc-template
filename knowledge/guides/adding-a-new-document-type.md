---
type: guide
audience: contributors
status: current
last_updated: 2026-07-14
tags: [guide, how-to, document-types, search]
---

# Guide: Adding a new document type to Lorekeeper

A "document type" (e.g. `note`, `decision`, `runbook`) controls how a document is
parsed, displayed, and indexed. This guide walks through adding one end to end.

## When to use this

Add a new type when a class of documents needs distinct front-matter fields or a
distinct rendering — not for a one-off. If two teams would model it differently,
it may belong in the ontology as a domain term first (see `ontology/`).

## Steps

1. **Register the type** in `store/doc_types.py`:
   ```python
   DOC_TYPES["runbook"] = DocType(
       name="runbook",
       required_fields=["title", "owner", "on_call"],
       icon="book",
   )
   ```
2. **Add a template** under `templates/runbook.md` so `lorekeeper new runbook` scaffolds it.
3. **Make it searchable** — confirm `Document.searchable_text()` includes the fields
   you care about. New body fields are indexed automatically; new front-matter fields
   are not unless you add them here.
4. **Add a card renderer** (optional) if the type needs a custom result card — see
   `ontology/reusable-assets/ux-components/document-card.md` for the base component.
5. **Test it**: `lorekeeper new runbook`, save, then search for a phrase in the body.

## Verification checklist

- [ ] `lorekeeper new runbook` produces a valid scaffold.
- [ ] The document is findable via keyword AND semantic search after save.
- [ ] The result card shows the right icon and excerpt.

## Related

- Architecture: `architecture/2026-07-10-knowledge-store-architecture.md`
- Search behavior: ticket `tickets/KMS-0042.md`
