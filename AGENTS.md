# AGENTS.md

Operational rules for humans and coding agents working in this repository.

## System Architecture Contract

This repo always operates two services:

1. Whisper API service
- Port: `8080`
- Process: `whisper-server` (via `start.sh` / launchd)
- Protocol: `http`
- Transcription endpoint: `POST /inference`

2. Web/proxy service
- Port: `3000`
- Process: `web/server.py` via `serve-web.sh` / launchd
- Protocol: `https`
- Proxies `POST /inference` to `http://127.0.0.1:8080/inference`

Do not collapse these into one conceptual endpoint in docs or scripts.

## Endpoint Expectations

- `GET /inference` returns `404` on both services by design.
- Health/connectivity checks should use `GET /`.
- If client is configured for port `3000`, it must use `https://`.
- If client is configured for port `8080`, it must use `http://`.

## Default Runtime Mode

Default is persistent background mode via `launchd`.

Use:
- `./install-all-bg.sh` to install/start both agents
- `./status.sh` to verify both are loaded and listening
- `./uninstall-all-bg.sh` to stop/remove both

Avoid relying on foreground-only runs except for debugging.

## Service Labels

- API: `com.nihal.whisperserver`
- Web: `com.nihal.whisperserver.web`

## Background Runtime

The recommended install path uses system `LaunchDaemons` so the services survive GUI logout.
Legacy `LaunchAgents` may still exist on older installs, but new installs should use the daemon path.

## TLS/SAN Requirement for 3000

`serve-web.sh` must keep certificate SAN aligned with current LAN and Tailscale IPs so mobile clients can connect to `https://<tailscale-ip>:3000`.

## Documentation Requirements

Any doc changes must preserve and state:
- `3000` vs `8080` role split
- protocol split (`https` vs `http`)
- persistent background workflow as recommended default
