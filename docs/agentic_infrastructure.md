# The Infrastructure Layer: Running Agentic Coding at Scale

By Igor Moochnick

---

*This document covers the infrastructure that makes the IDLC workflow reliable at scale: parallel execution, session isolation, permission control, and the careful use of autonomous mode. The workflow itself — the discipline, the knowledge store, the agentic cycle — is described in the [README](../README.md) and the `.claude/skills/` library.*

*The IDLC workflow describes what to do. This describes how to build the machine that does it.*

---

## 1. The Scaling Problem Nobody Talks About

The Agentic Cycle works. One agent, one ticket, one clean session. You load context, approve a plan, let it execute, verify the output, update knowledge, and reset. Reliable. Predictable.

Then you try to run two features at once.

The problems emerge immediately. Two agents editing the same files create conflicts. Switching branches invalidates each agent's mental model of the codebase. Running the same process in parallel on the same working directory is just asking for corruption. You end up serializing work that should be parallel, and the 3-5x speed advantage starts shrinking back toward 1x.

The solution is infrastructure. Specifically, three layers of infrastructure that the agentic workflow requires but rarely describes:

**Parallelism**: A mechanism for running multiple agents concurrently without interference.

**Isolation**: A mechanism for guaranteeing that each session starts from a clean, consistent state.

**Control**: A mechanism for defining exactly what agents are allowed to do, and enforcing those boundaries without manual approval for every action.

These are not optional enhancements. They are prerequisites for running agentic development at production scale. And they are all already in this repository.

---

## 2. Parallelism by Design: Git Worktrees as Agent Sandboxes

### The Wrong Solution

The naive approach to parallel AI development is to clone the repository multiple times. One clone per agent, one agent per feature. It works, in the same sense that using a screwdriver as a hammer works.

Clones duplicate the entire `.git` directory. They have no awareness of each other. Updates to the main branch require manual synchronization in each clone. They consume disproportionate disk space. And when you push from multiple clones, you create a coordination nightmare that the humans — not the agents — end up solving.

### The Right Solution

Git worktrees solve all of this. A worktree is a separate working directory attached to the same repository database. Multiple worktrees share a single `.git` history. Each has its own branch, its own files, its own agent. They are genuinely isolated for file operations but remain connected at the version control level.

The mental model: a single repository, multiple simultaneous working directories, each running an independent agent. The repository is the single source of truth. The worktrees are concurrent experiments.

### How create_worktree.sh Works

This repository includes `scripts/create_worktree.sh`, a script that automates the full setup of an agent-ready worktree.

```bash
./scripts/create_worktree.sh [worktree_name] [base_branch]
```

If you do not provide a name, it generates a human-readable one like `swift_fix_1430` — enough specificity to identify the branch at a glance, short enough not to be annoying.

What the script does, step by step:

**1. Creates the worktree on a new branch:**

```bash
git worktree add -b swift_fix_1430 ../worktrees/swift_fix_1430 main
```

The worktree lives at `../worktrees/{name}`, a sibling directory to the main repository. This separation is important: it keeps the main repository clean while giving agents a full working directory.

**2. Converts the `.git` reference to a relative path:**

Each worktree contains a `.git` file that points back to the main repository's `.git/worktrees/{name}` directory. By default, this is an absolute path, which breaks inside devcontainers where the host filesystem is mounted at a different path. The script rewrites it as a relative path:

```
gitdir: ../../{repo-name}/.git/worktrees/{name}
```

This makes worktrees portable across different host-to-container mount configurations — a detail that would bite you the first time you tried to open a worktree in a devcontainer.

**3. Copies `.claude` and `.mcp.json`:**

The agent needs its workflow configuration to function. The script copies both so each worktree has the full slash command library, agent definitions, and MCP server configuration available independently.

**4. Runs project setup:**

The script detects and runs the appropriate setup step — `.devcontainer/scripts/setup.sh`, or your project's dependency-install and build command — so the worktree is ready to run code immediately after creation.

### Setting Up the Worktrees Directory

Before using the script, create the sibling directory:

```bash
mkdir -p ../worktrees
```

Override the default location with `PROJECT_WORKTREE_BASE`:

```bash
export PROJECT_WORKTREE_BASE="/custom/path/to/worktrees"
./scripts/create_worktree.sh
```

### Launching Agents in Parallel

Once worktrees are created, each gets its own terminal and its own Claude Code session:

