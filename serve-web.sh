#!/bin/bash
# Serve the web UI for WhisperServer over HTTPS
# Usage: ./serve-web.sh [port]
#   port: port for the web UI (default: 3000)
#
# HTTPS is required for browser microphone access on non-localhost origins.
# On first run, generates a self-signed certificate in certs/.

PORT="${1:-3000}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CERT_DIR="$SCRIPT_DIR/certs"
CERT="$CERT_DIR/cert.pem"
KEY="$CERT_DIR/key.pem"

# Generate self-signed cert if missing
if [ ! -f "$CERT" ] || [ ! -f "$KEY" ]; then
    echo "Generating self-signed TLS certificate..."
    mkdir -p "$CERT_DIR"
    openssl req -x509 -newkey rsa:2048 -nodes \
        -keyout "$KEY" -out "$CERT" \
        -days 365 -subj "/CN=WhisperServer" \
        -addext "subjectAltName=IP:$(ipconfig getifaddr en0),IP:127.0.0.1,DNS:localhost" \
        2>/dev/null
    echo "Certificate created at $CERT_DIR/"
    echo ""
fi

LOCAL_IP="$(ipconfig getifaddr en0)"
echo "Web UI: https://${LOCAL_IP}:$PORT"
echo "Whisper API must be running on port 8080 (./start.sh)"
echo ""
echo "NOTE: Your browser will warn about the self-signed certificate."
echo "      Accept/trust it to proceed."
echo ""

exec python3 "$SCRIPT_DIR/web/server.py" "$PORT" "$CERT" "$KEY" "$SCRIPT_DIR/web"
