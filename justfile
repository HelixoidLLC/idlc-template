# ─── Shared defaults ─────────────────────────────────────────
# Override any of these on the command line, e.g.
#   just browse prompt="open https://example.com and list the headings"

default_prompt := "Open https://example.com, describe the page structure, and report the main heading text."

default_story := "tests/ui/stories/example.md"

stories_glob := "tests/ui/stories/*.md"

# List available commands
default:
    @just --list

# ─── Layer 1: Skill (capability) ─────────────────────────────

# Browser automation via the browser-automation skill, in the current session
browse prompt=default_prompt headed="false":
    claude --dangerously-skip-permissions --model opus "/browser-automation (headed: {{headed}}) {{prompt}}"

# ─── Layer 2: Subagent (scale, isolated context) ─────────────

# Same task, but in a subagent with its own context window — parallelizable
browse-agent prompt=default_prompt headed="false":
    claude --dangerously-skip-permissions --model opus "Use a @browser-agent to do this: (headed: {{headed}}) {{prompt}}"

# ─── Layer 3: Orchestration (workflows) ──────────────────────

# Validate one user story file and report per-step PASS/FAIL with screenshots
ui-story story=default_story headed="false":
    claude --dangerously-skip-permissions --model opus "Use a @ui-validation-agent to execute the user story in {{story}}. (headed: {{headed}})"

# Validate every user story, one subagent per story, in parallel
ui-review stories=stories_glob headed="false":
    claude --dangerously-skip-permissions --model opus "For each user story file matching {{stories}}, spawn a @ui-validation-agent in parallel. (headed: {{headed}}) Collect every verdict into a single summary table."

# ─── Housekeeping ────────────────────────────────────────────

# Verify every skill and agent referenced by this justfile actually exists
doctor:
    #!/usr/bin/env bash
    set -uo pipefail
    status=0
    # Skills: a slash command opening a quoted prompt, e.g. "/playwright-cli ...
    for skill in $(grep -oE '"/[a-z0-9-]+' justfile | sed 's|^"/||' | sort -u); do
      if [ -f ".claude/skills/$skill/SKILL.md" ]; then
        echo "  ok    skill  $skill"
      else
        echo "  MISS  skill  $skill (.claude/skills/$skill/SKILL.md)"; status=1
      fi
    done
    # Agents: @-prefixed names ending in -agent, e.g. @browser-agent
    for agent in $(grep -oE '@[a-z0-9-]+-agent' justfile | tr -d '@' | sort -u); do
      if [ -f ".claude/agents/$agent.md" ]; then
        echo "  ok    agent  $agent"
      else
        echo "  MISS  agent  $agent (.claude/agents/$agent.md)"; status=1
      fi
    done
    if [ $status -eq 0 ]; then echo "all justfile references resolve"; else echo "dangling references found"; fi
    exit $status

# Delete UI validation run output
clean-runs:
    rm -rf tests/ui/runs/*
