import { 
  type RuntimeSnapshot, 
  type RuntimeFileContent, 
  type RuntimeReceipt, 
  type RuntimeProcess, 
  type RuntimeTask, 
  type RuntimePatch, 
  type RuntimePatchOperation, 
  type BeMoreRuntimeProtocol,
  type RuntimeCommandRequest,
  type RuntimeFileNode,
  type RuntimeDiff,
  type RuntimeArtifact,
  type RuntimeBuddyState,
  type PairingState
} from '@prismtek/agent-protocol';

export interface BuddyEvent {
  event_id: string;
  session_id: string;
  timestamp: string;
  sequence: number;
  type: 'status' | 'tool_request' | 'receipt' | 'artifact_created' | 'diff_proposed';
  [key: string]: any;
}

class RuntimeClient implements BeMoreRuntimeProtocol {
  private baseUrl = 'http://127.0.0.1:4319/api';

  private async request<T>(endpoint: string, options: RequestInit = {}): Promise<T> {
    const response = await fetch(`${this.baseUrl}${endpoint}`, {
      ...options,
      headers: { 'Content-Type': 'application/json', ...options.headers },
    });
    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`Runtime API error (${response.status}): ${errorText}`);
    }
    return response.json();
  }

  async snapshot(): Promise<RuntimeSnapshot> {
    return this.request<RuntimeSnapshot>('/snapshot');
  }

  async selectWorkspace(path: string): Promise<RuntimeSnapshot> {
    return this.request<RuntimeSnapshot>('/workspace/select', {
      method: 'POST',
      body: JSON.stringify({ workspacePath: path }),
    });
  }

  async listWorkspaceFiles(): Promise<RuntimeFileNode[]> {
    const snapshot = await this.snapshot();
    return snapshot.files;
  }

  async readFile(relativePath: string): Promise<RuntimeFileContent> {
    return this.request<RuntimeFileContent>(`/workspace/file?path=${encodeURIComponent(relativePath)}`);
  }

  async writeFile(file: RuntimeFileContent): Promise<RuntimeReceipt> {
    const response = await this.request<{receipt: RuntimeReceipt}>('/workspace/file', {
      method: 'PUT',
      body: JSON.stringify(file),
    });
    return response.receipt;
  }

  async searchFiles(query: string): Promise<RuntimeFileNode[]> {
    const snapshot = await this.snapshot();
    const term = query.trim().toLowerCase();
    if (!term) return snapshot.files;
    const matches = (nodes: RuntimeFileNode[]): RuntimeFileNode[] =>
      nodes
        .filter((node) => node.name.toLowerCase().includes(term) || node.relativePath.toLowerCase().includes(term))
        .map((node) => ({
          ...node,
          children: node.children ? matches(node.children) : undefined,
        }));
    return matches(snapshot.files);
  }

  async runCommand(request: RuntimeCommandRequest): Promise<RuntimeProcess> {
    return this.request<RuntimeProcess>('/processes', {
      method: 'POST',
      body: JSON.stringify(request),
    });
  }

  streamProcessOutput(processId: string): AsyncIterable<RuntimeProcess> {
    const url = `${this.baseUrl}/processes/stream/${processId}`;
    return (async function* () {
      const response = await fetch(url);
      const reader = response.body?.getReader();
      if (!reader) throw new Error('No reader available for stream');

      while (true) {
        const { done, value } = await reader.read();
        if (done) break;
        const chunk = new TextDecoder().decode(value);
        yield JSON.parse(chunk);
      }
    })();
  }

  async listProcesses(): Promise<RuntimeProcess[]> {
    const snapshot = await this.snapshot();
    return snapshot.processes;
  }

  async stopProcess(processId: string): Promise<RuntimeReceipt> {
    const response = await this.request<{receipt: RuntimeReceipt}>(`/processes/${processId}/stop`, {
      method: 'POST',
    });
    return response.receipt;
  }

  async listTasks(): Promise<RuntimeTask[]> {
    return this.request<RuntimeTask[]>('/tasks');
  }

  async createTask(task: Pick<RuntimeTask, 'title' | 'detail' | 'command'>): Promise<RuntimeTask> {
    return this.request<RuntimeTask>('/tasks', {
      method: 'POST',
      body: JSON.stringify(task),
    });
  }

  async runTask(taskId: string): Promise<RuntimeTask> {
    return this.request<RuntimeTask>(`/tasks/run/${taskId}`, {
      method: 'POST',
    });
  }

  async runSubtask(taskId: string, title: string): Promise<RuntimeTask> {
    return this.request<RuntimeTask>(`/tasks/${taskId}/subtasks`, {
      method: 'POST',
      body: JSON.stringify({ title, detail: '', command: '' }),
    });
  }

  async retryTask(taskId: string): Promise<RuntimeTask> {
    return this.request<RuntimeTask>(`/tasks/retry/${taskId}`, {
      method: 'POST',
    });
  }

  async listDiffs(): Promise<RuntimeDiff> {
    return this.request<RuntimeDiff>('/diffs/current');
  }

  async getDiff(path?: string): Promise<RuntimeDiff> {
    void path;
    return this.request<RuntimeDiff>('/diffs/current');
  }

  async listPatches(): Promise<RuntimePatch[]> {
    return this.request<RuntimePatch[]>('/patches');
  }

  async previewPatch(patch: Pick<RuntimePatch, 'title' | 'operations' | 'taskId'>): Promise<RuntimePatch> {
    return this.request<RuntimePatch>('/patches/preview', {
      method: 'POST',
      body: JSON.stringify(patch),
    });
  }

  async applyPatch(patchId: string): Promise<RuntimePatch> {
    return this.request<RuntimePatch>(`/patches/apply/${patchId}`, {
      method: 'POST',
    });
  }

  async rejectPatch(patchId: string): Promise<RuntimePatch> {
    return this.request<RuntimePatch>(`/patches/reject/${patchId}`, {
      method: 'POST',
    });
  }

  async listArtifacts(): Promise<RuntimeArtifact[]> {
    return this.request<RuntimeArtifact[]>('/artifacts');
  }

  async readArtifact(artifactId: string): Promise<RuntimeFileContent> {
    return this.request<RuntimeFileContent>(`/artifacts/file?path=${encodeURIComponent(artifactId)}`);
  }

  async getReceipts(): Promise<RuntimeReceipt[]> {
    return this.request<RuntimeReceipt[]>('/receipts');
  }

  async listSkills(): Promise<string[]> {
    return [];
  }

  async runSkill(skillId: string, input: unknown): Promise<RuntimeReceipt> {
    throw new Error(`Skill execution is not wired in the macOS runtime yet: ${skillId} ${JSON.stringify(input)}`);
  }

  async getBuddyState(): Promise<RuntimeBuddyState> {
    return this.request<RuntimeBuddyState>('/buddy');
  }

  async applyBuddyEvent(event: string): Promise<RuntimeBuddyState> {
    throw new Error(`Buddy events are not wired in the macOS runtime yet: ${event}`);
  }

  async getPairingState(): Promise<PairingState> {
    const snapshot = await this.snapshot();
    return snapshot.pairing;
  }

  // --- Supervision Extensions ---

  async launchTask(goal: string, context?: string, constraints?: any): Promise<string> {
    throw new Error(`Supervision sessions are not available in the current macOS runtime yet: ${goal} ${context ?? ''} ${JSON.stringify(constraints ?? {})}`);
  }

  async submitApproval(sessionId: string, actionId: string, decision: 'approve' | 'reject'): Promise<void> {
    throw new Error(`Approvals are not available in the current macOS runtime yet: ${sessionId} ${actionId} ${decision}`);
  }

  async getArtifact(artifactId: string): Promise<string> {
    const response = await this.request<{content: string}>(`/artifacts/file?path=${encodeURIComponent(artifactId)}`);
    return response.content;
  }

  streamEvents(sessionId: string, onEvent: (event: BuddyEvent) => void): void {
    void sessionId;
    void onEvent;
    throw new Error('Supervision event streaming is not available in the current macOS runtime yet.');
  }

  async delegateTask(taskId: string, title: string, detail: string, command: string): Promise<RuntimeTask> {
    return this.request<RuntimeTask>(`/tasks/${taskId}/subtasks`, {
      method: 'POST',
      body: JSON.stringify({ taskId, title, detail, command }),
    });
  }
}

export const runtimeClient = new RuntimeClient();
export type { RuntimeSnapshot };
