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
  private baseUrl = 'http://localhost:8000';

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
      body: JSON.stringify({ path }),
    });
  }

  async listWorkspaceFiles(): Promise<RuntimeFileNode[]> {
    return this.request<RuntimeFileNode[]>('/files');
  }

  async readFile(relativePath: string): Promise<RuntimeFileContent> {
    return this.request<RuntimeFileContent>(`/files/read?path=${encodeURIComponent(relativePath)}`);
  }

  async writeFile(file: RuntimeFileContent): Promise<RuntimeReceipt> {
    return this.request<RuntimeReceipt>('/files/write', {
      method: 'POST',
      body: JSON.stringify(file),
    });
  }

  async searchFiles(query: string): Promise<RuntimeFileNode[]> {
    return this.request<RuntimeFileNode[]>(`/files/search?q=${encodeURIComponent(query)}`);
  }

  async runCommand(request: RuntimeCommandRequest): Promise<RuntimeProcess> {
    return this.request<RuntimeProcess>('/commands/run', {
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
    return this.request<RuntimeProcess[]>('/processes');
  }

  async stopProcess(processId: string): Promise<RuntimeReceipt> {
    return this.request<RuntimeReceipt>(`/processes/stop/${processId}`, {
      method: 'POST',
    });
  }

  async listTasks(): Promise<RuntimeTask[]> {
    return this.request<RuntimeTask[]>('/tasks');
  }

  async createTask(task: Pick<RuntimeTask, 'title' | 'detail' | 'command'>): Promise<RuntimeTask> {
    return this.request<RuntimeTask>('/tasks/create', {
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
    return this.request<RuntimeTask>(`/tasks/subtask/${taskId}`, {
      method: 'POST',
      body: JSON.stringify({ title }),
    });
  }

  async retryTask(taskId: string): Promise<RuntimeTask> {
    return this.request<RuntimeTask>(`/tasks/retry/${taskId}`, {
      method: 'POST',
    });
  }

  async listDiffs(): Promise<RuntimeDiff> {
    return this.request<RuntimeDiff>('/diffs');
  }

  async getDiff(path?: string): Promise<RuntimeDiff> {
    const query = path ? `?path=${encodeURIComponent(path)}` : '';
    return this.request<RuntimeDiff>(`/diffs${query}`);
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
    return this.request<RuntimeFileContent>(`/artifacts/read/${artifactId}`);
  }

  async getReceipts(): Promise<RuntimeReceipt[]> {
    return this.request<RuntimeReceipt[]>('/receipts');
  }

  async listSkills(): Promise<string[]> {
    return this.request<string[]>('/skills');
  }

  async runSkill(skillId: string, input: unknown): Promise<RuntimeReceipt> {
    return this.request<RuntimeReceipt>('/skills/run', {
      method: 'POST',
      body: JSON.stringify({ skillId, input }),
    });
  }

  async getBuddyState(): Promise<RuntimeBuddyState> {
    return this.request<RuntimeBuddyState>('/buddy/state');
  }

  async applyBuddyEvent(event: string): Promise<RuntimeBuddyState> {
    return this.request<RuntimeBuddyState>('/buddy/event', {
      method: 'POST',
      body: JSON.stringify({ event }),
    });
  }

  async getPairingState(): Promise<PairingState> {
    return this.request<PairingState>('/pairing/state');
  }

  // --- Supervision Extensions ---

  async launchTask(goal: string, context?: string, constraints?: any): Promise<string> {
    const response = await this.request<{session_id: string}>('/sessions', {
      method: 'POST',
      body: JSON.stringify({ goal, context, constraints }),
    });
    return response.session_id;
  }

  async submitApproval(sessionId: string, actionId: string, decision: 'approve' | 'reject'): Promise<void> {
    await this.request<void>(`/sessions/${sessionId}/approvals`, {
      method: 'POST',
      body: JSON.stringify({ action_id: actionId, decision }),
    });
  }

  async getArtifact(artifactId: string): Promise<string> {
    const response = await this.request<{content: string}>(`/artifacts/${artifactId}`);
    return response.content;
  }

  streamEvents(sessionId: string, onEvent: (event: BuddyEvent) => void): void {
    const url = `${this.baseUrl}/sessions/${sessionId}/events`;
    const eventSource = new EventSource(url);
    eventSource.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data);
        onEvent(data);
      } catch (e) {
        console.error('Error parsing event stream:', e);
      }
    };
    eventSource.onerror = (err) => {
      console.error('EventSource error:', err);
      eventSource.close();
    };
  }

  async delegateTask(taskId: string, title: string, detail: string, command: string): Promise<RuntimeTask> {
    return this.request<RuntimeTask>('/tasks/delegate', {
      method: 'POST',
      body: JSON.stringify({ taskId, title, detail, command }),
    });
  }
}

export const runtimeClient = new RuntimeClient();
export type { RuntimeSnapshot };
