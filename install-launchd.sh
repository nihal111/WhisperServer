#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LABEL="com.nihal.whisperserver"
PLIST_DIR="/Library/LaunchDaemons"
PLIST_PATH="${PLIST_DIR}/${LABEL}.plist"
LOG_DIR="$SCRIPT_DIR/data"
MODEL_PATH="${1:-$SCRIPT_DIR/models/ggml-large-v3-turbo.bin}"
PORT="${2:-8080}"
WHISPER_SERVER_BIN="${WHISPER_SERVER_BIN:-$(command -v whisper-server || true)}"
RUN_AS_USER="${RUN_AS_USER:-$(id -un)}"
RUN_AS_GROUP="${RUN_AS_GROUP:-$(id -gn)}"

if [ ! -f "$MODEL_PATH" ]; then
  echo "Error: model not found at $MODEL_PATH"
  echo "Run: ./download-model.sh"
  exit 1
fi

if [ -z "$WHISPER_SERVER_BIN" ]; then
  echo "Error: whisper-server not found in PATH."
  echo "Install with: brew install whisper-cpp"
  exit 1
fi

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
    <string>${SCRIPT_DIR}/start.sh</string>
    <string>${MODEL_PATH}</string>
    <string>${PORT}</string>
  </array>

  <key>EnvironmentVariables</key>
  <dict>
    <key>PATH</key>
    <string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
    <key>WHISPER_SERVER_BIN</key>
    <string>${WHISPER_SERVER_BIN}</string>
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
  <string>${LOG_DIR}/whisper-server.log</string>
  <key>StandardErrorPath</key>
  <string>${LOG_DIR}/whisper-server.log</string>
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
