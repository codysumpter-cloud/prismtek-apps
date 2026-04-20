import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import path from 'path';
import { spawn } from 'node:child_process';
import crypto from 'node:crypto';
import { mkdir, readFile } from 'node:fs/promises';
import { fileURLToPath, pathToFileURL } from 'url';
import admin from 'firebase-admin';
import { AppFactory } from '@prismtek/app-factory';
import {
  BUDDY_VISUAL_STATES,
  type BmoStackAdapterSnapshot,
  type BuddyAppearanceGenerationResult,
  type BuddyAppearanceStudioDraft,
  type BuddyGenerationProviderConfig,
  type BuddyAppearancePalette,
  type BuddyAppearanceProfile,
  type BuddyAsciiFrames,
  type BuddyPixelAssetSet,
  type BuddyVisualState,
  type CodexRunRequest,
  type CodexRunResult,
  type CodexRunSummary,
  defaultPixelLabProviderConfig,
  validateBuddyAsciiFrames,
} from '@prismtek/core';
import { SandboxManager } from '@prismtek/sandbox';
import firebaseConfig from '../../firebase-applet-config.json' with { type: 'json' } ;

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT || 3001;
const DEFAULT_BMO_STACK_ROOT = path.resolve(__dirname, '..', '..', '..', 'bmo-stack');
const BMO_STACK_ROOT = path.resolve(process.env.BMO_STACK_ROOT || DEFAULT_BMO_STACK_ROOT);
const BUDDY_PROFILE_COLLECTION = 'buddy_appearance_profiles';

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(process.env.FIREBASE_SERVICE_ACCOUNT as string || {}),
  databaseURL: `https://${firebaseConfig.projectId}.firebaseio.com`
});

const db = admin.firestore();
const auth = admin.auth();

const appFactory = new AppFactory();
const sandboxManager = new SandboxManager(process.env.SANDBOX_DOCKER_IMAGE || 'prismtek/sandbox:latest');

// Initialize Templates in Firestore
async function initTemplates() {
  const templates = appFactory.getTemplates();
  const templatesCol = db.collection('templates');
  
  for (const template of templates) {
    await templatesCol.doc(template.id).set(template, { merge: true });
  }
  console.log('Templates initialized in Firestore');
}

initTemplates().catch(console.error);

type AuthenticatedRequest = express.Request & {
  user?: {
    uid: string;
    email?: string;
  };
};

app.use(cors());
app.use(express.json());

// Auth Middleware (Firebase)
const authenticateToken = async (req: any, res: any, next: any) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) return res.status(401).json({ error: 'Unauthorized' });

  try {
    const decodedToken = await auth.verifyIdToken(token);
    req.user = decodedToken;
    next();
  } catch (err) {
    return res.status(403).json({ error: 'Forbidden' });
  }
};

function nowIso() {
  return new Date().toISOString();
}

function resolvePixelLabProviderConfig() {
  const config = defaultPixelLabProviderConfig();
  const apiBaseUrl = process.env.PIXELLAB_API_BASE_URL || config.apiBaseUrl;
  const apiKeyEnvVar = process.env.PIXELLAB_API_KEY ? 'PIXELLAB_API_KEY' : config.apiKeyEnvVar;
  const mcpServerUrl = process.env.PIXELLAB_MCP_SERVER_URL || config.mcpServerUrl;

  if (process.env.PIXELLAB_API_KEY) {
    return {
      ...config,
      enabled: true,
      mode: 'api' as const,
      apiBaseUrl,
      apiKeyEnvVar,
      mcpServerUrl,
    };
  }

  if (process.env.PIXELLAB_MCP_SERVER_URL) {
    return {
      ...config,
      enabled: true,
      mode: 'mcp' as const,
      apiBaseUrl,
      apiKeyEnvVar,
      mcpServerUrl,
    };
  }

  return {
    ...config,
    apiBaseUrl,
    apiKeyEnvVar,
    mcpServerUrl,
  };
}

async function importBmoModule<T = any>(relativePath: string): Promise<T> {
  const target = path.join(BMO_STACK_ROOT, relativePath);
  return import(pathToFileURL(target).href) as Promise<T>;
}

async function readBmoJson(relativePath: string) {
  const raw = await readFile(path.join(BMO_STACK_ROOT, relativePath), 'utf8');
  return JSON.parse(raw);
}

function sanitizeText(value: string, fallback: string) {
  const trimmed = String(value || '').trim();
  return trimmed || fallback;
}

