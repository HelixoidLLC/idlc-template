#!/bin/bash

# create_worktree.sh - Create a new worktree for development work
# Usage: ./create_worktree.sh [worktree_name] [base_branch]
# If no name provided, generates a unique human-readable one
# If no base branch provided, uses current branch

set -e  # Exit on any error


# Function to generate a unique worktree name
generate_unique_name() {
    local adjectives=("swift" "bright" "clever" "smooth" "quick" "clean" "sharp" "neat" "cool" "fast")
    local nouns=("fix" "task" "work" "dev" "patch" "branch" "code" "build" "test" "run")

    local adj=${adjectives[$RANDOM % ${#adjectives[@]}]}
    local noun=${nouns[$RANDOM % ${#nouns[@]}]}
    local timestamp=$(date +%H%M)

    echo "${adj}_${noun}_${timestamp}"
}

# Get worktree name from parameter or generate one
WORKTREE_NAME=${1:-$(generate_unique_name)}

# Get base branch from second parameter or use current branch
BASE_BRANCH=${2:-$(git branch --show-current)}

# Get the repo base name (used for relative .git path calculation)
REPO_BASE_NAME=$(basename "$(pwd)")

# Default worktrees location: sibling directory named "worktrees"
# Override with PROJECT_WORKTREE_BASE env var if set
if [ -n "$PROJECT_WORKTREE_BASE" ]; then
    WORKTREES_BASE="${PROJECT_WORKTREE_BASE}"
else
    WORKTREES_BASE="../worktrees"
fi

WORKTREE_PATH="${WORKTREES_BASE}/${WORKTREE_NAME}"

echo "🌳 Creating worktree: ${WORKTREE_NAME}"
echo "📁 Location: ${WORKTREE_PATH}"

# Check if worktrees base directory exists
if [ ! -d "$WORKTREES_BASE" ]; then
    echo "❌ Error: Directory $WORKTREES_BASE does not exist."
    echo "   Please create it first: mkdir -p $WORKTREES_BASE"
    exit 1
fi

# Check if worktree already exists
if [ -d "$WORKTREE_PATH" ]; then
    echo "❌ Error: Worktree directory already exists: $WORKTREE_PATH"
    exit 1
fi

# Display base branch info
echo "🔀 Creating from branch: ${BASE_BRANCH}"

# Create worktree (creates branch if it doesn't exist)
if git show-ref --verify --quiet "refs/heads/${WORKTREE_NAME}"; then
    echo "📋 Using existing branch: ${WORKTREE_NAME}"
    git worktree add "$WORKTREE_PATH" "$WORKTREE_NAME"
else
    echo "🆕 Creating new branch: ${WORKTREE_NAME}"
    git worktree add -b "$WORKTREE_NAME" "$WORKTREE_PATH" "$BASE_BRANCH"
fi

# Convert .git file to use relative path for devcontainer compatibility
echo "🔧 Converting .git to relative path for devcontainer support..."
if [ -f "$WORKTREE_PATH/.git" ]; then
    # Calculate relative path from worktree to main repo's .git worktrees dir
    # From: ../worktrees/worktree-name
    # To:   ../../{repo-name}/.git/worktrees/worktree-name
    RELATIVE_GITDIR="../../${REPO_BASE_NAME}/.git/worktrees/${WORKTREE_NAME}"

    echo "gitdir: $RELATIVE_GITDIR" > "$WORKTREE_PATH/.git"
    echo "✅ Updated .git to use relative path: $RELATIVE_GITDIR"
fi

# Copy .claude directory if it exists
if [ -d ".claude" ]; then
    echo "📋 Copying .claude directory..."
    cp -r .claude "$WORKTREE_PATH/"
fi

# Copy .mcp.json if it exists
if [ -f ".mcp.json" ]; then
    echo "📋 Copying .mcp.json..."
    cp .mcp.json "$WORKTREE_PATH/"
fi

# Change to worktree directory
cd "$WORKTREE_PATH"

# Run project setup if a setup script or known package manager is available
echo "🔧 Setting up worktree dependencies..."
if [ -f ".devcontainer/scripts/setup.sh" ]; then
    .devcontainer/scripts/setup.sh
elif [ -f "package.json" ] && command -v bun &>/dev/null; then
    bun install || true
elif [ -f "Cargo.toml" ] && command -v cargo &>/dev/null; then
    cargo build 2>/dev/null || true
else
    echo "⚠️  No recognized setup method found. Run setup manually if needed."
fi

# Return to original directory
cd - > /dev/null

echo "✅ Worktree created successfully!"
echo "📁 Path: ${WORKTREE_PATH}"
echo "🔀 Branch: ${WORKTREE_NAME}"
echo ""
echo "To work in this worktree:"
echo "  cd ${WORKTREE_PATH}"
echo ""
echo "To remove this worktree later:"
echo "  git worktree remove ${WORKTREE_PATH}"
echo "  git branch -D ${WORKTREE_NAME}"
