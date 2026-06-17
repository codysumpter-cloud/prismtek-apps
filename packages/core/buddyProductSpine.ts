export type BuddyProductSurfaceKind =
  | 'app-ui'
  | 'runtime'
  | 'orchestration'
  | 'workspace'
  | 'browser'
  | 'skill'
  | 'docs';

export type BuddyProductRiskClass =
  | 'read-only'
  | 'draft-only'
  | 'write'
  | 'external-action'
  | 'destructive'
  | 'credential'
  | 'money'
  | 'repo-mutation';

export interface BuddyProductRepo {
  name: string;
  defaultBranch: string;
  owns: string[];
}

export interface BuddyProductSurface {
  id: string;
  title: string;
  kind: BuddyProductSurfaceKind;
  ownerRepo: string;
  paths: string[];
  status: string;
  productRole: string;
}

export interface BuddyProductFlowStep {
  order: number;
  actor: string;
  surfaceId: string;
  action: string;
  output: string;
  risk: BuddyProductRiskClass;
}

export interface BuddyProductSpine {
  version: string;
  product: string;
  promise: string;
  repos: BuddyProductRepo[];
  surfaces: BuddyProductSurface[];
  flow: BuddyProductFlowStep[];
  approvalRequired: BuddyProductRiskClass[];
  canonicalRuntimeArtifacts: string[];
  localProjectArtifacts: string[];
}

export const BUDDY_PRODUCT_SPINE_VERSION = '2026-06-09';

