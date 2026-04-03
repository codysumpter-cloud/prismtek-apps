import { SandboxSession } from '@prismtek/core';

export interface SandboxOptions {
  memoryLimit?: string;
  cpuLimit?: number;
  timeout?: number;
  env?: Record<string, string>;
}

export class SandboxManager {
  private sessions: Map<string, SandboxSession> = new Map();

  constructor(private dockerImage: string) {}

  async launch(workspaceId: string, options: SandboxOptions = {}): Promise<SandboxSession> {
    console.log(`Launching sandbox for workspace ${workspaceId} with image ${this.dockerImage}`);
    
    const sessionId = `sb_${Math.random().toString(36).substring(2, 9)}`;
    const session: SandboxSession = {
      id: sessionId,
      workspaceId,
      status: 'active',
      url: `https://sandbox.prismtek.dev/${sessionId}`,
      expiresAt: new Date(Date.now() + (options.timeout || 3600) * 1000).toISOString(),
      resources: {
        cpu: options.cpuLimit || 0.5,
        memory: options.memoryLimit || '512Mi'
      }
    };

    this.sessions.set(sessionId, session);
    return session;
  }

  async terminate(sessionId: string): Promise<void> {
    const session = this.sessions.get(sessionId);
    if (session) {
      console.log(`Terminating sandbox session ${sessionId}`);
      session.status = 'terminating';
      // Real cleanup would happen here
      this.sessions.delete(sessionId);
    }
  }

  async getStatus(sessionId: string): Promise<SandboxSession | undefined> {
    return this.sessions.get(sessionId);
  }

  async listActiveSessions(): Promise<SandboxSession[]> {
    return Array.from(this.sessions.values()).filter(s => s.status === 'active');
  }
}
