import cors from 'cors';
import express, {type NextFunction, type Request, type Response} from 'express';

const app = express();
const host = process.env.BEMORE_GEMMA4_GATEWAY_HOST ?? '127.0.0.1';
const port = Number(process.env.BEMORE_GEMMA4_GATEWAY_PORT ?? 4320);
const apiBaseUrl = stripTrailingSlash(process.env.BEMORE_GEMMA4_API_BASE_URL ?? 'http://127.0.0.1:11434/v1');
const apiToken = process.env.BEMORE_GEMMA4_API_TOKEN ?? process.env.OLLAMA_API_KEY ?? '';
const gatewayToken = process.env.BEMORE_BUDDY_AGENT_TOKEN ?? '';

const defaultAllowedModels = [
  'gemma4',
  'gemma4:27b',
  'gemma4:e2b',
  'gemma4:e4b',
  'gemma4:26b-a4b',
  'gemma4:31b',
  'gemma-4-e2b-it',
  'gemma-4-e4b-it',
  'gemma-4-E2B-it-q4f16_1-MLC',
  'google/gemma-4-e2b-it',
  'google/gemma-4-e4b-it',
  'google/gemma-4-26b-a4b-it',
  'google/gemma-4-31b-it',
];

const configuredAllowedModels = (process.env.BEMORE_GEMMA4_ALLOWED_MODELS ?? '')
  .split(',')
  .map((value) => value.trim())
  .filter(Boolean);
const allowedModels = Array.from(new Set([...defaultAllowedModels, ...configuredAllowedModels]));
const defaultModel = process.env.BEMORE_GEMMA4_MODEL ?? 'gemma4';

type ChatMessage = {
  role: 'system' | 'user' | 'assistant' | 'tool';
  content: string;
};

type ChatRequest = {
  model?: string;
  messages?: ChatMessage[];
  temperature?: number;
  maxTokens?: number;
};

function stripTrailingSlash(value: string) {
  return value.replace(/\/+$/, '');
}

function bearerToken(req: Request) {
  const header = req.header('authorization') ?? '';
  return header.startsWith('Bearer ') ? header.slice('Bearer '.length).trim() : '';
}

function requireGatewayToken(req: Request, res: Response, next: NextFunction) {
  if (!gatewayToken || req.method === 'GET') {
    next();
    return;
  }
  if (bearerToken(req) !== gatewayToken) {
    res.status(401).json({ok: false, error: 'Missing or invalid BeMore Buddy gateway token.'});
    return;
  }
  next();
}

function looksLikeGemma4(model: string) {
  const normalized = model.toLowerCase();
  return /(^|[/:_-])gemma[-:]?4([/:_-]|$)/.test(normalized) || normalized.includes('gemma-4');
}

function assertAllowedModel(model: string) {
  if (!model || /\s/.test(model) || model.includes('..')) {
    throw new Error('Model id is empty or invalid.');
  }
  if (!allowedModels.includes(model) && !looksLikeGemma4(model)) {
    throw new Error(`Model ${model} is not allowed. This gateway is Gemma 4 only.`);
  }
}

function assertMessages(messages: unknown): asserts messages is ChatMessage[] {
  if (!Array.isArray(messages) || messages.length === 0) {
    throw new Error('messages must be a non-empty array.');
  }
  for (const message of messages) {
    if (typeof message !== 'object' || message === null) throw new Error('Each message must be an object.');
    const candidate = message as Partial<ChatMessage>;
    if (!['system', 'user', 'assistant', 'tool'].includes(String(candidate.role))) {
      throw new Error(`Unsupported message role: ${String(candidate.role)}`);
    }
    if (typeof candidate.content !== 'string' || candidate.content.length > 24000) {
      throw new Error('Each message.content must be a string under 24,000 characters.');
    }
  }
}

function extractAssistantText(raw: unknown): string {
  const choice = (raw as {choices?: Array<{message?: {content?: unknown}; text?: unknown}>}).choices?.[0];
  const content = choice?.message?.content ?? choice?.text;
  if (typeof content === 'string') return content;
  if (Array.isArray(content)) {
    return content
      .map((part) => {
        if (typeof part === 'string') return part;
        if (typeof part === 'object' && part !== null && 'text' in part) return String((part as {text: unknown}).text);
        return '';
      })
      .join('')
      .trim();
  }
  return '';
}

