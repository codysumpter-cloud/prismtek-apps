export interface User {
  id: string;
  email: string;
  name?: string;
}

export interface Workspace {
  id: string;
  name: string;
  ownerId: string;
  templateId: string;
  status: 'running' | 'paused' | 'stopped' | 'error';
  createdAt: string;
  updatedAt: string;
}

export interface AppTemplate {
  id: string;
  name: string;
  description: string;
  repoUrl: string;
  version: string;
}

export interface SandboxSession {
  id: string;
  workspaceId: string;
  status: 'active' | 'inactive' | 'terminating';
  url: string;
  expiresAt: string;
  resources?: {
    cpu: number;
    memory: string;
  };
  logs?: string[];
}

export interface AppGenerationJob {
  id: string;
  workspaceId: string;
  templateId: string;
  status: 'queued' | 'processing' | 'completed' | 'failed';
  progress: number;
  error?: string;
}

export interface SystemStats {
  totalUsers: number;
  activeSessions: number;
  appGenerations: number;
  systemLoad: number;
  trends: {
    users: string;
    sessions: string;
    generations: string;
    load: string;
  };
}

export interface SystemLog {
  id: string;
  event: string;
  user: string;
  time: string;
  type: 'info' | 'warning' | 'error' | 'success';
}

export type OperationType = 'create' | 'update' | 'delete' | 'list' | 'get' | 'write';

export interface FirestoreErrorInfo {
  error: string;
  operationType: OperationType;
  path: string | null;
  authInfo: {
    userId?: string;
    email?: string;
    emailVerified?: boolean;
    isAnonymous?: boolean;
    tenantId?: string;
  }
}
