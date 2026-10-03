# AGENTS.md

Guidance for AI coding agents (Claude Code, Codex, Cursor, GitHub Copilot, Pi, …)
working in this repository. This is the canonical, harness-neutral instruction
file. Claude Code loads it via an `@AGENTS.md` import in `CLAUDE.md`; the other
harnesses read `AGENTS.md` natively. See `PORTABILITY.md` for how the rest of the
agentic configuration maps to each harness.

## ⚠️ CRITICAL POLICIES

### Integrity Rule (ABSOLUTE)
- ❌ NO shortcuts - do the work properly or don't do it
- ❌ NO fake data - use real data, real tests, real results
- ❌ NO false claims - only report what actually works and is verified
- ✅ ALWAYS implement all code/tests with proper implementation
- ✅ ALWAYS verify before claiming success
- ✅ ALWAYS use real database queries, not mocks, for integration tests
- ✅ ALWAYS run actual tests, not assume they pass

**We value the quality we deliver to our users.**

### Git Operations
- ❌ NEVER auto-commit/push without explicit user request
- ❌ NEVER add AI/assistant attribution to commits (no `Co-Authored-By`, no
  "Generated with …" trailers) — commits are authored solely by the user
- ✅ ALWAYS wait for: "commit this" or "push to main"


## Project Overview

**{PROJECT_NAME}** - brief description of what this project does:
- Key feature 1 (e.g., data storage layer)
- Key feature 2 (e.g., API integration)
- Key feature 3 (e.g., workflow engine)
- Key feature 4 (e.g., UI application)

## Repository Structure

```
{project-name}/
├── backend/             # Backend code (language-specific)
│   ├── core/            # Core library
│   ├── api/             # API layer
├── frontend/            # Frontend application
│   ├── web/             # Web app
├── packages/            # Shared packages/libraries
├── tests/               # Integration tests
└── docs/                # Documentation
```

## Build Commands

### Quick Actions
- `{package-manager} dev` - Start development server
- `{package-manager} build` - Build for production
- `{package-manager} test` - Run all tests
- `{package-manager} lint` - Lint all code
- `make check` - Run pre-push checks

### Backend Development
```bash
{build-tool} build -p {package-name}    # Build specific packages
{build-tool} test --all-features        # Run tests
{build-tool} fmt && {build-tool} lint   # Format and lint
```

**IMPORTANT:** Always use the installed `{cli-name}` CLI when available, NOT the development build command.

### CLI Tool
```bash
{cli-name} {command}             # Primary command
{cli-name} {subcommand} <args>   # Subcommand with arguments
{cli-name} --help                # Show help
```

### Service Management (if applicable)
```bash
# Auto-detection (recommended)
{cli-name} service start         # Start service for current project
{cli-name} service stop          # Stop service
{cli-name} service status        # Show status
{cli-name} service restart       # Restart service
{cli-name} service logs          # View logs (use -f to follow)

# Custom options
{cli-name} service start --port 8080       # Custom port
{cli-name} service start --foreground      # Run in foreground
{cli-name} service start --timeout 600     # Custom timeout

# Configuration
# - Configs stored in ~/.{project-name}/
# - Each instance gets its own directory
# - Location: ~/.{project-name}/profiles/{profile-id}/
```

### Data Management Commands (example)
```bash
{cli-name} data list             # List data items
{cli-name} data show <id>        # Show item details
{cli-name} data export           # Export data
{cli-name} data import <file>    # Import data

# Export formats: json, csv, xml
{cli-name} data export --format json -o output.json
```

See `docs/{FEATURE}_GUIDE.md` for detailed documentation.

### Frontend App
```bash
cd {frontend-directory}
{package-manager} dev            # Development mode
{package-manager} build          # Production build
```

## Architecture

### Core Components
- **{core-package}** - Core business logic and data layer
- **{cli-package}** - Command-line interface tool
- **{frontend-package}** - User interface application
- **{shared-package}** - Shared types and utilities

### Tech Stack
- **Backend**: {language}, {framework-1}, {framework-2}, {database}
- **Frontend**: {ui-framework}, {state-management}, {ui-library}, {styling}, {build-tool}
- **Platform-specific**: {platform-framework} with plugins ({plugin-1}, {plugin-2}, etc.)

### Custom Feature/Workflow (example)
Configurable workflows defined in `.{config-dir}/{entity-type}/{entity-id}/config.yaml`:
- Default states: state1 → state2 → state3 → state4 → completed
- Integrates with external systems (GitHub, Jira, etc.)
- See `docs/{FEATURE}_CONFIGURATION.md`

### Data Layer
Tracks relationships between entities:
- Current implementation: {current-tech}
- Planned/alternative: {planned-tech}

## Testing

Test organization:
- Unit tests: Inline with source (language-specific pattern)
- Integration: `{backend-dir}/*/tests/`
- End-to-end: `{e2e-tests-dir}/`

```bash
{test-command}                    # All tests
{test-command} -p {package}       # Specific package
{test-runner} run                 # Alternative test runner
{snapshot-tool} review            # Snapshot tests (if applicable)
```

## Development Conventions

### File Organization