function makeStateFrameId(state: BuddyVisualState, index: number) {
  return `${state}-${index + 1}`;
}

function buildPalette(paletteName: string): BuddyAppearancePalette {
  const key = paletteName.trim().toLowerCase();
  const palettes: Record<string, BuddyAppearancePalette> = {
    forest: { primary: '#7BE0AD', secondary: '#214B43', accent: '#F8E16C', outline: '#0B1F1A', background: '#08120F' },
    candy: { primary: '#FF8CCB', secondary: '#76295B', accent: '#FFF08A', outline: '#3C0F29', background: '#160712' },
    ocean: { primary: '#72D9FF', secondary: '#0B3A5B', accent: '#8FF7D0', outline: '#041726', background: '#06111A' },
    ember: { primary: '#FF9966', secondary: '#552011', accent: '#FFE066', outline: '#2A0E08', background: '#120806' },
    mono: { primary: '#DADADA', secondary: '#3B3B3B', accent: '#F4F4F4', outline: '#131313', background: '#090909' },
  };
  return palettes[key] || palettes.forest;
}

function buildAsciiStateSet(draft: BuddyAppearanceStudioDraft): BuddyAsciiFrames {
  const name = sanitizeText(draft.displayName, 'Buddy').slice(0, 8);
  const accessory = draft.accessories[0] ? draft.accessories[0].slice(0, 4) : '--';
  const silhouette = sanitizeText(draft.silhouette, 'round').toLowerCase();
  const face = sanitizeText(draft.face, 'friendly').toLowerCase();
  const expression = sanitizeText(draft.expression, 'warm').toLowerCase();
  const animation = sanitizeText(draft.animationPersonality, 'calm').toLowerCase();

  const top = silhouette.includes('tall') ? '   /||\\' : silhouette.includes('sharp') ? '   /\\/\\' : '    /\\\\';
  const body = silhouette.includes('tiny') ? ' /_|__|_\\\\' : ' /_|____|_\\\\';
  const feetA = animation.includes('lively') ? '   /_  _\\\\' : '    /  \\\\';
  const feetB = animation.includes('lively') ? '   \\\\_  _/' : '    \\\\  /';
  const eyes = face.includes('strict') ? '>  <' : expression.includes('playful') ? '^  o' : draft.eyes.includes('soft') ? '-  -' : 'o  o';
  const brightEyes = expression.includes('happy') ? '^  ^' : draft.eyes.includes('wide') ? 'O  O' : eyes;

  const frame = (...lines: string[]) => lines.join('\n');

  return {
    width: 24,
    height: 8,
    fps: animation.includes('lively') ? 4 : 2,
    states: {
      idle: [
        { id: makeStateFrameId('idle', 0), content: frame(`${top} ${accessory}`.trimEnd(), ` < ${brightEyes} >`, ' /|  v |\\\\', body, feetA, `   ${name}`) },
        { id: makeStateFrameId('idle', 1), content: frame(`${top} ${accessory}`.trimEnd(), ` < ${brightEyes} >`, ' /|  v |\\\\', body, feetB, `   ${name}`) },
      ],
      happy: [
        { id: makeStateFrameId('happy', 0), content: frame(` \\ ${top.trim()} /`, ' < ^  ^ >', ' /|  * |\\\\', body, feetA, `   ${name}`) },
        { id: makeStateFrameId('happy', 1), content: frame(` * ${top.trim()} *`, ' < ^  o >', ' /|  * |\\\\', body, feetB, `   ${name}`) },
      ],
      thinking: [
        { id: makeStateFrameId('thinking', 0), content: frame(`${top}   ?`, ` < ${eyes} >`, ' /|  ? |\\\\', body, feetA, `   ${name}`) },
        { id: makeStateFrameId('thinking', 1), content: frame(`${top}  ..`, ' < o  O >', ' /|  ? |\\\\', body, feetB, `   ${name}`) },
      ],
      working: [
        { id: makeStateFrameId('working', 0), content: frame(`${top}  ##`, ' < >  < >', ' /| [ ]|\\\\', body, feetA, `   ${name}`) },
        { id: makeStateFrameId('working', 1), content: frame(`${top} ###`, ' < >  < >', ' /| [*]|\\\\', body, feetB, `   ${name}`) },
      ],
      sleepy: [
        { id: makeStateFrameId('sleepy', 0), content: frame(`${top}   z`, ' < -  - >', ' /|  . |\\\\', body, '    /__\\\\', `   ${name}`) },
        { id: makeStateFrameId('sleepy', 1), content: frame(`${top}  zz`, ' < -  - >', ' /|  . |\\\\', body, '   _/  \\\\_', `   ${name}`) },
      ],
      'needs-attention': [
        { id: makeStateFrameId('needs-attention', 0), content: frame(` ! ${top.trim()} !`, ' < o  o >', ' /|  ! |\\\\', body, feetA, `   ${name}`) },
        { id: makeStateFrameId('needs-attention', 1), content: frame(`!! ${top.trim()} !!`, ' < O  o >', ' /|  ! |\\\\', body, feetB, `   ${name}`) },
      ],
    },
  };
}

