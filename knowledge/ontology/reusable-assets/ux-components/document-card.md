---
id: ux.document-card
kind: ux-component
status: active
owner: design-system-team
used_by:
  - capture.document
  - search.result
---

# DocumentCard

A display component for rendering a summary of a single document — used in search
results, the workspace list, and "related documents" panels.

## Props

| Prop | Type | Required | Description |
|---|---|---|---|
| `document_id` | string | yes | Stable identifier |
| `title` | string | yes | Document title |
| `doc_type` | DocType | yes | note / decision / runbook / research / … |
| `excerpt` | string | no | One-line snippet; the matched passage when shown in search |
| `updated_at` | date | no | Shown as relative time ("3 days ago") |
| `relevance_score` | number | no | Only passed in search context; renders a subtle bar |

## What this component does NOT own

It *renders* a document summary. It does not define what a document is — that lives in
`ontology/domains/knowledge-capture/glossary.md` (`capture.document`). It also does
not decide ranking; `relevance_score` is computed by the `search` domain and passed in.

## Usage

- Search results list (`search.result`)
- Workspace document list (`capture.document`)
- "Related documents" panel (future, entity graph)

Do not fork this component per surface. If a surface needs a different layout, add a
`variant` prop rather than duplicating the card — duplication is how two teams end up
with two subtly different ideas of what a document card is.
