import type {ComponentType} from 'react';
import {useEffect, useMemo, useState} from 'react';
import {
  Boxes,
  Brain,
  CheckCircle2,
  ClipboardList,
  FolderTree,
  GitPullRequest,
  HeartPulse,
  Play,
  RefreshCw,
  Save,
  Send,
  Settings,
  Sparkles,
  Square,
  Terminal,
} from 'lucide-react';
import type {RuntimeFileNode, RuntimePatch, RuntimePatchOperation, RuntimeProcess, RuntimeReceipt, RuntimeTask} from '@prismtek/agent-protocol';
import {getBuddyFrame, getBuddyLabel, type BuddyAnimationState, type BuddyArchetype} from './buddyAscii';
import {runtimeClient, type RuntimeSnapshot} from './runtimeClient';

type Section = 'Home' | 'Workspace' | 'Tasks' | 'Skills' | 'Results' | 'Settings';

const sections: Array<{id: Section; icon: ComponentType<{size?: number}>}> = [
  {id: 'Home', icon: HeartPulse},
  {id: 'Workspace', icon: FolderTree},
  {id: 'Tasks', icon: ClipboardList},
  {id: 'Skills', icon: Brain},
  {id: 'Results', icon: Boxes},
  {id: 'Settings', icon: Settings},
];

const skillCards = [
  {
    id: 'review',
    title: 'Review Changes',
    description: 'Buddy checks the current diff and leaves a receipt-backed task.',
    command: 'git status --short',
  },
  {
    id: 'build',
    title: 'Run Build',
    description: 'Buddy runs the project build in the workspace sandbox.',
    command: 'npm run build',
  },
  {
    id: 'map',
    title: 'Map Workspace',
    description: 'Buddy lists the top-level files so the next task starts with context.',
    command: 'find . -maxdepth 2 -type f | sort | head -80',
  },
];

const flattenFiles = (nodes: RuntimeFileNode[]): RuntimeFileNode[] =>
  nodes.flatMap((node) => [node, ...(node.children ? flattenFiles(node.children) : [])]);

const newestReceipt = (snapshot: RuntimeSnapshot | null) => snapshot?.receipts[0];

function useBuddyFrame(snapshot: RuntimeSnapshot | null, status: string, active: Section) {
  const [tick, setTick] = useState(0);

  useEffect(() => {
    const timer = window.setInterval(() => setTick((current) => current + 1), 520);
    return () => window.clearInterval(timer);
  }, []);

  const receipt = newestReceipt(snapshot);
  const hasRunningWork = Boolean(snapshot?.processes.some((process) => process.status === 'running') || snapshot?.tasks.some((task) => task.status === 'running'));
  const hasFailure = Boolean(receipt?.status === 'failed' || receipt?.status === 'blocked' || snapshot?.tasks.some((task) => task.status === 'failed'));
  const idleWorkspace = !snapshot?.workspaceRoot;
  const recentPatch = receipt?.action === 'applyPatch' && receipt.status === 'completed';
  const state: BuddyAnimationState = hasRunningWork
    ? 'working'
    : recentPatch
      ? 'levelUp'
      : hasFailure
        ? 'thinking'
        : idleWorkspace
          ? 'sleepy'
          : status.includes('Created') || status.includes('Saved') || status.includes('Delegated')
            ? 'happy'
            : tick % 11 === 0
              ? 'blink'
              : active === 'Skills'
                ? 'thinking'
                : 'idle';

  const archetype: BuddyArchetype = hasFailure ? 'neptr' : hasRunningWork ? 'prismo' : 'companion';
  return {state, archetype, frame: getBuddyFrame(archetype, state, tick), label: getBuddyLabel(archetype)};
}

function FileTree({nodes, onOpen}: {nodes: RuntimeFileNode[]; onOpen: (node: RuntimeFileNode) => void}) {
  return (
    <div className="tree">
      {nodes.map((node) => (
        <div key={node.id}>
          <button className={`tree-row ${node.kind}`} onClick={() => onOpen(node)}>
            <span>{node.kind === 'directory' ? '>' : '-'}</span>
            <span>{node.name}</span>
          </button>
          {node.children?.length ? (
            <div className="tree-children">
              <FileTree nodes={node.children} onOpen={onOpen} />
            </div>
          ) : null}
        </div>
      ))}
    </div>
  );
}

