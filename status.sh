#!/bin/bash
set -euo pipefail

LABEL="com.nihal.whisperserver"
WEB_LABEL="com.nihal.whisperserver.web"

if launchctl print "gui/$(id -u)/${LABEL}" >/tmp/whisper-launchd-status.txt 2>/dev/null; then
  echo "Whisper API LaunchAgent: loaded"
  rg "state =|pid =|last exit code =" /tmp/whisper-launchd-status.txt || true
else
  echo "Whisper API LaunchAgent: not loaded"
fi

echo ""
if launchctl print "gui/$(id -u)/${WEB_LABEL}" >/tmp/whisper-web-launchd-status.txt 2>/dev/null; then
  echo "Web UI LaunchAgent: loaded"
  rg "state =|pid =|last exit code =" /tmp/whisper-web-launchd-status.txt || true
else
  echo "Web UI LaunchAgent: not loaded"
fi

echo ""
echo "Port 8080:"
lsof -iTCP:8080 -sTCP:LISTEN -n -P || true
echo ""
echo "Port 3000:"
lsof -iTCP:3000 -sTCP:LISTEN -n -P || true