**NEVER save working files, text/mds, and tests to the root folder.** Use these directories:

- `/{backend-dir}/{package}/src/` - Backend source code
- `/{backend-dir}/*/tests/` - Backend integration tests
- `/{frontend-dir}/src/` - Frontend source code
- `/{frontend-dir}/__tests__/` - Frontend tests
- `/packages/` - Shared packages/libraries
- `/tests/` - Cross-component integration tests
- `/docs/` - Documentation and architecture files
- `/scripts/` - Build and utility scripts

### Code Style & Best Practices

- **Modular Design**: Files under 500 lines
- **Environment Safety**: Never hardcode secrets
- **Test-First**: Write tests before implementation
- **Clean Architecture**: Separate concerns
- **Documentation**: Keep updated

### TODO Annotations

We use a priority-based TODO annotation system throughout the codebase:

- `TODO(0)`: Critical - never merge
- `TODO(1)`: High - architectural flaws, major bugs
- `TODO(2)`: Medium - minor bugs, missing features
- `TODO(3)`: Low - polish, tests, documentation
- `TODO(4)`: Questions/investigations needed
- `PERF`: Performance optimization opportunities

## Development Methodology

### SPARC Framework

For complex features or refactors, use this structured approach:

1. **Specification** - Requirements analysis & acceptance criteria
2. **Pseudocode** - Algorithm design & logic flow
3. **Architecture** - System design & component structure
4. **Refinement** - TDD implementation & iteration
5. **Completion** - Integration & verification

## Development Workflow

This repository uses the **IDLC (Intent-Driven LifeCycle)** workflow. The workflow
steps are provided as skills under `.claude/skills/` (invocable as slash commands
in harnesses that support them, e.g. `/prepare-ticket`, `/create-plan`,
`/implement-plan`). See `README.md` for the full lifecycle and `PORTABILITY.md`
for how skills map to each harness.

### Data/Content Management (example)
```bash
{cli-name} {feature} init           # Initialize feature
{cli-name} {feature} add <item>     # Add item
{cli-name} {feature} sync           # Synchronize
{cli-name} {feature} search "query" # Search
{cli-name} {feature} list           # List items
```
Note: Additional directories may be used for specific purposes.
See `docs/{FEATURE}_GUIDE.md` for detailed documentation.

### Task/Issue Management (example)
- Items stored in `{data-dir}/{item-type}/` directory
- CLI commands via `{cli-name}` tool:
  - `{cli-name} {entity} list` - List all items
  - `{cli-name} {entity} show <id>` - Show item details
  - `{cli-name} {entity} create` - Create new item
  - `{cli-name} {entity} update <id> <field>` - Update item
  - `{cli-name} {entity} status <id>` - Show item status
- Optional integration with external systems (Jira, Linear, GitHub, etc.)

### Logging
- Backend: `{LOG_LEVEL_VAR}=debug`
- CLI: `--verbose` or `-v` flag

## Important Notes

### Workspace Organization (example)
- Backend code isolated in `{backend-dir}/` directory
- Separate workspace configuration for backend
- Root workspace includes all sub-projects

### Technology Choices
- Current: {current-tech} (MVP/initial implementation)
- Planned: {planned-tech} (future enhancement)

### Platform Support
- Supported platforms: {platform-1}, {platform-2}, {platform-3}
- Platform-specific requirements: {requirement-details}

## Configuration Files

- `{root-config}` - Root workspace/project configuration
- `{backend-dir}/{config-file}` - Backend configuration
- `{build-config}` - Build orchestration
- `.{config-dir}/config.yaml` - Project settings
- `.{config-dir}/{feature}/config.yaml` - Feature-specific settings
- `.{config-dir}/{entity-type}/*/settings.yaml` - Per-entity configuration

### External Service Configuration (example)

See `.{config-dir}.example/` for example configurations.

**Quick setup**:
```bash
# Copy example configuration
cp .{config-dir}.example/{service}.yaml .{config-dir}/{service}.yaml

# Install/configure required dependencies
{dependency-manager} install {package-name}
{dependency-manager} setup {service-name}
```

**Recommended settings** (based on testing/evaluation):
- **Option A**: `{config-value-1}` - Use for {use-case-1}
- **Option B**: `{config-value-2}` - Use for {use-case-2}
- **Deprecated**: `{old-config}` - Known issues with {problem-description}

**Common use cases**:
- **Use case 1**: Description of when to use specific configuration
- **Use case 2**: Description of another configuration scenario
- **Use case 3**: Special requirements or edge cases

See `.{config-dir}.example/README.md` for detailed configuration guide.

## Pre-commit/Pre-push Checks

Run `make check` or equivalent before committing:
- `{format-command}` - Format check
- `{lint-command}` - Lint check
- `{test-command}` - Run tests

## Documentation

Key docs in `docs/`:
- `GETTING_STARTED.md` - Initial setup and quickstart
- `{FEATURE}_GUIDE.md` - Feature-specific documentation
- `{WORKFLOW}_CONFIGURATION.md` - Configuration guides
- `ARCHITECTURE.md` - System architecture and design
- `API_REFERENCE.md` - API documentation
- `DEPLOYMENT.md` - Deployment instructions
