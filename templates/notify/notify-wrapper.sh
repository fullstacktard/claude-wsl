#!/bin/bash
# Wrapper to suppress all output from notify.sh
# This prevents Claude Code from seeing hook errors
# CRITICAL: Always exit 0 - never fail the hook even if notify.sh fails

# CRITICAL ERROR HANDLING: Never crash or fail
set +e  # Don't exit on errors
set +u  # Don't exit on undefined variables

# Safe directory determination with fallback
if [ -n "${BASH_SOURCE[0]}" ] 2>/dev/null; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)" || SCRIPT_DIR="/tmp"
else
    SCRIPT_DIR="/tmp"
fi

# Execute notify.sh with error suppression
# Pass stdin through so notify.sh can receive hook data from Claude Code
# Suppress stdout/stderr to prevent polluting Claude's output
# Even if notify.sh doesn't exist or fails, we exit 0
if [ -f "$SCRIPT_DIR/notify.sh" ] 2>/dev/null && [ -r "$SCRIPT_DIR/notify.sh" ] 2>/dev/null; then
    "$SCRIPT_DIR/notify.sh" >/dev/null 2>&1 || true
fi

# ALWAYS exit successfully - hook must never fail
exit 0
