#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

"$SCRIPT_DIR/uninstall-launchd-web.sh" || true
"$SCRIPT_DIR/uninstall-launchd.sh" || true
"$SCRIPT_DIR/status.sh"
