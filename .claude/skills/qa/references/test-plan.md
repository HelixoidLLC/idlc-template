# Flow: Spec-First Test Plan

Produce a spec-first test plan: what must be tested, derived from requirements — NOT from how the code happens to be implemented. This is the entry point of the QA safety net; the `tests` flow (`references/generate-tests.md`) consumes its output.

Reasoning-heavy flow: requirement extraction and edge-class enumeration reward careful, skeptical reading.

## Initial Response

If a ticket file, plan file, or component was provided as a parameter, read it FULLY and proceed. Otherwise respond with:

```
I'll create a spec-first test plan. Please provide one of:
- A ticket: `/qa plan knowledge/tickets/PROJ-1234.md`
- An implementation plan: `/qa plan knowledge/plans/2026-01-08-PROJ-1234-feature.md`
- A component: `/qa plan {backend-dir}/{package}/src/ticket/`
```

## Process

1. **Read all provided artifacts FULLY** (no limit/offset). Follow references to related research/plans in `knowledge/`.

2. **Spawn the qa-test-planner agent** with the artifact paths and any scope constraints the user gave. The planner extracts quote-backed requirements, invariants, edge classes, and a test matrix. It is read-only and will not peek at implementation to derive expected behavior.

3. **Review the returned plan critically**:
   - Every requirement must trace to a quote or be marked `(inferred)`
   - Open questions must stay open — do not resolve them by assuming
   - If the planner found existing coverage, verify a sample (read the test it cites)

4. **Present open questions to the user** before finalizing. A test plan with wrong assumptions produces confidently wrong tests.

5. **Write the plan** to `knowledge/artifacts/PROJ-XXXX-test-plan.md` (or `knowledge/artifacts/YYYY-MM-DD-<topic>-test-plan.md` when no ticket). Include:
   - the planner's full output (evidence table, invariants, edge classes, test matrix, existing coverage)
   - a `## Status` section listing each requirement as `planned | covered | blocked`

6. **Attach to ticket (if ticket ID available)** — best effort, continue on failure: save the test-plan artifact under `knowledge/tickets/<TICKET_ID>/` (e.g. copy or reference `knowledge/artifacts/PROJ-XXXX-test-plan.md` there).

7. **Present a summary**: requirement count, top-risk edge classes, open questions, and the suggested next step (`/qa tests knowledge/artifacts/PROJ-XXXX-test-plan.md`).

## Important Notes

- Do NOT write any tests in this flow — planning and generation are deliberately separate passes so the plan can be reviewed before code exists.
- If the spec is too thin to plan from (no acceptance criteria, vague ticket), say so and list exactly what's missing rather than padding the plan with invented requirements.
- Keep the plan artifact self-contained: someone should be able to implement tests from it without rereading the ticket.
