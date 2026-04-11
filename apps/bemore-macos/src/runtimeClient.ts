import type {
  PairingState,
  RuntimeArtifact,
  RuntimeBuddyState,
  RuntimeDiff,
  RuntimeFileContent,
  RuntimeFileNode,
  RuntimeProcess,
  RuntimeReceipt,
  RuntimeTask,
} from '@prismtek/agent-protocol';

const readJson = async <T>(response: Response): Promise<T> => {
  const body = await response.text();
  const payload = body ? JSON.parse(body) : {};
  if (!response.ok) {
    throw new Error(payload.error ?? response.statusText);
  }
  return payload as T;
};

const api = async <T>(path: string, init?: RequestInit): Promise<T> =>
  readJson<T>(
    await fetch(`/api${path}`, {
      headers: {'Content-Type': 'application/json', ...(init?.headers ?? {})},
      ...init,
    }),
  );

export interface RuntimeSnapshot {
  workspaceRoot: string | null;
  files: RuntimeFileNode[];
  tasks: RuntimeTask[];
  processes: RuntimeProcess[];
  artifacts: RuntimeArtifact[];
  receipts: RuntimeReceipt[];
  diff: RuntimeDiff;
  buddy: RuntimeBuddyState;
  pairing: PairingState;
}

export const runtimeClient = {
  snapshot: () => api<RuntimeSnapshot>('/snapshot'),
  selectWorkspace: (workspacePath: string) =>
    api<RuntimeSnapshot>('/workspace/select', {
      method: 'POST',
      body: JSON.stringify({workspacePath}),
    }),
  readFile: (relativePath: string) =>
    api<RuntimeFileContent>(`/workspace/file?path=${encodeURIComponent(relativePath)}`),
  writeFile: (relativePath: string, content: string) =>
    api<{receipt: RuntimeReceipt}>(`/workspace/file`, {
      method: 'PUT',
      body: JSON.stringify({relativePath, content}),
    }),
  runCommand: (command: string, taskId?: string) =>
    api<RuntimeProcess>('/processes', {
      method: 'POST',
      body: JSON.stringify({command, taskId}),
    }),
  stopProcess: (processId: string) =>
    api<{receipt: RuntimeReceipt}>(`/processes/${encodeURIComponent(processId)}/stop`, {method: 'POST'}),
  createTask: (title: string, detail: string, command?: string) =>
    api<RuntimeTask>('/tasks', {
      method: 'POST',
      body: JSON.stringify({title, detail, command}),
    }),
  runTask: (taskId: string) => api<RuntimeTask>(`/tasks/${encodeURIComponent(taskId)}/run`, {method: 'POST'}),
  refreshDiff: () => api<RuntimeDiff>('/diffs/current'),
};
