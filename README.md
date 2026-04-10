# WhisperServer

A self-hosted speech-to-text system running on your Mac, powered by [whisper.cpp](https://github.com/ggerganov/whisper.cpp). Designed as a local alternative to cloud-based transcription services like Wispr Flow — your voice data never leaves your network.

Open a web page on your phone, hold a button to talk, and get transcribed text back. Inference runs on the Apple Silicon GPU via Metal.

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

This starts the whisper.cpp inference server on `0.0.0.0:8080`. Custom model or port:

```bash
./start.sh models/ggml-base.en.bin 9090
```

### 3. Start the Web UI

```bash
./serve-web.sh
```

This serves the web interface over HTTPS on port 3000. A self-signed TLS certificate is generated automatically on first run (required for browser microphone access over the network).

Custom port:

```bash
./serve-web.sh 4000
```

### 4. Use It

1. Open `https://<your-mac-ip>:3000` on your phone (the IP is printed when you run `serve-web.sh`)
2. Accept the self-signed certificate warning in your browser
3. Grant microphone permission when prompted
4. **Hold the button** to record, **release** to transcribe
5. Tap any transcription to copy it to your clipboard

### 5. Test via CLI

```bash
./test.sh
```

Sends a test audio file to the server and prints the transcription. Uses the most recent [Handy](https://github.com/cjpais/Handy) recording if available, or place a `test.wav` in the project directory.

## API

### `POST /inference`

Transcribe an audio file. Accepts any audio format (converted to WAV server-side via ffmpeg).

```bash
curl http://<your-mac-ip>:8080/inference \
  -F "file=@recording.wav" \
  -F "temperature=0.0" \
  -F "response_format=json"
```

Response:

```json
{
  "text": "The transcribed text appears here."
}
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `file` | file | required | Audio file (WAV, MP3, OGG, WebM, etc.) |
| `temperature` | float | `0.0` | Sampling temperature (0.0 = greedy) |
| `temperature_inc` | float | `0.2` | Temperature increment on fallback |
| `response_format` | string | `json` | `json`, `text`, `verbose_json`, `vtt`, or `srt` |

## Architecture

```
┌──────────────┐       HTTPS        ┌──────────────────┐       HTTP        ┌──────────────────┐
│ Phone/Browser │ ── hold to talk ─► │  serve-web.sh     │ ── /inference ──► │  whisper-server   │
│ (mic capture) │ ◄── text ────────  │  (HTTPS :3000)    │ ◄── JSON ───────  │  (Metal GPU :8080)│
└──────────────┘                    └──────────────────┘                   └──────────────────┘
```

## Performance

Benchmarked on Apple M4 with `ggml-large-v3-turbo.bin`:

- ~17 seconds of audio transcribed in ~5 seconds (~3x faster than real-time)
- Model stays resident in GPU memory between requests

## Roadmap

- [ ] Android client app with floating overlay widget for voice recording
- [ ] `launchd` plist for running as a persistent background service
- [ ] Audio compression (Opus/OGG) on the client to reduce upload size
- [ ] Streaming transcription for lower perceived latency
- [ ] mDNS/Bonjour for automatic server discovery on the local network
