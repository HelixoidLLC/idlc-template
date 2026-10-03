# Flow: Flaky Test Hunt

Find flaky tests, prove they are flaky (same test, pass AND fail, no code change), and diagnose root causes.

## Initial Response

If a suite scope or suspect test name was provided, target it. Otherwise default to the full backend suite (`{test-command}`) and mention that end-to-end and frontend suites can be included on request.

## Process

1. **Confirm clean working tree** (`git status --short`). Flakiness evidence is worthless if code changes between runs. If dirty, ask whether to proceed anyway and note it in the report.

2. **Spawn the qa-flaky-hunter agent** with the scope. It runs baseline + retries (`{test-command} --retries 2` surfaces tests that only pass on retry), stress loops on suspects, and serial-vs-parallel comparison, then classifies root causes (timing, shared state, filesystem, ports, production races, external deps).

3. **Triage the findings**:
   - **Production races** are bugs, not test hygiene — surface these first and recommend a ticket per race.
   - **Confirmed flaky tests**: present each with evidence tallies and the proposed stabilization. Do NOT apply fixes in this flow; flaky-test fixes deserve their own reviewed change.
   - **Consistently failing tests** are out of scope — note them for normal debugging.

4. **Write the report** to `knowledge/artifacts/YYYY-MM-DD-flaky-report.md`:
   - environment (machine, test-runner version, iteration counts)
   - confirmed flaky: test | evidence | root-cause class | proposed fix
   - production races found
   - suites that survived N repetitions clean (absence of flakes is also evidence)

5. **Offer follow-ups**: create tickets for production races (a new ticket under `knowledge/tickets/`), or implement a specific stabilization as a normal change with review.

## Important Notes

- One failure is not flakiness. Require pass+fail evidence on identical code.
- Common suspect classes: file-descriptor limits (raise the ulimit if your DB/store opens many files), a fixed dev-server port colliding across parallel runs, stale daemon socket/PID files in your app state directory, database lock contention under parallel test execution.
- Long stress loops are expensive — cap at ~10 iterations per suspect unless the user asks for more.
