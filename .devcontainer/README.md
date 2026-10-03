# Development Container

## Overview

This development container provides a complete, isolated development environment with Rust, Node.js, Python, Bun, and Claude Code pre-configured. The container is based on Ubuntu 24.04 and uses Mise for tool version management.

Replace `{PROJECT_NAME}` in `devcontainer.json` with your actual project name before use.

## Architecture

### Base Image

- **OS**: Ubuntu 24.04 LTS
- **User**: `ubuntu` (non-root with sudo access)
- **Workspace**: `/workspaces/project` (rename to match your project)

### Tool Installation Strategy

1. System dependencies installed via `apt`
2. Mise installed for tool version management
3. Rust installed via `rustup`
4. Additional tools installed via Mise (Node, Python, cargo tools)
5. Claude Code installed via the official install script

## Installed Tools & Versions

### Core Languages

- **Rust**: 1.92.0 (via rustup, stable channel)
- **Node.js**: 22.21.1 (via Mise)
- **Python**: 3.13.11 (via Mise)

### Package Managers

- **Bun**: 1.3.5 (via npm/Mise)
- **uv**: 0.9.21 (Python package manager via pipx/Mise)
- **npm**: 10.9.4 (bundled with Node)
- **cargo**: Bundled with Rust

### Development Tools

- **cargo-watch**: 8.5.3 (file watching for Rust)
- **ripgrep**: 15.1.0 (fast grep alternative)
- **Claude Code CLI**: Latest

### System Utilities

- git
- curl
- build-essential (gcc, g++, make)
- clang
- cmake
- pkg-config
- OpenSSL development libraries
- zlib development libraries

> **Note**: The Dockerfile also includes GTK/WebKit libraries for Tauri desktop app development. Remove those lines if you don't need a GUI app.

## Container Configuration

### Capabilities

The container runs with the following Linux capabilities:

- `NET_ADMIN`: Network administration (reserved for future use)
- `NET_RAW`: Raw socket access (reserved for future use)

### Volume Mounts

**Persistent volumes** (survive container rebuilds):

```
dev-claude-config                        → /home/ubuntu/.claude (Claude config & auth)
claude-code-bashhistory-{id}             → /commandhistory (bash history)
```

**Workspace mount**:

```
${localWorkspaceFolder}/../.. → /workspaces (covers repo + sibling worktrees)
```

### Environment Variables

- `CLAUDE_CONFIG_DIR=/home/ubuntu/.claude`: Claude Code configuration directory
- `WORKSPACE_FOLDER`: Current container workspace path
- `PATH`: Includes Mise shims, Cargo bin, and local bin directories

### Network Configuration

- **Mode**: Bridge (default Docker networking)
- **Local access**: Via `host.docker.internal` or host LAN IP

## VS Code Integration

### Installed Extensions

1. **anthropic.claude-code**: Claude Code AI assistant
2. **rust-lang.rust-analyzer**: Rust language server
3. **vadimcn.vscode-lldb**: Rust/C++ debugger
4. **tamasfe.even-better-toml**: TOML syntax support
5. **ms-azuretools.vscode-docker**: Docker integration
6. **dbaeumer.vscode-eslint**: JavaScript/TypeScript linting
7. **esbenp.prettier-vscode**: Code formatting
8. **bradlc.vscode-tailwindcss**: Tailwind CSS IntelliSense
9. **ms-python.python**: Python language support

### Editor Settings

- **Format on save**: Enabled
- **Default formatter**: Prettier
- **Default shell**: Bash

## Usage Instructions

### Initial Setup

1. **Prerequisites**:
   - VS Code installed
   - Docker Desktop installed and running
   - Dev Containers extension installed in VS Code

2. **Customize for your project**:
   - Replace `{PROJECT_NAME}` in `devcontainer.json`
   - Update `WORKDIR` and COPY paths in `Dockerfile` if needed
   - Adjust VS Code extensions to match your stack

3. **Open in Container**:

   ```bash
   code /path/to/your/project
   # VS Code will prompt to "Reopen in Container"
   # Or: Cmd+Shift+P → "Dev Containers: Reopen in Container"
   ```

4. **First Build**:
   - Container build takes ~3-5 minutes on first run
   - Subsequent rebuilds use Docker cache (faster)

### Claude Code Setup

