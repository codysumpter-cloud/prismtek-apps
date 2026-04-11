import type {RuntimeReceipt, RuntimeStatus} from '@prismtek/agent-protocol';

export interface ReceiptInput {
  action: string;
  status: RuntimeStatus;
  startedAt?: string;
  completedAt?: string;
  summary: string;
  command?: string;
  cwd?: string;
  exitCode?: number | null;
  taskId?: string;
  artifactIds?: string[];
}

export function createReceipt(input: ReceiptInput): RuntimeReceipt {
  const completedAt = input.completedAt ?? new Date().toISOString();
  return {
    id: `receipt-${completedAt.replace(/[^0-9A-Za-z]/g, '').toLowerCase()}-${Math.random().toString(36).slice(2, 8)}`,
    action: input.action,
    status: input.status,
    startedAt: input.startedAt ?? completedAt,
    completedAt,
    summary: input.summary,
    command: input.command,
    cwd: input.cwd,
    exitCode: input.exitCode,
    taskId: input.taskId,
    artifactIds: input.artifactIds ?? [],
  };
}

export function summarizeReceipt(receipt: RuntimeReceipt): string {
  const code = receipt.exitCode === undefined || receipt.exitCode === null ? '' : ` exit ${receipt.exitCode}`;
  return `${receipt.status}: ${receipt.action}${code} - ${receipt.summary}`;
}