function openApiDocument() {
  return {
    openapi: '3.1.0',
    info: {
      title: 'BeMore Buddy Gemma 4 Gateway',
      version: '1.0.0-build.6',
      description: 'Gemma 4-only model gateway for BeMore Buddy desktop, custom GPT Actions, and ChatGPT app connectors.',
    },
    servers: [{url: process.env.BEMORE_GEMMA4_PUBLIC_URL ?? `http://${host}:${port}`}],
    components: {
      securitySchemes: {
        bearerAuth: {type: 'http', scheme: 'bearer'},
      },
    },
    security: [{bearerAuth: []}],
    paths: {
      '/api/gemma4/status': {
        get: {
          operationId: 'getGemma4GatewayStatus',
          summary: 'Check Gemma 4 gateway status and allowed models.',
          responses: {'200': {description: 'Gateway status'}},
        },
      },
      '/api/gemma4/chat': {
        post: {
          operationId: 'chatWithGemma4',
          summary: 'Send a BeMore Buddy chat turn through an allowed Gemma 4 model.',
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  required: ['messages'],
                  properties: {
                    model: {type: 'string'},
                    messages: {
                      type: 'array',
                      items: {
                        type: 'object',
                        required: ['role', 'content'],
                        properties: {
                          role: {type: 'string', enum: ['system', 'user', 'assistant', 'tool']},
                          content: {type: 'string'},
                        },
                      },
                    },
                    temperature: {type: 'number'},
                    maxTokens: {type: 'integer'},
                  },
                },
              },
            },
          },
          responses: {'200': {description: 'Gemma 4 chat response'}},
        },
      },
    },
  };
}

app.use(cors());
app.use(express.json({limit: '2mb'}));
app.use('/api', requireGatewayToken);

app.get(['/openapi.json', '/api/openapi.json'], (_req, res) => {
  res.json(openApiDocument());
});

app.get('/api/gemma4/status', (_req, res) => {
  res.json({
    ok: true,
    gateway: 'bemore-buddy-gemma4',
    model: defaultModel,
    allowedModels,
    apiBaseUrl,
    requiresToken: Boolean(gatewayToken),
    recovery: [
      'Run a Gemma 4 OpenAI-compatible server locally, for example Ollama at http://127.0.0.1:11434/v1.',
      'Start with BEMORE_GEMMA4_MODEL=gemma4 for Ollama-style local proof-of-life, then switch to your exact installed Gemma 4 artifact id.',
      'Use mobile LiteRT or MediaPipe .task/.bin packages inside iOS/Android apps instead of routing phone-native inference through this desktop gateway.',
      'Set BEMORE_GEMMA4_API_BASE_URL when the runtime is elsewhere.',
      'Set BEMORE_BUDDY_AGENT_TOKEN before exposing this gateway to ChatGPT Actions or any non-local client.',
    ],
  });
});

app.post('/api/gemma4/chat', async (req, res, next) => {
  try {
    const body = req.body as ChatRequest;
    const model = body.model ?? defaultModel;
    assertAllowedModel(model);
    assertMessages(body.messages);

    const response = await fetch(`${apiBaseUrl}/chat/completions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...(apiToken ? {Authorization: `Bearer ${apiToken}`} : {}),
      },
      body: JSON.stringify({
        model,
        messages: body.messages,
        temperature: body.temperature ?? 0.4,
        max_tokens: body.maxTokens ?? 1024,
      }),
    });

    if (!response.ok) {
      const text = await response.text();
      throw new Error(`Gemma 4 runtime returned ${response.status}: ${text}`);
    }

    const raw = (await response.json()) as unknown;
    const text = extractAssistantText(raw);
    res.json({ok: true, model, text, raw});
  } catch (error) {
    next(error);
  }
});

app.use((error: unknown, _req: Request, res: Response, _next: NextFunction) => {
  const message = error instanceof Error ? error.message : String(error);
  res.status(400).json({ok: false, error: message});
});

app.listen(port, host, () => {
  console.log(`BeMore Buddy Gemma 4 gateway listening on http://${host}:${port}`);
});
