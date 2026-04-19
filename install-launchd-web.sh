#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LABEL="com.nihal.whisperserver.web"
PLIST_DIR="/Library/LaunchDaemons"
PLIST_PATH="${PLIST_DIR}/${LABEL}.plist"
LOG_DIR="$SCRIPT_DIR/data"
PORT="${1:-3000}"
RUN_AS_USER="${RUN_AS_USER:-$(id -un)}"
RUN_AS_GROUP="${RUN_AS_GROUP:-$(id -gn)}"

mkdir -p "$LOG_DIR"

TMP_PLIST="$(mktemp /tmp/${LABEL}.XXXXXX.plist)"
trap 'rm -f "$TMP_PLIST"' EXIT
cat > "$TMP_PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>${LABEL}</string>

  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>${SCRIPT_DIR}/serve-web.sh</string>
    <string>${PORT}</string>
  </array>

  <key>EnvironmentVariables</key>
  <dict>
    <key>PATH</key>
    <string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
  </dict>

  <key>WorkingDirectory</key>
  <string>${SCRIPT_DIR}</string>

  <key>UserName</key>
  <string>${RUN_AS_USER}</string>
  <key>GroupName</key>
  <string>${RUN_AS_GROUP}</string>
  <key>InitGroups</key>
  <true/>

  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>

  <key>StandardOutPath</key>
  <string>${LOG_DIR}/web-ui.log</string>
  <key>StandardErrorPath</key>
  <string>${LOG_DIR}/web-ui.log</string>
</dict>
</plist>
PLIST

sudo install -o root -g wheel -m 644 "$TMP_PLIST" "$PLIST_PATH"

sudo launchctl bootout system "$PLIST_PATH" >/dev/null 2>&1 || true
sudo launchctl bootstrap system "$PLIST_PATH"
sudo launchctl enable system/"${LABEL}"
sudo launchctl kickstart -k system/"${LABEL}"

echo "Installed and started LaunchDaemon: ${LABEL}"
echo "Plist: ${PLIST_PATH}"
