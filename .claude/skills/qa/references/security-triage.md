# Flow: Security Scan and Triage

A two-stage security pass: deterministic tools DETECT, a read-only agent CLASSIFIES. Never let the model be the scanner.

## Process

### Stage 1: Run scanners (deterministic, outside the model)

Create an output directory in the scratchpad (or `/tmp/qa-security/`). Run every available scanner; for missing ones, record "not run" — absence of a scanner is a coverage gap, not a clean result.

```bash
OUT=<scratchpad>/qa-security && mkdir -p "$OUT"

# Backend dependency advisories
{dependency-audit-command} --version >/dev/null 2>&1 \
  && (cd {backend-dir} && {dependency-audit-command} > "$OUT/dependency-audit.json" 2>&1 || true) \
  || echo "dependency-audit tool NOT INSTALLED (installing your dependency-audit tool)" | tee "$OUT/dependency-audit.SKIPPED"

# Secret leakage (full repo history is expensive; default to working tree + staged)
{secret-scan-command} >/dev/null 2>&1 \
  && ({secret-scan-command} > "$OUT/secret-scan.json" 2>&1 || true) \
  || echo "secret-scanner NOT INSTALLED (installing your secret-scanner)" | tee "$OUT/secret-scan.SKIPPED"

# Frontend dependency advisories
(cd {frontend-dir} && {dependency-audit-command} > "$OUT/frontend-audit.json" 2>&1 || true)

# Linter with security-relevant/panic lints (always available)
{lint-command} 2> "$OUT/lint-panics.txt" || true
```

Also capture the diff context under review: `git diff main...HEAD > "$OUT/diff.patch"` (or working-tree diff if no branch).

### Stage 2: Triage (model, read-only)

Spawn the **qa-security-triager** agent with the output directory path and diff context. It deduplicates, buckets findings (merge blocker / investigate / false positive / defer), assesses exploitability against this repo's trust boundaries (daemon HTTP, LLM output parsing, user-writable ticket files), and lists what NO scanner covered.

### Stage 3: Report and act

1. Present the triage summary: blockers first, then the "not covered" list.
2. Write the report to `knowledge/artifacts/YYYY-MM-DD-security-triage.md` (prefix `<TICKET_ID>-` if for a ticket), including which scanners ran, versions, and which were SKIPPED.
3. **If any confirmed merge blocker exists, say plainly: do not merge until resolved.**
4. Best-effort ticket attach if a ticket ID was provided: save the report under `knowledge/tickets/<TICKET_ID>/` so it lives alongside the ticket.

## Important Notes

- Findings on your linter's panic/unwrap lints matter most where input is untrusted (handlers, parsers); the triager weighs this — don't pre-filter its input.
- Never paste discovered secrets into the report — reference file:line and the secret's type only.
- If ALL scanners are missing, stop after reporting how to install them (`{install-qa-tools-command}` covers the backend ones); a triage over zero scanner output is theater.
