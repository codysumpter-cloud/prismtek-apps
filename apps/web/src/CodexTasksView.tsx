import { useEffect, useMemo, useState } from 'react';
import type { CodexRunResult, CodexRunSummary } from '@prismtek/core';

const API_ROOT = 'http://localhost:3001';
const FIELD_CLASS =
  'w-full rounded-2xl border border-white/10 bg-white/[0.04] px-4 py-3 text-sm text-white outline-none transition focus:border-sky-300/40 focus:bg-white/[0.06]';

interface CodexTasksViewProps {
  token: string;
}

const REPO_OPTIONS = [
  '/Users/prismtek/code/prismtek-apps',
  '/Users/prismtek/code/bmo-stack',
];

async function authedFetch<T>(token: string, input: string, init?: RequestInit): Promise<T> {
  const response = await fetch(input, {
    ...init,
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${token}`,
      ...(init?.headers || {}),
    },
  });
  if (!response.ok) {
    throw new Error(await response.text());
  }
  return response.json();
}

export function CodexTasksView({ token }: CodexTasksViewProps) {
  const [repoPath, setRepoPath] = useState(REPO_OPTIONS[0]);
  const [approvalMode, setApprovalMode] = useState<'suggest' | 'auto_edit' | 'full_auto'>('suggest');
  const [taskBrief, setTaskBrief] = useState('Audit the current package boundaries and suggest the smallest safe cleanup.');
  const [runs, setRuns] = useState<CodexRunSummary[]>([]);
  const [selectedRunId, setSelectedRunId] = useState<string | null>(null);
  const [selectedResult, setSelectedResult] = useState<CodexRunResult | null>(null);
  const [isLaunching, setIsLaunching] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const selectedRun = useMemo(
    () => runs.find((run) => run.runId === selectedRunId) || null,
    [runs, selectedRunId],
  );

  useEffect(() => {
    const activeRuns = runs.filter((run) => run.status === 'queued' || run.status === 'preparing' || run.status === 'running');
    if (!activeRuns.length) {
      return;
    }

    const interval = window.setInterval(async () => {
      for (const run of activeRuns) {
        try {
          const next = await authedFetch<CodexRunSummary>(token, `${API_ROOT}/api/codex/runs/${run.runId}/status`);
          setRuns((current) => current.map((entry) => (entry.runId === next.runId ? next : entry)));
        } catch (requestError) {
          setError(String(requestError));
        }
      }
    }, 2200);

    return () => window.clearInterval(interval);
  }, [runs, token]);

  const launchRun = async () => {
    setIsLaunching(true);
    setError(null);
    try {
      const created = await authedFetch<CodexRunSummary>(token, `${API_ROOT}/api/codex/runs`, {
        method: 'POST',
        body: JSON.stringify({
          repoPath,
          taskBrief,
          approvalMode,
        }),
      });
      setRuns((current) => [created, ...current]);
      setSelectedRunId(created.runId);
      setSelectedResult(null);
    } catch (requestError) {
      setError(String(requestError));
    } finally {
      setIsLaunching(false);
    }
  };

  const refreshRun = async (runId: string) => {
    const next = await authedFetch<CodexRunSummary>(token, `${API_ROOT}/api/codex/runs/${runId}/status`);
    setRuns((current) => current.map((entry) => (entry.runId === runId ? next : entry)));
  };

  const loadResult = async (runId: string) => {
    const result = await authedFetch<CodexRunResult>(token, `${API_ROOT}/api/codex/runs/${runId}/result`);
    setSelectedResult(result);
    setSelectedRunId(runId);
  };

  return (
    <div className="space-y-8">
      <section className="rounded-3xl border border-white/10 bg-[#0f0f0f] p-6">
        <div className="mb-6 flex items-start justify-between gap-4">
          <div>
            <p className="text-xs uppercase tracking-[0.2em] text-white/40">Codex Task Control</p>
            <h2 className="mt-2 text-3xl font-bold">Ask Buddy to do technical work</h2>
            <p className="mt-2 max-w-2xl text-sm text-white/50">
              This panel queues real runs through the existing `bmo-stack` Codex bridge and polls the structured run artifacts.
            </p>
          </div>
          <div className="rounded-2xl border border-white/10 bg-white/5 px-4 py-3 text-sm text-white/60">
            Existing bridge, no parallel executor
          </div>
        </div>

        <div className="grid gap-4 md:grid-cols-2">
          <label className="space-y-2">
            <span className="text-xs uppercase tracking-[0.18em] text-white/40">Repo</span>
            <select className={FIELD_CLASS} value={repoPath} onChange={(event) => setRepoPath(event.target.value)}>
              {REPO_OPTIONS.map((option) => <option key={option} value={option}>{option}</option>)}
            </select>
          </label>
          <label className="space-y-2">
            <span className="text-xs uppercase tracking-[0.18em] text-white/40">Approval mode</span>
            <select className={FIELD_CLASS} value={approvalMode} onChange={(event) => setApprovalMode(event.target.value as typeof approvalMode)}>
              <option value="suggest">Suggest</option>
              <option value="auto_edit">Auto edit</option>
              <option value="full_auto">Full auto</option>
            </select>
          </label>
        </div>

        <label className="mt-4 block space-y-2">
          <span className="text-xs uppercase tracking-[0.18em] text-white/40">Task brief</span>
          <textarea
            className={`${FIELD_CLASS} min-h-[180px]`}
            value={taskBrief}
            onChange={(event) => setTaskBrief(event.target.value)}
          />
        </label>

        <div className="mt-4 flex items-center gap-3">
          <button
            className="rounded-2xl bg-sky-400 px-5 py-3 text-sm font-semibold text-black transition hover:bg-sky-300 disabled:opacity-50"
            onClick={launchRun}
            disabled={isLaunching}
          >
            {isLaunching ? 'Queueing...' : 'Queue Codex Run'}
          </button>
          <span className="text-sm text-white/50">Status, logs, branch, and worktree metadata stay attached to the run.</span>
        </div>
        {error ? <p className="mt-3 text-sm text-rose-300">{error}</p> : null}
      </section>

      <div className="grid gap-6 lg:grid-cols-[0.95fr_1.05fr]">
        <section className="rounded-3xl border border-white/10 bg-[#0f0f0f] p-6">
          <div className="mb-4 flex items-center justify-between">
            <div>
              <p className="text-xs uppercase tracking-[0.2em] text-white/40">Run History</p>
              <h3 className="mt-2 text-xl font-semibold">Active and recent runs</h3>
            </div>
            <span className="text-sm text-white/50">{runs.length} run(s)</span>
          </div>

          <div className="space-y-3">
            {runs.map((run) => (
              <button
                key={run.runId}
                className={`w-full rounded-2xl border p-4 text-left transition ${
                  selectedRunId === run.runId ? 'border-sky-300/40 bg-sky-300/10' : 'border-white/10 bg-white/[0.03]'
                }`}
                onClick={() => setSelectedRunId(run.runId)}
              >
                <div className="flex items-center justify-between gap-3">
                  <div>
                    <p className="font-medium">{run.status}</p>
                    <p className="text-xs text-white/40">{run.targetBranch || 'branch pending'} • {run.approvalMode}</p>
                  </div>
                  <span className="text-xs text-white/40">{run.runId}</span>
                </div>
                <p className="mt-2 line-clamp-2 text-sm text-white/60">{run.finalAgentMessage || run.repoPath}</p>
              </button>
            ))}
            {!runs.length ? <div className="rounded-2xl border border-dashed border-white/10 p-6 text-sm text-white/40">No Codex runs yet.</div> : null}
          </div>
        </section>

        <section className="rounded-3xl border border-white/10 bg-[#0f0f0f] p-6">
          <div className="mb-4 flex items-center justify-between">
            <div>
              <p className="text-xs uppercase tracking-[0.2em] text-white/40">Run Detail</p>
              <h3 className="mt-2 text-xl font-semibold">{selectedRun?.runId || 'Select a run'}</h3>
            </div>
            {selectedRun ? (
              <div className="flex gap-2">
                <button className="rounded-xl border border-white/10 px-3 py-2 text-xs text-white/70" onClick={() => refreshRun(selectedRun.runId)}>
                  Refresh
                </button>
                <button className="rounded-xl border border-white/10 px-3 py-2 text-xs text-white/70" onClick={() => loadResult(selectedRun.runId)}>
                  Load result
                </button>
                <button
                  className="rounded-xl border border-white/10 px-3 py-2 text-xs text-white/70"
                  onClick={() => setTaskBrief(selectedResult?.brief || selectedRun.finalAgentMessage || taskBrief)}
                >
                  Reuse brief
                </button>
              </div>
            ) : null}
          </div>

          {selectedRun ? (
            <div className="space-y-4">
              <div className="grid gap-3 md:grid-cols-2">
                <InfoCard label="Repo" value={selectedRun.repoPath} />
                <InfoCard label="Worktree" value={selectedRun.worktreePath} />
                <InfoCard label="Branch" value={selectedRun.targetBranch || 'pending'} />
                <InfoCard label="Exit code" value={selectedRun.exitCode == null ? 'running' : String(selectedRun.exitCode)} />
              </div>

              <div className="rounded-2xl border border-white/10 bg-black/30 p-4">
                <p className="text-xs uppercase tracking-[0.18em] text-white/40">Progress tail</p>
                <pre className="mt-3 overflow-auto whitespace-pre-wrap text-sm text-white/75">
                  {selectedRun.stdoutTail || selectedRun.stderrTail || selectedRun.finalAgentMessage || 'No output yet.'}
                </pre>
              </div>

              {selectedResult ? (
                <div className="rounded-2xl border border-emerald-400/20 bg-emerald-400/5 p-4">
                  <p className="text-xs uppercase tracking-[0.18em] text-emerald-200/60">Final result</p>
                  <p className="mt-2 text-sm text-emerald-50">{selectedResult.finalAgentMessage || 'No final assistant message recorded.'}</p>
                  <pre className="mt-3 overflow-auto whitespace-pre-wrap text-xs text-emerald-100/75">{selectedResult.brief}</pre>
                </div>
              ) : null}
            </div>
          ) : (
            <div className="rounded-2xl border border-dashed border-white/10 p-8 text-sm text-white/40">
              Select a run to inspect logs, branch metadata, worktree location, and the final result summary.
            </div>
          )}
        </section>
      </div>
    </div>
  );
}

function InfoCard({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-2xl border border-white/10 bg-white/[0.03] p-4">
      <p className="text-xs uppercase tracking-[0.18em] text-white/40">{label}</p>
      <p className="mt-2 break-all text-sm text-white/75">{value}</p>
    </div>
  );
}
