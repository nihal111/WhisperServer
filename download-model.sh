#!/bin/bash
set -euo pipefail

# One-click model download for WhisperServer.
# Usage:
#   ./download-model.sh
#   ./download-model.sh base.en
#   ./download-model.sh small
#   ./download-model.sh large-v3-turbo

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MODEL_DIR="$SCRIPT_DIR/models"
MODEL_KEY="${1:-large-v3-turbo}"

case "$MODEL_KEY" in
  base.en)
    MODEL_FILE="ggml-base.en.bin"
    ;;
  small)
    MODEL_FILE="ggml-small.bin"
    ;;
  large-v3-turbo)
    MODEL_FILE="ggml-large-v3-turbo.bin"
    ;;
  large-v3-q5_0)
    MODEL_FILE="ggml-large-v3-q5_0.bin"
    ;;
  *)
    echo "Unknown model '$MODEL_KEY'"
    echo "Choose one of: base.en, small, large-v3-turbo, large-v3-q5_0"
    exit 1
    ;;
esac

URL="https://huggingface.co/ggerganov/whisper.cpp/resolve/main/${MODEL_FILE}"
TARGET="$MODEL_DIR/$MODEL_FILE"

mkdir -p "$MODEL_DIR"

if [ -f "$TARGET" ]; then
  echo "Model already exists: $TARGET"
  exit 0
fi

echo "Downloading $MODEL_FILE ..."
curl -fL "$URL" -o "$TARGET"

echo "Done: $TARGET"
