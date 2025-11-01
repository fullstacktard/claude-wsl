#!/bin/bash
# Global Configuration for Claude Code Notifier
# This file is intentionally minimal - only essential settings

# CRITICAL ERROR HANDLING: Never crash the shell when sourced
set +e  # Don't exit on errors
set +u  # Don't exit on undefined variables

# Enable/disable notifications (1=enabled, 0=disabled) - with error handling
export CLAUDE_NOTIFY_ENABLED=1 2>/dev/null || true
