# Flow: Release Gate Review

An evidence-based gate review. The output is `go`, `no_go`, or `unknown` — and `unknown` is a legitimate, common answer. Green tests alone are not sufficient; missing evidence is never implicit approval.

Reasoning-heavy flow: weighing evidence honestly rewards careful judgment — this is the one flow that must never be optimistic.

## Initial Response

If a ticket ID, branch, or change description was provided, scope to it. Otherwise gate the current working tree / branch against main and say so.

## Process

1. **Assemble the evidence already available in this session/conversation**: test reports, coverage reports, security triage artifacts (check `knowledge/artifacts/` for this ticket), plan checkboxes, prior command outputs. List what exists and what's missing.

2. **Spawn the qa-gatekeeper agent** with:
   - the scope (ticket ID / branch / diff)
   - paths to every evidence artifact found
   - explicit note of which checks it should re-verify fresh vs reuse

   The gatekeeper runs verification commands (format check, lint, tests, ticket state), builds the evidence table, and returns a verdict with blockers.

3. **Review the verdict yourself**:
   - Confirm every `no_go` blocker cites concrete evidence
   - Confirm nothing in the `go` path relies on "reported but unverified" claims
   - Manual verification items require explicit human confirmation — if the user hasn't confirmed them in this conversation, they are UNCONFIRMED regardless of what any document claims

4. **Present the gate review** with the decision up front, blockers, the evidence table, and exactly what would move `unknown` → `go`.

5. **Write the review** by saving the artifact under `knowledge/tickets/<TICKET_ID>/` (e.g. `knowledge/tickets/<TICKET_ID>/gate-review.md`, or a dated filename).

6. **On `go` with a ticket in `code-review`**: remind the user the terminal status move is theirs — update the ticket's status to `done` in its file under `knowledge/tickets/<TICKET_ID>/`. Do NOT move the ticket or merge yourself — this flow recommends; humans decide.

## Important Notes

- When torn between `go` and `unknown`, the answer is `unknown`.
- If the user pushes back on a blocker, re-verify it rather than argue — fresh command output settles it either way.
- A gate review older than the latest code change is stale; rerun, don't reuse.
