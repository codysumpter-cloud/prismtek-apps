import cors from 'cors';
import express from 'express';
import {spawn} from 'node:child_process';
import {randomUUID} from 'node:crypto';
import {existsSync} from 'node:fs';
import {mkdir, readdir, readFile, stat, writeFile} from 'node:fs/promises';
import {homedir, hostname} from 'node:os';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import type {
  PairingState,
  RuntimeArtifact,
  RuntimeBuddyState,
  RuntimeDiff,
  RuntimeDiffFile,
  RuntimeFileNode,
  RuntimeProcess,
  RuntimeReceipt,
  RuntimeTask,
} from '@prismtek/agent-protocol';
import {createReceipt} from '@prismtek/receipts-core';
import {
  BEMORE_IGNORED_WORKSPACE_NAMES,
  createArtifact,
  createFileNode,
  createTask,
  isTextEditablePath,
  normalizeDiffStatus,
} from '@prismtek/workspace-core';

const app = express();
const port = Number(process.env.BEMORE_MAC_RUNTIME_PORT ?? 4319);
const host = process.env.BEMORE_MAC_RUNTIME_HOST ?? '127.0.0.1';
const clientDist = path.join(path.dirname(fileURLToPath(import.meta.url)), '..');

app.use(cors());
app.use(express.json({limit: '5mb'}));

let workspaceRoot: string | null = process.env.BEMORE_WORKSPACE_ROOT ?? null;
const processes = new Map<string, RuntimeProcess & {child?: ReturnType<typeof spawn>}>();
const tasks = new Map<string, RuntimeTask>();
const receipts: RuntimeReceipt[] = [];
let pairingState: PairingState = {
  hostId: `bemore-mac-${hostname().replace(/[^a-z0-9]/gi, '-').toLowerCase()}`,
  hostName: hostname(),
  status: 'ready',
  pairingCode: Math.random().toString(36).slice(2, 8).toUpperCase(),
  devices: [],
};

const ensureWorkspace = () => {
  if (!workspaceRoot) {
    throw new Error('Choose a workspace folder before using the runtime.');
  }
  return workspaceRoot;
};

const safePath = (relativePath = '') => {
  const root = ensureWorkspace();
  const resolved = path.resolve(root, relativePath);
  if (!resolved.startsWith(path.resolve(root))) {
    throw new Error('Path escapes the selected workspace.');
  }
  return resolved;
};

const toRelative = (absolutePath: string) => path.relative(ensureWorkspace(), absolutePath).split(path.sep).join('/');

async function listWorkspaceFiles(dir = ensureWorkspace(), depth = 0): Promise<RuntimeFileNode[]> {
  if (depth > 3) return [];
  const entries = await readdir(dir, {withFileTypes: true});
  const nodes: RuntimeFileNode[] = [];
  for (const entry of entries) {
    if (BEMORE_IGNORED_WORKSPACE_NAMES.has(entry.name)) continue;
    const absolute = path.join(dir, entry.name);
    const info = await stat(absolute);
    const relativePath = toRelative(absolute);
    nodes.push(
      createFileNode({
        name: entry.name,
        relativePath,
        kind: entry.isDirectory() ? 'directory' : 'file',
        size: info.size,
        modifiedAt: info.mtime.toISOString(),
        children: entry.isDirectory() ? await listWorkspaceFiles(absolute, depth + 1) : undefined,
      }),
    );
  }
  return nodes.sort((a, b) => Number(a.kind === 'file') - Number(b.kind === 'file') || a.name.localeCompare(b.name));
}

async function runGit(args: string[]): Promise<string> {
  const root = ensureWorkspace();
  if (!existsSync(path.join(root, '.git'))) return '';
  return await new Promise((resolve) => {
    const child = spawn('git', args, {cwd: root, shell: false});
    let output = '';
    child.stdout.on('data', (chunk: Buffer) => {
      output += chunk.toString();
    });
    child.stderr.on('data', (chunk: Buffer) => {
      output += chunk.toString();
    });
    child.on('close', () => resolve(output));
  });
}

async function currentDiff(): Promise<RuntimeDiff> {
  if (!workspaceRoot || !existsSync(path.join(workspaceRoot, '.git'))) {
    return {id: 'diff:none', generatedAt: new Date().toISOString(), files: [], unifiedDiff: ''};
  }
  const porcelain = await runGit(['status', '--porcelain']);
  const files: RuntimeDiffFile[] = porcelain
    .split('\n')
    .filter(Boolean)
    .map((line) => {
      const status = line.slice(0, 2);
      const filePath = line.slice(3);
      return {
        path: filePath,
        status: normalizeDiffStatus(status),
        summary: `${status.trim() || 'changed'} ${filePath}`,
      };
    });
  const unifiedDiff = await runGit(['diff', '--', '.']);
  return {id: `diff-${Date.now()}`, generatedAt: new Date().toISOString(), files, unifiedDiff};
}

