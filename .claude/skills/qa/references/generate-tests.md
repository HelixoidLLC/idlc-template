# Flow: Generate and Run Tests

Turn an approved test plan into running tests, using separate generator and adversarial agents, and verify the result honestly.

Reasoning-heavy flow: honest verification and bug triage reward careful judgment.

## Initial Response

If a test-plan artifact path was provided (e.g. `knowledge/artifacts/PROJ-1234-test-plan.md`), read it FULLY and proceed. If a ticket/component was provided but no test plan exists yet, tell the user to run `/qa plan` first — generating tests without a spec-first plan produces tests that mirror the implementation. Only with explicit user consent may you skip the plan (and then note this in the final report).

## Process

1. **Read the test plan FULLY.** Identify:
   - requirement groups mapped to standard tests (unit/integration/snapshot/frontend)
   - edge classes suited to the adversarial pass
   - blocked items (missing seams) — skip these, they need human decisions

2. **Spawn agents** (in parallel when target files don't overlap; sequentially otherwise to avoid edit conflicts):
   - **qa-test-generator** — with the plan's test matrix, target locations, and the requirement list. It writes conventional tests and runs them.
   - **qa-adversarial-tester** — with the plan's edge classes and the components' input surfaces. It writes falsification tests.

3. **Verify the agents' claims yourself**:

   ```bash
   {test-command}
   cd {frontend-dir} && {frontend-test-command}   # if frontend tests were added
   ```

   Also run `{format-check-command}` and `{lint-command}` on touched packages — new tests must not break the pre-push gate.

4. **Handle findings by category** (report, don't fix production code):
   - **Spec mismatches / bugs found**: these are the safety net WORKING. Present each with its reproduction. Ask the user whether to file a ticket, fix now, or accept the skipped, known-bug-marked failing test as tracked.
   - **Blocked requirements**: list the missing seams verbatim.

5. **Update the test-plan artifact's `## Status` section**: mark each requirement `covered` (with test name), `blocked`, or `bug-found`.

6. **Write a test report** to `knowledge/artifacts/PROJ-XXXX-test-report.md` (or dated filename without ticket):
   - tests added (file -> names -> requirement covered)
   - full-suite result you verified yourself (exact command + pass/fail counts)
   - bugs found with reproductions
   - assumptions that survived adversarial attack
   - remaining gaps

7. **Save to the ticket folder (if ticket ID available)** — best effort, continue on failure. Copy the test report under the ticket's directory:
   ```bash
   cp knowledge/artifacts/PROJ-XXXX-test-report.md knowledge/tickets/<TICKET_ID>/test-report.md
   ```

## Important Guidelines

- **Never weaken an assertion to go green.** A failing spec-derived test is signal.
- **Never let agents modify production code.** If a generator did anyway, revert that hunk and report it.
- Integrity rule applies fully: report actual run output, not assumed results.
- If the full suite was already red BEFORE this flow touched anything, stop and report that first — don't build on a broken baseline.