```bash
# Terminal 1 — Agent A working on the auth feature
cd ../worktrees/swift_fix_1430
claude

# Terminal 2 — Agent B working on the API layer
cd ../worktrees/bright_dev_1445
claude

# Terminal 3 — Agent C working on tests
cd ../worktrees/clean_test_1501
claude
```

Each agent sees its own branch. Each reads and writes its own files. Each has its own conversation context. They are, from a filesystem perspective, completely isolated. From a version control perspective, they all descend from the same commit, which means merging later is a clean git operation rather than a manual file reconciliation.

### The tmux Upgrade

For teams running multiple agents regularly, tmux combined with worktrees is the standard operational pattern. The devcontainer's `scripts/tmux-workspace.sh` sets up the workspace session automatically. You can extend this to create a named window per worktree:

```bash
tmux new-window -n "auth-agent" -c "../worktrees/swift_fix_1430"
tmux new-window -n "api-agent" -c "../worktrees/bright_dev_1445"
```

This gives you a single tmux session with one window per agent, each pinned to its worktree. Switching agents is `Ctrl+B` followed by the window number. Context switching cost drops to near zero.

### What to Run in Parallel

Not every feature should be parallelized. The cost of a merge conflict is not zero. Some heuristics:

**Good for parallel execution:**
- Features in clearly separate modules or packages
- Bug fixes that touch isolated files
- Test writing for completed features
- Documentation generation
- Performance investigations on specific components

**Keep sequential:**
- Changes to shared interfaces or core data models
- Refactors that cross module boundaries
- Any two tasks where one depends on the output of the other
- Infrastructure changes that affect build configuration

When in doubt: write the ticket first. If the ticket's scope can be described without mentioning files that another active ticket touches, it is safe to parallelize.

### Merging Back

When an agent finishes:

```bash
# In the main repository
git merge worktrees/swift_fix_1430

# Or via PR workflow
cd ../worktrees/swift_fix_1430
git push -u origin swift_fix_1430
# Then open PR from branch swift_fix_1430
```

Cleanup after merge:

```bash
git worktree remove ../worktrees/swift_fix_1430
git branch -D swift_fix_1430
```

The `create_worktree.sh` script prints these commands at the end of each run so you do not have to remember them.

---

## 3. Session Integrity: The Devcontainer as the AI's Laboratory

### Why Sessions Drift

A session that starts clean rarely stays that way.

Installed packages accumulate. Environment variables get set and forgotten. Test databases fill with state. Build artifacts from last week's experiment interfere with today's build. The longer a development environment runs without resetting, the more it diverges from what any specification assumes.

For human developers, this is manageable. We know what we changed. We remember installing that package. We can diagnose the drift.

Agents do not. An agent operating in a dirty environment makes decisions based on a filesystem that does not match its training or its CLAUDE.md. It will attempt to install packages that are already installed, or worse, miss packages that should not be there. It will encounter behavior that its plan did not account for, and instead of flagging it, it will adapt — silently introducing an assumption that will not be documented.

The fix is simple: make every session start from the same known state. The devcontainer in this repository does exactly that.

### The Devcontainer Anatomy

The `.devcontainer/` directory is not just a container configuration. It is a specification of the exact environment in which every agent session runs.

```
.devcontainer/
├── Dockerfile              # Exact tool versions, pinned
├── devcontainer.json       # Container behavior and VS Code integration
├── .env.example            # Template for authentication config
└── scripts/
    ├── setup.sh            # Post-create: runs once at container creation
    ├── post-setup.sh       # Post-attach: runs at each session start
    ├── setup-claude-auth.sh # One-time Claude OAuth setup
    └── tmux-workspace.sh   # Workspace initialization
```

The Dockerfile pins every tool version via a version manager (the shipped example uses Mise). Whatever runtimes and tools your project needs — a language toolchain, a package manager, a test runner — are pinned to exact versions. When the container rebuilds, it rebuilds to exactly those versions. When a new worktree opens in a new container, it opens to exactly those versions.

The specification of the environment is the environment.

### Claude Authentication: Set Once, Use Everywhere

The one configuration that must survive container rebuilds is Claude authentication. The devcontainer handles this by storing the OAuth token outside the repository, at `~/.config/dev-container/devcontainer.env`, and bind-mounting it read-only into each container.

First-time setup:

