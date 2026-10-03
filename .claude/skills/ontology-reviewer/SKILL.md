---
disable-model-invocation: true
name: ontology-reviewer
description: Audit the project's existing ontology/glossary against the IDLC Knowledge Architecture Policy, producing a coverage table and prioritized findings. Use when the user wants to review, check, or validate domain vocabulary for gaps, inconsistencies, missing mappings, or misalignment with architecture domains. Reports honestly and stops if no ontology exists rather than fabricating findings.
---

# Ontology Reviewer v3

Audit the project's ontology against the IDLC Knowledge Architecture Policy.

> Policy reference: `design_idlc_brainstorming/ontology/IDLC_Knowledge_Architecture_Policy.md`

---

## Before you start

Determine the current state:

```bash
Glob: "knowledge/ontology/**/*.md"
Glob: "knowledge/architecture/domains/**/README.md"
Glob: "knowledge/architecture/domains/**/boundaries.md"
Glob: "knowledge/ontology/mappings/*.md"
```

Identify which maturity level the ontology is at:

| Level | Structure |
|---|---|
| 0 | `ontology/glossary.md` — flat file, all domains |
| 1 | `ontology/{domain}.md` — one file per domain |
| 2 | Level 1 + `ontology/mappings/{a}--{b}.md` |
| 3 | `ontology/domains/{domain}/glossary/{term}.md` |

If there is no ontology at all, report that and stop. Do not fabricate findings.

---

## Step 1 — Inventory

List every domain found in:
- `knowledge/architecture/domains/`
- `knowledge/ontology/domains/` (or equivalent per the current level)

For each domain, note:
- Number of terms documented
- Whether a matching entry exists in both `architecture/` and `ontology/`
- Whether any mappings exist for that domain

This produces a coverage table:

```
| Domain | Arch folder | Ontology folder | Term count | Mappings |
|--------|-------------|-----------------|------------|---------|
```

---

## Step 2 — Term Audit

For each term in the ontology, check all of the following. Report findings per term.

### 2a. Domain qualification

Every term must use a domain-qualified ID: `billing.customer`, not `customer`.

**Check**: Does the `id` field (or the `## {header}` at Level 0) include the domain prefix?

If not: flag as **MISSING DOMAIN QUALIFIER** — this must be fixed before the project grows beyond Level 0 or retrofitting becomes expensive.

### 2b. Required fields

Minimum required fields at any level:

- `id` — domain-qualified (`{domain}.{term}`)
- `context` — the owning domain
- `preferred_label` — human-readable label
- `owner` — team responsible for this definition

Flag any term missing one or more required fields as **INCOMPLETE SCHEMA**.

At Level 2+, also check that `status` is present and set to one of: `active`, `deprecated`, `proposed`.

### 2c. "Not this" section

Every term must have an explicit "Not this" (or equivalent negative definition) — at least one exclusion linking to a related term that people might confuse it with.

**Check**: Does the term body contain a sentence that starts with "Not the same as", "Not this", or an equivalent negative statement?

If not: flag as **MISSING EXCLUSION**. This is the second most important check after domain qualification. A definition without an exclusion is ambiguous by default.

### 2d. Implementation details

The following must not appear in ontology:

- Function names, method signatures, column names, internal variable names
- Processing states that never cross a domain boundary (`ProcessingInQueue`, `AwaitingRetry`)
- Obvious structural things a developer would not misunderstand (`UserRepository`, `Logger`, `Config`)
- Anything behind a feature flag or in an A/B test — those belong in `product/experiments/`

**Test**: Would a different team or an agent misunderstand or duplicate this concept without the ontology entry? If the answer is no, the entry does not belong.

Flag as **IMPLEMENTATION DETAIL — REMOVE** with a suggested destination (code comment, `product/experiments/`, or simply delete).

### 2e. Experimental content

Flag any term with `status: proposed` or whose definition references an unimplemented feature as **EXPERIMENTAL — NOT READY**. These should not appear in active catalogs until the concept is committed.

---

## Step 3 — Collision Scan

Search for the same natural-language label appearing under different domains:

```bash
Grep: "preferred_label: {Label}" in knowledge/ontology/
Grep: "## {Label}" in knowledge/ontology/
```

For each collision found:

