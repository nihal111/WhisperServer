# WhisperServer

A self-hosted speech-to-text API running on your Mac, powered by [whisper.cpp](https://github.com/ggerganov/whisper.cpp). Designed as a local alternative to cloud-based transcription services like Wispr Flow — your voice data never leaves your network.

## How It Works

Your Mac runs a `whisper-server` instance that exposes an HTTP API on your local network. Any device (phone, tablet, another computer) can send audio to it and receive transcribed text back. Inference runs on the Apple Silicon GPU via Metal for fast performance.

## Prerequisites

- macOS with Apple Silicon (M1+)
- [Homebrew](https://brew.sh)

Install dependencies:

```bash
brew install whisper-cpp ffmpeg
```

## Setup

### 1. Download a Model

Download a Whisper GGML model into the `models/` directory:

```bash
mkdir -p models

# Recommended: Large V3 Turbo (1.5GB) — best speed/quality balance
curl -L -o models/ggml-large-v3-turbo.bin \
  "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo.bin"
```

Other model options (from [huggingface.co/ggerganov/whisper.cpp](https://huggingface.co/ggerganov/whisper.cpp/tree/main)):

| Model | Size | Speed | Quality | Best For |
|-------|------|-------|---------|----------|
| `ggml-base.en.bin` | 142MB | Fastest | Good | Quick English-only use |
| `ggml-small.bin` | 466MB | Fast | Better | Multilingual, low latency |
| `ggml-large-v3-turbo.bin` | 1.5GB | Medium | Great | **Recommended default** |
| `ggml-large-v3-q5_0.bin` | 1.1GB | Slow | Best | Maximum accuracy |

### 2. Start the Server

```bash
./start.sh
```

This starts the server on `0.0.0.0:8080`, accessible from any device on your local network.

Custom model or port:

```bash
./start.sh models/ggml-base.en.bin 9090
```

### 3. Test It

```bash
./test.sh
```

This sends a test audio file to the server and prints the transcription. It will automatically use the most recent [Handy](https://github.com/cjpais/Handy) recording if you have one, or you can place a `test.wav` in the project directory.

## API

### `POST /inference`

Transcribe an audio file. Accepts any audio format (converted to WAV server-side via ffmpeg).

**Request:**

```bash
curl http://<your-mac-ip>:8080/inference \
  -F "file=@recording.wav" \
  -F "temperature=0.0" \
  -F "response_format=json"
```

**Response:**

```json
{
  "text": "The transcribed text appears here."
}
```

**Parameters:**

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `file` | file | required | Audio file (WAV, MP3, OGG, FLAC, etc.) |
| `temperature` | float | `0.0` | Sampling temperature (0.0 = greedy, most deterministic) |
| `temperature_inc` | float | `0.2` | Temperature increment on decoder failure/fallback |
| `response_format` | string | `json` | `json`, `text`, `verbose_json`, `vtt`, or `srt` |

### `GET /`

Serves a built-in web UI for testing transcription in the browser.

## Performance

Benchmarked on Apple M4 with `ggml-large-v3-turbo.bin`:

- ~17 seconds of audio transcribed in ~5 seconds (~3x faster than real-time)
- Model loaded into GPU memory via Metal, stays resident between requests

## Architecture

```
┌──────────────┐         HTTP POST         ┌──────────────────┐
│ Android App  │  ──── /inference ────────► │  whisper-server   │
│ (or any      │  (audio file)             │  (Mac, port 8080) │
│  HTTP client)│ ◄──── JSON ──────────────  │  Metal GPU accel  │
└──────────────┘   {"text": "..."}         └──────────────────┘
```

## Roadmap

- [ ] Android client app with floating overlay widget for voice recording
- [ ] `launchd` plist for running the server as a persistent background service
- [ ] Audio compression (Opus/OGG) on the client to reduce upload size
- [ ] Streaming transcription for lower perceived latency
- [ ] mDNS/Bonjour for automatic server discovery on the local network