```bash
# Step 1: Get your OAuth token
claude setup-token

# Step 2: Run the setup script (prompts for the token)
.devcontainer/scripts/setup-claude-auth.sh

# Step 3: Rebuild the container
# VS Code: Cmd+Shift+P → "Dev Containers: Rebuild Container"
```

Or manually:

```bash
mkdir -p ~/.config/dev-container
echo 'CLAUDE_CODE_OAUTH_TOKEN=sk-ant-oat01-...' > ~/.config/dev-container/devcontainer.env
chmod 600 ~/.config/dev-container/devcontainer.env
```

The key property: this runs once on the host machine and then works in every container, in every worktree, forever until the token expires. Each worktree gets its own container but shares the same auth. This is what makes worktree-based parallelism practical at scale — there is no per-worktree authentication ceremony.

### Per-Worktree Authentication Overrides

If you need a different token for a specific worktree — a different API account, a restricted token for autonomous execution — the devcontainer supports local overrides:

```bash
cd .devcontainer
cp .env.example .env
# Edit .env with the worktree-specific CLAUDE_CODE_OAUTH_TOKEN
```

The local `.env` file is gitignored and takes precedence over the shared config. This is the mechanism for giving an autonomous agent a rate-limited or scope-restricted API key without affecting other sessions.

### Customizing for Your Stack

The devcontainer ships configured for an example stack (a language toolchain, Node, and a package manager). Your stack is different. Customize these files before using it:

**`Dockerfile`**: Remove language-specific system packages you do not need. The shipped example bundles desktop-GUI libraries for building GUI apps — cut them if you are building a server.

**`devcontainer.json`**: Update the `name` field from `{PROJECT_NAME}` to your actual project name. Remove VS Code extensions that do not apply to your language.

**Tool-version file** (in the repository root, e.g. `mise.toml`): Define the exact tool versions for your project. The version manager resolves everything else.

**`scripts/setup.sh`**: This is the post-create hook. It runs once after the container is built. This is where you install project-specific dependencies, run database migrations, seed development data, or anything else that your project needs to be in a runnable state.

The principle: if a developer joining your team needs to do it manually to get the project running, it belongs in `setup.sh` so the container does it automatically.

---

## 4. Trust but Verify: The Permission Architecture

### What Permissions Actually Control

When you run Claude Code without any configuration, every tool use — every file edit, every bash command, every web request — triggers a confirmation prompt. This is the safe default. It is also, at scale, unbearable.

The permission architecture exists to solve this. It lets you pre-authorize operations that are genuinely safe and pre-block operations that are genuinely dangerous, so the confirmation prompts only appear for the genuinely ambiguous cases.

The configuration lives in `.claude/settings.local.json`. This file is gitignored, so it is personal to your machine and your workflow. The project-level `.claude/settings.json` (committed to the repository) carries the team's shared policies. Local overrides project.

### The Settings Hierarchy

Understanding the precedence order is essential before writing any configuration:

```
Managed settings (IT-deployed, immutable)
    ↓
Command-line arguments (session-only)
    ↓
settings.local.json (your personal overrides)
    ↓
settings.json (team-shared, committed to repo)
    ↓
~/.claude/settings.json (user-wide defaults)
```

Higher levels always win. If the team's `.claude/settings.json` denies `Bash(rm -rf *)`, your local `settings.local.json` cannot override that deny. Deny rules propagate upward in authority.

The practical implication: put safety rules in the committed `settings.json`. Put personal workflow optimizations in `settings.local.json`.

### Writing Permission Rules

The syntax is: `Tool(specifier)` or just `Tool` for all uses of that tool.

```json
{
  "permissions": {
    "allow": [
      "Bash(git status)",
      "Bash(git diff *)",
      "Bash(git log *)",
      "Bash({build-tool} build *)",
      "Bash({test-command} *)",
      "Bash({package-manager} run *)",
      "Read(./**)",
      "Edit(./src/**)",
      "Edit(./tests/**)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(git push --force *)",
      "Bash(git reset --hard *)",
      "Bash(curl * | bash)",
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)",
      "WebFetch"
    ],
    "ask": [
      "Bash(git push *)",
      "Bash(git commit *)"
    ]
  }
}
```

Rules are evaluated in order: **deny first, then ask, then allow**. The first matching rule wins.

Wildcards:
- `*` matches within a single path segment: `Bash(npm run *)` matches `npm run test` but not `npm run test:coverage`
- `**` matches zero or more segments: `Read(./src/**)` matches any file under `src/`

### The Settings in This Repository