async function listArtifacts(): Promise<RuntimeArtifact[]> {
  if (!workspaceRoot) return [];
  const candidates = ['dist', 'build', 'artifacts', 'receipts', '.bemore'];
  const artifacts: RuntimeArtifact[] = [];
  for (const candidate of candidates) {
    const absolute = path.join(workspaceRoot, candidate);
    if (!existsSync(absolute)) continue;
    const info = await stat(absolute);
    artifacts.push(createArtifact(candidate, {size: info.size, modifiedAt: info.mtime.toISOString(), isDirectory: info.isDirectory()}));
  }
  return artifacts;
}

function buddyState(): RuntimeBuddyState {
  return {
    mode: pairingState.devices.length ? 'paired' : 'standalone',
    activeFocus: workspaceRoot ? `Working in ${workspaceRoot}` : 'Choose a workspace to begin.',
    guidance: [
      'Use receipts as the truth for every command and task.',
      'Pairing requests can read state first; write and run scopes stay explicit.',
      'Keep BeMore product-owned even when adapters borrow older runtime ideas.',
    ],
    council: [
      {seat: 'Buddy', status: 'running', note: 'Ready to turn workspace actions into receipts.'},
      {seat: 'Prismo', status: 'idle', note: 'Pairing boundary is ready for iPhone delegation.'},
      {seat: 'NEPTR', status: 'idle', note: 'Review diffs and failed receipts before claiming done.'},
    ],
  };
}

async function snapshot() {
  return {
    workspaceRoot,
    files: workspaceRoot ? await listWorkspaceFiles() : [],
    tasks: Array.from(tasks.values()),
    processes: Array.from(processes.values()).map(({child, ...process}) => process),
    artifacts: await listArtifacts(),
    receipts,
    diff: await currentDiff(),
    buddy: buddyState(),
    pairing: pairingState,
  };
}

app.get('/api/snapshot', async (_req, res, next) => {
  try {
    res.json(await snapshot());
  } catch (error) {
    next(error);
  }
});

app.get('/api/runtime/status', async (_req, res) => {
  res.json({
    status: 'ready',
    runtime: 'bemore-mac',
    version: '1.0.0-build.1',
    workspaceRoot,
    processCount: processes.size,
    taskCount: tasks.size,
    receiptCount: receipts.length,
    pairing: pairingState,
  });
});

app.post('/api/workspace/select', async (req, res, next) => {
  try {
    const requestedPath = String(req.body.workspacePath || '').replace(/^~(?=$|\/)/, homedir());
    const info = await stat(requestedPath);
    if (!info.isDirectory()) throw new Error('Workspace path must be a folder.');
    workspaceRoot = path.resolve(requestedPath);
    res.json(await snapshot());
  } catch (error) {
    next(error);
  }
});

app.get('/api/workspace/file', async (req, res, next) => {
  try {
    const relativePath = String(req.query.path ?? '');
    if (!isTextEditablePath(relativePath)) throw new Error('This Build 1 editor only opens text files.');
    res.json({relativePath, content: await readFile(safePath(relativePath), 'utf8'), encoding: 'utf8'});
  } catch (error) {
    next(error);
  }
});

app.put('/api/workspace/file', async (req, res, next) => {
  try {
    const relativePath = String(req.body.relativePath ?? '');
    const content = String(req.body.content ?? '');
    const startedAt = new Date().toISOString();
    await mkdir(path.dirname(safePath(relativePath)), {recursive: true});
    await writeFile(safePath(relativePath), content, 'utf8');
    const receipt = createReceipt({
      action: 'writeFile',
      status: 'completed',
      startedAt,
      summary: `Saved ${relativePath}`,
    });
    receipts.unshift(receipt);
    res.json({receipt});
  } catch (error) {
    next(error);
  }
});

