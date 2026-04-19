#!/bin/bash
set -euo pipefail

LABEL="com.nihal.whisperserver.web"
SYSTEM_PLIST="/Library/LaunchDaemons/${LABEL}.plist"
USER_PLIST="$HOME/Library/LaunchAgents/${LABEL}.plist"

sudo launchctl bootout system/"${LABEL}" >/dev/null 2>&1 || true
sudo launchctl disable system/"${LABEL}" >/dev/null 2>&1 || true
launchctl bootout "gui/$(id -u)/${LABEL}" >/dev/null 2>&1 || true
launchctl disable "gui/$(id -u)/${LABEL}" >/dev/null 2>&1 || true
sudo rm -f "$SYSTEM_PLIST"
rm -f "$USER_PLIST"

echo "Removed web/proxy launch service: ${LABEL}"