The current `settings.local.json` configures:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1",
    "CLAUDE_CODE_MAX_OUTPUT_TOKENS": "64000",
    "CLAUDE_CODE_EFFORT_LEVEL": "high",
    "CLAUDE_CODE_DISABLE_AUTO_MEMORY": "O"
  },
  "enableAllProjectMcpServers": true,
  "enabledMcpjsonServers": ["perplexity", "sequential-thinking", "context7"],
  "statusLine": {
    "type": "command",
    "command": ".claude/statusline.sh",
    "padding": 0
  }
}
```

A few things worth noting:

`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` enables the multi-agent teams feature, which allows spawning coordinated subagent groups. Required for the team-based skills in `.claude/skills/`.

`CLAUDE_CODE_EFFORT_LEVEL: "high"` tells the model to use maximum reasoning depth. For complex architectural work, this matters. It increases latency and cost, so consider dropping it to `"medium"` for routine tasks.

`enableAllProjectMcpServers` auto-approves MCP servers listed in `.mcp.json`. Combined with `enabledMcpjsonServers`, this allows the agent to use Perplexity for web research, sequential-thinking for structured analysis, and Context7 for documentation lookup without confirmation prompts per use.

### Hook-Based Enforcement

Hooks go beyond allow/deny lists. They execute code at specific lifecycle events, enabling dynamic policy enforcement that static rules cannot express.

**PreToolUse**: Runs before any tool call. Can abort the operation.

**PostToolUse**: Runs after a tool call completes. Useful for logging, notification, and side effects.

A minimal safety hook that blocks the most dangerous bash operations:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "type": "command",
        "command": "~/.claude/hooks/pre-tool-safety.sh"
      }
    ]
  }
}
```

```bash
#!/bin/bash
# ~/.claude/hooks/pre-tool-safety.sh

# Read tool name and input from stdin (Claude sends JSON)
INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [ "$TOOL" = "Bash" ]; then
    # Block force pushes to main
    if echo "$COMMAND" | grep -qE 'git push.*--force.*(main|master)'; then
        echo "BLOCKED: Force push to main is not allowed" >&2
        exit 1
    fi

    # Block recursive deletion of important directories
    if echo "$COMMAND" | grep -qE 'rm -rf.*(src|tests|\.git|/)'; then
        echo "BLOCKED: Recursive deletion of protected directories" >&2
        exit 1
    fi
fi

exit 0
```

The hook receives tool input as JSON on stdin. Exit code 0 allows the operation. Any non-zero exit aborts it with the stderr output shown to the user.

Hooks run on every tool use in every session, enforcing policies that even an autonomous agent cannot override. They are the floor beneath the permission system.

### Configuration Profiles for Different Scenarios

**Interactive development** — You are present and reviewing everything:

```json
{
  "permissions": {
    "defaultMode": "ask",
    "allow": [
      "Read(./**)",
      "Bash(git status)",
      "Bash(git diff *)",
      "Bash({build-tool} check *)",
      "Bash({lint-command})"
    ]
  }
}
```

**Supervised execution** — You are watching but not approving every action:

```json
{
  "permissions": {
    "defaultMode": "acceptEdits",
    "allow": [
      "Read(./**)",
      "Edit(./src/**)",
      "Edit(./tests/**)",
      "Bash({build-tool} build *)",
      "Bash({test-command} *)",
      "Bash({package-manager} run *)",
      "Bash(git add *)",
      "Bash(git status)"
    ],
    "deny": [
      "Bash(git push *)",
      "Bash(git commit *)",
      "WebFetch"
    ]
  }
}
```

**Autonomous execution** — Agent runs a complete task without supervision (see next section):

```json
{
  "permissions": {
    "defaultMode": "acceptEdits",
    "allow": [
      "Read(./**)",
      "Edit(./src/**)",
      "Edit(./tests/**)",
      "Bash({build-tool} build *)",
      "Bash({test-command} *)",
      "Bash({package-manager} run *)",
      "Bash(git add *)",
      "Bash(git commit *)"
    ],
    "deny": [
      "Bash(git push *)",
      "Bash(rm -rf *)",
      "Bash(*--force*)",
      "WebFetch"
    ]
  }
}
```

---

## 5. The Nuclear Option: --dangerously-skip-permissions

### What It Does

`claude --dangerously-skip-permissions` bypasses the entire permission system. Every tool call executes without confirmation. Every file is readable. Every bash command runs. The agent operates without any intervention from the safety layer.