function BuddyStage({
  frame,
  label,
  state,
  snapshot,
  onCreateFocusTask,
  onRunStatus,
}: {
  frame: string;
  label: string;
  state: BuddyAnimationState;
  snapshot: RuntimeSnapshot | null;
  onCreateFocusTask: () => void;
  onRunStatus: () => void;
}) {
  const activeTasks = snapshot?.tasks.filter((task) => task.status === 'running').length ?? 0;
  const completedReceipts = snapshot?.receipts.filter((receipt) => receipt.status === 'completed').length ?? 0;
  const workspaceName = snapshot?.workspaceRoot?.split('/').filter(Boolean).at(-1) ?? 'No workspace';

  return (
    <section className="buddy-hero">
      <div className="buddy-stage">
        <div className="buddy-glow" />
        <pre className="buddy-ascii" aria-label={`${label} ${state}`}>{frame}</pre>
      </div>
      <div className="buddy-copy">
        <p className="eyebrow">{label} is {state}</p>
        <h1>Buddy keeps the work moving.</h1>
        <p>Open a workspace, give Buddy a task, review the patch, and keep the receipts.</p>
        <div className="hero-actions">
          <button onClick={onCreateFocusTask}>
            <Sparkles size={16} /> Start Buddy Task
          </button>
          <button className="secondary" onClick={onRunStatus}>
            <Terminal size={16} /> Check Workspace
          </button>
        </div>
        <div className="signal-grid">
          <span><strong>{workspaceName}</strong> workspace</span>
          <span><strong>{activeTasks}</strong> running</span>
          <span><strong>{completedReceipts}</strong> receipts</span>
        </div>
      </div>
    </section>
  );
}

function BuddyRail({frame, label, state, snapshot}: {frame: string; label: string; state: BuddyAnimationState; snapshot: RuntimeSnapshot | null}) {
  const latest = newestReceipt(snapshot);
  return (
    <aside className="buddy-rail">
      <pre className="buddy-ascii small" aria-label={`${label} ${state}`}>{frame}</pre>
      <strong>{label}</strong>
      <span>{state}</span>
      <p>{latest ? latest.summary : 'Ready for the first receipt.'}</p>
    </aside>
  );
}

function ProcessCard({process, onStop}: {process: RuntimeProcess; onStop: (id: string) => void}) {
  return (
    <article className="item">
      <div className="row between">
        <div>
          <strong>{process.command}</strong>
          <p>{process.status} in {process.cwd}</p>
        </div>
        {process.status === 'running' ? (
          <button className="secondary" onClick={() => onStop(process.id)}>
            <Square size={16} /> Stop
          </button>
        ) : (
          <span className="pill">{process.exitCode ?? 'done'}</span>
        )}
      </div>
      <pre className="terminal-output">{process.stdout || process.stderr || 'Waiting for output.'}</pre>
      {process.stderr ? <pre className="terminal-error">{process.stderr}</pre> : null}
    </article>
  );
}

function TaskRow({task, onRun, onDelegate, onRetry}: {task: RuntimeTask; onRun: (id: string) => void; onDelegate: (id: string) => void; onRetry: (id: string) => void}) {
  return (
    <article className="item">
      <div className="row between">
        <div>
          <strong>{task.title}</strong>
          <p>{task.detail || task.command || task.resultSummary || 'Buddy is waiting for a command or note.'}</p>
          <p>{task.parentId ? `Child of ${task.parentId}` : `${task.childIds.length} child tasks`} · retry {task.retryCount}/{task.maxRetries}</p>
          {task.failureReason ? <p>{task.failureReason}</p> : null}
        </div>
        <div className="row wrap">
          <button className="secondary" onClick={() => onRun(task.id)}>
            <Play size={16} /> Run
          </button>
          <button className="secondary" onClick={() => onDelegate(task.id)}>Delegate</button>
          <button className="secondary" onClick={() => onRetry(task.id)}>Retry</button>
        </div>
      </div>
      <span className="pill">{task.status}</span>
    </article>
  );
}

function ReceiptList({receipts}: {receipts: RuntimeReceipt[]}) {
  if (!receipts.length) {
    return <p className="quiet">Run a Buddy task to create the first receipt.</p>;
  }
  return (
    <div className="stack compact">
      {receipts.slice(0, 8).map((receipt) => (
        <article key={receipt.id} className="receipt-row">
          <span className={`dot ${receipt.status}`} />
          <div>
            <strong>{receipt.action}</strong>
            <p>{receipt.summary}</p>
          </div>
        </article>
      ))}
    </div>
  );
}

