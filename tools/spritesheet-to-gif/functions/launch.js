const TOOL_PATH = '/tools/spritesheet-to-gif/';
const MAX_FILES = 10;

function json(body, status = 200) {
  return new Response(JSON.stringify(body, null, 2), {
    status,
    headers: {
      'content-type': 'application/json; charset=utf-8',
      'cache-control': 'no-store',
      'access-control-allow-origin': '*',
      'access-control-allow-methods': 'POST, OPTIONS',
      'access-control-allow-headers': 'content-type, authorization'
    }
  });
}

function clampInteger(value, { min, max, fallback }) {
  const numeric = Number.parseInt(String(value ?? ''), 10);
  if (!Number.isFinite(numeric)) return fallback;
  return Math.max(min, Math.min(max, numeric));
}

function sanitizeHex(value, fallback = '#000000') {
  const text = String(value || '').trim();
  return /^#[0-9a-f]{6}$/i.test(text) ? text.toLowerCase() : fallback;
}

function sanitizeAlphaMode(value) {
  return value === 'fill' ? 'fill' : 'keep';
}

function safeFileSummary(files) {
  if (!Array.isArray(files)) return [];
  return files.slice(0, MAX_FILES).map((file, index) => ({
    index,
    name: String(file?.name || `sprite-sheet-${index + 1}`).slice(0, 160),
    id: String(file?.id || '').slice(0, 120),
    mimeType: String(file?.mime_type || file?.mimeType || 'unknown').slice(0, 80),
    hasDownloadLink: Boolean(file?.download_link || file?.downloadLink)
  }));
}

function buildToolUrl(request, settings) {
  const url = new URL(request.url);
  url.pathname = TOOL_PATH;
  url.search = '';
  url.searchParams.set('rows', String(settings.rows));
  url.searchParams.set('columns', String(settings.columns));
  url.searchParams.set('delay', String(settings.delay));
  url.searchParams.set('scale', String(settings.scale));
  url.searchParams.set('startFrame', String(settings.startFrame));
  if (settings.endFrame > 0) url.searchParams.set('endFrame', String(settings.endFrame));
  url.searchParams.set('offsetTop', String(settings.offsetTop));
  url.searchParams.set('offsetBottom', String(settings.offsetBottom));
  url.searchParams.set('offsetLeft', String(settings.offsetLeft));
  url.searchParams.set('offsetRight', String(settings.offsetRight));
  url.searchParams.set('alphaMode', settings.alphaMode);
  url.searchParams.set('background', settings.background.replace('#', ''));
  return url.toString();
}

function normalizeSettings(body = {}) {
  return {
    rows: clampInteger(body.rows, { min: 1, max: 64, fallback: 1 }),
    columns: clampInteger(body.columns, { min: 1, max: 64, fallback: 4 }),
    delay: clampInteger(body.frameDelayMs ?? body.delay, { min: 10, max: 5000, fallback: 120 }),
    scale: clampInteger(body.scale, { min: 1, max: 12, fallback: 4 }),
    startFrame: clampInteger(body.startFrame, { min: 1, max: 4096, fallback: 1 }),
    endFrame: clampInteger(body.endFrame, { min: 0, max: 4096, fallback: 0 }),
    offsetTop: clampInteger(body.offsetTop, { min: 0, max: 4096, fallback: 0 }),
    offsetBottom: clampInteger(body.offsetBottom, { min: 0, max: 4096, fallback: 0 }),
    offsetLeft: clampInteger(body.offsetLeft, { min: 0, max: 4096, fallback: 0 }),
    offsetRight: clampInteger(body.offsetRight, { min: 0, max: 4096, fallback: 0 }),
    alphaMode: sanitizeAlphaMode(body.alphaMode),
    background: sanitizeHex(body.background)
  };
}

export async function onRequest({ request }) {
  if (request.method === 'OPTIONS') return json({ ok: true });
  if (request.method !== 'POST') {
    return json({ ok: false, error: 'Use POST to create a Sprite Sheet to GIF launch link.' }, 405);
  }

  let body;
  try {
    body = await request.json();
  } catch {
    return json({ ok: false, error: 'Request body must be JSON.' }, 400);
  }

  const settings = normalizeSettings(body);
  const files = safeFileSummary(body.openaiFileIdRefs);
  const toolUrl = buildToolUrl(request, settings);

  return json({
    ok: true,
    tool: 'Prismtek Sprite Sheet to GIF',
    toolUrl,
    toolPath: TOOL_PATH,
    settings,
    files,
    instructions: [
      'Open the toolUrl in ChatGPT in-app browser or Safari on iPhone.',
      'Save or download the sprite sheet from the ChatGPT conversation if needed, then tap Upload sprite sheet in the Prismtek tool.',
      'The settings in this response are the values ChatGPT should tell the user to apply. The web tool handles the GIF export locally in the browser.',
      'Tap Generate GIF, preview the result, then use Download GIF.'
    ],
    limitation: 'GPT Actions can receive uploaded files, but this first version returns an iPhone-friendly launch link and settings handoff rather than returning a GIF as a native ChatGPT attachment.',
    sourceOfTruth: 'prismtek-apps/tools/spritesheet-to-gif/functions/launch.js'
  });
}