The name is not marketing hyperbole. It is accurate.

In the wrong context, this flag enables an agent to delete your codebase, push breaking changes to production, exfiltrate sensitive files, or install malicious packages — not through malicious intent, but through confident misexecution of an ambiguous instruction. The agent does not want to cause harm. It simply does what it concludes you wanted, at full speed, without pause for confirmation.

In the right context, this flag is the difference between an agent that produces a feature in 20 minutes and one that produces the same feature in two hours, interrupted by 40 confirmation prompts.

The question is not whether to use it. The question is whether the conditions are right.

### Three Prerequisites

Before using `--dangerously-skip-permissions`, three conditions must be true simultaneously:

**1. The permission rules are complete.**

You have written explicit `allow` and `deny` rules for every category of action the agent will take. Not approximately complete — fully complete. The agent should not need to access anything that is not explicitly permitted. Review the rules against the plan before starting.

The deny list matters more than the allow list. Enumerate explicitly what the agent must never do: push to remote, delete directories, modify configuration files, access secrets. Write them before you start.

**2. The session runs in an isolated environment.**

The devcontainer is the preferred isolation layer. An agent running with skipped permissions in a devcontainer can do significant damage to its working directory and nothing beyond it. The container boundary is real.

If you are not in a devcontainer, use a worktree as a fallback. The worktree will not prevent destructive bash commands, but it will at least contain file operations to a branch that has not been merged. The blast radius is limited.

Never use `--dangerously-skip-permissions` in your main working directory on your host machine without container isolation.

**3. The task is fully specified.**

Autonomy requires precision. An agent operating without confirmation prompts will fill ambiguous instructions with its best guess — and it will do so confidently and at speed. A vague ticket becomes an unexpected implementation. An open-ended scope becomes scope creep executed without recourse.

Run `/prepare-ticket` and `/create-plan` before starting an autonomous session. Read the plan. Verify that the scope is what you intended. Make sure the acceptance criteria are measurable. Only then start the agent.

The confirmation prompt, when it appears, is usually the agent asking for clarification it cannot resolve from the specification. If you skip all confirmation prompts before the specification is complete, you are removing the mechanism that surfaces your own ambiguity.

### The Invocation Pattern

The standard autonomous session:

```bash
# In a worktree, inside the devcontainer
cd ../worktrees/my-feature-branch

# Verify the plan is loaded
cat knowledge/plans/2026-03-01-PROJ-0042-feature-name.md

# Start autonomous session with a specific instruction
claude --dangerously-skip-permissions \
  "/implement-plan knowledge/plans/2026-03-01-PROJ-0042-feature-name.md"
```

The instruction is explicit: implement this specific plan file. Not "implement the feature." Not "look at the ticket and figure it out." The plan file is the complete specification. The agent's job is to execute it.

### Disabling It Organization-Wide

For teams where autonomous mode should require explicit enablement — or should be completely unavailable — the managed settings file overrides command-line flags:

```json
// In managed-settings.json (IT/admin deployed)
{
  "permissions": {
    "disableBypassPermissionsMode": "disable"
  }
}
```

When this is set, `--dangerously-skip-permissions` is unavailable to all users, regardless of what they pass on the command line. The flag simply does nothing. This is the appropriate setting for any agent that interacts with production systems, shared databases, or external APIs.

The setting exists because "don't use dangerous flags" is insufficient organizational policy. Enforcement belongs in configuration, not in documentation.

---

## 6. The Full Stack in Practice

These three layers — worktrees, devcontainer, permissions — do not operate independently. They compose.

A complete parallel development session looks like this:

**1. Ticket and plan are ready** (from the IDLC workflow): `knowledge/tickets/PROJ-0042.md` and `knowledge/plans/2026-03-01-PROJ-0042-feature-name.md` exist. The plan is reviewed. Acceptance criteria are clear.

**2. Create a worktree:**

```bash
./scripts/create_worktree.sh feature-auth-layer main
# Output: Worktree created at ../worktrees/feature-auth-layer
```

**3. Open the worktree in a devcontainer:**

In VS Code, open `../worktrees/feature-auth-layer`. VS Code detects `.devcontainer/devcontainer.json` and prompts to reopen in container. Accept. The container builds with exact tool versions and Claude auth mounted from host config.

**4. Configure the session:**

