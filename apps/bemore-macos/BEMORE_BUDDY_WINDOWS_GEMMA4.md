# BeMore Buddy Windows + Gemma 4

This runbook wires the existing BeMore desktop runtime into a Windows-launchable Buddy shell and a Gemma 4-only gateway that can also be used by a custom GPT Action.

## What this branch adds

- Windows launcher: `scripts/start-bemore-buddy-windows.ps1`
- Gemma 4 gateway: `apps/bemore-macos/gemma4-gateway.ts`
- Desktop client hooks for Gemma 4 status and chat
- Custom GPT setup files:
  - `apps/bemore-macos/chatgpt-gpt-instructions.md`
  - `apps/bemore-macos/chatgpt-action.openapi.yaml`

This is a localhost-first Windows shell, not a signed installer yet.

## Runtime split

There are two valid local Gemma paths:

1. Desktop/local server path for BeMore Buddy Windows and GPT Actions.
   - Use an OpenAI-compatible endpoint such as Ollama at `http://127.0.0.1:11434/v1`.
   - Start with `BEMORE_GEMMA4_MODEL=gemma4` for proof of life.
2. Phone-native path for iOS/Android apps.
   - Use LiteRT, MediaPipe, AI Edge Gallery, or MLC package artifacts inside the app.
   - Do not treat the desktop gateway as proof that phone-native inference is working.

## Launch on Windows

From the repository root:

```powershell
.\scripts\start-bemore-buddy-windows.ps1
```

The script starts:

- Desktop shell: `http://127.0.0.1:4319`
- Gemma 4 gateway: `http://127.0.0.1:4320`

Keep both terminal windows open while using the app.

## Gemma 4 runtime settings

The gateway expects an OpenAI-compatible chat endpoint.

Default values:

```text
BEMORE_GEMMA4_API_BASE_URL=http://127.0.0.1:11434/v1
BEMORE_GEMMA4_MODEL=gemma4
```

Set `BEMORE_GEMMA4_MODEL` to the exact Gemma 4 model id exposed by your runtime after the first proof-of-life works.

Useful endpoints:

```text
GET  /api/gemma4/status
POST /api/gemma4/chat
GET  /openapi.json
GET  /api/openapi.json
```

## Local proof-of-life

Check the upstream runtime first:

```powershell
Invoke-RestMethod http://127.0.0.1:11434/v1/models
```

Confirm the returned model list includes the value you plan to use for `BEMORE_GEMMA4_MODEL`.

Then check the BeMore gateway:

```powershell
Invoke-RestMethod http://127.0.0.1:4320/api/gemma4/status
```

Then send one short prompt:

```powershell
$body = @{
  messages = @(
    @{ role = "system"; content = "You are BeMore Buddy for Prismtek. Answer briefly." },
    @{ role = "user"; content = "Reply with one short readiness check." }
  )
} | ConvertTo-Json -Depth 5

Invoke-RestMethod http://127.0.0.1:4320/api/gemma4/chat -Method Post -ContentType "application/json" -Body $body
```

Only increase context length, model size, or multimodal inputs after this short prompt works.

## Custom GPT Action setup

1. Start the Gemma 4 gateway.
2. Replace the server URL in `chatgpt-action.openapi.yaml`.
3. Paste `chatgpt-gpt-instructions.md` into the GPT instructions.
4. Add the OpenAPI schema as the GPT Action.
5. Test `getGemma4GatewayStatus`, then `chatWithGemma4`.

## Phone-native checklist

For iOS or Android local inference, verify all of these separately from the desktop gateway:

- The model artifact matches the runtime format expected by the app.
- AI Edge Gallery / MediaPipe tests use `.task` bundles where that runtime expects them.
- LiteRT or Swift wrappers use the package layout they document.
- BeMore iOS MLC package checks still require the app archive to contain configured Gemma package markers and parameter shards.

## Validation

Run:

```powershell
npm --workspace apps/bemore-macos run lint
npm --workspace apps/bemore-macos run build
```

Repository-wide checks:

```powershell
npm run lint
npm run build
```

## Honest boundary

- The gateway enforces Gemma 4 routing by allowlist and model-id checks.
- It cannot prove model availability until the upstream runtime answers successfully.
- ChatGPT custom GPTs do not replace their hosted model with Gemma 4; they call this gateway through an Action.
- Phone-native Gemma uses LiteRT, MediaPipe, AI Edge, or MLC app packaging, not this desktop gateway.
- A signed Windows installer still needs a packaging/signing workflow.
