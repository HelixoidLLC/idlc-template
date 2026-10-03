---
id: governance.policy
status: active
owner: knowledge-platform-team
tags: [governance, policy, ontology, conventions]
last_updated: 2026-07-17
---

# Governance

The rules that keep the other knowledge layers from drifting. Governance is applied
*across* Product, Ontology, Architecture, and Workflows — it is not a fifth pile of
documents so much as the conventions that hold the other four together.

## Naming conventions

- Dated artifacts: `YYYY-MM-DD-{TICKET}-{slug}.md`.
- Tickets: `{PREFIX}-{####}.md` (this project: `KMS`).
- Ontology term ids are always domain-qualified: `capture.document`, never `document`.

## Domain ownership

- Every domain exists in **both** `architecture/domains/{domain}/` and
  `ontology/domains/{domain}/` — the symmetry rule. A domain in one but not the other
  is a defect: undefined meaning or unbounded structure.
- Each domain has one owning team, recorded in the `owner:` field of its glossary terms.

## Term lifecycle

`proposed → active → deprecated → superseded`. A term is never deleted once it has been
`active`; it is marked `deprecated` and, if replaced, carries `superseded_by`.
Experiments and feature-flagged concepts stay in `product/experiments/` and are
promoted to an `active` term only once committed.

## What agents may and may not do

- Agents **may** add `proposed` terms and draft ADRs.
- Agents **must not** silently change an `active` term's meaning — that requires an ADR
  and the owning team's review (the `/ontology_reviewer` cycle).
- Agents **must** load relevant domain context before acting and update it after
  (enforced by the rules file / `CLAUDE.md`).

## Review cadence

- `/ontology_builder` adds/extends terms; `/ontology_reviewer` audits for collisions
  and drift. Run them on the same cadence as feature development.
- Findings are severity-grouped: **Critical** (breaks retrieval / hides a collision —
  fix before merge), **Major** (fix before next release), **Minor** (batch on a cadence).

## What NOT to document

Implementation details, obvious structural classes (`Logger`, `Config`), transient
internal states, and spurious `exactMatch` mappings. The test: would a different team
or agent misunderstand or duplicate this without the entry? If not, leave it out.

---

*This is a living policy. Changes that touch the folder structure, term schema, or
link model require an ADR and go through the architecture-review workflow.*