async function callPixelLabApi(draft: BuddyAppearanceStudioDraft, palette: BuddyAppearancePalette, config: BuddyGenerationProviderConfig): Promise<BuddyPixelAssetSet> {
  try {
    if (config.mode === 'disabled' || !config.enabled) {
      throw new Error('PixelLab provider is disabled');
    }

    const apiKey = process.env[config.apiKeyEnvVar || 'PIXELLAB_API_KEY'];
    if (!apiKey) {
      throw new Error('PIXELLAB_API_KEY not found in environment');
    }

    const description = `A pixel-art buddy character. Archetype: ${draft.archetype}, Vibe: ${draft.vibe}, Palette: ${draft.paletteName} (Primary: ${palette.primary}, Secondary: ${palette.secondary}, Accent: ${palette.accent}), Silhouette: ${draft.silhouette}, Face: ${draft.face}, Expression: ${draft.expression}, Accessories: ${draft.accessories.join(', ')}.`;

    const response = await fetch(`${config.apiBaseUrl}/generate`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
        description,
        width: 12,
        height: 12,
        model: 'bitforge',
        palette: palette,
      }),
    });

    if (!response.ok) {
      throw new Error(`PixelLab API responded with ${response.status}: ${await response.text()}`);
    }

    const data = await response.json();
    
    return {
      ...data,
      provider: config.mode === 'api' ? 'pixellab-api' : 'pixellab-mcp',
    };
  } catch (error) {
    console.error('PixelLab API call failed, falling back to local preview:', error);
    return buildLocalPixelAssetSet(draft, palette);
  }
}

function buildLocalPixelAssetSet(draft: BuddyAppearanceStudioDraft, palette: BuddyAppearancePalette): BuddyPixelAssetSet {
  const width = 12;
  const height = 12;
  const accent = palette.accent;
  const states = Object.fromEntries(
    BUDDY_VISUAL_STATES.map((state, index) => {
      const offset = state === 'happy' ? -1 : state === 'sleepy' ? 1 : 0;
      const cells = [];
      const centerX = Math.floor(width / 2);
      const centerY = Math.floor(height / 2) + offset;
      for (let y = centerY - 3; y <= centerY + 2; y += 1) {
        for (let x = centerX - 3; x <= centerX + 3; x += 1) {
          const edge = x === centerX - 3 || x === centerX + 3 || y === centerY - 3 || y === centerY + 2;
          cells.push({ x, y, color: edge ? palette.secondary : palette.primary });
        }
      }
      cells.push({ x: centerX - 1, y: centerY - 1, color: '#FFFFFF' });
      cells.push({ x: centerX + 1, y: centerY - 1, color: '#FFFFFF' });
      cells.push({ x: centerX - 1, y: centerY, color: palette.secondary });
      cells.push({ x: centerX + 1, y: centerY, color: palette.secondary });
      cells.push({ x: centerX, y: centerY + 1, color: accent });

      return [
        state,
        [
          {
            id: `${state}-pixel-${index + 1}`,
            width,
            height,
            cells,
          },
        ],
      ];
    }),
  ) as BuddyPixelAssetSet['states'];

  return {
    provider: 'local-preview',
    width,
    height,
    transparentBackground: true,
    states,
    warnings: [
      'PixelLab enhancement is not configured, so this is a local preview pack rather than a provider-generated sprite sheet.',
    ],
  };
}

function buildAnimationMapping(ascii: BuddyAsciiFrames, pixel?: BuddyPixelAssetSet) {
  return {
    states: Object.fromEntries(
      BUDDY_VISUAL_STATES.map((state) => [
        state,
        {
          loop: state !== 'happy',
          fps: ascii.fps,
          asciiFrameIds: ascii.states[state].map((frame) => frame.id),
          pixelFrameIds: pixel?.states[state]?.map((frame) => frame.id),
        },
      ]),
    ) as Record<BuddyVisualState, { loop: boolean; fps: number; asciiFrameIds: string[]; pixelFrameIds?: string[] }>,
  };
}

