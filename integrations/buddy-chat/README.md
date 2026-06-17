# BeMore Buddy Chat app

This integration is the first shippable ChatGPT-side Buddy app surface.

It exposes a dependency-free HTTP MCP-compatible server with a tiny iframe widget so users can create, render, care for, and chat with BeMore Buddies inside ChatGPT.

## What it provides

- `buddy_home` opens the Buddy panel and returns a starter buddy.
- `create_buddy` creates pixel, ASCII, or tamagotchi-style buddy state.
- `care_for_buddy` applies feed/play/rest/work style care events.
- `render_buddy` returns structured ASCII and pixel data for the widget.
- `chat_with_buddy` routes through the configured local OpenAI-compatible model endpoint and falls back safely if the local model is unavailable.

## Runtime boundary

The intended production path is:

```text
ChatGPT app
  -> HTTPS reverse proxy
  -> /mcp on this Buddy Chat server
  -> local OpenAI-compatible Ollama endpoint
  -> gemma4:e2b
```

The Hostinger sovereign cloud knowledge-vault receipt says the VPS is running Ollama with local `gemma4:e2b` at `http://127.0.0.1:11434/v1/`, with `hermes-gateway.service` also active. This app uses the same local model route by default, but does not require Telegram or Hermes-specific credentials to run.

## Local validation

From this folder:

```bash
node scripts/validate.mjs
```

From the repo root, CI runs the same validation before the monorepo type/build checks.

## Local dev

```bash
cd integrations/buddy-chat
BUDDY_CHAT_PORT=4388 node src/server.mjs
curl http://127.0.0.1:4388/healthz
```

Then test the MCP endpoint:

```bash
curl -s http://127.0.0.1:4388/mcp \
  -H 'Content-Type: application/json' \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
```

## Environment variables

| Variable | Default | Purpose |
| --- | --- | --- |
| `BUDDY_CHAT_HOST` | `127.0.0.1` | Bind host. Keep local behind nginx. |
| `BUDDY_CHAT_PORT` | `4388` | Local service port. |
| `BUDDY_CHAT_PUBLIC_BASE_URL` | local URL | Public HTTPS origin used in manifests/CSP. |
| `BUDDY_CHAT_API_TOKEN` | empty | Optional bearer token for `/mcp`; set for public deployments. |
| `BUDDY_MODEL_BASE_URL` | `http://127.0.0.1:11434/v1` | OpenAI-compatible local model endpoint. |
| `BUDDY_MODEL` | `gemma4:e2b` | Local model id. |
| `BUDDY_MODEL_MAX_TOKENS` | `512` | Reply budget. |
| `BUDDY_MODEL_TIMEOUT_MS` | `30000` | Local model timeout. |

## ChatGPT setup

1. Deploy this server behind HTTPS.
2. Use `/manifest.json` to inspect the generated endpoint and widget URLs.
3. Register the app/MCP endpoint as the ChatGPT app tool surface.
4. Start with `buddy_home`, then test `create_buddy`, `render_buddy`, `care_for_buddy`, and `chat_with_buddy`.

## Honest limits

- This is the ChatGPT app/MCP surface, not a native mobile build.
- Buddy state is stateless by default and should be carried by ChatGPT/tool outputs until a persistence layer is intentionally added.
- The widget can call tools only when ChatGPT exposes the bridge for the iframe.
- Public deployment must use HTTPS and an auth/reverse-proxy policy before real users are invited.
