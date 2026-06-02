// GENERATED CONTRACT SNAPSHOT EXTENSION.
// Source of truth target: codysumpter-cloud/prismtek-buddy-core.
// Kept here so Prismtek Apps can consume the Buddy Action Loop v1 contract until package auth is configured.

export const BUDDY_ACTION_LOOP_V1_SCHEMA_VERSION = "2026-06-02.buddy-action.v1" as const;
export const BUDDY_AGENT_SESSION_V1_SCHEMA_VERSION = "2026-06-02.buddy-agent-session.v1" as const;

export type BuddyRiskClass =
  | "read-only"
  | "draft-only"
  | "write"
  | "external-action"
  | "destructive"
  | "money"
  | "identity"
  | "location"
  | "credential"
  | "repo-mutation";

export type BuddyRiskDefault = "allow" | "confirm" | "deny" | "deny-by-default";

export type BuddyAgentRole = "orchestrator" | "worker";

export type BuddyAgentRunMode = "manual" | "supervised-autonomy" | "fully-manual-approval";

export type BuddyWorkerReportStatus =
  | "step-completed"
  | "needs-next-step"
  | "blocked"
  | "needs-approval"
  | "failed"
  | "done";

export type BuddyActionType =
  | "browser.open"
  | "browser.summarize"
  | "memory.remember"
  | "memory.recall"
  | "note.draft"
  | "calendar.draft"
  | "calendar.create"
  | "message.draft"
  | "message.send"
  | "email.draft"
  | "email.send"
  | "github.inspect"
  | "github.pr.prepare"
  | "sandbox.inspect"
  | "sandbox.command"
  | "model.complete"
  | "skill.invoke";

export type BuddyActionStatus =
  | "draft"
  | "delegated"
  | "needs-review"
  | "approved"
  | "running"
  | "completed"
  | "failed"
  | "cancelled"
  | "denied";

export type BuddyActionSource =
  | "agent-tab"
  | "chat"
  | "shortcut"
  | "orchestrator"
  | "worker"
  | "runtime"
  | "skill"
  | "system";

export interface BuddyActionActor {
  id: string;
  displayName: string;
  kind: "user" | "buddy" | "system" | "runtime";
  role?: BuddyAgentRole;
}

export interface BuddyProviderRef {
  id: string;
  label: string;
  kind: "local" | "oauth-cloud" | "api-key" | "browser-ai" | "offline";
  model?: string;
  privacyTier: "local" | "account" | "external";
}

export interface BuddyToolRef {
  id: string;
  label: string;
  surface: "ios" | "macos" | "web" | "runtime" | "vault" | "device";
  adapterStatus: "available" | "draft-only" | "planned" | "disabled";
}

export interface BuddyActionInputRef {
  kind: "url" | "memory" | "selection" | "file" | "repo" | "prompt" | "opaque";
  label: string;
  value?: string;
  redacted?: boolean;
}

export interface BuddyActionApproval {
  required: boolean;
  mode: "none" | "allow-once" | "always-allow" | "deny";
  requestedAt?: string;
  decidedAt?: string;
  decidedBy?: BuddyActionActor;
  note?: string;
}

export interface BuddyActionResult {
  summary: string;
  outputRefs?: BuddyActionInputRef[];
  errorCode?: string;
  safeForReceipt: boolean;
}

export interface BuddyMemoryWrite {
  memoryId?: string;
  title: string;
  bodySummary: string;
  sourceActionId: string;
  reviewRequired: boolean;
}

export interface BuddyAgentRuntimeProfile {
  agentId: string;
  buddyId: string;
  role: BuddyAgentRole;
  displayName: string;
  model?: BuddyProviderRef;
  allowedRiskClasses: BuddyRiskClass[];
  allowedActionTypes: BuddyActionType[];
  canTalkToHuman: boolean;
  canDelegate: boolean;
  canExecuteTools: boolean;
}

export interface BuddyAgentSessionPolicy {
  runMode: BuddyAgentRunMode;
  maxAutonomousSteps: number;
  requireHumanApprovalFor: BuddyRiskClass[];
  workerMustReportEveryStep: boolean;
  orchestratorOnlyHumanContact: boolean;
  stopOnUnknownRisk: boolean;
}

export interface BuddyDelegation {
  id: string;
  sessionId: string;
  parentActionId?: string;
  orchestratorAgentId: string;
  workerAgentId: string;
  objective: string;
  originalHumanRequest: string;
  nextInstruction: string;
  allowedActionTypes: BuddyActionType[];
  blockedRiskClasses: BuddyRiskClass[];
  status: "queued" | "running" | "blocked" | "completed" | "cancelled" | "failed";
  createdAt: string;
  updatedAt?: string;
}