async function materializeAppearanceProfile(draft: BuddyAppearanceStudioDraft, profileId?: string): Promise<BuddyAppearanceGenerationResult> {
  const timestamp = nowIso();
  const palette = buildPalette(draft.paletteName);
  const ascii = buildAsciiStateSet(draft);
  const asciiValidation = validateBuddyAsciiFrames(ascii);
  const providerConfig = resolvePixelLabProviderConfig();
  const wantsPixel = draft.outputMode === 'pixel' || draft.outputMode === 'both';
  const pixel = wantsPixel ? await callPixelLabApi(draft, palette, providerConfig) : undefined;

  const profile: BuddyAppearanceProfile = {
    id: profileId || crypto.randomUUID(),
    buddyId: draft.buddyId,
    displayName: sanitizeText(draft.displayName, 'Buddy'),
    archetype: sanitizeText(draft.archetype, 'companion'),
    vibe: sanitizeText(draft.vibe, 'calm'),
    paletteName: sanitizeText(draft.paletteName, 'forest'),
    palette,
    silhouette: sanitizeText(draft.silhouette, 'round'),
    face: sanitizeText(draft.face, 'friendly'),
    eyes: sanitizeText(draft.eyes, 'bright'),
    expression: sanitizeText(draft.expression, 'warm'),
    accessories: draft.accessories.filter(Boolean),
    animationPersonality: sanitizeText(draft.animationPersonality, 'calm'),
    outputMode: draft.outputMode,
    isDefault: false,
    visualStateSet: {
      outputMode: draft.outputMode,
      ascii,
      pixel,
      animation: buildAnimationMapping(ascii, pixel),
    },
    providerConfig,
    source: {
      generator: pixel?.provider === 'local-preview' ? 'local-preview' : (wantsPixel ? (pixel?.provider || 'pixellab-api') : 'local-ascii'),
      sourceOfTruth: 'prismtek-apps',
      reusedFrom: [
        'packages/core/buddyPersonalizationEngine.ts',
        'apps/bemore-ios-native/OpenClawShell/Views/BuddyAsciiView.swift',
      ],
    },
    createdAt: timestamp,
    updatedAt: timestamp,
  };

  const warnings = [
    ...asciiValidation.issues.map((issue) => `${issue.state}: ${issue.message}`),
    ...(pixel?.warnings || []),
  ];

  if (wantsPixel && providerConfig.enabled === false) {
    warnings.unshift('PixelLab is optional and currently not configured. Pixel output is a local preview only.');
  }

  return {
    profile,
    warnings,
    generationNotes: [
      'ASCII frames are generated locally and validated against the Buddy shell size contract.',
      wantsPixel
        ? `Pixel previews use a local fallback while PixelLab remains optional (${providerConfig.mode}).`
        : 'Pixel generation was not requested.',
      `Validated ASCII bounds: ${asciiValidation.width}x${asciiValidation.height}.`,
    ],
  };
}

function formatCodexRun(raw: any): CodexRunSummary {
  return {
    runId: raw.run_id,
    status: raw.status,
    repoPath: raw.repo_path,
    worktreePath: raw.worktree_path,
    targetBranch: raw.target_branch,
    approvalMode: raw.approval_mode,
    model: raw.model ?? null,
    startedAt: raw.started_at,
    finishedAt: raw.finished_at ?? null,
    exitCode: raw.exit_code ?? null,
    finalAgentMessage: raw.final_agent_message ?? null,
    stdoutTail: raw.stdout_tail,
    stderrTail: raw.stderr_tail,
    nextSteps: raw.next_steps,
  };
}

async function readCodexStatus(runId: string): Promise<CodexRunSummary> {
  const module = await importBmoModule<{ getCodexRunStatus: (args: { run_id: string; log_lines?: number }) => Promise<any> }>(
    'mcp/codex-bridge/server/tools/getCodexRunStatus.js',
  );
  const raw = await module.getCodexRunStatus({ run_id: runId, log_lines: 80 });
  return formatCodexRun(raw);
}

async function readCodexResult(runId: string): Promise<CodexRunResult> {
  const module = await importBmoModule<{ readCodexRunResult: (args: { run_id: string }) => Promise<any> }>(
    'mcp/codex-bridge/server/tools/readCodexRunResult.js',
  );
  const raw = await module.readCodexRunResult({ run_id: runId });
  return {
    ...formatCodexRun(raw),
    brief: raw.brief ?? '',
    usage: raw.usage,
  };
}

