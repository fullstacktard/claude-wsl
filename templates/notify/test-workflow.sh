#!/bin/bash
# Test script for notification click workflow

echo "=== Testing Notification Click Workflow ==="
echo ""

# Get current session info
CURRENT_WT_SESSION="$WT_SESSION"
CURRENT_SESSION_ID="${CLAUDE_SESSION_ID:-test-$(date +%s)}"
CURRENT_DIR="$(basename "$PWD")"

echo "Current session info:"
echo "  WT_SESSION: $CURRENT_WT_SESSION"
echo "  SESSION_ID: $CURRENT_SESSION_ID"
echo "  Tab Title: $CURRENT_DIR"
echo ""

# Create mock session file
SESSION_FILE="/tmp/claude-session-$CURRENT_SESSION_ID.json"
cat > "$SESSION_FILE" <<EOF
{
  "SessionId": "$CURRENT_SESSION_ID",
  "TabTitle": "$CURRENT_DIR",
  "TabIndex": "",
  "WtSession": "$CURRENT_WT_SESSION",
  "Timestamp": "$(date '+%Y-%m-%d %H:%M:%S')"
}
EOF

echo "Created session file: $SESSION_FILE"
echo "Contents:"
cat "$SESSION_FILE"
echo ""

# Test 1: Create a test notification
echo "=== Test 1: Creating test notification ==="
read -p "Press Enter to send test notification..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden \
    -File "$(wslpath -w "$SCRIPT_DIR/send-notification.ps1")" \
    -Title "Test Notification" \
    -Message "Click me to test window focus!" \
    -SessionId "$CURRENT_SESSION_ID" \
    -TabTitle "$CURRENT_DIR" \
    -WtSession "$CURRENT_WT_SESSION"

echo "Notification sent! Check if it appears."
echo ""

# Test 2: Manually trigger focus script
echo "=== Test 2: Testing focus script directly ==="
echo "This will try to focus this tab. Switch to another tab first!"
read -p "Switch to a different tab, then press Enter to trigger focus..."

# Create focus signal file
touch "/tmp/claude-focus-$CURRENT_SESSION_ID"

# Call focus script directly
powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden \
    -File "$(wslpath -w "$SCRIPT_DIR/focus-terminal-improved.ps1")" \
    -SessionId "$CURRENT_SESSION_ID"

echo ""
echo "Check the log file for details:"
echo "  powershell.exe -Command \"Get-Content '\$env:TEMP\\claude-focus-debug.log' -Tail 50\""
echo ""

# Test 3: Check for signal file cleanup
echo "=== Test 3: Checking signal file cleanup ==="
if [ -f "/tmp/claude-focus-$CURRENT_SESSION_ID" ]; then
    echo "❌ Signal file still exists (should be cleaned by prompt hook)"
else
    echo "✓ Signal file cleaned up correctly"
fi

echo ""
echo "=== Testing Complete ==="
echo ""
echo "To view detailed logs:"
echo "  Windows: powershell.exe -Command \"Get-Content '\$env:TEMP\\claude-focus-debug.log'\""
echo "  WSL: cat /tmp/claude-notify-debug.log"
