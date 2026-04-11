#!/usr/bin/env node
import {spawn} from 'node:child_process';
import process from 'node:process';
import {fileURLToPath} from 'node:url';
import type {
  RuntimeArtifact,
  RuntimeBuddyState,
  RuntimeDiff,
  RuntimeFileContent,
  RuntimeFileNode,
  RuntimePatch,
  RuntimePatchOperation,
  RuntimeProcess,
  RuntimeReceipt,
  RuntimeSandboxSession,
  RuntimeTask,
} from '@prismtek/agent-protocol';

const defaultRuntimeUrl = process.env.BEMORE_RUNTIME_URL ?? 'http://127.0.0.1:4319';
const repoRoot = fileURLToPath(new URL('../../..', import.meta.url));

interface CliState {
  args: string[];
  json: boolean;
  runtimeUrl: string;
}

interface RuntimeSnapshot {
  workspaceRoot: string | null;
  files: RuntimeFileNode[];
  tasks: RuntimeTask[];
  processes: RuntimeProcess[];
  patches: RuntimePatch[];
  artifacts: RuntimeArtifact[];
  receipts: RuntimeReceipt[];
  diff: RuntimeDiff;
  buddy: RuntimeBuddyState;
  sandbox: RuntimeSandboxSession;
}

function parseArgs(argv: string[]): CliState {
  const args = [...argv];
  let json = false;
  let runtimeUrl = defaultRuntimeUrl;
  for (let index = 0; index < args.length; index += 1) {
    const arg = args[index];
    if (arg === '--json') {
      json = true;
      args.splice(index, 1);
      index -= 1;
    } else if (arg === '--runtime-url') {
      runtimeUrl = args[index + 1] ?? runtimeUrl;
      args.splice(index, 2);
      index -= 1;
    }
  }
  return {args, json, runtimeUrl};
}

async function api<T>(state: CliState, path: string, init?: RequestInit): Promise<T> {
  const response = await fetch(`${state.runtimeUrl.replace(/\/$/, '')}/api${path}`, {
    headers: {'Content-Type': 'application/json', ...(init?.headers ?? {})},
    ...init,
  });
  const text = await response.text();
  const payload = text ? JSON.parse(text) : {};
  if (!response.ok) {
    throw new Error(payload.error ?? response.statusText);
  }
  return payload as T;
}

function print(state: CliState, payload: unknown, human?: string): void {
  if (state.json) {
    console.log(JSON.stringify(payload, null, 2));
    return;
  }
  if (human) {
    console.log(human);
    return;
  }
  if (typeof payload === 'string') console.log(payload);
  else console.log(JSON.stringify(payload, null, 2));
}

function flatten(nodes: RuntimeFileNode[]): RuntimeFileNode[] {
  return nodes.flatMap((node) => [node, ...(node.children ? flatten(node.children) : [])]);
}

async function waitForProcess(state: CliState, processId: string): Promise<RuntimeProcess> {
  for (;;) {
    const record = await api<RuntimeProcess>(state, `/processes/${encodeURIComponent(processId)}`);
    if (record.status !== 'running') return record;
    await new Promise((resolve) => setTimeout(resolve, 500));
  }
}

async function startRuntime(state: CliState): Promise<void> {
  const workspaceIndex = state.args.indexOf('--workspace');
  const workspaceRoot = workspaceIndex >= 0 ? state.args[workspaceIndex + 1] : undefined;
  const child = spawn('npm', ['--workspace', '@prismtek/bemore-macos', 'run', 'dev'], {
    cwd: repoRoot,
    env: {...process.env, ...(workspaceRoot ? {BEMORE_WORKSPACE_ROOT: workspaceRoot} : {})},
    stdio: 'inherit',
  });
  await new Promise((resolve, reject) => {
    child.on('error', reject);
    child.on('exit', (code) => (code === 0 ? resolve(undefined) : reject(new Error(`runtime exited with ${code}`))));
  });
}