async function queueCodexRun(payload: CodexRunRequest) {
  const bridge = await importBmoModule<{
    ensureRuntimeLayout: () => Promise<void>;
    getRunPaths: (runId: string) => {
      runDir: string;
      worktreePath: string;
      statusPath: string;
    };
    makeRunId: () => string;
    writeJson: (target: string, data: unknown) => Promise<void>;
  }>('mcp/codex-bridge/server/lib/bridge.js');

  await bridge.ensureRuntimeLayout();
  const runId = bridge.makeRunId();
  const runPaths = bridge.getRunPaths(runId);
  await mkdir(runPaths.runDir, { recursive: true });
  await bridge.writeJson(runPaths.statusPath, {
    run_id: runId,
    status: 'queued',
    repo_path: payload.repoPath,
    worktree_path: runPaths.worktreePath,
    target_branch: payload.targetBranch || null,
    approval_mode: payload.approvalMode,
    model: payload.model || null,
    started_at: nowIso(),
    finished_at: null,
    exit_code: null,
    final_agent_message: null,
    next_steps: ['Wait for the bridge process to create the worktree and update this run.'],
  });

  const cliPath = path.join(BMO_STACK_ROOT, 'mcp/codex-bridge/server/bin/dispatchCodexTaskCli.js');
  const args = [
    cliPath,
    '--repo-path',
    payload.repoPath,
    '--task-brief',
    payload.taskBrief,
    '--approval-mode',
    payload.approvalMode,
    '--run-id',
    runId,
  ];

  if (payload.targetBranch) {
    args.push('--target-branch', payload.targetBranch);
  }

  if (payload.model) {
    args.push('--model', payload.model);
  }

  const child = spawn('node', args, {
    cwd: BMO_STACK_ROOT,
    detached: true,
    stdio: 'ignore',
    env: {
      ...process.env,
      BMO_STACK_ROOT,
    },
  });
  child.unref();

  return { runId, worktreePath: runPaths.worktreePath };
}

async function buildBmoStackAdapterSnapshot(): Promise<BmoStackAdapterSnapshot> {
  const councilManifest = await readBmoJson('config/council/spawn-manifest.json');
  const founderManifest = await readBmoJson('config/agents/founder-os.manifest.json');
  const skillsIndex = await readBmoJson('skills/index.json');

  return {
    runtimeBase: {
      name: 'Hermes reference runtime',
      summary: 'bmo-stack currently exposes a thin bootstrap around the Hermes reference runtime for prototype Buddy execution.',
      sourceFiles: ['runtime/prototype/boundary.md', 'runtime/prototype/runtime_bootstrap.py'],
    },
    modes: [
      {
        id: 'companion',
        label: 'Companion',
        summary: 'Everyday usefulness, teachability, memory, skills, and growth stay visible before deeper operator mechanics.',
        sourceFiles: ['memory.md', 'context/identity/SOUL.md'],
      },
      {
        id: 'operator',
        label: 'Operator',
        summary: 'Repo work, debugging, runtime checks, council escalation, and structured technical execution.',
        sourceFiles: ['context/identity/AGENTS.md', 'context/RUNBOOK.md'],
      },
    ],
    council: [...councilManifest.council_seats, ...councilManifest.workers].map((seat: any) => ({
      name: seat.name,
      kind: seat.kind,
      status: seat.status,
      surface: seat.surface,
      sourceFile: seat.source_file,
      defaultTrigger: seat.default_trigger,
    })),
    founderRoles: founderManifest.roles.map((role: any) => ({
      id: role.id,
      name: role.name,
      operatingRole: role.operatingRole,
      objective: role.objective,
      councilMapping: role.councilMapping,
      memoryFile: role.memoryFile,
      tools: role.tools,
    })),
    skills: Object.entries(skillsIndex.skills).map(([id, spec]: any) => ({
      id,
      triggers: spec.triggers,
      actions: spec.actions,
      defaultAction: spec.default_action,
    })),
    postureSourceFiles: [
      'AGENTS.md',
      'memory.md',
      'soul.md',
      'context/identity/AGENTS.md',
      'context/identity/SOUL.md',
      'context/RUNBOOK.md',
    ],
  };
}

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.get('/api/bmo-stack/adapter', authenticateToken, async (_req, res) => {
  try {
    res.json(await buildBmoStackAdapterSnapshot());
  } catch (error) {
    res.status(500).json({ error: (error as Error).message, bmoStackRoot: BMO_STACK_ROOT });
  }
});

