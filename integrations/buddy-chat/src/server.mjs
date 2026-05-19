import http from 'node:http';
import {URL} from 'node:url';
import {APP_MANIFEST, APP_NAME, SERVER_VERSION, TOOL_DEFINITIONS, WIDGET_URI, widgetHtml} from './app-metadata.mjs';
import {buddySystemPrompt, createBuddyProfile, defaultBuddy, evolveBuddy, normalizeBuddy} from './buddy-engine.mjs';

const host = process.env.BUDDY_CHAT_HOST || '127.0.0.1';
const port = Number(process.env.BUDDY_CHAT_PORT || 4388);
const publicBaseUrl = stripTrailingSlash(process.env.BUDDY_CHAT_PUBLIC_BASE_URL || `http://${host}:${port}`);
const authToken = process.env.BUDDY_CHAT_API_TOKEN || '';
const modelBaseUrl = stripTrailingSlash(process.env.BUDDY_MODEL_BASE_URL || 'http://127.0.0.1:11434/v1');
const modelName = process.env.BUDDY_MODEL || 'gemma4:e2b';
const maxModelTokens = Number(process.env.BUDDY_MODEL_MAX_TOKENS || 512);
const modelTimeoutMs = Number(process.env.BUDDY_MODEL_TIMEOUT_MS || 30000);

const toolHandlers = new Map([
  ['buddy_home', buddyHome],
  ['create_buddy', createBuddy],
  ['care_for_buddy', careForBuddy],
  ['chat_with_buddy', chatWithBuddy],
  ['render_buddy', renderBuddy],
]);

const server = http.createServer(async (req, res) => {
  try {
    const url = new URL(req.url || '/', publicBaseUrl);
    setCommonHeaders(res);

    if (req.method === 'OPTIONS') {
      res.writeHead(204);
      res.end();
      return;
    }

    if (req.method === 'GET' && url.pathname === '/healthz') {
      sendJson(res, 200, healthPayload());
      return;
    }

    if (req.method === 'GET' && url.pathname === '/manifest.json') {
      sendJson(res, 200, manifestPayload());
      return;
    }

    if (req.method === 'GET' && url.pathname === '/privacy') {
      sendText(res, 200, privacyText(), 'text/plain; charset=utf-8');
      return;
    }

    if (req.method === 'GET' && url.pathname === '/widget/buddy.html') {
      sendText(res, 200, widgetHtml(), 'text/html+skybridge; charset=utf-8');
      return;
    }

    if (req.method === 'POST' && url.pathname === '/mcp') {
      if (!authorized(req)) {
        sendJson(res, 401, {error: 'missing_or_invalid_bearer_token'});
        return;
      }
      const body = await readJson(req);
      const reply = Array.isArray(body) ? await Promise.all(body.map(handleRpc)) : await handleRpc(body);
      sendJson(res, 200, reply);
      return;
    }

    sendJson(res, 404, {ok: false, error: 'not_found'});
  } catch (error) {
    sendJson(res, 500, {ok: false, error: error instanceof Error ? error.message : String(error)});
  }
});

server.listen(port, host, () => {
  console.log(`${APP_NAME} ${SERVER_VERSION} listening on http://${host}:${port}`);
  console.log(`MCP endpoint: ${publicBaseUrl}/mcp`);
});

async function handleRpc(request) {
  const id = request?.id ?? null;
  try {
    if (!request || request.jsonrpc !== '2.0' || typeof request.method !== 'string') {
      return rpcError(id, -32600, 'Invalid JSON-RPC request.');
    }

    switch (request.method) {
      case 'initialize':
        return rpcResult(id, {
          protocolVersion: request.params?.protocolVersion || '2025-06-18',
          capabilities: {tools: {}, resources: {}},
          serverInfo: {name: 'bemore-buddy-chat', version: SERVER_VERSION},
        });
      case 'notifications/initialized':
        return null;
      case 'ping':
        return rpcResult(id, {});
      case 'tools/list':
        return rpcResult(id, {tools: TOOL_DEFINITIONS});
      case 'tools/call':
        return rpcResult(id, await callTool(request.params));
      case 'resources/list':
        return rpcResult(id, {resources: [widgetResourceDescriptor()]});
      case 'resources/read':
        return rpcResult(id, readResource(request.params));
      default:
        return rpcError(id, -32601, `Unsupported MCP method: ${request.method}`);
    }
  } catch (error) {
    return rpcError(id, -32000, error instanceof Error ? error.message : String(error));
  }
}