export interface BuddyWorkerReport {
  id: string;
  sessionId: string;
  delegationId: string;
  workerAgentId: string;
  orchestratorAgentId: string;
  status: BuddyWorkerReportStatus;
  summary: string;
  completedActionIds: string[];
  producedReceiptIds: string[];
  proposedNextInstruction?: string;
  approvalRequest?: BuddyActionApproval;
  blockedByRisk?: BuddyRiskClass;
  createdAt: string;
}

export interface BuddyAgentSession {
  schemaVersion: typeof BUDDY_AGENT_SESSION_V1_SCHEMA_VERSION;
  id: string;
  humanActor: BuddyActionActor;
  originalHumanRequest: string;
  orchestrator: BuddyAgentRuntimeProfile;
  workers: BuddyAgentRuntimeProfile[];
  policy: BuddyAgentSessionPolicy;
  status: "open" | "waiting-for-human" | "running" | "completed" | "failed" | "cancelled";
  createdAt: string;
  updatedAt?: string;
}

export interface BuddyReceipt {
  id: string;
  actionId: string;
  sessionId?: string;
  delegationId?: string;
  agentId?: string;
  agentRole?: BuddyAgentRole;
  createdAt: string;
  status: Extract<BuddyActionStatus, "completed" | "failed" | "cancelled" | "denied">;
  title: string;
  summary: string;
  risk: BuddyRiskClass;
  provider?: BuddyProviderRef;
  tool?: BuddyToolRef;
  redactions: string[];
}

export interface BuddyAction {
  schemaVersion: typeof BUDDY_ACTION_LOOP_V1_SCHEMA_VERSION;
  id: string;
  sessionId?: string;
  delegationId?: string;
  buddyId: string;
  title: string;
  intent: string;
  type: BuddyActionType;
  source: BuddyActionSource;
  status: BuddyActionStatus;
  risk: BuddyRiskClass;
  requiresApproval: boolean;
  actor: BuddyActionActor;
  assignedAgentId?: string;
  assignedAgentRole?: BuddyAgentRole;
  createdAt: string;
  updatedAt?: string;
  inputRefs?: BuddyActionInputRef[];
  approval?: BuddyActionApproval;
  provider?: BuddyProviderRef;
  tool?: BuddyToolRef;
  result?: BuddyActionResult;
  receiptId?: string;
  memoryWrites?: BuddyMemoryWrite[];
}

export interface BuddySkillManifestV1 {
  schemaVersion: "2026-06-02.buddy-skill.v1";
  id: string;
  name: string;
  description: string;
  risk: BuddyRiskClass;
  supportedSurfaces: Array<"ios" | "macos" | "web" | "runtime" | "vault" | "device">;
  actionTypes: BuddyActionType[];
  requiredPermissions: string[];
  adapterStatus: "working" | "partial" | "planned" | "disabled";
  testCommand?: string;
  notes?: string;
}

export const BUDDY_SAFE_DEFAULT_RISK_POLICY: Record<BuddyRiskClass, BuddyRiskDefault> = {
  "read-only": "allow",
  "draft-only": "allow",
  write: "confirm",
  "external-action": "confirm",
  destructive: "deny-by-default",
  money: "deny-by-default",
  identity: "deny-by-default",
  location: "confirm",
  credential: "deny",
  "repo-mutation": "confirm",
};

export const BUDDY_DEFAULT_SESSION_POLICY: BuddyAgentSessionPolicy = {
  runMode: "supervised-autonomy",
  maxAutonomousSteps: 25,
  requireHumanApprovalFor: [
    "write",
    "external-action",
    "destructive",
    "money",
    "identity",
    "location",
    "credential",
    "repo-mutation",
  ],
  workerMustReportEveryStep: true,
  orchestratorOnlyHumanContact: true,
  stopOnUnknownRisk: true,
};

export function buddyActionRequiresApproval(risk: BuddyRiskClass): boolean {
  const decision = BUDDY_SAFE_DEFAULT_RISK_POLICY[risk];
  return decision === "confirm" || decision === "deny-by-default" || decision === "deny";
}

export function buddyActionCanRunWithoutApproval(action: BuddyAction): boolean {
  return !action.requiresApproval && BUDDY_SAFE_DEFAULT_RISK_POLICY[action.risk] === "allow";
}

export function buddyWorkerCanContinueWithoutHuman(report: BuddyWorkerReport): boolean {
  return report.status === "step-completed" || report.status === "needs-next-step";
}

export function buddyWorkerReportRequiresHuman(report: BuddyWorkerReport): boolean {
  return report.status === "needs-approval" || Boolean(report.approvalRequest || report.blockedByRisk);
}

export function createBuddyActionDraft(input: Omit<BuddyAction, "schemaVersion" | "status" | "requiresApproval">): BuddyAction {
  return {
    ...input,
    schemaVersion: BUDDY_ACTION_LOOP_V1_SCHEMA_VERSION,
    status: "draft",
    requiresApproval: buddyActionRequiresApproval(input.risk),
  };
}
