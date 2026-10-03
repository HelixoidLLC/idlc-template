#!/bin/bash
set -e

# Setup Claude Code authentication for devcontainer
# This creates the shared config that works across all git worktrees

CONFIG_DIR="$HOME/.config/dev-container"
CONFIG_FILE="$CONFIG_DIR/devcontainer.env"

echo "🔧 Dev Container - Claude Auth Setup"
echo "======================================"
echo ""

# Check if already configured
if [ -f "$CONFIG_FILE" ]; then
    echo "⚠️  Configuration already exists at: $CONFIG_FILE"
    echo ""
    read -p "Do you want to update it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Setup cancelled"
        exit 0
    fi
fi

# Create config directory
mkdir -p "$CONFIG_DIR"

# Prompt for token
echo "📝 Please provide your Claude Code OAuth token"
echo "   (Get it by running: claude setup-token)"
echo ""
read -sp "Token (sk-ant-oat01-...): " TOKEN
echo ""

# Validate token format
if [[ ! $TOKEN =~ ^sk-ant-oat01- ]]; then
    echo "❌ Invalid token format. Token should start with 'sk-ant-oat01-'"
    exit 1
fi

# Write config
echo "CLAUDE_CODE_OAUTH_TOKEN=$TOKEN" > "$CONFIG_FILE"
chmod 600 "$CONFIG_FILE"

echo ""
echo "✅ Configuration saved to: $CONFIG_FILE"
echo "🔐 Permissions set to 600 (owner read/write only)"
echo ""
echo "📌 This configuration works across ALL git worktrees"
echo "🚀 Next: Rebuild your devcontainer to apply changes"
echo "   (Cmd+Shift+P → 'Dev Containers: Rebuild Container')"