**Authentication**:

- Uses OAuth token stored in `~/.config/dev-container/devcontainer.env` (shared across worktrees)
- Host Claude authentication is **NOT** affected or used
- Token is valid for 1 year
- **Worktree-friendly**: Set up once, works in all worktrees automatically

**First-time setup**:

**Option A: Automated script (easiest)**

```bash
# 1. Get your OAuth token
claude setup-token
# Copy the token shown

# 2. Run setup script
.devcontainer/scripts/setup-claude-auth.sh
# Paste your token when prompted

# 3. Rebuild container
# In VS Code: Cmd+Shift+P → "Dev Containers: Rebuild Container"
```

**Option B: Manual setup**

```bash
# 1. Get your OAuth token (run ONCE)
claude setup-token
# Copy the token: sk-ant-oat01-...

# 2. Create shared config (ONE TIME setup)
mkdir -p ~/.config/dev-container
echo 'CLAUDE_CODE_OAUTH_TOKEN=sk-ant-oat01-...' > ~/.config/dev-container/devcontainer.env
chmod 600 ~/.config/dev-container/devcontainer.env

# 3. Rebuild container
# In VS Code: Cmd+Shift+P → "Dev Containers: Rebuild Container"
```

**Per-worktree overrides** (optional, advanced):

```bash
# If you need different tokens per worktree
cd .devcontainer
cp .env.example .env
# Edit .env with worktree-specific token
```

**Run Claude Code**:

```bash
# Interactive mode
claude

# With auto-approval (use only with trusted code)
claude --dangerously-skip-permissions
```

**Configuration location**:

- Settings: `/home/ubuntu/.claude` (Docker volume)
- Authentication: From `~/.config/dev-container/devcontainer.env` (host, mounted read-only)

### Development Workflows

#### Rust Development

```bash
# Build
cargo build

# Run tests
cargo test --all-features

# Watch for changes
cargo watch -x build
```

#### Node/Bun Development

```bash
# Install dependencies
bun install

# Run dev server
bun run dev

# Build
bun run build
```

#### Python Development

```bash
# Create virtual environment
uv venv

# Install dependencies
uv pip install -r requirements.txt

# Run scripts
uv run script.py
```

### Container Management

**Rebuild container**:

```
Cmd+Shift+P → "Dev Containers: Rebuild Container"
```

**Rebuild without cache** (clean build):

```
Cmd+Shift+P → "Dev Containers: Rebuild Container Without Cache"
```

**View container logs**:

```bash
docker logs <container-id>
```

**Access container shell** (outside VS Code):

```bash
docker exec -it <container-name> bash
```

## File Structure

```
.devcontainer/
├── Dockerfile              # Container image definition
├── devcontainer.json       # VS Code devcontainer configuration
├── .env                    # Local overrides (gitignored)
├── .env.example            # Template for per-worktree env vars
├── README.md               # This file
└── scripts/
    ├── setup-claude-auth.sh  # Claude OAuth token setup
    ├── setup.sh              # Post-create setup
    ├── post-setup.sh         # Post-attach setup
    ├── load-env.sh           # Env var loader (disabled by default)
    └── tmux-workspace.sh     # tmux workspace initializer
```

## Build Process

### Dockerfile Stages

1. **Base image**: Ubuntu 24.04
2. **System packages**: Install build tools and dependencies
3. **User setup**: Create `ubuntu` user with sudo access
4. **Mise installation**: Install Mise tool manager
5. **Claude Code installation**: Install via official install script
6. **Rust installation**: Install Rust via rustup
7. **Workspace setup**: Create `/workspaces/project` directory
8. **Mise tools**: Install Python, pipx, then remaining tools (Node, Bun, cargo tools)

### Build Context

- **Context directory**: `..` (repository root)
- **Copied files**: `mise.toml` from repository root
- **Build time**: ~3-5 minutes (first build)

## Data Persistence

### What Persists

✅ **Claude Code configuration** - Docker volume (`dev-claude-config`), survives rebuilds
✅ **Bash command history** - Docker volume, survives container rebuilds
✅ **Workspace files** - Bind-mounted from host, changes sync both ways
✅ **Git configuration** - Read from host `~/.gitconfig` by devcontainer feature

### What Doesn't Persist

