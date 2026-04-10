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
LOCAL_IP="$(ipconfig getifaddr en0 2>/dev/null || true)"
TAILSCALE_IP="$(ifconfig | awk '/inet 100\./ { print $2; exit }')"

if [ -z "$LOCAL_IP" ]; then
    LOCAL_IP="127.0.0.1"
fi

SAN="IP:${LOCAL_IP},IP:127.0.0.1,DNS:localhost"
if [ -n "$TAILSCALE_IP" ]; then
    SAN="${SAN},IP:${TAILSCALE_IP}"
fi

# Generate or refresh self-signed cert if missing or SAN is stale
NEED_CERT=0
if [ ! -f "$CERT" ] || [ ! -f "$KEY" ]; then
    NEED_CERT=1
elif ! openssl x509 -in "$CERT" -noout -text 2>/dev/null | rg -q "IP Address:${LOCAL_IP}"; then
    NEED_CERT=1
elif [ -n "$TAILSCALE_IP" ] && ! openssl x509 -in "$CERT" -noout -text 2>/dev/null | rg -q "IP Address:${TAILSCALE_IP}"; then
    NEED_CERT=1
fi

if [ "$NEED_CERT" -eq 1 ]; then
    echo "Generating self-signed TLS certificate..."
    mkdir -p "$CERT_DIR"
    openssl req -x509 -newkey rsa:2048 -nodes \
        -keyout "$KEY" -out "$CERT" \
        -days 365 -subj "/CN=WhisperServer" \
        -addext "subjectAltName=${SAN}" \
        2>/dev/null
    echo "Certificate created at $CERT_DIR/"
    echo ""
fi

echo "Web UI: https://${LOCAL_IP}:$PORT"
if [ -n "$TAILSCALE_IP" ]; then
    echo "Web UI (Tailscale): https://${TAILSCALE_IP}:$PORT"
fi
echo "Whisper API must be running on port 8080 (./start.sh)"
echo ""
echo "NOTE: Your browser will warn about the self-signed certificate."
echo "      Accept/trust it to proceed."
echo ""

exec python3 "$SCRIPT_DIR/web/server.py" "$PORT" "$CERT" "$KEY" "$SCRIPT_DIR/web"
