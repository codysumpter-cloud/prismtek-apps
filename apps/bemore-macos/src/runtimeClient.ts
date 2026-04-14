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
}