async function callTool(params = {}) {
  const name = String(params.name || '');
  const args = typeof params.arguments === 'object' && params.arguments !== null ? params.arguments : {};
  const handler = toolHandlers.get(name);
  if (!handler) throw new Error(`Unknown tool: ${name}`);
  return handler(args);
}

function buddyHome() {
  const buddy = defaultBuddy();
  return toolResult('Buddy home is ready inside ChatGPT.', {
    ok: true,
    buddy,
    status: healthPayload(),
    nextActions: ['create_buddy', 'chat_with_buddy', 'care_for_buddy', 'render_buddy'],
  });
}

function createBuddy(args) {
  const buddy = createBuddyProfile(args);
  return toolResult(`Created ${buddy.name}.`, {
    ok: true,
    buddy,
    message: `${buddy.name} is ready: ${buddy.traits.join(', ')}.`,
  });
}

function careForBuddy(args) {
  const buddy = evolveBuddy(args);
  return toolResult(`${buddy.name} feels ${buddy.mood}.`, {
    ok: true,
    buddy,
    message: `${buddy.name} is now ${buddy.mood}. Energy ${buddy.energy}, bond ${buddy.bond}, level ${buddy.level}.`,
  });
}

function renderBuddy(args) {
  const buddy = normalizeBuddy(args.buddy || defaultBuddy());
  return toolResult(`Rendered ${buddy.name}.`, {
    ok: true,
    buddy,
    render: {
      ascii: buddy.ascii,
      pixel: buddy.pixel,
      palette: buddy.palette,
    },
  });
}

async function chatWithBuddy(args) {
  const buddy = evolveBuddy({buddy: args.buddy || defaultBuddy(), event: 'chat'});
  const message = cleanText(args.message, '').slice(0, 4000);
  const context = cleanText(args.context, '').slice(0, 3000);
  if (!message) throw new Error('message is required.');

  const localFallback = `${buddy.name}: I can help with that. Smallest useful wedge: ${summarizeWedge(message)}`;
  const modelReply = await askLocalModel({buddy, message, context}).catch((error) => ({
    ok: false,
    reply: localFallback,
    error: error instanceof Error ? error.message : String(error),
  }));

  return toolResult(modelReply.reply || localFallback, {
    ok: true,
    buddy,
    reply: modelReply.reply || localFallback,
    model: {
      routed: modelReply.ok === true,
      provider: 'ollama-openai-compatible',
      model: modelName,
      baseUrl: redactLocalUrl(modelBaseUrl),
      error: modelReply.ok ? undefined : modelReply.error,
    },
  });
}

async function askLocalModel({buddy, message, context}) {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), modelTimeoutMs);
  try {
    const response = await fetch(`${modelBaseUrl}/chat/completions`, {
      method: 'POST',
      signal: controller.signal,
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({
        model: modelName,
        messages: [
          {role: 'system', content: buddySystemPrompt(buddy)},
          ...(context ? [{role: 'system', content: `Context supplied by the caller:\n${context}`}] : []),
          {role: 'user', content: message},
        ],
        temperature: 0.4,
        max_tokens: maxModelTokens,
      }),
    });
    if (!response.ok) {
      const text = await response.text();
      throw new Error(`model_http_${response.status}: ${text.slice(0, 500)}`);
    }
    const payload = await response.json();
    const reply = extractText(payload);
    if (!reply) throw new Error('model_response_empty');
    return {ok: true, reply};
  } finally {
    clearTimeout(timeout);
  }
}

function toolResult(text, structuredContent) {
  return {
    content: [{type: 'text', text}],
    structuredContent,
    _meta: {
      'openai/outputTemplate': WIDGET_URI,
      'openai/widgetAccessible': true,
      'openai/resultCanProduceWidget': true,
      widgetSessionId: structuredContent?.buddy?.id || 'bemore-buddy',
    },
  };
}

