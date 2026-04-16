export interface User {
  id: string;
  email: string;
  name?: string;
}

export interface AIModel {
  id: string;
  name: string;
  provider: 'Google' | 'NVIDIA' | 'Meta' | 'Mistral';
  parameters: string;
  description: string;
  isFree: boolean;
}

export interface Workspace {
  id: string;
  name: string;
  ownerId: string;
  templateId: string;
  status: 'running' | 'paused' | 'stopped' | 'error';
  createdAt: string;
  updatedAt: string;
  lastSyncedAt?: string;
  repoUrl?: string;
  activeModelId?: string;
}

export interface AppTemplate {
  id: string;
  name: string;
  description: string;
  repoUrl: string;
  version: string;
  supportedModels?: string[];
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

export type CapabilityPackageKind = 'skill-package' | 'app-package' | 'buddy-binding' | 'installed-package';
export type CapabilityMaturity = 'mvp' | 'beta' | 'stable' | 'deprecated';
export type CapabilityExecutionMode = 'request-response' | 'orchestrated-surface';
export type InstallScope = 'user' | 'workspace' | 'project' | 'repo';
export type ArtifactType = 'task-receipt' | 'report' | 'patch' | 'draft' | 'release-plan' | 'validation-report';
export type EventType =
  | 'skill.run.requested'
  | 'skill.run.started'
  | 'skill.run.progress'
  | 'skill.run.completed'
  | 'skill.run.failed'
  | 'app.opened'
  | 'app.config.updated'
  | 'app.skill.invoked'
  | 'app.view.changed'
  | 'artifact.created';

export interface CapabilityPackageMetadata {
  name: string;
  description: string;
  ownerRepo: 'prismtek-apps' | 'external-runtime';
  category: string;
  tags?: string[];
  maturity: CapabilityMaturity;
}

export interface CapabilityPermissionEnvelope {
  tools: {
    required: string[];
    optional?: string[];
  };
  dataScopes?: string[];
  network?: 'none' | 'bounded' | 'external';
  artifacts?: {
    emits?: ArtifactType[];
    consumes?: ArtifactType[];
  };
  humanApprovalRequired?: string[];
}

export interface JsonSchemaLike {
  type?: string;
  required?: string[];
  properties?: Record<string, JsonSchemaLike | { type?: string; enum?: string[]; items?: JsonSchemaLike }>;
  items?: JsonSchemaLike;
  enum?: string[];
  additionalProperties?: boolean;
}

export interface CapabilityInputOutputContract {
  schema: JsonSchemaLike;
}

export interface CapabilityUiHook {
  type: string;
  placement: string;
}

export interface CapabilityRuntimeBindingRules {
  executionMode: CapabilityExecutionMode;
  supportsBackground: boolean;
  requiresBuddyBinding: boolean;
  memoryPolicy: 'shared-runtime-only';
  routingPolicy: 'shared-runtime-only';
}

export interface SkillPackageManifest {
  kind: 'skill-package';
  apiVersion: 'buddy.prismtek/v1';
  id: string;
  version: string;
  metadata: CapabilityPackageMetadata;
  permissions: CapabilityPermissionEnvelope;
  inputs: CapabilityInputOutputContract;
  outputs: CapabilityInputOutputContract;
  artifactTypes: ArtifactType[];
  eventTypes: EventType[];
  uiHooks: {
    launchers?: CapabilityUiHook[];
    inspectors?: CapabilityUiHook[];
    settings?: CapabilityUiHook[];
  };
  install: {
    configSchema: JsonSchemaLike;
  };
  runtimeBindingRules: CapabilityRuntimeBindingRules;
}

export interface AppPackageManifest {
  kind: 'app-package';
  apiVersion: 'buddy.prismtek/v1';
  id: string;
  version: string;
  metadata: CapabilityPackageMetadata;
  capability: {
    skills: string[];
  };
  permissions: CapabilityPermissionEnvelope;
  inputs: {
    appLaunchContext: JsonSchemaLike;
  };
  outputs: {
    primaryViews: string[];
  };
  artifactTypes: ArtifactType[];
  eventTypes: EventType[];
  uiHooks: {
    surfaces: CapabilityUiHook[];
  };
  install: {
    configSchema: JsonSchemaLike;
  };
  runtimeBindingRules: CapabilityRuntimeBindingRules;
}

export interface BuddyBindingManifest {
  kind: 'buddy-binding';
  apiVersion: 'buddy.prismtek/v1';
  id: string;
  version: string;
  metadata: {
    buddyId: string;
    targetType: 'skill-package' | 'app-package';
    targetId: string;
    displayName: string;
  };
  binding: {
    mode: 'operate' | 'create' | 'adopt';
    adoptionType: 'explicit' | 'default';
    installScope: InstallScope;
  };
  persona: {
    role: string;
    tone?: string;
    defaultGoals?: string[];
  };
  permissions: {
    inheritsFromPackage: boolean;
    extraRestrictions?: {
      denyTools?: string[];
      requireApprovalFor?: string[];
    };
  };
  ui: {
    icon?: string;
    entryLabel: string;
    visibility: {
      appLibrary: boolean;
      buddyDock: boolean;
      quickActions: boolean;
    };
  };
  config?: {
    defaults?: Record<string, string | number | boolean | string[]>;
  };
  runtimeRules: {
    planner: 'shared-buddy-runtime';
    memoryNamespace: string;
    policyNamespace: 'shared/global';
    routeNamespace: 'shared/global';
    executionAudit: 'required';
  };
}

export interface InstalledPackageRecord {
  kind: 'installed-package';
  id: string;
  packageId: string;
  packageVersion: string;
  bindingId: string;
  scope: InstallScope;
  status: 'installed' | 'disabled' | 'error';
  config: Record<string, string | number | boolean | string[] | null>;
}
