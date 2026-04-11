import type {RuntimeArtifact, RuntimeDiffFile, RuntimeFileNode, RuntimeTask} from '@prismtek/agent-protocol';

export const BEMORE_IGNORED_WORKSPACE_NAMES = new Set([
  '.git',
  '.turbo',
  'dist',
  'node_modules',
  '.next',
  '.vercel',
]);

export function isTextEditablePath(path: string): boolean {
  return /\.(cjs|css|html|js|json|jsx|md|mjs|swift|toml|ts|tsx|txt|yaml|yml|zsh)$/i.test(path);
}

export function createFileNode(input: Omit<RuntimeFileNode, 'id'>): RuntimeFileNode {
  return {
    ...input,
    id: input.relativePath || '/',
  };
}

export function normalizeDiffStatus(status: string): RuntimeDiffFile['status'] {
  if (status.includes('A')) return 'added';
  if (status.includes('D')) return 'deleted';
  if (status.includes('R')) return 'renamed';
  if (status.includes('?')) return 'untracked';
  if (status.includes('M')) return 'modified';
  return 'unknown';
}

export function createTask(title: string, detail = '', command?: string): RuntimeTask {
  const now = new Date().toISOString();
  return {
    id: `task-${now.replace(/[^0-9A-Za-z]/g, '').toLowerCase()}-${Math.random().toString(36).slice(2, 8)}`,
    title,
    detail,
    command,
    status: 'idle',
    createdAt: now,
    updatedAt: now,
    receiptIds: [],
    artifactIds: [],
  };
}

export function createArtifact(
  relativePath: string,
  stat?: {size?: number; modifiedAt?: string; isDirectory?: boolean},
): RuntimeArtifact {
  const parts = relativePath.split('/').filter(Boolean);
  const name = parts.at(-1) ?? relativePath;
  const lower = name.toLowerCase();
  return {
    id: `artifact:${relativePath}`,
    name,
    relativePath,
    kind: stat?.isDirectory ? 'directory' : lower.endsWith('.log') ? 'log' : lower.endsWith('.receipt.json') ? 'receipt' : 'file',
    size: stat?.size,
    modifiedAt: stat?.modifiedAt,
  };
}