app.get('/api/buddy/appearance/flows', authenticateToken, (_req, res) => {
  res.json({
    providerConfig: resolvePixelLabProviderConfig(),
    states: BUDDY_VISUAL_STATES,
    fields: [
      'archetype',
      'vibe',
      'palette',
      'silhouette',
      'face',
      'eyes',
      'expression',
      'accessories',
      'animationPersonality',
      'outputMode',
    ],
  });
});

// Admin Routes
app.get('/api/admin/stats', authenticateToken, async (req: any, res) => {
  try {
    const usersCount = (await auth.listUsers()).users.length;
    const workspacesCount = (await db.collection('workspaces').get()).size;
    const sessionsCount = (await db.collection('sandbox_sessions').get()).size;

    res.json({
      totalUsers: usersCount,
      activeSessions: sessionsCount,
      appGenerations: workspacesCount,
      systemLoad: 14,
      trends: {
        users: '+12%',
        sessions: '+5%',
        generations: '+24%',
        load: '-2%'
      }
    });
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch stats' });
  }
});

app.get('/api/admin/logs', authenticateToken, async (req, res) => {
  try {
    const snapshot = await db.collection('system_logs').orderBy('time', 'desc').limit(50).get();
    const logs = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    res.json(logs);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch logs' });
  }
});

// Workspace Routes
app.get('/api/workspaces', authenticateToken, async (req: any, res) => {
  try {
    const snapshot = await db.collection('workspaces').where('ownerId', '==', req.user.uid).get();
    const workspaces = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    res.json(workspaces);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch workspaces' });
  }
});

app.post('/api/workspaces/:id/sync', authenticateToken, async (req: any, res) => {
  try {
    const wsRef = db.collection('workspaces').doc(req.params.id);
    const wsDoc = await wsRef.get();
    
    if (!wsDoc.exists) {
      return res.status(404).json({ error: 'Workspace not found' });
    }

    await wsRef.update({ status: 'syncing' });
    
    // Simulate sync process
    setTimeout(async () => {
      await wsRef.update({ 
        status: 'running',
        lastSyncedAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      });
      
      await db.collection('system_logs').add({
        id: Date.now().toString(),
        event: `Workspace Synced to ${wsDoc.data()?.repoUrl || 'Repository'}`,
        user: req.user.email,
        time: new Date().toISOString(),
        type: 'success'
      });
    }, 2000);

    res.json({ success: true, message: 'Sync started' });
  } catch (err) {
    res.status(500).json({ error: 'Sync failed' });
  }
});

// App Factory Service Interface
app.get('/api/factory/templates', authenticateToken, (req, res) => {
  res.json(appFactory.getTemplates());
});

app.get('/api/factory/models', authenticateToken, (req, res) => {
  res.json(appFactory.getModels());
});

app.post('/api/factory/generate', authenticateToken, async (req: any, res) => {
  const { description, templateId, target, modelId } = req.body;
  try {
    const job = await appFactory.generate({ description, templateId, target, modelId });
    
    // Log the event in Firestore
    await db.collection('system_logs').add({
      id: Date.now().toString(),
      event: 'App Generation Started',
      user: req.user.email,
      time: new Date().toISOString(),
      type: 'info'
    });

    // Handle job completion in background
    const pollJob = async () => {
      let status = 'processing';
      while (status !== 'completed' && status !== 'failed') {
        await new Promise(r => setTimeout(r, 2000));
        const currentJob = await appFactory.getJobStatus(job.id);
        if (!currentJob) break;
        status = currentJob.status;
        
        if (status === 'completed') {
          const template = appFactory.getTemplates().find(t => t.id === templateId);
          if (template) {
            await db.collection('workspaces').doc(job.id).set({
              id: job.id,
              name: `Generated ${template.name}`,
              templateId: template.id,
              status: 'running',
              repoUrl: template.repoUrl,
              lastSyncedAt: new Date().toISOString(),
              createdAt: new Date().toISOString(),
              updatedAt: new Date().toISOString(),
              ownerId: req.user.uid
            });
            
            await db.collection('system_logs').add({
              id: Date.now().toString(),
              event: `App Generation Completed: ${template.name}`,
              user: req.user.email,
              time: new Date().toISOString(),
              type: 'success'
            });
          }
        }
      }
    };
    pollJob();

    res.json(job);
  } catch (error) {
    res.status(400).json({ error: (error as Error).message });
  }
});

