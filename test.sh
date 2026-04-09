#!/bin/bash
# Quick test: record 5 seconds of audio and send to the server
#
# Usage: ./test.sh [server_url]
#   server_url: full URL (default: http://localhost:8080)

SERVER="${1:-http://localhost:8080}"

# Check if a test WAV file exists, otherwise try to use one from Handy's recordings
TEST_FILE=""
if [ -f "test.wav" ]; then
    TEST_FILE="test.wav"
else
    # Grab the most recent Handy recording as a test file
    HANDY_REC=$(ls -t ~/Library/Application\ Support/com.pais.handy/recordings/*.wav 2>/dev/null | head -1)
    if [ -n "$HANDY_REC" ]; then
        TEST_FILE="$HANDY_REC"
        echo "Using Handy recording: $(basename "$TEST_FILE")"
    else
        echo "No test audio found. Either:"
        echo "  1. Place a test.wav in this directory"
        echo "  2. Record something with Handy first"
        exit 1
    fi
fi

echo "Sending audio to $SERVER/inference ..."
echo ""

curl -s "$SERVER/inference" \
    -H "Content-Type: multipart/form-data" \
    -F "file=@$TEST_FILE" \
    -F "temperature=0.0" \
    -F "temperature_inc=0.2" \
    -F "response_format=json" | python3 -m json.tool

echo ""
