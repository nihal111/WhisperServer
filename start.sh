#!/bin/bash
# WhisperServer - Local speech-to-text API powered by whisper.cpp
#
# Usage: ./start.sh [model] [port]
#   model: path to ggml model file (default: models/ggml-large-v3-turbo.bin)
#   port:  port to listen on (default: 8080)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MODEL="${1:-$SCRIPT_DIR/models/ggml-large-v3-turbo.bin}"
PORT="${2:-8080}"
WHISPER_SERVER_BIN="${WHISPER_SERVER_BIN:-$(command -v whisper-server || true)}"

if [ ! -f "$MODEL" ]; then
    echo "Error: Model not found at $MODEL"
    echo "Download one from: https://huggingface.co/ggerganov/whisper.cpp/tree/main"
    exit 1
fi

if [ -z "$WHISPER_SERVER_BIN" ]; then
    echo "Error: whisper-server not found in PATH."
    echo "Install with: brew install whisper-cpp"
    exit 1
fi

echo "Starting WhisperServer on port $PORT with model: $(basename "$MODEL")"
echo "API endpoint: http://$(ipconfig getifaddr en0):$PORT/inference"
echo ""

exec "$WHISPER_SERVER_BIN" \
    --model "$MODEL" \
    --host 0.0.0.0 \
    --port "$PORT" \
    --language en \
    --convert \
    --print-realtime
