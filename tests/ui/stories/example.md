# Story: Example page loads

**URL:** https://example.com
**Session:** example

## Workflow

1. Load the page. Verify an `h1` heading is present and non-empty.
2. Verify the body contains at least one paragraph of text.
3. Verify the page contains a link.

## Expected

All three steps pass. A 4xx/5xx response, an empty body, or a missing heading is a
FAIL.

---

Copy this file to start a new story. Keep one flow per file, one assertion per step,
and always state the failure condition under `## Expected` — without it an agent will
rationalize a degraded page as a pass.
