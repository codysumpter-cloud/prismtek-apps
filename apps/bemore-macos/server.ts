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
  RuntimePatch,
  RuntimePatchOperation,
  RuntimeProcess,
  RuntimeReceipt,
  RuntimeSandboxSession,
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
const patches = new Map<string, RuntimePatch>();
const receipts: RuntimeReceipt[] = [];
const sandboxSession: RuntimeSandboxSession = {
  id: `sandbox-${randomUUID()}`,
  workspaceRoot,
  mode: 'workspace-bound',
  createdAt: new Date().toISOString(),
  commandTimeoutMs: Number(process.env.BEMORE_COMMAND_TIMEOUT_MS ?? 120000),
  maxOutputBytes: Number(process.env.BEMORE_MAX_OUTPUT_BYTES ?? 256000),
  blockedCommands: ['rm -rf /', 'sudo ', 'mkfs', ':(){', 'dd if=', '> /dev/'],
  note: 'Commands run as child processes on this Mac, bounded to the selected workspace with command blocking, timeout, and output limits. This is not VM isolation.',
};
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
  const relative = path.relative(path.resolve(root), resolved);
  if (relative.startsWith('..') || path.isAbsolute(relative)) {
    throw new Error('Path escapes the selected workspace.');
  }
  return resolved;
};

const safeCommand = (command: string) => {
  const normalized = command.replace(/\s+/g, ' ').trim();
  if (!normalized) throw new Error('Command is required.');
  const blocked = sandboxSession.blockedCommands.find((pattern) => normalized.includes(pattern));
  if (blocked) throw new Error(`Command blocked by BeMore workspace sandbox policy: ${blocked}`);
  return normalized;
};

const clampOutput = (value: string) => {
  const bytes = Buffer.byteLength(value);
  if (bytes <= sandboxSession.maxOutputBytes) return value;
  return `${value.slice(0, sandboxSession.maxOutputBytes)}\n[BeMore truncated output at ${sandboxSession.maxOutputBytes} bytes]`;
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

function operationDiff(operation: RuntimePatchOperation): string {
  const before = operation.kind === 'write' && operation.before === undefined ? '' : operation.before ?? '';
  const beforeLines = before.split('\n');
  const afterLines = operation.after.split('\n');
  const removed = beforeLines.length === 1 && beforeLines[0] === '' ? [] : beforeLines.map((line) => `-${line}`);
  const added = afterLines.length === 1 && afterLines[0] === '' ? [] : afterLines.map((line) => `+${line}`);
  return [`--- a/${operation.path}`, `+++ b/${operation.path}`, '@@', ...removed, ...added].join('\n');
}

async function previewPatch(title: string, operations: RuntimePatchOperation[], taskId?: string): Promise<RuntimePatch> {
  if (!operations.length) throw new Error('Patch requires at least one operation.');
  const normalized: RuntimePatchOperation[] = [];
  const files: RuntimeDiffFile[] = [];
  for (const operation of operations) {
    const relativePath = String(operation.path ?? '');
    if (!isTextEditablePath(relativePath)) throw new Error(`Patch target is not text-editable: ${relativePath}`);
    const absolute = safePath(relativePath);
    const current = existsSync(absolute) ? await readFile(absolute, 'utf8') : '';
    if (operation.kind === 'replace' && operation.before !== undefined && !current.includes(operation.before)) {
      throw new Error(`Patch before text was not found in ${relativePath}`);
    }
    const after = operation.kind === 'replace' && operation.before !== undefined ? current.replace(operation.before, operation.after) : operation.after;
    normalized.push({...operation, path: relativePath, before: current, after});
    files.push({path: relativePath, status: existsSync(absolute) ? 'modified' : 'added', summary: `${operation.kind} ${relativePath}`});
  }
  const now = new Date().toISOString();
  return {
    id: `patch-${now.replace(/[^0-9A-Za-z]/g, '').toLowerCase()}-${Math.random().toString(36).slice(2, 8)}`,
    title,
    status: 'previewed',
    createdAt: now,
    updatedAt: now,
    taskId,
    operations: normalized,
    files,
    unifiedDiff: normalized.map(operationDiff).join('\n'),
    receiptIds: [],
  };
}

async function applyRuntimePatch(patch: RuntimePatch): Promise<RuntimePatch> {
  const startedAt = new Date().toISOString();
  try {
    for (const operation of patch.operations) {
      const absolute = safePath(operation.path);
      if (operation.kind === 'replace' && operation.before !== undefined) {
        const current = existsSync(absolute) ? await readFile(absolute, 'utf8') : '';
        if (!current.includes(operation.before)) throw new Error(`Patch before text no longer matches ${operation.path}`);
      }
    }
    for (const operation of patch.operations) {
      await mkdir(path.dirname(safePath(operation.path)), {recursive: true});
      await writeFile(safePath(operation.path), operation.after, 'utf8');
    }
    patch.status = 'applied';
    patch.updatedAt = new Date().toISOString();
    const receipt = createReceipt({
      action: 'applyPatch',
      status: 'completed',
      startedAt,
      summary: `Applied patch ${patch.title}`,
      taskId: patch.taskId,
      patchId: patch.id,
      sandboxSessionId: sandboxSession.id,
    });
    patch.receiptIds.unshift(receipt.id);
    receipts.unshift(receipt);
    if (patch.taskId) {
      const task = tasks.get(patch.taskId);
      if (task) {
        task.receiptIds.unshift(receipt.id);
        task.updatedAt = patch.updatedAt;
      }
    }
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    patch.status = 'failed';
    patch.failureReason = message;
    patch.updatedAt = new Date().toISOString();
    const receipt = createReceipt({
      action: 'applyPatch',
      status: 'failed',
      startedAt,
      summary: `Failed to apply patch ${patch.title}`,
      taskId: patch.taskId,
      patchId: patch.id,
      sandboxSessionId: sandboxSession.id,
      failureReason: message,
    });
    patch.receiptIds.unshift(receipt.id);
    receipts.unshift(receipt);
  }
  return patch;
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
    patches: Array.from(patches.values()),
    artifacts: await listArtifacts(),
    receipts,
    diff: await currentDiff(),
    buddy: buddyState(),
    pairing: pairingState,
    sandbox: {...sandboxSession, workspaceRoot},
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
    patchCount: patches.size,
    sandbox: {...sandboxSession, workspaceRoot},
    pairing: pairingState,
  });
});

