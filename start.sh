#!/bin/bash
# WhisperServer - Local speech-to-text API powered by whisper.cpp
#
# Usage: ./start.sh [model] [port]
#   model: path to ggml model file (default: models/ggml-large-v3-turbo.bin)
#   port:  port to listen on (default: 8080)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MODEL="${1:-$SCRIPT_DIR/models/ggml-large-v3-turbo.bin}"
PORT="${2:-8080}"

if [ ! -f "$MODEL" ]; then
    echo "Error: Model not found at $MODEL"
    echo "Download one from: https://huggingface.co/ggerganov/whisper.cpp/tree/main"
    exit 1
fi

echo "Starting WhisperServer on port $PORT with model: $(basename "$MODEL")"
echo "API endpoint: http://$(ipconfig getifaddr en0):$PORT/inference"
echo ""

exec whisper-server \
    --model "$MODEL" \
    --host 0.0.0.0 \
    --port "$PORT" \
    --language en \
    --convert \
    --print-realtime
