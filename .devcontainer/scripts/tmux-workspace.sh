#!/bin/bash
set -e

# tmux workspace initialization
# Creates a tmux session named 'workspace' if it doesn't exist

if ! tmux has-session -t workspace 2>/dev/null; then
    tmux new-session -d -s workspace -c "${WORKSPACE_FOLDER:-/workspaces/project}"
    echo "✅ tmux workspace session created"
else
    echo "✅ tmux workspace session already exists"
fi

# Don't attach here - let the terminal profile handle it
# This prevents blocking the terminal