app.post('/api/workspace/select', async (req, res, next) => {
  try {
    const requestedPath = String(req.body.workspacePath || '').replace(/^~(?=$|\/)/, homedir());
    const info = await stat(requestedPath);
    if (!info.isDirectory()) throw new Error('Workspace path must be a folder.');
    workspaceRoot = path.resolve(requestedPath);
    sandboxSession.workspaceRoot = workspaceRoot;
    res.json(await snapshot());
  } catch (error) {
    next(error);
  }
});

app.get('/api/workspace/file', async (req, res, next) => {
  try {
    const relativePath = String(req.query.path ?? '');
    if (!isTextEditablePath(relativePath)) throw new Error('This editor only opens text files.');
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
    const startedAt = new Date().toISOString();
    let command: string;
    try {
      command = safeCommand(String(req.body.command ?? ''));
    } catch (error) {
      const failureReason = error instanceof Error ? error.message : String(error);
      const receipt = createReceipt({
        action: 'runCommand',
        status: 'blocked',
        startedAt,
        command: String(req.body.command ?? ''),
        cwd: root,
        taskId: req.body.taskId,
        sandboxSessionId: sandboxSession.id,
        failureReason,
        summary: `Blocked command: ${String(req.body.command ?? '').trim()}`,
      });
      receipts.unshift(receipt);
      throw error;
    }
    const id = `process-${randomUUID()}`;
    const timeoutMs = Number(req.body.timeoutMs ?? sandboxSession.commandTimeoutMs);
    const processRecord: RuntimeProcess & {child?: ReturnType<typeof spawn>} = {
      id,
      command,
      cwd: root,
      status: 'running',
      stdout: '',
      stderr: '',
      startedAt,
      sandboxSessionId: sandboxSession.id,
    };
    const child = spawn(command, {cwd: root, shell: true});
    processRecord.child = child;
    const timer = setTimeout(() => {
      if (processRecord.status === 'running') {
        processRecord.failureReason = `Timed out after ${timeoutMs}ms`;
        processRecord.stderr = clampOutput(`${processRecord.stderr}\n[BeMore terminated command after ${timeoutMs}ms]`);
        child.kill('SIGTERM');
      }
    }, timeoutMs);
    child.stdout.on('data', (chunk: Buffer) => {
      processRecord.stdout = clampOutput(processRecord.stdout + chunk.toString());
    });
    child.stderr.on('data', (chunk: Buffer) => {
      processRecord.stderr = clampOutput(processRecord.stderr + chunk.toString());
    });
    child.on('close', (exitCode) => {
      clearTimeout(timer);
      processRecord.exitCode = exitCode;
      processRecord.status = exitCode === 0 ? 'completed' : 'failed';
      processRecord.endedAt = new Date().toISOString();
      if (processRecord.status === 'failed' && !processRecord.failureReason) {
        processRecord.failureReason = processRecord.stderr.trim().split('\n').at(-1) || `Command exited ${exitCode}`;
      }
      const receipt = createReceipt({
        action: 'runCommand',
        status: processRecord.status,
        startedAt,
        command,
        cwd: root,
        exitCode,
        taskId: req.body.taskId,
        sandboxSessionId: sandboxSession.id,
        failureReason: processRecord.failureReason,
        summary: exitCode === 0 ? `Command completed: ${command}` : `Command failed: ${command}`,
      });
      processRecord.receiptId = receipt.id;
      receipts.unshift(receipt);
      if (req.body.taskId) {
        const task = tasks.get(String(req.body.taskId));
        if (task) {
          task.status = processRecord.status;
          task.updatedAt = processRecord.endedAt;
          task.resultSummary = processRecord.status === 'completed' ? `Command completed with exit ${exitCode}` : `Command failed with exit ${exitCode}`;
          task.failureReason = processRecord.failureReason;
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
      sandboxSessionId: sandboxSession.id,
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
  const task = createTask(String(req.body.title ?? 'Untitled task'), String(req.body.detail ?? ''), req.body.command, {
    role: req.body.role,
    maxRetries: Number(req.body.maxRetries ?? 1),
  });
  tasks.set(task.id, task);
  res.json(task);
});

app.post('/api/tasks/:id/subtasks', (req, res, next) => {
  try {
    const parent = tasks.get(req.params.id);
    if (!parent) throw new Error('Parent task not found.');
    const subtask = createTask(String(req.body.title ?? 'Delegated subtask'), String(req.body.detail ?? ''), req.body.command, {
      parentId: parent.id,
      role: req.body.role ?? 'worker',
      maxRetries: Number(req.body.maxRetries ?? parent.maxRetries ?? 1),
    });
    parent.childIds.push(subtask.id);
    parent.updatedAt = new Date().toISOString();
    tasks.set(subtask.id, subtask);
    const receipt = createReceipt({
      action: 'delegateSubtask',
      status: 'completed',
      taskId: subtask.id,
      parentTaskId: parent.id,
      sandboxSessionId: sandboxSession.id,
      summary: `Delegated ${subtask.title} from ${parent.title}`,
    });
    subtask.receiptIds.unshift(receipt.id);
    parent.receiptIds.unshift(receipt.id);
    receipts.unshift(receipt);
    res.json(subtask);
  } catch (error) {
    next(error);
  }
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
        parentTaskId: task.parentId,
        sandboxSessionId: sandboxSession.id,
        summary: `Recorded task without command: ${task.title}`,
      });
      task.status = 'completed';
      task.resultSummary = receipt.summary;
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

app.post('/api/tasks/:id/retry', (req, res, next) => {
  try {
    const task = tasks.get(req.params.id);
    if (!task) throw new Error('Task not found.');
    if (task.retryCount >= task.maxRetries) throw new Error(`Retry limit reached for ${task.id}`);
    const retry = createTask(
      String(req.body.title ?? `${task.title} retry ${task.retryCount + 1}`),
      String(req.body.detail ?? `Retry of ${task.id}. Last failure: ${task.failureReason ?? 'unknown'}`),
      req.body.command ?? task.command,
      {
        parentId: task.parentId ?? task.id,
        role: task.role ?? 'worker',
        maxRetries: task.maxRetries,
        retryOfTaskId: task.id,
      },
    );
    retry.retryCount = task.retryCount + 1;
    task.retryCount += 1;
    task.childIds.push(retry.id);
    task.updatedAt = new Date().toISOString();
    tasks.set(retry.id, retry);
    const receipt = createReceipt({
      action: 'retryTask',
      status: 'completed',
      taskId: retry.id,
      parentTaskId: task.id,
      sandboxSessionId: sandboxSession.id,
      retryCount: retry.retryCount,
      failureReason: task.failureReason,
      summary: `Created bounded retry ${retry.retryCount}/${task.maxRetries} for ${task.title}`,
    });
    retry.receiptIds.unshift(receipt.id);
    task.receiptIds.unshift(receipt.id);
    receipts.unshift(receipt);
    res.json(retry);
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

app.get('/api/patches', (_req, res) => {
  res.json(Array.from(patches.values()));
});

app.post('/api/patches/preview', async (req, res, next) => {
  try {
    const patch = await previewPatch(
      String(req.body.title ?? 'Untitled patch'),
      (req.body.operations ?? []) as RuntimePatchOperation[],
      req.body.taskId ? String(req.body.taskId) : undefined,
    );
    patches.set(patch.id, patch);
    const receipt = createReceipt({
      action: 'previewPatch',
      status: 'completed',
      taskId: patch.taskId,
      patchId: patch.id,
      sandboxSessionId: sandboxSession.id,
      summary: `Previewed patch ${patch.title}`,
    });
    patch.receiptIds.unshift(receipt.id);
    receipts.unshift(receipt);
    res.json(patch);
  } catch (error) {
    next(error);
  }
});

app.post('/api/patches/:id/apply', async (req, res, next) => {
  try {
    const patch = patches.get(req.params.id);
    if (!patch) throw new Error('Patch not found.');
    if (patch.status !== 'previewed' && patch.status !== 'failed') throw new Error(`Patch is ${patch.status} and cannot be applied.`);
    res.json(await applyRuntimePatch(patch));
  } catch (error) {
    next(error);
  }
});

app.post('/api/patches/:id/reject', (req, res, next) => {
  try {
    const patch = patches.get(req.params.id);
    if (!patch) throw new Error('Patch not found.');
    patch.status = 'rejected';
    patch.updatedAt = new Date().toISOString();
    const receipt = createReceipt({
      action: 'rejectPatch',
      status: 'completed',
      taskId: patch.taskId,
      patchId: patch.id,
      sandboxSessionId: sandboxSession.id,
      summary: `Rejected patch ${patch.title}`,
    });
    patch.receiptIds.unshift(receipt.id);
    receipts.unshift(receipt);
    res.json(patch);
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
