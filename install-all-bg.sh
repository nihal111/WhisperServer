#!/bin/bash
set -euo pipefail

# Installs and starts both background launch daemons:
# - API server on 8080
# - HTTPS web proxy on 3000
#
# Usage:
#   ./install-all-bg.sh
#   ./install-all-bg.sh /abs/path/to/model.bin
#   ./install-all-bg.sh /abs/path/to/model.bin 8080 3000

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MODEL_PATH="${1:-$SCRIPT_DIR/models/ggml-large-v3-turbo.bin}"
API_PORT="${2:-8080}"
WEB_PORT="${3:-3000}"

# Clear stale launchctl state before reinstalling both services.
launchctl bootout "gui/$(id -u)/com.nihal.whisperserver" >/dev/null 2>&1 || true
launchctl bootout "gui/$(id -u)/com.nihal.whisperserver.web" >/dev/null 2>&1 || true

"$SCRIPT_DIR/install-launchd.sh" "$MODEL_PATH" "$API_PORT"
"$SCRIPT_DIR/install-launchd-web.sh" "$WEB_PORT"
"$SCRIPT_DIR/status.sh"