app.get('/api/factory/jobs/:id', authenticateToken, async (req, res) => {
  const job = await appFactory.getJobStatus(req.params.id);
  if (!job) return res.status(404).json({ error: 'Job not found' });
  res.json(job);
});

// Sandbox Service Interface
app.post('/api/sandbox/launch', authenticateToken, async (req: any, res) => {
  const { workspaceId } = req.body;
  try {
    const session = await sandboxManager.launch(workspaceId);
    
    // Create session in Firestore
    const sessionData = {
      id: session.id,
      workspaceId,
      ownerId: req.user.uid,
      status: 'running',
      expiresAt: session.expiresAt,
      createdAt: new Date().toISOString(),
      logs: [
        '# Initializing BeMore workspace sandbox...',
        '# Mounting virtual filesystem...',
        '# Loading BeMore runtime harness...',
        '# Environment ready.'
      ]
    };
    
    await db.collection('sandbox_sessions').doc(session.id).set(sessionData);

    await db.collection('system_logs').add({
      id: Date.now().toString(),
      event: 'Sandbox Launch',
      user: req.user.email,
      time: new Date().toISOString(),
      type: 'success'
    });

    res.json(sessionData);
  } catch (error) {
    res.status(500).json({ error: (error as Error).message });
  }
});

app.get('/api/sandbox/sessions', authenticateToken, async (req, res) => {
  const sessions = await sandboxManager.listActiveSessions();
  res.json(sessions);
});

app.delete('/api/sandbox/sessions/:id', authenticateToken, async (req, res) => {
  await sandboxManager.terminate(req.params.id);
  res.json({ success: true });
});

app.get('/api/buddies/:buddyId/appearance-profiles', authenticateToken, async (req: AuthenticatedRequest, res) => {
  try {
    const snapshot = await db
      .collection(BUDDY_PROFILE_COLLECTION)
      .where('ownerId', '==', req.user?.uid)
      .where('buddyId', '==', req.params.buddyId)
      .get();
    const profiles = snapshot.docs.map((doc) => doc.data());
    res.json({ profiles });
  } catch (error) {
    res.status(500).json({ error: (error as Error).message });
  }
});

app.post('/api/buddies/:buddyId/appearance-profiles/generate', authenticateToken, async (req: AuthenticatedRequest, res) => {
  try {
    const rawDraft = req.body?.draft || {};
    const buddyId = String(req.params.buddyId);
    const draft: BuddyAppearanceStudioDraft = {
      buddyId,
      displayName: sanitizeText(rawDraft.displayName, 'Buddy'),
      archetype: sanitizeText(rawDraft.archetype, 'companion'),
      vibe: sanitizeText(rawDraft.vibe, 'calm'),
      paletteName: sanitizeText(rawDraft.paletteName, 'forest'),
      silhouette: sanitizeText(rawDraft.silhouette, 'round'),
      face: sanitizeText(rawDraft.face, 'friendly'),
      eyes: sanitizeText(rawDraft.eyes, 'bright'),
      expression: sanitizeText(rawDraft.expression, 'warm'),
      accessories: Array.isArray(rawDraft.accessories)
        ? rawDraft.accessories.map((value: string) => sanitizeText(value, '')).filter(Boolean)
        : [],
      animationPersonality: sanitizeText(rawDraft.animationPersonality, 'calm'),
      outputMode: rawDraft.outputMode || 'ascii',
      notes: rawDraft.notes ? String(rawDraft.notes) : undefined,
    };

    const generated = await materializeAppearanceProfile(draft);
    const makeDefault = req.body?.makeDefault !== false;

    if (makeDefault) {
      const existingDefaults = await db
        .collection(BUDDY_PROFILE_COLLECTION)
        .where('ownerId', '==', req.user?.uid)
        .where('buddyId', '==', buddyId)
        .where('isDefault', '==', true)
        .get();
      await Promise.all(existingDefaults.docs.map((doc) => doc.ref.update({ isDefault: false })));
      generated.profile.isDefault = true;
    }

    await db.collection(BUDDY_PROFILE_COLLECTION).doc(generated.profile.id).set({
      ...generated.profile,
      ownerId: req.user?.uid,
      ownerEmail: req.user?.email || null,
    });

    await db.collection('system_logs').add({
      id: Date.now().toString(),
      event: `Buddy appearance saved for ${buddyId}`,
      user: req.user?.email || 'unknown',
      time: nowIso(),
      type: 'success',
    });

    res.json(generated);
  } catch (error) {
    res.status(400).json({ error: (error as Error).message });
  }
});

