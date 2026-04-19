#!/bin/bash
set -euo pipefail

LABEL="com.nihal.whisperserver"
WEB_LABEL="com.nihal.whisperserver.web"
SYSTEM_API_PLIST="/Library/LaunchDaemons/${LABEL}.plist"
SYSTEM_WEB_PLIST="/Library/LaunchDaemons/${WEB_LABEL}.plist"
USER_API_PLIST="$HOME/Library/LaunchAgents/${LABEL}.plist"
USER_WEB_PLIST="$HOME/Library/LaunchAgents/${WEB_LABEL}.plist"

if launchctl print "system/${LABEL}" >/tmp/whisper-launchd-status.txt 2>/dev/null; then
  echo "Whisper API LaunchDaemon: loaded"
  rg "state =|pid =|last exit code =" /tmp/whisper-launchd-status.txt || true
else
  echo "Whisper API LaunchDaemon: not loaded"
fi

echo ""
if launchctl print "system/${WEB_LABEL}" >/tmp/whisper-web-launchd-status.txt 2>/dev/null; then
  echo "Web UI LaunchDaemon: loaded"
  rg "state =|pid =|last exit code =" /tmp/whisper-web-launchd-status.txt || true
else
  echo "Web UI LaunchDaemon: not loaded"
fi

echo ""
echo "Plists:"
echo "  API: ${SYSTEM_API_PLIST}"
echo "  Web: ${SYSTEM_WEB_PLIST}"
echo "  Legacy API: ${USER_API_PLIST}"
echo "  Legacy Web: ${USER_WEB_PLIST}"
echo ""
echo "Port 8080:"
lsof -iTCP:8080 -sTCP:LISTEN -n -P || true
echo ""
echo "Port 3000:"
lsof -iTCP:3000 -sTCP:LISTEN -n -P || true
