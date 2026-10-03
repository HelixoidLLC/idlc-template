# Knowledge-Capture Domain Events

> Domain: `capture`. Events emitted by this domain across its boundary. Consumers in
> other domains (e.g. `search`, `curation`) listen to these. No other domain emits
> events under the `capture.` namespace. Internal-only state changes are NOT listed —
> only events that cross a boundary.

| Event | Trigger | Payload | Consumed by |
|---|---|---|---|
| `capture.DocumentCreated` | A new document is saved for the first time | `document_id`, `workspace_id`, `doc_type` | search (index it), graph (extract entities) |
| `capture.DocumentUpdated` | An existing document's body changes | `document_id`, `changed_fields` | search (re-index) |
| `capture.DocumentDeleted` | A document is removed | `document_id` | search (remove from index), graph (prune entities) |
| `capture.DocumentSuperseded` | A document is replaced by a newer one | `document_id`, `superseded_by` | curation (update lineage) |
| `capture.DocumentsImported` | A bulk import completes | `document_ids[]`, `workspace_id` | search (index all — see bug KMS-0043) |

## Notes

- `capture.DocumentsImported` exists as a distinct event *because* the bulk path
  bypassing per-document indexing was the root cause of bug KMS-0043. Modeling the
  bulk event explicitly forces every consumer to handle it.
- Events are the contract. If `search` needs a new field to index, that is a change
  to the event payload here — negotiated, not silently read from `capture`'s internals.