async function main(): Promise<void> {
  const state = parseArgs(process.argv.slice(2));
  const [group, command, ...rest] = state.args;

  if (!group || group === 'help' || group === '--help') {
    print(state, usage(), usage());
    return;
  }

  if (group === 'runtime' && command === 'start') {
    await startRuntime({...state, args: rest});
    return;
  }

  if (group === 'runtime' && command === 'status') {
    const status = await api<Record<string, unknown>>(state, '/runtime/status');
    print(state, status, `BeMore runtime ${status.status} at ${state.runtimeUrl}\nworkspace: ${status.workspaceRoot ?? 'none'}`);
    return;
  }

  if (group === 'runtime' && command === 'sandbox') {
    const snapshot = await api<RuntimeSnapshot>(state, '/snapshot');
    print(state, snapshot.sandbox, `${snapshot.sandbox.id}\nmode: ${snapshot.sandbox.mode}\nworkspace: ${snapshot.sandbox.workspaceRoot ?? 'none'}\n${snapshot.sandbox.note}`);
    return;
  }

  if (group === 'workspace' && command === 'open') {
    const workspacePath = rest[0] ?? process.cwd();
    const snapshot = await api<RuntimeSnapshot>(state, '/workspace/select', {
      method: 'POST',
      body: JSON.stringify({workspacePath}),
    });
    print(state, snapshot, `Opened ${snapshot.workspaceRoot}`);
    return;
  }

  if (group === 'workspace' && (command === 'list' || command === 'show')) {
    const snapshot = await api<RuntimeSnapshot>(state, '/snapshot');
    print(state, {workspaceRoot: snapshot.workspaceRoot}, snapshot.workspaceRoot ?? 'No workspace selected.');
    return;
  }

  if (group === 'files' && command === 'list') {
    const snapshot = await api<RuntimeSnapshot>(state, '/snapshot');
    const files = flatten(snapshot.files);
    print(state, files, files.map((file) => `${file.kind}\t${file.relativePath}`).join('\n') || 'No files.');
    return;
  }

  if (group === 'file' && command === 'read') {
    const relativePath = required(rest[0], 'file read requires a path');
    const file = await api<RuntimeFileContent>(state, `/workspace/file?path=${encodeURIComponent(relativePath)}`);
    print(state, file, file.content);
    return;
  }

  if (group === 'file' && command === 'write') {
    const relativePath = required(rest[0], 'file write requires a path');
    const content = rest.includes('--stdin') ? await stdin() : required(rest.slice(1).join(' '), 'file write requires content or --stdin');
    const result = await api<{receipt: RuntimeReceipt}>(state, '/workspace/file', {
      method: 'PUT',
      body: JSON.stringify({relativePath, content}),
    });
    print(state, result, result.receipt.summary);
    return;
  }

  if (group === 'run') {
    const runArgs = [command, ...rest].filter(Boolean);
    const wait = runArgs.includes('--wait');
    const commandText = runArgs.filter((arg) => arg !== '--wait').join(' ');
    const record = await api<RuntimeProcess>(state, '/processes', {
      method: 'POST',
      body: JSON.stringify({command: required(commandText, 'run requires a command')}),
    });
    const finalRecord = wait ? await waitForProcess(state, record.id) : record;
    print(state, finalRecord, [finalRecord.stdout, finalRecord.stderr].filter(Boolean).join('\n') || `${finalRecord.status}: ${finalRecord.command}`);
    return;
  }

  if (group === 'tasks' && command === 'list') {
    const tasks = await api<RuntimeTask[]>(state, '/tasks');
    print(state, tasks, tasks.map((task) => `${task.status}\t${task.id}\t${task.title}`).join('\n') || 'No tasks.');
    return;
  }

  if (group === 'tasks' && command === 'create') {
    const title = required(rest[0], 'tasks create requires a title');
    const commandIndex = rest.indexOf('--command');
    const detailIndex = rest.indexOf('--detail');
    const task = await api<RuntimeTask>(state, '/tasks', {
      method: 'POST',
      body: JSON.stringify({
        title,
        detail: detailIndex >= 0 ? rest[detailIndex + 1] ?? '' : '',
        command: commandIndex >= 0 ? rest.slice(commandIndex + 1).join(' ') : undefined,
        role: valueAfter(rest, '--role'),
        maxRetries: Number(valueAfter(rest, '--max-retries') ?? 1),
      }),
    });
    print(state, task, `Created ${task.id}: ${task.title}`);
    return;
  }

  if (group === 'tasks' && command === 'delegate') {
    const parentId = required(rest[0], 'tasks delegate requires a parent task id');
    const title = required(rest[1], 'tasks delegate requires a title');
    const commandIndex = rest.indexOf('--command');
    const detailIndex = rest.indexOf('--detail');
    const subtask = await api<RuntimeTask>(state, `/tasks/${encodeURIComponent(parentId)}/subtasks`, {
      method: 'POST',
      body: JSON.stringify({
        title,
        detail: detailIndex >= 0 ? rest[detailIndex + 1] ?? '' : '',
        command: commandIndex >= 0 ? rest.slice(commandIndex + 1).join(' ') : undefined,
        role: valueAfter(rest, '--role') ?? 'worker',
        maxRetries: Number(valueAfter(rest, '--max-retries') ?? 1),
      }),
    });
    print(state, subtask, `Delegated ${subtask.id}: ${subtask.title}`);
    return;
  }

  if (group === 'tasks' && command === 'retry') {
    const task = await api<RuntimeTask>(state, `/tasks/${encodeURIComponent(required(rest[0], 'tasks retry requires an id'))}/retry`, {method: 'POST'});
    print(state, task, `Created retry ${task.id}: ${task.title}`);
    return;
  }

  if (group === 'tasks' && command === 'run') {
    const task = await api<RuntimeTask>(state, `/tasks/${encodeURIComponent(required(rest[0], 'tasks run requires an id'))}/run`, {method: 'POST'});
    print(state, task, `Started ${task.id}: ${task.title}`);
    return;
  }

  if (group === 'artifacts' && command === 'list') {
    const artifacts = await api<RuntimeArtifact[]>(state, '/artifacts');
    print(state, artifacts, artifacts.map((artifact) => `${artifact.kind}\t${artifact.relativePath}`).join('\n') || 'No artifacts.');
    return;
  }

  if (group === 'patches' && command === 'list') {
    const patches = await api<RuntimePatch[]>(state, '/patches');
    print(state, patches, patches.map((patch) => `${patch.status}\t${patch.id}\t${patch.title}`).join('\n') || 'No patches.');
    return;
  }

  if (group === 'patches' && command === 'preview') {
    const title = required(rest[0], 'patches preview requires a title');
    const filePath = required(valueAfter(rest, '--file'), 'patches preview requires --file PATH');
    const taskId = valueAfter(rest, '--task');
    const kind = rest.includes('--write') ? 'write' : 'replace';
    const before = valueAfter(rest, '--before');
    const after = rest.includes('--stdin') ? await stdin() : required(valueAfter(rest, '--after'), 'patches preview requires --after TEXT or --stdin');
    const operation: RuntimePatchOperation = {path: filePath, kind, before, after};
    const patch = await api<RuntimePatch>(state, '/patches/preview', {
      method: 'POST',
      body: JSON.stringify({title, taskId, operations: [operation]}),
    });
    print(state, patch, patch.unifiedDiff);
    return;
  }

  if (group === 'patches' && command === 'apply') {
    const patch = await api<RuntimePatch>(state, `/patches/${encodeURIComponent(required(rest[0], 'patches apply requires an id'))}/apply`, {method: 'POST'});
    print(state, patch, `${patch.status}: ${patch.title}`);
    return;
  }

  if (group === 'patches' && command === 'reject') {
    const patch = await api<RuntimePatch>(state, `/patches/${encodeURIComponent(required(rest[0], 'patches reject requires an id'))}/reject`, {method: 'POST'});
    print(state, patch, `${patch.status}: ${patch.title}`);
    return;
  }

  if (group === 'artifacts' && command === 'read') {
    const relativePath = required(rest[0], 'artifacts read requires a path');
    const artifact = await api<RuntimeFileContent>(state, `/artifacts/file?path=${encodeURIComponent(relativePath)}`);
    print(state, artifact, artifact.content);
    return;
  }

  if (group === 'receipts' && command === 'list') {
    const receipts = await api<RuntimeReceipt[]>(state, '/receipts');
    print(state, receipts, receipts.map((receipt) => `${receipt.status}\t${receipt.action}\t${receipt.summary}`).join('\n') || 'No receipts.');
    return;
  }

  if (group === 'buddy' && command === 'show') {
    const buddy = await api<RuntimeBuddyState>(state, '/buddy');
    print(state, buddy, `${buddy.mode}: ${buddy.activeFocus}\n${buddy.guidance.join('\n')}`);
    return;
  }

  if (group === 'diff' && (command === 'show' || command === 'current')) {
    const diff = await api<RuntimeDiff>(state, '/diffs/current');
    print(state, diff, diff.unifiedDiff || diff.files.map((file) => `${file.status}\t${file.path}`).join('\n') || 'No diff.');
    return;
  }

  throw new Error(`Unknown command: ${[group, command, ...rest].filter(Boolean).join(' ')}`);
}

