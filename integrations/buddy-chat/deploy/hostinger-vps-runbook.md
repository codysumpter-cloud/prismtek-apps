# Hostinger VPS runbook for BeMore Buddy Chat

This runbook deploys the Buddy Chat app surface next to the existing Hermes/Ollama stack.

## Source of truth

The Buddy Chat app is designed to run behind HTTPS and route model calls to a local OpenAI-compatible Ollama endpoint.

Default local route:

- model base URL: `http://127.0.0.1:11434/v1/`
- model: `gemma4:e2b`

## Install or update repo

```bash
sudo mkdir -p /opt/prismtek-apps
sudo chown -R hermes:hermes /opt/prismtek-apps
sudo -u hermes git -C /opt/prismtek-apps pull origin main || \
  sudo -u hermes git clone https://github.com/codysumpter-cloud/prismtek-apps /opt/prismtek-apps
```

## Validate app locally

```bash
cd /opt/prismtek-apps/integrations/buddy-chat
node scripts/validate.mjs
```

## Install systemd service

```bash
sudo cp /opt/prismtek-apps/integrations/buddy-chat/deploy/bemore-buddy-chat.service /etc/systemd/system/bemore-buddy-chat.service
sudo systemctl daemon-reload
sudo systemctl enable --now bemore-buddy-chat.service
sudo systemctl status bemore-buddy-chat.service --no-pager
curl -s http://127.0.0.1:4388/healthz
```

Before exposing publicly, edit the service file and set:

```text
BUDDY_CHAT_PUBLIC_BASE_URL=https://YOUR_PUBLIC_BUDDY_DOMAIN
BUDDY_CHAT_API_TOKEN=YOUR_RANDOM_BEARER_TOKEN
```

Keep `BUDDY_CHAT_HOST=127.0.0.1`; nginx should terminate HTTPS and reverse-proxy to the local service.

## Nginx sketch

```nginx
server {
  listen 443 ssl http2;
  server_name buddy.example.com;

  location / {
    proxy_pass http://127.0.0.1:4388;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-Proto https;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  }
}
```

Do not change DNS without explicit approval.

## Smoke tests

```bash
curl -s https://YOUR_PUBLIC_BUDDY_DOMAIN/healthz
curl -s https://YOUR_PUBLIC_BUDDY_DOMAIN/manifest.json
curl -s https://YOUR_PUBLIC_BUDDY_DOMAIN/mcp \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer YOUR_RANDOM_BEARER_TOKEN' \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
```

Then register the HTTPS `/mcp` endpoint in ChatGPT app setup.

## Rollback

```bash
sudo systemctl disable --now bemore-buddy-chat.service
sudo rm -f /etc/systemd/system/bemore-buddy-chat.service
sudo systemctl daemon-reload
```
