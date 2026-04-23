# Bootstrap Recovery

## Purpose

Recover from common setup failures during initial install, local environment drift, or partial host setup.

## When to use

- bootstrap scripts fail early
- `.env` is missing
- Docker is installed but services are not starting
- OpenClaw workspace files exist in the repo but not in the live workspace
- the stack worked before and now feels half-configured

## Typical recovery flow

1. confirm prerequisites exist (`docker`, `docker compose`, `openclaw`)
2. recreate `.env` from `.env.example` if it is missing
3. make sure auxiliary services start cleanly
4. re-run the OpenClaw agent configuration helper if routing or workspace state drifted
5. verify bindings and sandbox state

## Expected good state

- `.env` exists locally
- auxiliary services can start without missing-file errors
- `main` remains host-facing
- `bmo-tron` remains the sandbox worker
- Telegram is routed to `main`

## Common failure modes

- Docker not running
- `.env` missing after a fresh clone or reset
- users expecting Docker Compose to create the OpenClaw sandbox worker
- local clone not matching the current remote branch state

## Related

- scripts/bootstrap-mac.sh
- scripts/bootstrap-wsl.sh
- scripts/bootstrap-linux.sh
- scripts/configure-openclaw-agents.sh
- docs/OPENCLAW_AGENT_SPLIT.md