function readResource(params = {}) {
  const uri = String(params.uri || '');
  if (uri !== WIDGET_URI) throw new Error(`Unknown resource: ${uri}`);
  return {
    contents: [
      {
        uri: WIDGET_URI,
        mimeType: 'text/html+skybridge',
        text: widgetHtml(),
        _meta: {
          'openai/widgetDescription': 'Create, render, care for, and chat with tiny BeMore Buddies inside ChatGPT.',
          'openai/widgetPrefersBorder': true,
          'openai/widgetCSP': {
            connect_domains: [publicBaseUrl],
            resource_domains: [publicBaseUrl],
          },
        },
      },
    ],
  };
}

function widgetResourceDescriptor() {
  return {
    uri: WIDGET_URI,
    name: 'bemore-buddy-widget',
    title: 'BeMore Buddy Widget',
    description: 'Interactive Buddy panel for ChatGPT.',
    mimeType: 'text/html+skybridge',
  };
}

function manifestPayload() {
  return {
    ...APP_MANIFEST,
    publicBaseUrl,
    mcpUrl: `${publicBaseUrl}/mcp`,
    widgetUrl: `${publicBaseUrl}/widget/buddy.html`,
  };
}

function healthPayload() {
  return {
    ok: true,
    service: 'bemore-buddy-chat',
    version: SERVER_VERSION,
    model: modelName,
    modelBaseUrl: redactLocalUrl(modelBaseUrl),
    mcp: '/mcp',
    widget: '/widget/buddy.html',
  };
}

function privacyText() {
  return [
    'BeMore Buddy Chat privacy boundary',
    '',
    '- The app receives tool inputs that ChatGPT sends to the MCP endpoint.',
    '- The app does not persist buddy state by default.',
    '- Model calls route to the configured local OpenAI-compatible endpoint.',
    '- Do not expose this service publicly without HTTPS and auth.',
    '',
  ].join('\n');
}

function authorized(req) {
  if (!authToken) return true;
  const header = req.headers.authorization || '';
  return header === `Bearer ${authToken}`;
}

function rpcResult(id, result) {
  return {jsonrpc: '2.0', id, result};
}

function rpcError(id, code, message) {
  return {jsonrpc: '2.0', id, error: {code, message}};
}

function setCommonHeaders(res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,POST,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'content-type, authorization, mcp-session-id');
  res.setHeader('X-Content-Type-Options', 'nosniff');
}

function sendJson(res, status, payload) {
  res.writeHead(status, {'Content-Type': 'application/json; charset=utf-8'});
  res.end(JSON.stringify(payload, null, 2));
}

function sendText(res, status, text, contentType) {
  res.writeHead(status, {'Content-Type': contentType});
  res.end(text);
}

function readJson(req) {
  return new Promise((resolve, reject) => {
    let body = '';
    req.setEncoding('utf8');
    req.on('data', (chunk) => {
      body += chunk;
      if (body.length > 1_000_000) {
        reject(new Error('request_too_large'));
        req.destroy();
      }
    });
    req.on('end', () => {
      try {
        resolve(body ? JSON.parse(body) : {});
      } catch {
        reject(new Error('invalid_json'));
      }
    });
    req.on('error', reject);
  });
}

function extractText(payload) {
  const content = payload?.choices?.[0]?.message?.content ?? payload?.choices?.[0]?.text;
  if (typeof content === 'string') return content.trim();
  if (Array.isArray(content)) {
    return content.map((part) => (typeof part === 'string' ? part : part?.text || '')).join('').trim();
  }
  return '';
}

function summarizeWedge(message) {
  const words = cleanText(message, 'make a buddy').split(/\s+/).slice(0, 18).join(' ');
  return `make one tiny visible improvement for “${words}”, verify it, then evolve from there.`;
}

function cleanText(value, fallback) {
  const text = String(value ?? fallback ?? '').replace(/[\u0000-\u001f\u007f]/g, ' ').trim();
  return text || fallback;
}

function stripTrailingSlash(value) {
  return String(value || '').replace(/\/+$/, '');
}

function redactLocalUrl(value) {
  return String(value).replace(/(https?:\/\/)[^/]+/, '$1local-host');
}