Open `.claude/settings.local.json` in the worktree. Apply the autonomous execution profile from section 4. Add any task-specific denies — if this ticket does not touch the database, add `Bash(*psql*)` and `Bash(*migrate*)` to deny.

**5. Start the agent:**

```bash
claude --dangerously-skip-permissions \
  "/implement-plan knowledge/plans/2026-03-01-PROJ-0042-feature-name.md"
```

**6. In another terminal, start a second agent on a different ticket:**

```bash
./scripts/create_worktree.sh feature-api-endpoints main
# Open in second devcontainer, configure, launch
```

**7. Both agents run concurrently**, in isolated environments, on isolated branches, with their own context and their own file state. They do not know about each other. They cannot interfere with each other.

**8. When each agent finishes**, it reports completion. You review the output, run the verification steps from the plan's acceptance criteria, and either merge the worktree branch or send it back for revision.

**9. Clean up:**

```bash
git merge feature-auth-layer
git worktree remove ../worktrees/feature-auth-layer
git branch -D feature-auth-layer
```

This is what parallel agentic development looks like when the infrastructure is in place. Two features developed simultaneously. Each agent working at full speed. No coordination overhead between them. No conflicts. No shared state.

The infrastructure does not make the agents smarter. It makes the humans smarter — by removing the coordination problems that would otherwise require constant intervention.

---

## 7. What the Configuration in This Repository Assumes

This repository's devcontainer, worktree script, and settings files make specific assumptions that you should be aware of before adapting them.

**The worktree base is `../worktrees`.** This means your main repository and its worktrees are siblings under a common parent directory. If your directory structure is different, set `PROJECT_WORKTREE_BASE` before running the script.

**The Claude config volume is named `dev-claude-config`.** This is a Docker volume that persists across container rebuilds. If you are running multiple projects that each use this devcontainer template, they will share this volume. Rename it per project in `devcontainer.json` to avoid cross-contamination.

**The `settings.local.json` is not committed.** It is gitignored. Every developer on your team starts with no local settings and must configure their own. This is intentional — local settings are personal. Consider adding a `settings.local.json.example` to the repository to give developers a starting point.

**The MCP servers in `settings.local.json` are personal.** Perplexity, sequential-thinking, and context7 are configured because that is what this project uses. Your `.mcp.json` may list different servers. Make sure `enabledMcpjsonServers` matches what is available.

**`CLAUDE_CODE_EFFORT_LEVEL: "high"` costs more.** This setting increases token usage on every request. Monitor your API usage and drop it to `"medium"` for sessions that do not require deep reasoning — routine bug fixes, test generation, documentation updates.

---

## 8. The Principle That Ties It Together

The IDLC workflow describes the agentic cycle: load context, plan, review, execute, verify, update memory, reset.

The infrastructure described here makes that cycle reliable at scale:

- **Worktrees** make the parallel execution step possible without coordination overhead.
- **Devcontainers** make the reset step meaningful — you are not just starting a new conversation, you are starting in a clean environment.
- **Permissions** make the execute step safe — you define the boundary before the agent operates, not in response to something going wrong.
- **Controlled use of `--dangerously-skip-permissions`** makes the execute step fast when the prerequisites are met.

Each layer solves a specific failure mode. Without worktrees, parallelism creates conflicts. Without containers, clean sessions are aspirational. Without permissions, every autonomous action is a calculated risk. Without controlled bypass, confirmation prompts become the bottleneck.

The Agentic Cycle is the discipline. This infrastructure is the scaffold that holds it up.

Build the scaffold first. The discipline is much easier to maintain when the environment enforces it.

---

*Template project: [idlc-template](https://github.com/HelixoidLLC/idlc-template)*

Sources:
- [Common workflows — Claude Code Docs](https://code.claude.com/docs/en/common-workflows)
- [Claude Code Settings Reference](https://code.claude.com/docs/en/settings)
- [How we're shipping faster with Claude Code and Git Worktrees — incident.io](https://incident.io/blog/shipping-faster-with-claude-code-and-git-worktrees)
- [Parallel AI Coding with Git Worktrees and Custom Claude Code Commands — Agent Interviews](https://docs.agentinterviews.com/blog/parallel-ai-coding-with-gitworktrees/)
- [Claude Code Permissions — Steve Kinney](https://stevekinney.com/courses/ai-development/claude-code-permissions)
- [Claude Code Permission Hook: Skip Prompts Safely — claudefa.st](https://claudefa.st/blog/tools/hooks/permission-hook-guide)
