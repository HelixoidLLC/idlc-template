# User Journey: A researcher looks for prior work

- id: journey.researcher-finds-prior-work
- status: active
- persona: product/personas/knowledge-curator.md
- related_prd: product/prds/semantic-search.md

## Goal

Priya, a researcher, wants to check whether the team has already investigated a
question before she spends a day on it.

## The journey (what actually happens today)

1. Priya is assigned "improve new-hire onboarding". She suspects someone looked at
   this before.
2. She opens Lorekeeper and searches **"onboarding"**. Two results, both about
   *customer* onboarding, not employees.
3. She tries **"new hire"** — nothing. The relevant doc is titled "Ramp-up notes"
   and never uses the word "onboarding".
4. Frustrated, she asks in the team channel. Someone eventually links the doc — two
   hours later.
5. She reads it, realizes half her planned work is already done, and adjusts scope.
6. **Emotional arc**: hopeful → frustrated (search failed) → resigned (had to ask a
   human) → relieved (the doc existed all along).

## Where it breaks

- Step 3 is the failure point. The knowledge *existed* and was *unfindable*. The tool
  silently implied "no prior work" when the truth was "prior work, different words".

## What good looks like

- Step 2 returns "Ramp-up notes" directly, because search understands that
  "onboarding" and "ramp-up" are the same concept. Steps 3–4 disappear.

## Note

This is a journey, not a spec. It describes what Priya *experiences* — the friction
and the wrong turns. The requirements that fix it live in
`product/prds/semantic-search.md`; the implementation in `tickets/KMS-0042.md`.
