#!/bin/bash
# Load devcontainer environment variables from mounted config files
# NOTE: Disabled - Claude OAuth is stored in ~/.claude/.credentials.json instead

# The CLAUDE_CODE_OAUTH_TOKEN env var conflicts with interactive mode
# So we don't load it. Use `claude setup-token` instead for one-time auth.
