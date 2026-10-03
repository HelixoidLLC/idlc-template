# Flow: Coverage Gap Analysis

Produce a risk-ranked coverage gap report: which untested code paths matter most, not just a percentage.

## Initial Response

If a scope was provided (package, directory, or ticket), use it. Otherwise default to the full `{backend-dir}` workspace plus `{frontend-dir}/src/` and say so.

## Process

1. **Check tooling** (determines measurement quality):

   ```bash
   {coverage-command} --version 2>/dev/null || echo "NOT INSTALLED"
   ```

   If not installed, inform the user: instrumented coverage needs installing your coverage tool (or `{install-qa-tools-command}`); you'll proceed with structural approximation meanwhile.

2. **Spawn the qa-coverage-analyzer agent** with the scope and tool availability. It runs measurement (or structural analysis), risk-weights gaps by blast radius, input trust, change frequency, and unexercised error paths.

3. **Sanity-check the result**: pick 2-3 of the top-ranked gaps and confirm by reading the cited file that the claimed surface really has no tests. Analyzer output goes in the report only after this spot check.

4. **Write the report** to `knowledge/artifacts/YYYY-MM-DD-coverage-report.md` (prefix with `PROJ-XXXX-` when run for a ticket):
   - measurement method (instrumented vs approximation — never blur this)
   - overall numbers if measured
   - risk-ranked gap table
   - hot-but-untested files
   - explicit "not worth testing now" list with reasons

5. **Recommend next actions**: typically `/qa plan <top-gap component>` for the highest-risk gaps. Do not auto-generate tests from a coverage report — coverage says WHERE, the spec says WHAT.

6. **Attach to ticket (if ticket ID provided)** — best effort: save the report under `knowledge/tickets/<TICKET_ID>/` so it is linked to the ticket.

## Important Notes

- Coverage percentage is a diagnostic, not a target. Chasing a number produces assertion-free tests that execute code without verifying it.
- If coverage tooling reveals the suite doesn't even compile or run, that's the finding — report it and stop.