function required(value: string | undefined, message: string): string {
  if (!value) throw new Error(message);
  return value;
}

function valueAfter(args: string[], flag: string): string | undefined {
  const index = args.indexOf(flag);
  return index >= 0 ? args[index + 1] : undefined;
}

async function stdin(): Promise<string> {
  const chunks: Buffer[] = [];
  for await (const chunk of process.stdin) chunks.push(Buffer.from(chunk));
  return Buffer.concat(chunks).toString('utf8');
}

function usage(): string {
  return `BeMore CLI

Usage:
  bemore runtime status [--json] [--runtime-url URL]
  bemore runtime sandbox
  bemore runtime start [--workspace PATH]
  bemore workspace open PATH
  bemore workspace list
  bemore files list [--json]
  bemore file read PATH
  bemore file write PATH CONTENT
  bemore file write PATH --stdin
  bemore run COMMAND [--wait]
  bemore tasks list
  bemore tasks create TITLE [--detail TEXT] [--role worker] [--max-retries N] [--command COMMAND]
  bemore tasks run TASK_ID
  bemore tasks delegate TASK_ID TITLE [--detail TEXT] [--role worker] [--max-retries N] [--command COMMAND]
  bemore tasks retry TASK_ID
  bemore patches list
  bemore patches preview TITLE --file PATH --before TEXT --after TEXT [--task TASK_ID]
  bemore patches preview TITLE --file PATH --write --stdin [--task TASK_ID]
  bemore patches apply PATCH_ID
  bemore patches reject PATCH_ID
  bemore artifacts list
  bemore artifacts read PATH
  bemore receipts list
  bemore buddy show
  bemore diff show`;
}

main().catch((error: Error) => {
  console.error(`bemore: ${error.message}`);
  process.exitCode = 1;
});
