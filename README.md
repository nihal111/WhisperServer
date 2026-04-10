# WhisperServer (One-Click Wrapper)

This repository is intentionally lightweight.

It does **not** reimplement the Wispr/`whisper.cpp` server. The server already exists and already knows how to run and listen for requests.

The only purpose of this repo is convenience: make local setup on a Mac as close to one-click as possible, so an Android client can send audio to your laptop and get transcription back.

## Upstream and Client Repos

- `whisper.cpp` (upstream server/project): https://github.com/ggerganov/whisper.cpp
- Android client used with this server: https://github.com/nihal111/WhisperClientAndroid

## What This Repo Is

- A thin shell around the existing `whisper-server` binary (from `whisper.cpp` / Homebrew)
- A simple model download helper
- A small local web test UI
- Startup scripts for quick local bring-up

## Intended Workflow

1. Run the server on your Mac.
2. Put your Android phone and Mac on the same Tailscale VPN.
3. Android app sends audio to the Mac server.
4. Mac transcribes locally and returns text.

This gives you a local speech-to-text engine on your laptop that your phone can use, without sending voice to third-party cloud transcription services.

## Quick Start (One-Click Setup)

### 1. Install dependencies

```bash
brew install whisper-cpp ffmpeg
```

### 2. Download model (one command)

```bash
./download-model.sh
```

Optional models:

```bash
./download-model.sh base.en
./download-model.sh small
./download-model.sh large-v3-q5_0
```

### 3. Start transcription server

```bash
./start.sh
```

### 4. (Optional) Start web UI for quick testing

```bash
./serve-web.sh
```

## Android + Tailscale Notes

- Keep the Mac running `./start.sh`
- Connect both Mac and Android device to the same Tailscale network
- Point Android requests to the Mac's Tailscale IP on port `8080`
- Use `POST /inference` with multipart form audio upload

Example:

```bash
curl http://<mac-tailscale-ip>:8080/inference \
  -F "file=@recording.wav" \
  -F "temperature=0.0" \
  -F "response_format=json"
```

## Model Files and Git

Model binaries are intentionally not tracked by Git.

- Ignored path: `models/`
- This keeps large model files out of the repository

You can verify tracked model files with:

```bash
git ls-files models
```

Expected output: empty.

## Repository Scope

This project is deliberately minimal and convenience-focused.

If you need deeper server behavior changes, that belongs in upstream Wispr/`whisper.cpp` server code. This repo is just the local one-click wrapper around that existing server.
