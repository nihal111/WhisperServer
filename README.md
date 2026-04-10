# WhisperServer (One-Click Wrapper)

This repository is intentionally lightweight.

It does not reimplement Wispr/`whisper.cpp` server logic. It is a convenience shell to make setup on Mac one-click and keep a local transcription stack running for an Android client.

## Upstream and Client Repos

- `whisper.cpp` (upstream): https://github.com/ggerganov/whisper.cpp
- Android client for this server: https://github.com/nihal111/WhisperClientAndroid

## Core Semantics: Port 3000 vs 8080

There are two different services and both are important.

| Port | Service | Protocol | Purpose |
|---|---|---|---|
| `8080` | `whisper-server` | HTTP | Raw transcription API (`POST /inference`) |
| `3000` | `serve-web.sh` (`web/server.py`) | HTTPS | Web/proxy layer that forwards `POST /inference` to `http://127.0.0.1:8080` |

### Endpoint behavior

- `http://<host>:8080/` -> Whisper server landing page
- `http://<host>:8080/inference` -> **POST only** for transcription
- `https://<host>:3000/` -> Web UI landing page
- `https://<host>:3000/inference` -> Proxy endpoint, **POST only**

Important:
- Port `3000` is TLS (`https://`) only.
- Port `8080` is plain HTTP (`http://`) only.
- A `GET` to `/inference` returns `404`; this is expected.

## Quick Setup

### 1. Install dependencies

```bash
brew install whisper-cpp ffmpeg
```

### 2. Download model

```bash
./download-model.sh
```

Optional:

```bash
./download-model.sh base.en
./download-model.sh small
./download-model.sh large-v3-q5_0
```

### 3. Start everything in background (recommended)

```bash
./install-all-bg.sh
```

This installs and starts both launch agents:
- `com.nihal.whisperserver` (API on `8080`)
- `com.nihal.whisperserver.web` (HTTPS web/proxy on `3000`)

### 4. Check status

```bash
./status.sh
```

### 5. Stop everything

```bash
./uninstall-all-bg.sh
```

## Tailscale + Android Usage

Connect your Mac and phone to the same Tailscale network.

You can use either integration style:

1. Android app calls raw API directly:
- Base URL: `http://<mac-tailscale-ip>:8080`
- Transcribe: `POST /inference` multipart form

2. Android app calls HTTPS proxy:
- Base URL: `https://<mac-tailscale-ip>:3000`
- Transcribe: `POST /inference` multipart form
- Good when the client expects TLS on device networks

`serve-web.sh` automatically generates a self-signed cert and includes LAN + Tailscale IPs in SAN.

## Local Foreground Mode (manual)

Use this only for direct debugging.

```bash
./start.sh
./serve-web.sh
```

## Model Files and Git

Model binaries are intentionally not tracked by git.

- Ignored path: `models/`

Verify:

```bash
git ls-files models
```

Expected output: empty.

## Project Scope

This project is deliberately minimal and convenience-focused.

If you need deeper server behavior changes, those belong in upstream Wispr/`whisper.cpp` server code.
