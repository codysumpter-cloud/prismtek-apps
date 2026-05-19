export const APP_NAME = 'BeMore Buddy Chat App';
export const SERVER_VERSION = '0.1.0';
export const WIDGET_URI = 'ui://bemore-buddy/home.html';

const buddyStateSchema = {
  type: 'object',
  additionalProperties: true,
  properties: {
    id: {type: 'string'},
    name: {type: 'string'},
    kind: {type: 'string', enum: ['pixel', 'ascii', 'tamagotchi']},
    mood: {type: 'string'},
    energy: {type: 'number'},
    bond: {type: 'number'},
    level: {type: 'number'},
    traits: {type: 'array', items: {type: 'string'}},
    palette: {type: 'array', items: {type: 'string'}},
    ascii: {type: 'string'},
    pixel: {type: 'array', items: {type: 'string'}},
  },
};

const toolMeta = {
  securitySchemes: [{type: 'noauth'}],
  'openai/outputTemplate': WIDGET_URI,
  'openai/widgetAccessible': true,
};

export const TOOL_DEFINITIONS = [
  {
    name: 'buddy_home',
    title: 'Open Buddy Home',
    description: 'Open the BeMore Buddy panel inside ChatGPT with a default starter buddy.',
    inputSchema: {type: 'object', additionalProperties: false, properties: {}},
    annotations: {readOnlyHint: true},
    _meta: {
      ...toolMeta,
      'openai/toolInvocation/invoking': 'Opening Buddy home...',
      'openai/toolInvocation/invoked': 'Buddy home ready',
    },
  },
  {
    name: 'create_buddy',
    title: 'Create Buddy',
    description: 'Create a pixel, ASCII, or tamagotchi-style buddy profile.',
    inputSchema: {
      type: 'object',
      additionalProperties: false,
      properties: {
        name: {type: 'string'},
        kind: {type: 'string', enum: ['pixel', 'ascii', 'tamagotchi'], default: 'pixel'},
        vibe: {type: 'string'},
        palette: {
          oneOf: [
            {type: 'string'},
            {type: 'array', items: {type: 'string'}},
          ],
        },
      },
      required: ['name'],
    },
    annotations: {readOnlyHint: false},
    _meta: {
      ...toolMeta,
      'openai/toolInvocation/invoking': 'Creating Buddy...',
      'openai/toolInvocation/invoked': 'Buddy created',
    },
  },
  {
    name: 'care_for_buddy',
    title: 'Care For Buddy',
    description: 'Apply a small tamagotchi-style event and return the evolved state.',
    inputSchema: {
      type: 'object',
      additionalProperties: false,
      properties: {
        buddy: buddyStateSchema,
        event: {type: 'string'},
      },
      required: ['event'],
    },
    annotations: {readOnlyHint: false},
    _meta: {
      ...toolMeta,
      'openai/toolInvocation/invoking': 'Caring for Buddy...',
      'openai/toolInvocation/invoked': 'Buddy cared for',
    },
  },
  {
    name: 'chat_with_buddy',
    title: 'Chat With Buddy',
    description: 'Ask a buddy to respond through the configured local model endpoint.',
    inputSchema: {
      type: 'object',
      additionalProperties: false,
      properties: {
        message: {type: 'string'},
        buddy: buddyStateSchema,
        context: {type: 'string'},
      },
      required: ['message'],
    },
    annotations: {readOnlyHint: true},
    _meta: {
      ...toolMeta,
      'openai/toolInvocation/invoking': 'Asking Buddy...',
      'openai/toolInvocation/invoked': 'Buddy replied',
    },
  },
  {
    name: 'render_buddy',
    title: 'Render Buddy',
    description: 'Render a buddy as structured pixel/ascii data for the iframe widget.',
    inputSchema: {
      type: 'object',
      additionalProperties: false,
      properties: {buddy: buddyStateSchema},
    },
    annotations: {readOnlyHint: true},
    _meta: {
      ...toolMeta,
      'openai/toolInvocation/invoking': 'Rendering Buddy...',
      'openai/toolInvocation/invoked': 'Buddy rendered',
    },
  },
];

export const APP_MANIFEST = {
  name: APP_NAME,
  version: SERVER_VERSION,
  description: 'A ChatGPT app surface for creating, caring for, rendering, and chatting with BeMore Buddies.',
  mcp: {
    transport: 'streamable-http-compatible-json-rpc',
    endpoint: '/mcp',
    tools: TOOL_DEFINITIONS.map((tool) => tool.name),
    resources: [WIDGET_URI],
  },
  deployment: {
    requiresHttpsForChatGPT: true,
    suggestedVpsService: 'bemore-buddy-chat.service',
    modelGateway: 'Configure BUDDY_MODEL_BASE_URL to route calls to local Ollama.',
  },
};

