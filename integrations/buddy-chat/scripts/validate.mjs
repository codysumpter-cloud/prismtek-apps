import {spawn} from 'node:child_process';
import {setTimeout as delay} from 'node:timers/promises';
import {TOOL_DEFINITIONS, WIDGET_URI} from '../src/app-metadata.mjs';
import {createBuddyProfile, evolveBuddy} from '../src/buddy-engine.mjs';

const port = 4399;
const baseUrl = `http://127.0.0.1:${port}`;
let rpcId = 0;

assert(TOOL_DEFINITIONS.length >= 5, 'expected at least five app tools');
assert(
  TOOL_DEFINITIONS.every((tool) => tool.inputSchema?.type === 'object'),
  'every tool needs a JSON object input schema',
);
assert(
  TOOL_DEFINITIONS.every((tool) => tool._meta?.['openai/outputTemplate'] === WIDGET_URI),
  'every tool should point at the widget output template',
);

const created = createBuddyProfile({
  name: 'Lint Sprite',
  kind: 'tamagotchi',
  vibe: 'checks code',
  palette: 'mint,graphite',
});
assert(created.name === 'Lint Sprite', 'buddy name should round-trip');
assert(created.kind === 'tamagotchi', 'buddy kind should round-trip');
assert(created.pixel.length > 0, 'buddy pixel data should render');

const evolved = evolveBuddy({buddy: created, event: 'play'});
assert(evolved.bond > created.bond, 'care event should increase bond');

const child = spawn(process.execPath, ['src/server.mjs'], {
  cwd: new URL('..', import.meta.url),
  env: {
    ...process.env,
    BUDDY_CHAT_HOST: '127.0.0.1',
    BUDDY_CHAT_PORT: String(port),
    BUDDY_MODEL_BASE_URL: 'http://127.0.0.1:1/v1',
    BUDDY_MODEL_TIMEOUT_MS: '250',
  },
  stdio: ['ignore', 'pipe', 'pipe'],
});

let stderr = '';
child.stderr.on('data', (chunk) => {
  stderr += chunk.toString();
});

try {
  await waitForHealth();
  const manifest = await getJson('/manifest.json');
  assert(manifest.mcpUrl === `${baseUrl}/mcp`, 'manifest should expose MCP URL');
  assert(manifest.widgetUrl === `${baseUrl}/widget/buddy.html`, 'manifest should expose widget URL');

  const init = await rpc('initialize', {protocolVersion: '2025-06-18'});
  assert(init.result.serverInfo.name === 'bemore-buddy-chat', 'initialize should identify the server');

  const tools = await rpc('tools/list');
  assert(tools.result.tools.some((tool) => tool.name === 'create_buddy'), 'tools/list should include create_buddy');

  const home = await rpc('tools/call', {name: 'buddy_home', arguments: {}});
  assert(home.result.structuredContent.buddy.name === 'BMO Buddy', 'buddy_home should return starter buddy');

  const made = await rpc('tools/call', {
    name: 'create_buddy',
    arguments: {
      name: 'Pocket Prism',
      kind: 'pixel',
      vibe: 'community-first helper',
      palette: ['mint', 'violet'],
    },
  });
  assert(made.result.structuredContent.buddy.name === 'Pocket Prism', 'create_buddy should return requested buddy');

  const cared = await rpc('tools/call', {
    name: 'care_for_buddy',
    arguments: {buddy: made.result.structuredContent.buddy, event: 'feed'},
  });
  assert(
    cared.result.structuredContent.buddy.energy > made.result.structuredContent.buddy.energy,
    'care_for_buddy should update energy',
  );

  const rendered = await rpc('tools/call', {
    name: 'render_buddy',
    arguments: {buddy: cared.result.structuredContent.buddy},
  });
  assert(rendered.result.structuredContent.render.pixel.length > 0, 'render_buddy should return pixel data');

  const resource = await rpc('resources/read', {uri: WIDGET_URI});
  assert(
    resource.result.contents[0].mimeType === 'text/html+skybridge',
    'widget resource should be served as skybridge HTML',
  );

  console.log('Buddy Chat app validation passed.');
} finally {
  child.kill('SIGTERM');
  await delay(50);
  if (child.exitCode && child.exitCode !== 0) {
    console.error(stderr);
  }
}

async function waitForHealth() {
  for (let attempt = 0; attempt < 30; attempt += 1) {
    try {
      const health = await getJson('/healthz');
      if (health.ok) return;
    } catch {
      await delay(100);
    }
  }
  throw new Error(`server did not become healthy; stderr=${stderr}`);
}

async function getJson(path) {
  const response = await fetch(`${baseUrl}${path}`);
  if (!response.ok) throw new Error(`GET ${path} failed: ${response.status}`);
  return response.json();
}

async function rpc(method, params) {
  const response = await fetch(`${baseUrl}/mcp`, {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({jsonrpc: '2.0', id: ++rpcId, method, params}),
  });
  if (!response.ok) throw new Error(`RPC ${method} failed HTTP ${response.status}`);
  const payload = await response.json();
  if (payload.error) throw new Error(`RPC ${method} error: ${payload.error.message}`);
  return payload;
}

function assert(condition, message) {
  if (!condition) throw new Error(message);
}
