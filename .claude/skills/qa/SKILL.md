---
disable-model-invocation: true
name: qa
description: >-
  QA safety net - test planning, test generation, coverage, flaky hunt, security
  triage, and release gating; run one flow or the full pipeline
metadata:
  requires-subagents: true
---

# QA Suite

You are the entry point to the QA safety net: a layered system where the model proposes (plans, tests, triage) and deterministic tools decide (test runner, linter, scanners, human gates).

## Context discipline

Each flow's full instructions live in `references/` next to this file. Load **only** the file for the requested flow, using the **Read tool** — never the Skill tool, and never preload reference files you are not about to execute. The point: every interaction carries the minimum context — this router plus exactly one flow. In the full pipeline, read each stage's file at the start of that stage, not before.

## Routing

Parse the argument and route:

| Input looks like               | Flow                      | Read, then follow exactly       |
| ------------------------------ | ------------------------- | ------------------------------- |
| `plan <ticket/plan/component>` | Spec-first test plan      | `references/test-plan.md`       |
| `tests <test-plan artifact>`   | Generate + run tests      | `references/generate-tests.md`  |
| `coverage [scope]`             | Risk-ranked coverage gaps | `references/coverage.md`        |
| `flaky [scope]`                | Flaky-test hunt           | `references/flaky.md`           |
| `security`                     | Scanner run + triage      | `references/security-triage.md` |
| `gate [ticket/branch]`         | Go/no-go release gate     | `references/release-check.md`   |
| `full <ticket>`                | Full pipeline             | see below                       |
| nothing / unclear              | —                         | show the menu below and wait    |

Natural-language requests map the same way: "are these tests flaky?" → flaky; "is this safe to merge?" → gate; "what's untested?" → coverage.

**Menu (when invoked bare):**

```
QA safety net - what do you need?

- /qa plan <ticket|plan|component>  - spec-first test plan (start here)
- /qa tests <test-plan.md>          - generate + run tests from a plan
- /qa coverage [scope]              - risk-ranked coverage gaps
- /qa flaky [scope]                 - hunt flaky tests
- /qa security                      - scan + triage security findings
- /qa gate [ticket|branch]          - evidence-based go/no-go review
- /qa full <ticket>                 - full pipeline for a ticket

Pipeline order for a ticket: plan -> tests -> coverage -> security -> gate.
```

## Full Pipeline (`/qa full PROJ-XXXX`)

Run the stages in order, pausing between stages when a stage surfaces decisions. At the start of each stage, read that stage's reference file and follow it; drop earlier stages' instructions from consideration once their artifact is written.

1. **Plan** — `references/test-plan.md` on the ticket. STOP and confirm open questions with the user before continuing; everything downstream inherits the plan's assumptions.
2. **Tests** — `references/generate-tests.md` on the produced plan. If bugs are found, pause: the user decides fix-now vs ticket vs tracked known-bug before gating makes sense.
3. **Coverage** — `references/coverage.md` scoped to the ticket's touched components. Advisory; feeds gaps back into the plan's Status section.
4. **Security** — `references/security-triage.md`. Merge blockers stop the pipeline.
5. **Gate** — `references/release-check.md`. Present the verdict; the human acts on it.

Track pipeline progress with TodoWrite. Each stage writes its own artifact to `knowledge/artifacts/` and best-effort attaches it to the ticket, so a partially completed pipeline is resumable — check which artifacts already exist before rerunning a stage.

## Principles (apply in every flow)

- **Spec-first**: tests derive from requirements, never from implementation habits.
- **Separation of powers**: the agent that writes code never certifies it; generation, adversarial attack, and gating are different agents with different tool scopes.
- **Evidence or unknown**: no claim without command output or a quote; missing evidence is `unknown`, not `pass`.
- **Deterministic tools decide**: the test runner, linter, formatter, and scanners are the authority; the model's job is planning, classification, and prioritization.
- **A found bug is a success** of the safety net — report it prominently, never paper over it.
