import type { RuntimeSnapshot } from '@prismtek/agent-protocol';

export interface BuddyEvent {
  event_id: string;
  session_id: string;
  timestamp: string;
  sequence: number;
  type: 'status' | 'tool_request' | 'receipt' | 'artifact_created' | 'diff_proposed';
  [key: string]: any;
}

export interface SessionState {
  session_id: string;
  status: string;
  latest_event_sequence: number;
  pending_approvals: string[];
  artifacts: any[];
  summary: string;
  resumable: boolean;
}

export class iBuddyClient {
  private baseUrl: string = 'http://localhost:8000';

  async snapshot(): Promise<RuntimeSnapshot> {
    const response = await fetch(`${this.baseUrl}/snapshot`);
    if (!response.ok) throw new Error('Failed to fetch snapshot');
    return await response.json();
  }

  async launchTask(goal: string, context?: string, constraints?: any): Promise<string> {
    const response = await fetch(`${this.baseUrl}/sessions`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ goal, context, constraints }),
    });
    if (!response.ok) throw new Error('Failed to launch task');
    const data = await response.json();
    return data.session_id;
  }

  async submitApproval(sessionId: string, actionId: string, decision: 'approve' | 'reject'): Promise<void> {
    const response = await fetch(`${this.baseUrl}/sessions/${sessionId}/approvals`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ action_id: actionId, decision }),
    });
    if (!response.ok) throw new Error('Failed to submit approval');
  }

  async getArtifact(artifactId: string): Promise<string> {
    const response = await fetch(`${this.baseUrl}/artifacts/${artifactId}`);
    if (!response.ok) throw new Error('Failed to fetch artifact');
    const data = await response.json();
    return data.content;
  }

  async getSessionSummary(sessionId: string): Promise<string> {
    const response = await fetch(`${this.baseUrl}/sessions/${sessionId}/summary`);
    if (!response.ok) throw new Error('Failed to fetch summary');
    const data = await response.json();
    return data.summary;
  }

  streamEvents(sessionId: string, onEvent: (event: BuddyEvent) => void): void {
    const eventSource = new EventSource(`${this.baseUrl}/sessions/${sessionId}/events`);
    
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

  closeStream(sessionId: string) {
    // In a real app, we'd track the EventSource instances
  }

  // Mock methods to satisfy App.tsx
  async selectWorkspace(path: string): Promise<RuntimeSnapshot> {
    return this.snapshot();
  }
  async readFile(path: string): Promise<{relativePath: string, content: string}> {
    return { relativePath: path, content: 'File content placeholder' };
  }
  async writeFile(path: string, content: string): Promise<{receipt: {summary: string}}> {
    return { receipt: { summary: 'File written successfully' } };
  }
  async runCommand(cmd: string): Promise<{command: string, status: string, cwd: string}> {
    return { command: cmd, status: 'running', cwd: '/tmp' };
  }
  async createTask(title: string, detail: string, cmd: string): Promise<{id: string, title: string}> {
    return { id: 'task-123', title };
  }
  async runTask(id: string): Promise<void> {}
  async delegateTask(id: string, title: string, detail: string, cmd: string): Promise<{id: string, title: string}> {
    return { id: 'task-456', title };
  }
  async retryTask(id: string): Promise<{id: string, title: string}> {
    return { id: 'task-789', title: 'Retry Task' };
  }
  async previewPatch(title: string, taskId?: string, ops?: any[]): Promise<{id: string, title: string}> {
    return { id: 'patch-123', title };
  }
  async applyPatch(id: string): Promise<{status: string, title: string}> {
    return { status: 'completed', title: 'Patch Applied' };
  }
  async rejectPatch(id: string): Promise<{status: string, title: string}> {
    return { status: 'rejected', title: 'Patch Rejected' };
  }
  async stopProcess(id: string): Promise<{receipt: {summary: string}}> {
    return { receipt: { summary: 'Process stopped' } };
  }
}

export const runtimeClient = new iBuddyClient();
