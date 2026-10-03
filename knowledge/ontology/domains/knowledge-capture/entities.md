# Knowledge-Capture Entities

> Domain: `capture`. The persistent entities this domain owns and their key
> attributes. Attributes documented here are the *domain-meaningful* ones — not
> every database column. Internal implementation fields stay in code.

## Document

| Attribute | Meaning |
|---|---|
| `id` | Stable identifier, never reused |
| `title` | Human-facing name |
| `doc_type` | One of: note, decision, runbook, research, … |
| `body` | Markdown content — the source of truth |
| `tags` | Author-assigned `capture.tag` labels |
| `created_at` / `updated_at` | Lifecycle timestamps |

Lifecycle: `draft → published → (archived | superseded)`. A superseded document is
never deleted — it links forward to the document that replaced it.

## Workspace

| Attribute | Meaning |
|---|---|
| `id` | Workspace identifier |
| `root_path` | On-disk location of the document files |
| `doc_count` | Denormalized count for display |

A Workspace owns Documents. Documents cannot exist outside a Workspace. Deleting a
Workspace tombstones its Documents; it does not silently drop the files.

## Tag

| Attribute | Meaning |
|---|---|
| `name` | The label text (unique within a workspace) |
| `doc_count` | How many documents carry it |

## What is NOT modeled here

- `search.embedding` and `search.vector-index` — those are `search` domain entities,
  even though they are *derived from* a Document. Ownership follows the domain that
  produces the meaning, not the data lineage.