export function widgetHtml() {
  return `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>BeMore Buddy</title>
  <style>
    :root { color-scheme: light dark; font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace; }
    body { margin: 0; background: #0c1117; color: #f3f7fb; }
    .wrap { display: grid; gap: 14px; padding: 16px; }
    .card { border: 1px solid rgba(255,255,255,.14); border-radius: 18px; padding: 16px; background: rgba(255,255,255,.07); }
    .row { display: flex; align-items: center; justify-content: space-between; gap: 12px; }
    .title { font-size: 18px; font-weight: 800; }
    .pill { border: 1px solid rgba(255,255,255,.18); border-radius: 999px; padding: 4px 9px; color: #b9f6d3; font-size: 12px; }
    pre { white-space: pre; font-size: 18px; line-height: 1.1; margin: 12px 0; color: #8cf7c5; }
    .stats { display: grid; grid-template-columns: repeat(3, 1fr); gap: 8px; }
    .stat { padding: 8px; border-radius: 12px; background: rgba(255,255,255,.07); }
    .label { color: #9fb0c1; font-size: 11px; text-transform: uppercase; letter-spacing: .08em; }
    button { cursor: pointer; border: 0; border-radius: 12px; padding: 10px 12px; background: #83f7bd; color: #07110c; font-weight: 800; }
    button.secondary { background: rgba(255,255,255,.11); color: #f3f7fb; border: 1px solid rgba(255,255,255,.16); }
    input { width: 100%; box-sizing: border-box; border-radius: 12px; border: 1px solid rgba(255,255,255,.16); background: rgba(255,255,255,.08); color: inherit; padding: 11px; }
    .grid { display: grid; grid-template-columns: repeat(8, 14px); gap: 3px; margin: 12px 0; }
    .px { width: 14px; height: 14px; border-radius: 3px; background: rgba(255,255,255,.1); }
    .px.on { background: #83f7bd; }
  </style>
</head>
<body>
  <main class="wrap">
    <section class="card">
      <div class="row"><div class="title" id="name">BeMore Buddy</div><div class="pill" id="mood">ready</div></div>
      <pre id="ascii">[o_o]</pre>
      <div id="pixel" class="grid"></div>
      <div class="stats">
        <div class="stat"><div class="label">Energy</div><div id="energy">--</div></div>
        <div class="stat"><div class="label">Bond</div><div id="bond">--</div></div>
        <div class="stat"><div class="label">Level</div><div id="level">--</div></div>
      </div>
    </section>
    <section class="card">
      <div class="label">Ask your buddy</div>
      <div class="row" style="margin-top:8px">
        <input id="prompt" value="Help me ship the smallest useful wedge." />
        <button id="ask">Ask</button>
      </div>
      <p id="reply"></p>
    </section>
  </main>
  <script>
    let buddy = window.openai?.toolOutput?.structuredContent?.buddy || {name:'BMO Buddy', mood:'ready', energy:72, bond:8, level:1, ascii:'[o_o]', pixel:['00111100','01111110','11011011','11111111','10111101','11000011','01111110','00100100']};
    function render(next) {
      buddy = next || buddy;
      document.getElementById('name').textContent = buddy.name || 'Buddy';
      document.getElementById('mood').textContent = buddy.mood || 'ready';
      document.getElementById('ascii').textContent = buddy.ascii || '[o_o]';
      document.getElementById('energy').textContent = buddy.energy ?? '--';
      document.getElementById('bond').textContent = buddy.bond ?? '--';
      document.getElementById('level').textContent = buddy.level ?? '--';
      const root = document.getElementById('pixel');
      root.innerHTML = '';
      (buddy.pixel || []).join('').slice(0, 64).padEnd(64, '0').split('').forEach((bit) => {
        const cell = document.createElement('div');
        cell.className = bit === '1' ? 'px on' : 'px';
        root.appendChild(cell);
      });
    }
    async function callTool(name, args) {
      if (!window.openai?.callTool) throw new Error('Tool bridge is not available yet.');
      const result = await window.openai.callTool(name, args);
      return result?.structuredContent || result;
    }
    document.getElementById('ask').addEventListener('click', async () => {
      const reply = document.getElementById('reply');
      reply.textContent = 'Buddy is thinking...';
      try {
        const out = await callTool('chat_with_buddy', { buddy, message: document.getElementById('prompt').value });
        if (out?.buddy) render(out.buddy);
        reply.textContent = out?.reply || 'Buddy is here.';
      } catch (error) {
        reply.textContent = error.message || String(error);
      }
    });
    render(buddy);
  </script>
</body>
</html>`;
}
