#!/bin/bash
set -euo pipefail

LABEL="com.nihal.whisperserver"

if launchctl print "gui/$(id -u)/${LABEL}" >/tmp/whisper-launchd-status.txt 2>/dev/null; then
  echo "LaunchAgent: loaded"
  rg "state =|pid =|last exit code =" /tmp/whisper-launchd-status.txt || true
else
  echo "LaunchAgent: not loaded"
fi

echo ""
echo "Port 8080:"
lsof -iTCP:8080 -sTCP:LISTEN -n -P || true
