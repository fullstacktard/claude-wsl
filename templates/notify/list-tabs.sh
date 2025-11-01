#!/bin/bash

echo "=== Tabs in this Windows Terminal window ==="
echo ""

pgrep bash | while IFS= read -r bashpid; do
  wtsess=$(cat /proc/$bashpid/environ 2>/dev/null | tr '\0' '\n' | grep '^WT_SESSION=' | cut -d= -f2)
  pty=$(readlink /proc/$bashpid/fd/0 2>/dev/null)
  cmd=$(ps -p $bashpid -o args= 2>/dev/null | head -c 60)

  if [ -n "$wtsess" ] && [ "$pty" != "not a tty" ] && [[ "$pty" == /dev/pts/* ]]; then
    echo "Session: $wtsess"
    echo "  PID: $bashpid"
    echo "  PTY: $pty"
    echo "  Cmd: $cmd"
    echo ""
  fi
done
