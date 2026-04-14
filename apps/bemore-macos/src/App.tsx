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
import {SupervisionView} from './SupervisionView';

type Section = 'Home' | 'Chat' | 'Missions' | 'Workspace' | 'Results' | 'Settings' | 'Supervision';

type BuddyVitals = {
  energy: number;
  bond: number;
  focus: number;
  care: number;
  attention: number;
};

type BuddyCareAction = 'checkIn' | 'encourage' | 'train' | 'focus' | 'rest' | 'feedKnowledge' | 'play';

const activeBuddy = {
  name: 'Prism',
  role: 'Builder companion',
  archetype: 'prism' as BuddyArchetype,
  focus: 'Keep work useful, calm, and receipt-backed.',
};

const sections: Array<{id: Section; icon: ComponentType<{size?: number}>}> = [
  {id: 'Home', icon: HeartPulse},
  {id: 'Chat', icon: Send},
  {id: 'Missions', icon: ClipboardList},
  {id: 'Workspace', icon: FolderTree},
  {id: 'Results', icon: Boxes},
  {id: 'Settings', icon: Settings},
  {id: 'Supervision', icon: Sparkles},
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

function useBuddyFrame(snapshot: RuntimeSnapshot | null, status: string, active: Section, vitals: BuddyVitals) {
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
        ? 'needsAttention'
        : vitals.attention >= 70
          ? 'needsAttention'
          : vitals.energy <= 24
            ? 'sleepy'
            : idleWorkspace
              ? 'sleepy'
              : status.includes('Created') || status.includes('Saved') || status.includes('Delegated')
                ? 'happy'
                : tick % 11 === 0
                  ? 'blink'
                  : active === 'Missions'
                    ? 'thinking'
                    : 'idle';

  const archetype = activeBuddy.archetype;
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
  vitals,
  snapshot,
  onCreateFocusTask,
  onRunStatus,
  onCareAction,
}: {
  frame: string;
  label: string;
  state: BuddyAnimationState;
  vitals: BuddyVitals;
  snapshot: RuntimeSnapshot | null;
  onCreateFocusTask: () => void;
  onRunStatus: () => void;
  onCareAction: (action: BuddyCareAction) => void;
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
        <h1>{activeBuddy.name} is your Buddy.</h1>
        <p>{activeBuddy.role}. {activeBuddy.focus}</p>
        <div className="hero-actions">
          <button onClick={() => onCareAction('checkIn')}>
            <HeartPulse size={16} /> Check In
          </button>
          <button className="secondary" onClick={() => onCareAction('train')}>
            <Brain size={16} /> Train
          </button>
          <button className="secondary" onClick={() => onCareAction('rest')}>
            Rest
          </button>
          <button onClick={onCreateFocusTask}>
            <Sparkles size={16} /> Start Buddy Task
          </button>
          <button className="secondary" onClick={onRunStatus}>
            <Terminal size={16} /> Check Workspace
          </button>
        </div>
        <div className="vital-grid" aria-label={`${label} care state`}>
          <span><strong>{vitals.energy}</strong> energy</span>
          <span><strong>{vitals.bond}</strong> bond</span>
          <span><strong>{vitals.focus}</strong> focus</span>
          <span><strong>{vitals.care}</strong> care</span>
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

function BuddyRail({frame, label, state, vitals, snapshot}: {frame: string; label: string; state: BuddyAnimationState; vitals: BuddyVitals; snapshot: RuntimeSnapshot | null}) {
  const latest = newestReceipt(snapshot);
  return (
    <aside className="buddy-rail">
      <pre className="buddy-ascii small" aria-label={`${label} ${state}`}>{frame}</pre>
      <strong>{label}</strong>
      <span>{state} · energy {vitals.energy}</span>
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
  const [buddyVitals, setBuddyVitals] = useState<BuddyVitals>({
    energy: 72,
    bond: 61,
    focus: 68,
    care: 58,
  });

  const files = useMemo(() => flattenFiles(snapshot?.files ?? []).filter((file) => file.kind === 'file'), [snapshot]);
  const failedTasks = snapshot?.tasks.filter((task) => task.status === 'failed') ?? [];
  const recentTasks = snapshot?.tasks.slice(0, 5) ?? [];
  const buddy = useBuddyFrame(snapshot, status, active, buddyVitals);

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
    setBuddyVitals((current) => ({...current, focus: Math.min(100, current.focus + 3), attention: Math.max(0, current.attention - 8)}));
    setStatus(result.receipt.summary);
  };

  const runCommand = async (nextCommand = command) => {
    const process = await runtimeClient.runCommand(nextCommand);
    await refresh();
    setBuddyVitals((current) => ({...current, energy: Math.max(0, current.energy - 6), focus: Math.min(100, current.focus + 2)}));
    setActive('Results');
    setStatus(`Buddy started ${process.command}`);
  };

  const createTask = async (title = taskTitle, detail = taskDetail, nextCommand = taskCommand) => {
    const task = await runtimeClient.createTask(title, detail, nextCommand);
    await refresh();
    setBuddyVitals((current) => ({...current, attention: Math.max(0, current.attention - 6), bond: Math.min(100, current.bond + 2)}));
    setActive('Missions');
    setStatus(`Created ${task.title}`);
    return task;
  };

  const createFocusTask = async () => {
    await createTask('Buddy focus pass', 'Review the workspace state and decide the next useful action.', 'git status --short');
  };

  const runTask = async (id: string) => {
    await runtimeClient.runTask(id);
    await refresh();
    setBuddyVitals((current) => ({...current, energy: Math.max(0, current.energy - 8), focus: Math.min(100, current.focus + 4)}));
    setActive('Results');
    setStatus('Buddy is working. Watch receipts and output.');
  };

  const delegateTask = async (id: string) => {
    const task = await runtimeClient.delegateTask(id, 'Buddy delegated review', 'Check workspace status as a bounded subtask.', 'git status --short');
    await refresh();
    setBuddyVitals((current) => ({...current, care: Math.min(100, current.care + 2), attention: Math.max(0, current.attention - 4)}));
    setStatus(`Delegated ${task.title}`);
  };

  const retryTask = async (id: string) => {
    const task = await runtimeClient.retryTask(id);
    await refresh();
    setBuddyVitals((current) => ({...current, attention: Math.min(100, current.attention + 10), focus: Math.min(100, current.focus + 5)}));
    setStatus(`Created retry ${task.title}`);
  };

  const previewPatch = async () => {
    const operation: RuntimePatchOperation = {path: patchPath, kind: patchBefore ? 'replace' : 'write', before: patchBefore || undefined, after: patchAfter};
    const patch = await runtimeClient.previewPatch(patchTitle, patchTaskId || undefined, [operation]);
    await refresh();
    setBuddyVitals((current) => ({...current, focus: Math.min(100, current.focus + 4), care: Math.min(100, current.care + 1)}));
    setActive('Results');
    setStatus(`Buddy previewed ${patch.title}`);
  };

  const applyPatch = async (id: string) => {
    const patch = await runtimeClient.applyPatch(id);
    await refresh();
    setBuddyVitals((current) => ({...current, bond: Math.min(100, current.bond + 5), attention: Math.max(0, current.attention - 12)}));
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
    setBuddyVitals((current) => ({...current, energy: Math.min(100, current.energy + 3), attention: Math.max(0, current.attention - 4)}));
    setStatus(result.receipt.summary);
  };

  const careForBuddy = (action: BuddyCareAction) => {
    const updates: Record<BuddyCareAction, Partial<BuddyVitals>> = {
      checkIn: {bond: 6, care: 5, attention: -14},
      encourage: {bond: 4, focus: 3, attention: -8},
      train: {focus: 8, energy: -7, bond: 2},
      focus: {focus: 6, energy: -3, attention: -4},
      rest: {energy: 18, care: 5, attention: -6},
      feedKnowledge: {focus: 5, care: 3, energy: -2},
      play: {bond: 7, energy: -2, attention: -10},
    };
    const label: Record<BuddyCareAction, string> = {
      checkIn: 'checked in with',
      encourage: 'encouraged',
      train: 'trained',
      focus: 'focused',
      rest: 'rested',
      feedKnowledge: 'fed knowledge to',
      play: 'played with',
    };
    setBuddyVitals((current) => {
      const delta = updates[action];
      return {
        energy: Math.max(0, Math.min(100, current.energy + (delta.energy ?? 0))),
        bond: Math.max(0, Math.min(100, current.bond + (delta.bond ?? 0))),
        focus: Math.max(0, Math.min(100, current.focus + (delta.focus ?? 0))),
        care: Math.max(0, Math.min(100, current.care + (delta.care ?? 0))),
        attention: Math.max(0, Math.min(100, current.attention + (delta.attention ?? 0))),
      };
    });
    setStatus(`You ${label[action]} ${activeBuddy.name}.`);
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
        <BuddyRail frame={buddy.frame} label={buddy.label} state={buddy.state} vitals={buddyVitals} snapshot={snapshot} />
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
            <h1>{active === 'Home' ? `${activeBuddy.name} Home` : active}</h1>
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
            <BuddyStage frame={buddy.frame} label={buddy.label} state={buddy.state} vitals={buddyVitals} snapshot={snapshot} onCreateFocusTask={createFocusTask} onRunStatus={() => runCommand('git status --short')} onCareAction={careForBuddy} />
            <section className="grid three">
              <article className="panel">
                <h2>{activeBuddy.name}'s Queue</h2>
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

        {active === 'Chat' ? (
          <section className="grid two">
            <div className="panel companion-panel">
              <pre className="buddy-ascii small" aria-label={`${buddy.label} ${buddy.state}`}>{buddy.frame}</pre>
              <h2>Chat with {activeBuddy.name}</h2>
              <p>{activeBuddy.name} carries the same mood, care state, and task context from Home into chat.</p>
              <div className="vital-grid compact-vitals">
                <span><strong>{buddyVitals.energy}</strong> energy</span>
                <span><strong>{buddyVitals.bond}</strong> bond</span>
                <span><strong>{buddyVitals.focus}</strong> focus</span>
                <span><strong>{buddyVitals.care}</strong> care</span>
              </div>
              <div className="hero-actions">
                <button onClick={() => careForBuddy('encourage')}>Encourage</button>
                <button className="secondary" onClick={() => careForBuddy('feedKnowledge')}>Feed Knowledge</button>
              </div>
            </div>
            <div className="panel">
              <h2>{activeBuddy.name}</h2>
              <p>{activeBuddy.role}. Ask for a focus pass, run a skill, or move into the workspace when the work needs files and receipts.</p>
              <button onClick={createFocusTask}>
                <Sparkles size={16} /> Ask {activeBuddy.name} for a focus pass
              </button>
            </div>
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

        {active === 'Missions' ? (
          <section className="grid two">
            <div className="stack">
              <div className="panel">
                <h2>Give {activeBuddy.name} Work</h2>
                <input value={taskTitle} onChange={(event) => setTaskTitle(event.target.value)} />
                <textarea value={taskDetail} onChange={(event) => setTaskDetail(event.target.value)} />
                <input value={taskCommand} onChange={(event) => setTaskCommand(event.target.value)} />
                <button onClick={() => createTask()}>
                  <Send size={16} /> Create Mission
                </button>
              </div>
              <div className="panel">
                <h2>Train With Skills</h2>
                {skillCards.map((skill) => (
                  <article key={skill.id} className="skill-card compact-skill">
                    <Sparkles size={18} />
                    <div>
                      <strong>{skill.title}</strong>
                      <p>{skill.description}</p>
                    </div>
                    <button className="secondary" onClick={() => createTask(skill.title, skill.description, skill.command)}>Use</button>
                  </article>
                ))}
              </div>
            </div>
            <div className="stack">
              {(snapshot?.tasks ?? []).length ? (snapshot?.tasks ?? []).map((task) => <TaskRow key={task.id} task={task} onRun={runTask} onDelegate={delegateTask} onRetry={retryTask} />) : <p className="quiet">Buddy has no missions yet. Create one from Home this panel.</p>}
            </div>
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

        {active === 'Supervision' ? (
          <SupervisionView />
        ) : null}
      </section>
    </main>
  );
}