app.post('/api/processes', async (req, res, next) => {
  try {
    const root = ensureWorkspace();
    const command = String(req.body.command ?? '').trim();
    if (!command) throw new Error('Command is required.');
    const startedAt = new Date().toISOString();
    const id = `process-${randomUUID()}`;
    const processRecord: RuntimeProcess & {child?: ReturnType<typeof spawn>} = {
      id,
      command,
      cwd: root,
      status: 'running',
      stdout: '',
      stderr: '',
      startedAt,
    };
    const child = spawn(command, {cwd: root, shell: true});
    processRecord.child = child;
    child.stdout.on('data', (chunk: Buffer) => {
      processRecord.stdout += chunk.toString();
    });
    child.stderr.on('data', (chunk: Buffer) => {
      processRecord.stderr += chunk.toString();
    });
    child.on('close', (exitCode) => {
      processRecord.exitCode = exitCode;
      processRecord.status = exitCode === 0 ? 'completed' : 'failed';
      processRecord.endedAt = new Date().toISOString();
      const receipt = createReceipt({
        action: 'runCommand',
        status: processRecord.status,
        startedAt,
        command,
        cwd: root,
        exitCode,
        taskId: req.body.taskId,
        summary: exitCode === 0 ? `Command completed: ${command}` : `Command failed: ${command}`,
      });
      processRecord.receiptId = receipt.id;
      receipts.unshift(receipt);
      if (req.body.taskId) {
        const task = tasks.get(String(req.body.taskId));
        if (task) {
          task.status = processRecord.status;
          task.updatedAt = processRecord.endedAt;
          task.receiptIds.unshift(receipt.id);
        }
      }
    });
    processes.set(id, processRecord);
    const {child: _child, ...record} = processRecord;
    res.json(record);
  } catch (error) {
    next(error);
  }
});

app.get('/api/processes/:id', (req, res, next) => {
  try {
    const record = processes.get(req.params.id);
    if (!record) throw new Error('Process not found.');
    const {child: _child, ...process} = record;
    res.json(process);
  } catch (error) {
    next(error);
  }
});

app.post('/api/processes/:id/stop', (req, res, next) => {
  try {
    const record = processes.get(req.params.id);
    if (!record?.child || record.status !== 'running') throw new Error('Process is not running.');
    record.child.kill('SIGTERM');
    record.status = 'failed';
    const receipt = createReceipt({
      action: 'stopProcess',
      status: 'completed',
      summary: `Stopped ${record.command}`,
      command: record.command,
      cwd: record.cwd,
    });
    receipts.unshift(receipt);
    res.json({receipt});
  } catch (error) {
    next(error);
  }
});

app.get('/api/tasks', (_req, res) => {
  res.json(Array.from(tasks.values()));
});

app.post('/api/tasks', (req, res) => {
  const task = createTask(String(req.body.title ?? 'Untitled task'), String(req.body.detail ?? ''), req.body.command);
  tasks.set(task.id, task);
  res.json(task);
});

app.post('/api/tasks/:id/run', async (req, res, next) => {
  try {
    const task = tasks.get(req.params.id);
    if (!task) throw new Error('Task not found.');
    task.status = 'running';
    task.updatedAt = new Date().toISOString();
    if (!task.command) {
      const receipt = createReceipt({
        action: 'runTask',
        status: 'completed',
        taskId: task.id,
        summary: `Recorded task without command: ${task.title}`,
      });
      task.status = 'completed';
      task.receiptIds.unshift(receipt.id);
      receipts.unshift(receipt);
      res.json(task);
      return;
    }
    const commandResponse = await fetch(`http://127.0.0.1:${port}/api/processes`, {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({command: task.command, taskId: task.id}),
    });
    if (!commandResponse.ok) throw new Error(await commandResponse.text());
    task.updatedAt = new Date().toISOString();
    res.json(task);
  } catch (error) {
    next(error);
  }
});

app.get('/api/diffs/current', async (_req, res, next) => {
  try {
    res.json(await currentDiff());
  } catch (error) {
    next(error);
  }
});

app.get('/api/artifacts', async (_req, res, next) => {
  try {
    res.json(await listArtifacts());
  } catch (error) {
    next(error);
  }
});

app.get('/api/artifacts/file', async (req, res, next) => {
  try {
    const relativePath = String(req.query.path ?? '');
    res.json({relativePath, content: await readFile(safePath(relativePath), 'utf8'), encoding: 'utf8'});
  } catch (error) {
    next(error);
  }
});

app.get('/api/receipts', (_req, res) => {
  res.json(receipts);
});

app.get('/api/buddy', (_req, res) => {
  res.json(buddyState());
});

app.use(express.static(clientDist));
app.get(/.*/, (_req, res) => {
  res.sendFile(path.join(clientDist, 'index.html'));
});

app.use((error: unknown, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  const message = error instanceof Error ? error.message : String(error);
  res.status(400).json({error: message});
});

app.listen(port, host, () => {
  console.log(`BeMore Mac runtime listening on http://${host}:${port}`);
});
