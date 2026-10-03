#!/bin/bash
# Claude Code + Ollama Wrapper
# Launch Claude Code sessions with local Ollama models

set -euo pipefail
[[ "${VERBOSE:-0}" == "1" ]] && set -x

# Load configuration from .claude-ollama.env if present
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.claude-ollama.env"
if [ -f "$ENV_FILE" ]; then
  set -a
  # shellcheck source=.claude-ollama.env
  source "$ENV_FILE"
  set +a
fi

# Usage
usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS] [prompt]

Launch Claude Code with Ollama backend

Options:
  -m, --model MODEL    Ollama model to use (default: $DEFAULT_MODEL)
  -l, --list           List available Ollama models and exit
  -p, --print          Non-interactive mode (print response and exit)
  --port PORT          Ollama port (default: $OLLAMA_PORT)
  -h, --help           Show this help message

Available models in Ollama:
$(ollama list 2>/dev/null | tail -n +2 | awk '{print "  - " $1}' || echo "  (run 'ollama list' to see models)")

Examples:
  # Interactive session with default model
  $(basename "$0")

  # Interactive session with specific model
  $(basename "$0") --model qwen3-coder:30b

  # Non-interactive prompt
  $(basename "$0") --print --model phi4:14b "Write a hello world in Rust"

  # List available models
  $(basename "$0") --list

EOF
  exit 0
}

# Determine mode: tier routing or single model
# Tier mode is active when all three ANTHROPIC_DEFAULT_*_MODEL vars are set
USE_TIER_MODELS=false
if [ -n "${ANTHROPIC_DEFAULT_HAIKU_MODEL:-}" ] && \
   [ -n "${ANTHROPIC_DEFAULT_SONNET_MODEL:-}" ] && \
   [ -n "${ANTHROPIC_DEFAULT_OPUS_MODEL:-}" ]; then
  USE_TIER_MODELS=true
fi

# Parse arguments
MODEL="${DEFAULT_MODEL:-}"
MODEL_EXPLICIT=false
PRINT_MODE=false
PROMPT=""
EXTRA_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -m|--model)
      MODEL="$2"
      MODEL_EXPLICIT=true
      shift 2
      ;;
    -l|--list)
      echo "Available Ollama models:"
      ollama list
      exit 0
      ;;
    -p|--print)
      PRINT_MODE=true
      shift
      ;;
    --verbose)
      VERBOSE=1
      EXTRA_ARGS+=("$1")
      shift
      ;;
    --port)
      OLLAMA_PORT="$2"
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    -*)
      # Pass through unknown flags to Claude
      EXTRA_ARGS+=("$1")
      shift
      ;;
    *)
      # Remaining arguments are the prompt
      PROMPT="$*"
      break
      ;;
  esac
done

# Check if Ollama is running
if ! curl -s "http://localhost:$OLLAMA_PORT/api/tags" >/dev/null 2>&1; then
  echo "Error: Ollama is not running on port $OLLAMA_PORT"
  echo "Start it with: ollama serve"
  exit 1
fi

# Check if model exists (only in single-model mode)
if [ "$USE_TIER_MODELS" = false ] || [ "$MODEL_EXPLICIT" = true ]; then
  if ! ollama list | grep -q "$MODEL"; then
    echo "Warning: Model '$MODEL' not found in Ollama"
    echo ""
    echo "Available models:"
    ollama list
    echo ""
    read -p "Download $MODEL now? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      ollama pull "$MODEL"
    else
      echo "Exiting. Download the model first with: ollama pull $MODEL"
      exit 1
    fi
  fi
fi

# Validate: --print requires a prompt or piped stdin
if [ "$PRINT_MODE" = true ] && [ -z "$PROMPT" ] && [ -t 0 ]; then
  echo "Error: --print mode requires a prompt argument or piped input"
  echo "  Usage: $(basename "$0") -p \"your prompt\""
  echo "  Or:    echo \"your prompt\" | $(basename "$0") -p"
  exit 1
fi

# Set up environment for direct Ollama (overrides any router URL from env file)
export ANTHROPIC_AUTH_TOKEN=ollama
export ANTHROPIC_BASE_URL="http://localhost:$OLLAMA_PORT"
export ANTHROPIC_API_KEY=""

# Build Claude command
# In tier mode, omit --model so Claude routes per-request via ANTHROPIC_DEFAULT_*_MODEL
if [ "$USE_TIER_MODELS" = true ] && [ "$MODEL_EXPLICIT" = false ]; then
  CLAUDE_CMD=(env -u CLAUDECODE claude)
else
  CLAUDE_CMD=(env -u CLAUDECODE claude --model "$MODEL")
fi

# Add print mode if requested
if [ "$PRINT_MODE" = true ]; then
  CLAUDE_CMD+=(--print --dangerously-skip-permissions)
fi

# Add any extra arguments
if [ ${#EXTRA_ARGS[@]} -gt 0 ]; then
  CLAUDE_CMD+=("${EXTRA_ARGS[@]}")
fi

# Add prompt if provided
if [ -n "$PROMPT" ]; then
  CLAUDE_CMD+=("$PROMPT")
fi

# Show what we're running
echo "========================================="
echo "Claude Code + Ollama"
echo "========================================="
if [ "$USE_TIER_MODELS" = true ] && [ "$MODEL_EXPLICIT" = false ]; then
  echo "Model: tier routing"
  echo "  haiku  → $ANTHROPIC_DEFAULT_HAIKU_MODEL"
  echo "  sonnet → $ANTHROPIC_DEFAULT_SONNET_MODEL"
  echo "  opus   → $ANTHROPIC_DEFAULT_OPUS_MODEL"
else
  echo "Model: $MODEL"
fi
echo "Ollama: http://localhost:$OLLAMA_PORT"
if [ "$PRINT_MODE" = true ]; then
  echo "Mode: Non-interactive (--print)"
else
  echo "Mode: Interactive"
fi
echo "========================================="
if [[ "${VERBOSE:-0}" == "1" ]]; then
  echo "Command: ${CLAUDE_CMD[*]}"
  echo "========================================="
fi
echo ""

# Launch Claude Code
exec "${CLAUDE_CMD[@]}"
