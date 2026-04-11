export type RuntimeRequestKind =
  | 'listWorkspaceFiles'
  | 'readFile'
  | 'writeFile'
  | 'searchFiles'
  | 'runCommand'
  | 'streamProcessOutput'
  | 'listProcesses'
  | 'stopProcess'
  | 'listTasks'
  | 'createTask'
  | 'runTask'
  | 'runSubtask'
  | 'listDiffs'
  | 'getDiff'
  | 'listArtifacts'
  | 'readArtifact'
  | 'getReceipts'
  | 'listSkills'
  | 'runSkill'
  | 'getBuddyState'
  | 'applyBuddyEvent'
  | 'getPairingState';

export type RuntimeStatus = 'idle' | 'running' | 'completed' | 'failed' | 'blocked';

export interface RuntimeEnvelope<TKind extends RuntimeRequestKind = RuntimeRequestKind, TPayload = unknown> {
  id: string;
  kind: TKind;
  payload: TPayload;
  requestedAt: string;
  source: 'bemore-macos' | 'bemore-ios' | 'bemore-web' | 'automation';
}

export interface RuntimeResponse<TPayload = unknown> {
  requestId: string;
  ok: boolean;
  status: RuntimeStatus;
  payload?: TPayload;
  error?: string;
  receiptId?: string;
  completedAt: string;
}

export interface RuntimeFileNode {
  id: string;
  name: string;
  relativePath: string;
  kind: 'file' | 'directory';
  size?: number;
  modifiedAt?: string;
  children?: RuntimeFileNode[];
}

export interface RuntimeFileContent {
  relativePath: string;
  content: string;
  encoding: 'utf8';
  savedAt?: string;
}

export interface RuntimeCommandRequest {
  command: string;
  cwd?: string;
  taskId?: string;
}

export interface RuntimeProcess {
  id: string;
  command: string;
  cwd: string;
  status: RuntimeStatus;
  stdout: string;
  stderr: string;
  exitCode?: number | null;
  startedAt: string;
  endedAt?: string;
  receiptId?: string;
}

export interface RuntimeTask {
  id: string;
  title: string;
  detail: string;
  status: RuntimeStatus;
  createdAt: string;
  updatedAt: string;
  command?: string;
  receiptIds: string[];
  artifactIds: string[];
}

export interface RuntimeDiffFile {
  path: string;
  status: 'added' | 'modified' | 'deleted' | 'renamed' | 'untracked' | 'unknown';
  summary: string;
}

export interface RuntimeDiff {
  id: string;
  generatedAt: string;
  files: RuntimeDiffFile[];
  unifiedDiff?: string;
}

export interface RuntimeArtifact {
  id: string;
  name: string;
  relativePath: string;
  kind: 'file' | 'directory' | 'log' | 'receipt';
  size?: number;
  modifiedAt?: string;
}

export interface RuntimeReceipt {
  id: string;
  action: string;
  status: RuntimeStatus;
  startedAt: string;
  completedAt: string;
  summary: string;
  command?: string;
  cwd?: string;
  exitCode?: number | null;
  taskId?: string;
  artifactIds?: string[];
}

export interface RuntimeBuddyState {
  mode: 'standalone' | 'paired' | 'blocked';
  activeFocus: string;
  guidance: string[];
  council: Array<{
    seat: 'Buddy' | 'Prismo' | 'NEPTR' | 'Simon' | 'Operator';
    status: RuntimeStatus;
    note: string;
  }>;
}

export interface PairingDevice {
  id: string;
  name: string;
  platform: 'ios' | 'macos' | 'web';
  scopes: Array<'workspace:read' | 'workspace:write' | 'process:run' | 'review:read' | 'receipts:read'>;
  pairedAt: string;
  lastSeenAt?: string;
}

export interface PairingState {
  hostId: string;
  hostName: string;
  status: 'offline' | 'ready' | 'paired';
  pairingCode?: string;
  devices: PairingDevice[];
}

export interface BeMoreRuntimeProtocol {
  listWorkspaceFiles(): Promise<RuntimeFileNode[]>;
  readFile(relativePath: string): Promise<RuntimeFileContent>;
  writeFile(file: RuntimeFileContent): Promise<RuntimeReceipt>;
  searchFiles(query: string): Promise<RuntimeFileNode[]>;
  runCommand(request: RuntimeCommandRequest): Promise<RuntimeProcess>;
  streamProcessOutput(processId: string): AsyncIterable<RuntimeProcess>;
  listProcesses(): Promise<RuntimeProcess[]>;
  stopProcess(processId: string): Promise<RuntimeReceipt>;
  listTasks(): Promise<RuntimeTask[]>;
  createTask(task: Pick<RuntimeTask, 'title' | 'detail' | 'command'>): Promise<RuntimeTask>;
  runTask(taskId: string): Promise<RuntimeTask>;
  runSubtask(taskId: string, title: string): Promise<RuntimeTask>;
  listDiffs(): Promise<RuntimeDiff>;
  getDiff(path?: string): Promise<RuntimeDiff>;
  listArtifacts(): Promise<RuntimeArtifact[]>;
  readArtifact(artifactId: string): Promise<RuntimeFileContent>;
  getReceipts(): Promise<RuntimeReceipt[]>;
  listSkills(): Promise<string[]>;
  runSkill(skillId: string, input: unknown): Promise<RuntimeReceipt>;
  getBuddyState(): Promise<RuntimeBuddyState>;
  applyBuddyEvent(event: string): Promise<RuntimeBuddyState>;
  getPairingState(): Promise<PairingState>;
}