app.post('/api/buddies/:buddyId/appearance-profiles/:profileId/default', authenticateToken, async (req: AuthenticatedRequest, res) => {
  try {
    const buddyId = String(req.params.buddyId);
    const profileId = String(req.params.profileId);
    const profiles = await db
      .collection(BUDDY_PROFILE_COLLECTION)
      .where('ownerId', '==', req.user?.uid)
      .where('buddyId', '==', buddyId)
      .get();

    await Promise.all(
      profiles.docs.map((doc) => doc.ref.update({ isDefault: doc.id === profileId, updatedAt: nowIso() })),
    );

    const selected = await db.collection(BUDDY_PROFILE_COLLECTION).doc(profileId).get();
    res.json({ profile: selected.data() });
  } catch (error) {
    res.status(400).json({ error: (error as Error).message });
  }
});

app.post('/api/buddies/:buddyId/appearance-profiles/:profileId/duplicate', authenticateToken, async (req: AuthenticatedRequest, res) => {
  try {
    const profileId = String(req.params.profileId);
    const sourceDoc = await db.collection(BUDDY_PROFILE_COLLECTION).doc(profileId).get();
    if (!sourceDoc.exists) {
      return res.status(404).json({ error: 'Profile not found' });
    }

    const source = sourceDoc.data() as BuddyAppearanceProfile & { ownerId: string };
    if (source.ownerId !== req.user?.uid) {
      return res.status(403).json({ error: 'Forbidden' });
    }

    const duplicated: BuddyAppearanceProfile = {
      ...source,
      id: crypto.randomUUID(),
      displayName: `${source.displayName} Copy`,
      isDefault: false,
      createdAt: nowIso(),
      updatedAt: nowIso(),
    };

    await db.collection(BUDDY_PROFILE_COLLECTION).doc(duplicated.id).set({
      ...duplicated,
      ownerId: req.user?.uid,
      ownerEmail: req.user?.email || null,
    });

    res.json({ profile: duplicated });
  } catch (error) {
    res.status(400).json({ error: (error as Error).message });
  }
});

app.post('/api/codex/runs', authenticateToken, async (req: AuthenticatedRequest, res) => {
  try {
    const payload: CodexRunRequest = {
      repoPath: String(req.body?.repoPath || ''),
      taskBrief: String(req.body?.taskBrief || ''),
      approvalMode: req.body?.approvalMode || 'suggest',
      targetBranch: req.body?.targetBranch ? String(req.body.targetBranch) : undefined,
      model: req.body?.model ? String(req.body.model) : undefined,
    };

    if (!path.isAbsolute(payload.repoPath)) {
      return res.status(400).json({ error: 'repoPath must be an absolute path.' });
    }

    if (!payload.taskBrief.trim()) {
      return res.status(400).json({ error: 'taskBrief is required.' });
    }

    const queued = await queueCodexRun(payload);

    await db.collection('system_logs').add({
      id: Date.now().toString(),
      event: `Codex run queued for ${path.basename(payload.repoPath)}`,
      user: req.user?.email || 'unknown',
      time: nowIso(),
      type: 'info',
    });

    res.status(202).json({
      runId: queued.runId,
      status: 'queued',
      repoPath: payload.repoPath,
      worktreePath: queued.worktreePath,
      targetBranch: payload.targetBranch || null,
      approvalMode: payload.approvalMode,
      model: payload.model || null,
      startedAt: nowIso(),
      finishedAt: null,
      exitCode: null,
      finalAgentMessage: null,
      nextSteps: ['Poll /api/codex/runs/:runId/status for progress.'],
    } satisfies CodexRunSummary);
  } catch (error) {
    res.status(500).json({ error: (error as Error).message, bmoStackRoot: BMO_STACK_ROOT });
  }
});

app.get('/api/codex/runs/:runId/status', authenticateToken, async (req, res) => {
  try {
    res.json(await readCodexStatus(req.params.runId));
  } catch (error) {
    res.status(404).json({ error: (error as Error).message });
  }
});

app.get('/api/codex/runs/:runId/result', authenticateToken, async (req, res) => {
  try {
    res.json(await readCodexResult(req.params.runId));
  } catch (error) {
    res.status(404).json({ error: (error as Error).message });
  }
});

app.listen(PORT, () => {
  console.log(`BeMore API running on http://localhost:${PORT}`);
});