export const buddyProductSpine: BuddyProductSpine = {
  version: BUDDY_PRODUCT_SPINE_VERSION,
  product: 'Buddy / BeMore Agent Workspace',
  promise:
    'One functional product loop: Prismtek Apps owns the user-facing Agent Browser and .bemore runtime, Buddy Agent owns local runtime and project workspace contracts, and Buddy Brain owns orchestration, worker dispatch, and policy.',
  repos: [
    {
      name: 'codysumpter-cloud/prismtek-apps',
      defaultBranch: 'main',
      owns: [
        'iOS/macOS product surfaces',
        'guarded Agent Browser UI',
        '.bemore workspace runtime',
        'receipt/artifact rendering',
        'linked-account and app-visible settings',
      ],
    },
    {
      name: 'codysumpter-cloud/buddy-agent',
      defaultBranch: 'main',
      owns: [
        'local Buddy CLI/runtime',
        'app-chat bridge seam',
        'Buddy Playground project workspace',
        'Game Studio VS Code/Godot/Unity helpers',
        'integration status and local contracts',
      ],
    },
    {
      name: 'codysumpter-cloud/buddy-brain',
      defaultBranch: 'master',
      owns: [
        'operator policy',
        'workspace dispatch',
        'browser automation profile',
        'orchestrator/worker runbooks',
        'cross-repo ownership boundaries',
      ],
    },
  ],
  surfaces: [
    {
      id: 'agent-browser',
      title: 'Guarded Agent Browser',
      kind: 'app-ui',
      ownerRepo: 'codysumpter-cloud/prismtek-apps',
      paths: [
        'apps/bemore-ios-native/BeMoreAgentShell/Views/BuddyAgentBrowserView.swift',
        'apps/bemore-ios-native/BeMoreAgentShell/WebBrowserService.swift',
        'docs/BUDDY_ACTION_LOOP_V1.md',
      ],
      status: 'implemented-app-mvp',
      productRole:
        "Human starts missions, Buddy delegates to Lil' Buddy, and risky actions pause for approval.",
    },
    {
      id: 'bemore-workspace-runtime',
      title: '.bemore Workspace Runtime',
      kind: 'workspace',
      ownerRepo: 'codysumpter-cloud/prismtek-apps',
      paths: [
        'apps/bemore-ios-native/BeMoreAgentShell/BeMoreWorkspaceRuntime.swift',
        'docs/BUDDY_CAPABILITY_SURFACES.md',
      ],
      status: 'implemented-app-local-runtime',
      productRole:
        'Persists app-visible skills, artifacts, receipts, memory, session state, and runtime actions.',
    },
    {
      id: 'buddy-agent-runtime',
      title: 'Buddy Agent Runtime',
      kind: 'runtime',
      ownerRepo: 'codysumpter-cloud/buddy-agent',
      paths: ['src/buddy_agent/cli.py', 'src/buddy_agent/alpha.py', 'src/buddy_agent/runtime.py'],
      status: 'runnable-alpha',
      productRole:
        'Provides the local CLI, chat path, memory path, skills, app-chat seam, integrations, and diagnostics.',
    },
    {
      id: 'buddy-playground',
      title: 'Buddy Playground Workspace',
      kind: 'workspace',
      ownerRepo: 'codysumpter-cloud/buddy-agent',
      paths: ['src/buddy_agent/workspace.py', 'src/buddy_agent/cli_workspace.py', 'docs/BUDDY_GAME_STUDIO.md'],
      status: 'implemented-local-project-workspace',
      productRole:
        'Stores reviewable local files, browser notes, code tasks, art briefs, outbox drafts, and receipts before adapters act.',
    },
    {
      id: 'game-studio',
      title: 'Buddy Game Studio',
      kind: 'runtime',
      ownerRepo: 'codysumpter-cloud/buddy-agent',
      paths: ['src/buddy_agent/game_studio.py', 'docs/BUDDY_GAME_STUDIO.md'],
      status: 'implemented-vscode-cockpit',
      productRole:
        'Turns game repos into inspectable VS Code + Godot/Unity workspaces with Buddy task hooks.',
    },
    {
      id: 'workspace-dispatch',
      title: 'Workspace Dispatch',
      kind: 'orchestration',
      ownerRepo: 'codysumpter-cloud/buddy-brain',
      paths: ['skills/workspace-dispatch/SKILL.md', 'docs/UNIFIED_OPERATOR_APP.md'],
      status: 'documented-orchestration-contract',
      productRole:
        'Defines the worker task loop, verification rules, retry behavior, and operator ownership boundaries.',
    },
    {
      id: 'browser-policy',
      title: 'Browser Automation Policy',
      kind: 'browser',
      ownerRepo: 'codysumpter-cloud/buddy-brain',
      paths: ['docs/BROWSER_AUTOMATION_PROFILE.md', 'skills/browser-automation/README.md'],
      status: 'documented-policy-contract',
      productRole:
        'Keeps browser automation opt-in, scoped, auditable, and separate from default chat execution.',
    },
  ],
  flow: [
    {
      order: 1,
      actor: 'Human',
      surfaceId: 'agent-browser',
      action: 'Enter mission or open/search a page in the guarded Agent Browser.',
      output: 'BuddyAgentSession intent, current URL, and visible UI context.',
      risk: 'read-only',
    },
    {
      order: 2,
      actor: 'Buddy Orchestrator',
      surfaceId: 'workspace-dispatch',
      action: 'Decompose the mission into bounded worker steps with exit criteria.',
      output: 'Worker plan with approval checkpoints.',
      risk: 'draft-only',
    },
    {
      order: 3,
      actor: "Lil' Buddy Worker",
      surfaceId: 'buddy-playground',
      action:
        'Draft browser notes, code tasks, art briefs, files, email/message/calendar outbox items, or receipts.',
      output: 'Reviewable .buddy/playground artifact.',
      risk: 'draft-only',
    },
    {
      order: 4,
      actor: 'Buddy Runtime',
      surfaceId: 'buddy-agent-runtime',
      action: 'Validate local runtime status, integration capability, and app-chat handoff.',
      output: 'CLI/app bridge result and sanitized status.',
      risk: 'read-only',
    },
    {
      order: 5,
      actor: 'Prismtek Apps Runtime',
      surfaceId: 'bemore-workspace-runtime',
      action:
        'Promote approved useful outputs into .bemore skills, artifacts, receipts, memory, or session state.',
      output: 'App-visible BeMoreReceipt and persisted artifact.',
      risk: 'write',
    },
    {
      order: 6,
      actor: 'External Adapter',
      surfaceId: 'browser-policy',
      action:
        'Only after approval, perform browser/account/calendar/message/email/repo external actions.',
      output: 'Secret-free receipt and verification status.',
      risk: 'external-action',
    },
  ],
  approvalRequired: ['write', 'external-action', 'destructive', 'credential', 'money', 'repo-mutation'],
  canonicalRuntimeArtifacts: [
    '.bemore/soul.md',
    '.bemore/user.md',
    '.bemore/memory.md',
    '.bemore/session.md',
    '.bemore/skills.md',
    '.bemore/registry/skills.json',
    '.bemore/logs/latest-actions.log',
  ],
  localProjectArtifacts: [
    '.buddy/playground/manifest.json',
    '.buddy/playground/permissions.json',
    '.buddy/playground/browser/research_notes/',
    '.buddy/playground/code/tasks/',
    '.buddy/playground/art/requests/',
    '.buddy/playground/outbox/email_drafts/',
    '.buddy/playground/outbox/message_drafts/',
    '.buddy/playground/outbox/calendar_drafts/',
    '.buddy/playground/receipts/',
  ],
};

export function buddyProductSurface(id: string): BuddyProductSurface | undefined {
  return buddyProductSpine.surfaces.find((surface) => surface.id === id);
}

export function buddyProductFlowForSurface(surfaceId: string): BuddyProductFlowStep[] {
  return buddyProductSpine.flow.filter((step) => step.surfaceId === surfaceId);
}

export function buddyRiskRequiresApproval(risk: BuddyProductRiskClass): boolean {
  return buddyProductSpine.approvalRequired.includes(risk);
}