function PatchList({patches, onApply, onReject}: {patches: RuntimePatch[]; onApply: (id: string) => void; onReject: (id: string) => void}) {
  if (!patches.length) {
    return <p className="quiet">Preview a patch and Buddy will keep it here until you apply or reject it.</p>;
  }
  return (
    <div className="stack compact">
      {patches.map((patch) => (
        <article key={patch.id} className="item">
          <div className="row between">
            <div>
              <strong>{patch.title}</strong>
              <p>{patch.files.map((file) => file.path).join(', ')}</p>
            </div>
            <span className="pill">{patch.status}</span>
          </div>
          <pre className="patch-preview">{patch.unifiedDiff}</pre>
          <div className="row">
            <button className="secondary" onClick={() => onApply(patch.id)}>Apply</button>
            <button className="secondary" onClick={() => onReject(patch.id)}>Reject</button>
          </div>
        </article>
      ))}
    </div>
  );
}

export default function App() {
  const [active, setActive] = useState<Section>('Home');
  const [snapshot, setSnapshot] = useState<RuntimeSnapshot | null>(null);
  const [workspacePath, setWorkspacePath] = useState('');
  const [selectedPath, setSelectedPath] = useState('');
  const [editorValue, setEditorValue] = useState('');
  const [command, setCommand] = useState('git status --short');
  const [taskTitle, setTaskTitle] = useState('Buddy workspace check');
  const [taskDetail, setTaskDetail] = useState('Inspect the workspace and leave a receipt.');
  const [taskCommand, setTaskCommand] = useState('git status --short');
  const [patchTitle, setPatchTitle] = useState('Buddy patch');
  const [patchPath, setPatchPath] = useState('README.md');
  const [patchBefore, setPatchBefore] = useState('');
  const [patchAfter, setPatchAfter] = useState('');
  const [patchTaskId, setPatchTaskId] = useState('');
  const [status, setStatus] = useState('Buddy is ready.');

  const files = useMemo(() => flattenFiles(snapshot?.files ?? []).filter((file) => file.kind === 'file'), [snapshot]);
  const failedTasks = snapshot?.tasks.filter((task) => task.status === 'failed') ?? [];
  const recentTasks = snapshot?.tasks.slice(0, 5) ?? [];
  const buddy = useBuddyFrame(snapshot, status, active);

  const refresh = async () => {
    setSnapshot(await runtimeClient.snapshot());
  };

  useEffect(() => {
    refresh().catch((error: Error) => setStatus(error.message));
    const timer = window.setInterval(() => refresh().catch(() => undefined), 2500);
    return () => window.clearInterval(timer);
  }, []);

  const selectWorkspace = async () => {
    const requestedPath = workspacePath || snapshot?.workspaceRoot || '';
    if (!requestedPath) {
      setStatus('Choose a workspace path first.');
      return;
    }
    const next = await runtimeClient.selectWorkspace(requestedPath);
    setSnapshot(next);
    setActive('Home');
    setStatus(`Buddy opened ${next.workspaceRoot}`);
  };

  const openFile = async (node: RuntimeFileNode) => {
    if (node.kind !== 'file') return;
    const file = await runtimeClient.readFile(node.relativePath);
    setSelectedPath(file.relativePath);
    setEditorValue(file.content);
    setActive('Workspace');
    setStatus(`Buddy opened ${file.relativePath}`);
  };

  const saveFile = async () => {
    if (!selectedPath) return;
    const result = await runtimeClient.writeFile(selectedPath, editorValue);
    await refresh();
    setStatus(result.receipt.summary);
  };

  const runCommand = async (nextCommand = command) => {
    const process = await runtimeClient.runCommand(nextCommand);
    await refresh();
    setActive('Results');
    setStatus(`Buddy started ${process.command}`);
  };

  const createTask = async (title = taskTitle, detail = taskDetail, nextCommand = taskCommand) => {
    const task = await runtimeClient.createTask(title, detail, nextCommand);
    await refresh();
    setActive('Tasks');
    setStatus(`Created ${task.title}`);
    return task;
  };

  const createFocusTask = async () => {
    await createTask('Buddy focus pass', 'Review the workspace state and decide the next useful action.', 'git status --short');
  };

  const runTask = async (id: string) => {
    await runtimeClient.runTask(id);
    await refresh();
    setActive('Results');
    setStatus('Buddy is working. Watch receipts and output.');
  };

  const delegateTask = async (id: string) => {
    const task = await runtimeClient.delegateTask(id, 'Buddy delegated review', 'Check workspace status as a bounded subtask.', 'git status --short');
    await refresh();
    setStatus(`Delegated ${task.title}`);
  };

  const retryTask = async (id: string) => {
    const task = await runtimeClient.retryTask(id);
    await refresh();
    setStatus(`Created retry ${task.title}`);
  };

  const previewPatch = async () => {
    const operation: RuntimePatchOperation = {path: patchPath, kind: patchBefore ? 'replace' : 'write', before: patchBefore || undefined, after: patchAfter};
    const patch = await runtimeClient.previewPatch(patchTitle, patchTaskId || undefined, [operation]);
    await refresh();
    setActive('Results');
    setStatus(`Buddy previewed ${patch.title}`);
  };

  const applyPatch = async (id: string) => {
    const patch = await runtimeClient.applyPatch(id);
    await refresh();
    setStatus(`${patch.status}: ${patch.title}`);
  };

  const rejectPatch = async (id: string) => {
    const patch = await runtimeClient.rejectPatch(id);
    await refresh();
    setStatus(`${patch.status}: ${patch.title}`);
  };

  const stopProcess = async (id: string) => {
    const result = await runtimeClient.stopProcess(id);
    await refresh();
    setStatus(result.receipt.summary);
  };

  return (
    <main className="app-shell">
      <aside className="sidebar">
        <div className="brand">
          <HeartPulse />
          <div>
            <strong>BeMore</strong>
            <span>Buddy workspace</span>
          </div>
        </div>
        <BuddyRail frame={buddy.frame} label={buddy.label} state={buddy.state} snapshot={snapshot} />
        <nav>
          {sections.map(({id, icon: Icon}) => (
            <button key={id} className={active === id ? 'nav active' : 'nav'} onClick={() => setActive(id)}>
              <Icon size={18} /> {id}
            </button>
          ))}
        </nav>
      </aside>

      <section className="workspace">
        <header className="topbar">
          <div>
            <p className="eyebrow">Local Buddy runtime</p>
            <h1>{active === 'Home' ? 'Buddy Home' : active}</h1>
          </div>
          <button className="secondary" onClick={refresh}>
            <RefreshCw size={16} /> Refresh
          </button>
        </header>

        <div className="status-line">
          <CheckCircle2 size={16} /> {status}
        </div>

        {active === 'Home' ? (
          <section className="stack">
            <BuddyStage frame={buddy.frame} label={buddy.label} state={buddy.state} snapshot={snapshot} onCreateFocusTask={createFocusTask} onRunStatus={() => runCommand('git status --short')} />
            <section className="grid three">
              <article className="panel">
                <h2>Buddy Queue</h2>
                {recentTasks.length ? recentTasks.map((task) => <p key={task.id}>{task.status}: {task.title}</p>) : <p className="quiet">Start a Buddy task to build the queue.</p>}
              </article>
              <article className="panel">
                <h2>Receipts</h2>
                <ReceiptList receipts={snapshot?.receipts ?? []} />
              </article>
              <article className="panel">
                <h2>Needs Attention</h2>
                {failedTasks.length ? failedTasks.map((task) => <p key={task.id}>{task.title}: {task.failureReason}</p>) : <p className="quiet">No blocked tasks in this session.</p>}
              </article>
            </section>
          </section>
        ) : null}

        {active === 'Workspace' ? (
          <section className="grid workspace-grid">
            <div className="panel">
              <h2>Workspace</h2>
              <p>Buddy can inspect, edit, and run bounded commands in one selected folder.</p>
              <div className="inline-form">
                <input value={workspacePath} onChange={(event) => setWorkspacePath(event.target.value)} placeholder={snapshot?.workspaceRoot ?? 'Path to a workspace folder'} />
                <button onClick={selectWorkspace}>Open</button>
              </div>
              <p className="mono">{snapshot?.workspaceRoot ?? 'Choose a workspace to begin.'}</p>
              {snapshot?.files.length ? <FileTree nodes={snapshot.files} onOpen={openFile} /> : <p className="quiet">Buddy needs a workspace before files appear.</p>}
            </div>
            <div className="panel tall">
              <div className="row between">
                <div>
                  <h2>{selectedPath || 'Pick a file'}</h2>
                  <p>{files.length} editable files in the current snapshot.</p>
                </div>
                <button onClick={saveFile} disabled={!selectedPath}>
                  <Save size={16} /> Save
                </button>
              </div>
              <textarea className="editor" value={editorValue} onChange={(event) => setEditorValue(event.target.value)} spellCheck={false} />
            </div>
          </section>
        ) : null}

        {active === 'Tasks' ? (
          <section className="grid two">
            <div className="panel">
              <h2>Give Buddy Work</h2>
              <input value={taskTitle} onChange={(event) => setTaskTitle(event.target.value)} />
              <textarea value={taskDetail} onChange={(event) => setTaskDetail(event.target.value)} />
              <input value={taskCommand} onChange={(event) => setTaskCommand(event.target.value)} />
              <button onClick={() => createTask()}>
                <Send size={16} /> Create Task
              </button>
            </div>
            <div className="stack">
              {(snapshot?.tasks ?? []).length ? (snapshot?.tasks ?? []).map((task) => <TaskRow key={task.id} task={task} onRun={runTask} onDelegate={delegateTask} onRetry={retryTask} />) : <p className="quiet">Buddy has no tasks yet. Create one from Home or this panel.</p>}
            </div>
          </section>
        ) : null}

        {active === 'Skills' ? (
          <section className="grid three">
            {skillCards.map((skill) => (
              <article key={skill.id} className="panel skill-card">
                <Sparkles size={22} />
                <h2>{skill.title}</h2>
                <p>{skill.description}</p>
                <button onClick={() => createTask(skill.title, skill.description, skill.command)}>Use Skill</button>
              </article>
            ))}
          </section>
        ) : null}

        {active === 'Results' ? (
          <section className="grid results-grid">
            <div className="panel">
              <h2>Run Command</h2>
              <div className="inline-form">
                <input value={command} onChange={(event) => setCommand(event.target.value)} />
                <button onClick={() => runCommand()}>
                  <Play size={16} /> Run
                </button>
              </div>
              <div className="stack compact">
                {(snapshot?.processes ?? []).map((process) => <ProcessCard key={process.id} process={process} onStop={stopProcess} />)}
                {!snapshot?.processes.length ? <p className="quiet">Command output will appear here with receipts.</p> : null}
              </div>
            </div>
            <div className="panel">
              <h2>Patch Review</h2>
              <input value={patchTitle} onChange={(event) => setPatchTitle(event.target.value)} placeholder="Patch title" />
              <input value={patchPath} onChange={(event) => setPatchPath(event.target.value)} placeholder="README.md" />
              <input value={patchTaskId} onChange={(event) => setPatchTaskId(event.target.value)} placeholder="Optional task id" />
              <textarea value={patchBefore} onChange={(event) => setPatchBefore(event.target.value)} placeholder="Text to replace. Leave blank to write the whole file." />
              <textarea value={patchAfter} onChange={(event) => setPatchAfter(event.target.value)} placeholder="Replacement or full file content" />
              <button onClick={previewPatch}>
                <GitPullRequest size={16} /> Preview Patch
              </button>
              <PatchList patches={snapshot?.patches ?? []} onApply={applyPatch} onReject={rejectPatch} />
            </div>
            <div className="panel">
              <h2>Current Diff</h2>
              <pre className="diff">{snapshot?.diff.unifiedDiff || 'Clean working tree.'}</pre>
            </div>
            <div className="panel">
              <h2>Receipts</h2>
              <ReceiptList receipts={snapshot?.receipts ?? []} />
            </div>
          </section>
        ) : null}

        {active === 'Settings' ? (
          <section className="grid two">
            <div className="panel">
              <h2>Runtime Boundary</h2>
              <p>{snapshot?.sandbox.id}</p>
              <p>{snapshot?.sandbox.note}</p>
              <p>Timeout {snapshot?.sandbox.commandTimeoutMs}ms · output cap {snapshot?.sandbox.maxOutputBytes} bytes</p>
            </div>
            <div className="panel">
              <h2>iPhone Power Mode</h2>
              <p>Host {snapshot?.pairing.hostName} is {snapshot?.pairing.status}.</p>
              <div className="pair-code">{snapshot?.pairing.pairingCode}</div>
              <p>Pairing scopes stay explicit: workspace read, workspace write, process run, review read, receipts read.</p>
            </div>
          </section>
        ) : null}
      </section>
    </main>
  );
}