1. Confirm the two definitions are genuinely different (different domain, different meaning). If they are identical, that is duplication — propose merging.
2. If they are legitimately different, check whether a mapping file exists at `knowledge/ontology/mappings/{domain-a}--{domain-b}.md`.
3. Check whether both terms have a `maps_to` field pointing at each other.

Flag as **UNDOCUMENTED COLLISION** if same label, different domains, no mapping file.
Flag as **MISSING MAPS_TO** if mapping file exists but the individual term files lack the `maps_to` field.
Flag as **DUPLICATE DEFINITION** if same label, same meaning, two domains — propose merging under the owning domain.

---

## Step 4 — Symmetry Check

The symmetry rule: every domain in `architecture/domains/` must have a counterpart in `ontology/domains/` and vice versa.

For each domain in the inventory table from Step 1:

- **Architecture without ontology**: domain boundary is defined but vocabulary is undefined. Risk: agents working in this domain have no terms to retrieve. Flag as **MISSING ONTOLOGY FOR DOMAIN**.
- **Ontology without architecture**: vocabulary is defined but no structural boundary exists. Risk: terms float without ownership. Flag as **MISSING ARCHITECTURE FOR DOMAIN**.

These are structural integrity issues, not style issues.

---

## Step 5 — Drift Detection

Look for the following drift signals:

### Stale terms

A term is stale if:
- `status: active` but no code, port, or component references it
- The `used_by` field is empty or points to a component that no longer exists

```bash
Grep: "billing.customer" in src/
Grep: "billing.customer" in knowledge/architecture/
```

If the term appears in no active reference: flag as **STALE TERM — VERIFY RELEVANCE**.

### Shadow terms

A shadow term is an informal definition that has spread through code, docs, or Slack without being recorded in the ontology. Look for:

```bash
Grep: "Customer|Invoice|Order|Account" (capitalized nouns) in docs/ src/ knowledge/
```

Compare against the term index. If a concept is used consistently in multiple files but is not in the ontology, flag as **UNDOCUMENTED CONCEPT — CANDIDATE FOR ADDITION**.

### Deprecated terms not marked

Terms that appear in code but also appear in the glossary without a `status: deprecated` and `superseded_by` field:

```bash
Grep: "superseded_by|deprecated" in knowledge/ontology/
```

If a term is known to be replaced but is still marked `active`, flag as **DEPRECATED WITHOUT MARKING**.

### Diverged mappings

A mapping file says `closeMatch` but the definitions have since diverged significantly, or one of the two terms has changed without the mapping being updated. Spot-check: read the two term definitions referenced in each mapping and compare them against the stated relation type. Flag as **STALE MAPPING — VERIFY RELATION**.

---

## Step 6 — Maturity Assessment

Given the findings from Steps 1–5, assess whether the current level is still appropriate.

**Recommend upgrade when:**

| Current level | Upgrade trigger |
|---|---|
| Level 0 → 1 | More than one domain with more than 5 terms each, or more than one team |
| Level 1 → 2 | Same label in two or more domains, or teams are actively arguing about a shared word |
| Level 2 → 3 | Any domain with more than 20 terms, or terms need individual change history |

**Recommend not upgrading when:**

- The project is early-stage and ontology coverage is low — adding structure before terms exist adds overhead with no value.
- The upgrade trigger condition is not yet met.

Do not recommend a level jump beyond one step at a time. Jumping from Level 0 to Level 3 because the project is ambitious produces a structure nobody populates.

---

## Output

Produce findings grouped by severity:

### Critical (block merging / break agent retrieval)

- Missing domain qualifiers
- Undocumented collisions across domains
- Domains existing in architecture but not in ontology (or vice versa)

### Major (degrade vocabulary quality)

- Missing "Not this" exclusions
- Incomplete schema (missing required fields)
- Duplicate definitions that should be merged

### Minor (maintenance hygiene)

- Stale terms with no active references
- Deprecated terms not marked
- Shadow terms that should be added
- Stale mapping relation types

### Recommendations

- Maturity level upgrade/downgrade recommendation with trigger condition
- Specific terms to add based on undocumented concept scan
- Specific mappings to create based on collision scan

### Summary table

```
| Finding type | Count | Severity |
|---|---|---|
```

For each finding, include:
- File and line (or section) where the issue exists
- The specific problem
- The recommended fix — not just the problem

Do not summarize what you found without telling the person what to do about it.
