# CLAUDE.md

Project operating guidance.

## Purpose

This repository is a thin convenience wrapper around upstream `whisper.cpp` server components.
It exists to provide one-click setup and stable background operation for Android + Tailscale use.

## Non-Negotiable Port Semantics

- `8080` = raw whisper API (`http://`, `whisper-server`)
- `3000` = HTTPS web/proxy (`https://`, `serve-web.sh` + `web/server.py`)

The proxy on `3000` forwards transcription requests to `127.0.0.1:8080`.

## Client Integration Rules

- Raw API client: `http://<host>:8080` + `POST /inference`
- Proxy client: `https://<host>:3000` + `POST /inference`
- Do not use `GET /inference` as health check; it is expected to be `404`.
- Use `GET /` for connectivity checks.

## Runbook (Preferred)

1. Ensure model exists (`./download-model.sh`).
2. Start persistent background services (`./install-all-bg.sh`).
3. Verify both services (`./status.sh`).
4. Stop services only when needed (`./uninstall-all-bg.sh`).

## Service Names

- `com.nihal.whisperserver`
- `com.nihal.whisperserver.web`

## Background Mode

The preferred background install uses system `LaunchDaemons`, not user `LaunchAgents`, so the services survive logout.

## Doc Update Policy

When updating docs/scripts, keep `3000` and `8080` semantics explicit and consistent everywhere.