❌ **Installed system packages** (if added manually)
❌ **Global npm/cargo packages** (if added manually)
❌ **System-level changes** (require Dockerfile modification)

### Adding Persistent Tools

To add tools that persist across rebuilds, modify:

- **Dockerfile**: For system packages
- **mise.toml**: For language tools and utilities

## Networking

### Outbound Access

The container has full outbound network access to:

- Public internet
- Host machine processes
- Other Docker containers

### Accessing Host Services

From inside the container:

```bash
# Docker Desktop special hostname
curl http://host.docker.internal:8080

# Or use host's LAN IP
curl http://192.168.1.x:8080
```

## Security Considerations

### Current Security Posture

- **Isolation**: Process and filesystem isolation via Docker
- **User**: Runs as non-root `ubuntu` user with sudo access
- **Network**: No firewall rules (standard Docker networking)
- **Capabilities**: NET_ADMIN and NET_RAW granted but unused

### Sensitive Data

- **Claude OAuth token**: Stored in `~/.config/dev-container/devcontainer.env` (outside repo, shared across worktrees)
- **Claude settings**: Docker volume at `/home/ubuntu/.claude`
- **SSH keys**: Not mounted by default (use git credential helpers or mount separately)
- **Environment secrets**: Store in `~/.config/dev-container/devcontainer.env`

**Security notes**:

- `~/.config/dev-container/devcontainer.env` is **outside** the repository (never committed)
- OAuth token is container-only, does **NOT** affect host Claude authentication
- **Worktree-friendly**: Set up once in `~/.config`, works across all worktrees automatically
- Optional per-worktree overrides via `.devcontainer/.env` (gitignored)

## Troubleshooting

### Container Won't Start

1. Check Docker Desktop is running
2. Check Docker has sufficient resources (4GB+ RAM recommended)
3. View build logs: Cmd+Shift+P → "Dev Containers: Show Container Log"

### Tools Not Found

```bash
# Verify Mise activation
eval "$(mise activate bash)"

# Check installed tools
mise list

# Reinstall tools
mise install
```

### Claude Code Authentication Issues

```bash
# Check if token file is mounted
ls -la /home/ubuntu/.devcontainer-shared.env

# Check Claude CLI works
claude --version

# Re-run auth setup
.devcontainer/scripts/setup-claude-auth.sh
```

### Port Forwarding Not Working

1. Check VS Code Ports panel (Cmd+Shift+P → "Ports: Focus on Ports View")
2. Manually forward: Right-click port → "Forward Port"
3. Check process is bound to `0.0.0.0`, not `127.0.0.1`

## Customization

### Adding VS Code Extensions

Edit `.devcontainer/devcontainer.json`:

```json
"customizations": {
  "vscode": {
    "extensions": [
      "existing.extensions",
      "new.extension-id"
    ]
  }
}
```

### Adding System Packages

Edit `.devcontainer/Dockerfile`:

```dockerfile
RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y \
    your-package \
    && rm -rf /var/lib/apt/lists/*
```

### Adding Development Tools

Edit root `mise.toml`:

```toml
[tools]
"cargo:your-tool" = "latest"
```

## Technical Details

### PATH Configuration

```bash
/home/ubuntu/.local/bin              # pipx and local binaries
/home/ubuntu/.local/share/mise/shims # Mise tool shims
/home/ubuntu/.cargo/bin              # Rust tools
/usr/local/bin                       # System binaries
/usr/bin                             # Standard binaries
```

### Docker Image Layers

The final image contains approximately:

- Base Ubuntu: ~75 MB
- System packages: ~200 MB
- Rust toolchain: ~1.5 GB
- Node.js: ~150 MB
- Python: ~100 MB
- Total: ~2 GB (compressed)

## Maintenance

### Updating Tools

**Update Mise tools**:

1. Edit `mise.toml` with new versions
2. Rebuild container

**Update Claude Code**:

```bash
# Reinstall manually:
curl -fsSL https://claude.ai/install.sh | bash -s stable
```

**Update VS Code extensions**:

- Extensions auto-update when configured in devcontainer.json
- Or manually in Extensions panel

### Cleaning Up

**Remove dangling images**:

```bash
docker image prune
```

**Remove unused volumes**:

```bash
docker volume prune
```

**Full cleanup** (removes everything):

```bash
docker system prune -a --volumes
```
