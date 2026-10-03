# Harness Portability

This repo's agentic configuration is authored **once, for Claude Code**, but
structured so it ports to other coding agents (Codex, Cursor, GitHub Copilot, Pi)

## Canonical source (edit here)

| What         | Where                                    | Notes                                                         |
| ------------ | ---------------------------------------- | ------------------------------------------------------------- |
| Instructions | `AGENTS.md` (+ `CLAUDE.md` importing it) | Edit `AGENTS.md`; keep only Claude-only notes in `CLAUDE.md`. |
| skills       | `.claude/skills/<name>/SKILL.md`         | Slash name = directory name.                                  |
| Subagents    | `.claude/agents/<name>.md`               |                                                               |
| MCP servers  | `.mcp.examples.json`                     | Real `.mcp.json` is gitignored (secrets).                     |

## Read map — what each harness consumes

Legend: **native** = harness reads the canonical path directly (do nothing) ·
**copy** = one `cp -r` · **manual** = format differs, hand-adapt · **n/a** = no analog.

| Concept           | Claude                                     | Codex                           | Cursor                         | Copilot                              | Pi                       |
| ----------------- | ------------------------------------------ | ------------------------------- | ------------------------------ | ------------------------------------ | ------------------------ |
| Instructions      | `CLAUDE.md` (imports `AGENTS.md`) — native | `AGENTS.md` — native            | `AGENTS.md` — native           | `AGENTS.md` — native                 | `AGENTS.md` — native     |
| Commands / skills | `.claude/skills/` — native                 | `.codex/skills/` — copy         | `.cursor/skills/` — copy       | `.claude/skills/` — **native**       | `.agents/skills/` — copy |
| Subagents         | `.claude/agents/` — native                 | `.codex/agents/*.toml` — manual | `.cursor/agents/` — copy       | `.github/agents/*.agent.md` — manual | **n/a**                  |
| MCP               | `.mcp.json` — copy+fill                    | `.codex/config.toml` — manual   | `.cursor/mcp.json` — copy+fill | `.vscode/mcp.json` — manual          | **n/a**                  |

## Copy recipes (run from repo root)

**Cursor**

```bash
cp -r .claude/skills .cursor/skills      # slash commands + skills
cp -r .claude/agents .cursor/agents      # subagents (name/description/model carry over)
cp .mcp.examples.json .cursor/mcp.json   # then fill in secrets; key is "mcpServers"
# AGENTS.md is read natively.
```

**Codex**

```bash
cp -r .claude/skills .codex/skills       # skills use the same SKILL.md format
# AGENTS.md is read natively.
# Subagents + MCP need manual format conversion (see Ceilings).
```

**Pi**

```bash
cp -r .claude/skills .agents/skills      # Pi reads .agents/skills (and .pi/skills)
# AGENTS.md is read natively.
```

**GitHub Copilot**

```bash
# Nothing to copy for instructions or skills:
#   AGENTS.md is read natively, and Copilot auto-discovers .claude/skills/.
# Subagents + MCP need manual format conversion (see Ceilings).
```

## Ceilings (things content can't make portable)

- **Copilot** "agents" are chat-mode personas, **not isolated sub-contexts** like
  Claude/Cursor subagents. Emit `.github/agents/*.agent.md` only if you accept
  that tool isolation is not enforced.
- **Pi** has **no subagents and no MCP** by design. The `.claude/agents/` and
  `.mcp.examples.json` assets simply don't apply.
- **Claude-only frontmatter** on subagents (`color`, `permissionMode`) and the
  `skills:` list are ignored by other harnesses — harmless, not an error.
