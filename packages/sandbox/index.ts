import { exec } from 'child_process';
import { promisify } from 'util';
import { SandboxSession } from '@prismtek/core';

const execAsync = promisify(exec);

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
    console.log(`Launching real sandbox for workspace ${workspaceId}...`);
    
    const sandboxName = `sb_${workspaceId}_${Math.random().toString(36).substring(2, 5)}`;
    const cpu = options.cpuLimit || 0.5;
    const mem = options.memoryLimit || '512Mi';
    
    try {
      const { stdout } = await execAsync(`openshell sandbox create ${sandboxName} --cpu ${cpu} --mem ${mem}`);
      console.log(`Sandbox created: ${stdout}`);
      
      const session: SandboxSession = {
        id: sandboxName,
        workspaceId,
        status: 'active',
        url: `https://sandbox.prismtek.dev/${sandboxName}`,
        expiresAt: new Date(Date.now() + (options.timeout || 3600) * 1000).toISOString(),
        resources: {
          cpu,
          memory: mem
        }
      };
      
      this.sessions.set(sandboxName, session);
      return session;
    } catch (error) {
      console.error(`Failed to launch sandbox: ${error}`);
      throw new Error(`Sandbox launch failed: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  async terminate(sessionId: string): Promise<void> {
    const session = this.sessions.get(sessionId);
    if (session) {
      console.log(`Terminating real sandbox session ${sessionId}...`);
      try {
        await execAsync(`openshell sandbox remove ${sessionId}`);
        console.log(`Sandbox ${sessionId} removed successfully`);
        this.sessions.delete(sessionId);
      } catch (error) {
        console.error(`Failed to terminate sandbox ${sessionId}: ${error}`);
        throw new Error(`Sandbox termination failed: ${error instanceof Error ? error.message : String(error)}`);
      }
    }
  }

  async getStatus(sessionId: string): Promise<SandboxSession | undefined> {
    return this.sessions.get(sessionId);
  }

  async listActiveSessions(): Promise<SandboxSession[]> {
    return Array.from(this.sessions.values()).filter(s => s.status === 'active');
  }
}
