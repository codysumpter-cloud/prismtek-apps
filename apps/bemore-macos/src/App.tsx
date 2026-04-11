import type {ComponentType} from 'react';
import {useEffect, useMemo, useState} from 'react';
import {
  Boxes,
  CheckCircle2,
  CircleDot,
  ClipboardList,
  Cpu,
  FileCode2,
  FolderTree,
  GitPullRequest,
  Link2,
  Play,
  RefreshCw,
  Save,
  Send,
  Square,
  Terminal,
} from 'lucide-react';
import type {RuntimeFileNode, RuntimePatchOperation, RuntimeProcess, RuntimeTask} from '@prismtek/agent-protocol';
import {runtimeClient, type RuntimeSnapshot} from './runtimeClient';

type Section = 'Workspace' | 'Editor' | 'Terminal' | 'Tasks' | 'Review' | 'Artifacts' | 'Buddy' | 'Pairing';

const sections: Array<{id: Section; icon: ComponentType<{size?: number}>}> = [
  {id: 'Workspace', icon: FolderTree},
  {id: 'Editor', icon: FileCode2},
  {id: 'Terminal', icon: Terminal},
  {id: 'Tasks', icon: ClipboardList},
  {id: 'Review', icon: GitPullRequest},
  {id: 'Artifacts', icon: Boxes},
  {id: 'Buddy', icon: CircleDot},
  {id: 'Pairing', icon: Link2},
];

const flattenFiles = (nodes: RuntimeFileNode[]): RuntimeFileNode[] =>
  nodes.flatMap((node) => [node, ...(node.children ? flattenFiles(node.children) : [])]);

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

function ProcessCard({process, onStop}: {process: RuntimeProcess; onStop: (id: string) => void}) {
  return (
    <article className="panel item">
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
      <pre className="terminal-output">{process.stdout || process.stderr || 'No output yet.'}</pre>
      {process.stderr ? <pre className="terminal-error">{process.stderr}</pre> : null}
    </article>
  );
}

function TaskRow({task, onRun, onDelegate, onRetry}: {task: RuntimeTask; onRun: (id: string) => void; onDelegate: (id: string) => void; onRetry: (id: string) => void}) {
  return (
    <article className="panel item">
      <div className="row between">
        <div>
          <strong>{task.title}</strong>
          <p>{task.detail || task.command || task.resultSummary || 'No extra detail yet.'}</p>
          <p>{task.parentId ? `Child of ${task.parentId}` : `${task.childIds.length} child tasks`} · retry {task.retryCount}/{task.maxRetries}</p>
          {task.failureReason ? <p>{task.failureReason}</p> : null}
        </div>
        <div className="row">
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

export default function App() {
  const [active, setActive] = useState<Section>('Workspace');
  const [snapshot, setSnapshot] = useState<RuntimeSnapshot | null>(null);
  const [workspacePath, setWorkspacePath] = useState('');
  const [selectedPath, setSelectedPath] = useState('');
  const [editorValue, setEditorValue] = useState('');
  const [command, setCommand] = useState('npm run build');
  const [taskTitle, setTaskTitle] = useState('Ship the next BeMore slice');
  const [taskDetail, setTaskDetail] = useState('Create receipts and inspect the resulting diff.');
  const [taskCommand, setTaskCommand] = useState('git status --short');
  const [patchTitle, setPatchTitle] = useState('Reviewable BeMore patch');
  const [patchPath, setPatchPath] = useState('README.md');
  const [patchBefore, setPatchBefore] = useState('');
  const [patchAfter, setPatchAfter] = useState('');
  const [patchTaskId, setPatchTaskId] = useState('');
  const [status, setStatus] = useState('Ready.');

  const files = useMemo(() => flattenFiles(snapshot?.files ?? []).filter((file) => file.kind === 'file'), [snapshot]);

  const refresh = async () => {
    setSnapshot(await runtimeClient.snapshot());
  };

  useEffect(() => {
    refresh().catch((error: Error) => setStatus(error.message));
    const timer = window.setInterval(() => refresh().catch(() => undefined), 2500);
    return () => window.clearInterval(timer);
  }, []);

  const selectWorkspace = async () => {
    const next = await runtimeClient.selectWorkspace(workspacePath);
    setSnapshot(next);
    setStatus(`Workspace opened: ${next.workspaceRoot}`);
  };

  const openFile = async (node: RuntimeFileNode) => {
    if (node.kind !== 'file') return;
    const file = await runtimeClient.readFile(node.relativePath);
    setSelectedPath(file.relativePath);
    setEditorValue(file.content);
    setActive('Editor');
    setStatus(`Opened ${file.relativePath}`);
  };

  const saveFile = async () => {
    if (!selectedPath) return;
    const result = await runtimeClient.writeFile(selectedPath, editorValue);
    await refresh();
    setStatus(result.receipt.summary);
  };

  const runCommand = async () => {
    const process = await runtimeClient.runCommand(command);
    await refresh();
    setActive('Terminal');
    setStatus(`Started ${process.command}`);
  };

  const createTask = async () => {
    const task = await runtimeClient.createTask(taskTitle, taskDetail, taskCommand);
    await refresh();
    setActive('Tasks');
    setStatus(`Created ${task.title}`);
  };

  const runTask = async (id: string) => {
    await runtimeClient.runTask(id);
    await refresh();
    setStatus('Task started. Watch Terminal and Receipts for evidence.');
  };

  const delegateTask = async (id: string) => {
    const task = await runtimeClient.delegateTask(id, `Subtask for ${id.slice(0, 16)}`, 'Delegated from the Mac task graph.', 'git status --short');
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
    setActive('Review');
    setStatus(`Previewed ${patch.title}`);
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
          <Cpu />
          <div>
            <strong>BeMore Mac</strong>
            <span>Build 1</span>
          </div>
        </div>
        {sections.map(({id, icon: Icon}) => (
          <button key={id} className={active === id ? 'nav active' : 'nav'} onClick={() => setActive(id)}>
            <Icon size={18} /> {id}
          </button>
        ))}
      </aside>

      <section className="workspace">
        <header className="topbar">
          <div>
            <p>Local workstation</p>
            <h1>{active}</h1>
          </div>
          <button className="secondary" onClick={refresh}>
            <RefreshCw size={16} /> Refresh
          </button>
        </header>

        <div className="status-line">
          <CheckCircle2 size={16} /> {status}
        </div>

        {active === 'Workspace' ? (
          <section className="grid two">
            <div className="panel">
              <h2>Open Workspace</h2>
              <p>Use a local path on this Mac.</p>
              <div className="inline-form">
                <input value={workspacePath} onChange={(event) => setWorkspacePath(event.target.value)} placeholder="/Users/prismtek/code/prismtek-apps" />
                <button onClick={selectWorkspace}>Open</button>
              </div>
              <p className="mono">{snapshot?.workspaceRoot ?? 'No workspace selected.'}</p>
            </div>
            <div className="panel">
              <h2>Files</h2>
              {snapshot?.files.length ? <FileTree nodes={snapshot.files} onOpen={openFile} /> : <p>Choose a workspace to browse files.</p>}
            </div>
          </section>
        ) : null}

        {active === 'Editor' ? (
          <section className="panel tall">
            <div className="row between">
              <div>
                <h2>{selectedPath || 'Open a file from Workspace'}</h2>
                <p>{files.length} editable candidates in the current tree snapshot.</p>
              </div>
              <button onClick={saveFile} disabled={!selectedPath}>
                <Save size={16} /> Save
              </button>
            </div>
            <textarea className="editor" value={editorValue} onChange={(event) => setEditorValue(event.target.value)} spellCheck={false} />
          </section>
        ) : null}

        {active === 'Terminal' ? (
          <section className="stack">
            <div className="panel">
              <h2>Run Command</h2>
              <div className="inline-form">
                <input value={command} onChange={(event) => setCommand(event.target.value)} />
                <button onClick={runCommand}>
                  <Play size={16} /> Run
                </button>
              </div>
            </div>
            {(snapshot?.processes ?? []).map((process) => <ProcessCard key={process.id} process={process} onStop={stopProcess} />)}
          </section>
        ) : null}

        {active === 'Tasks' ? (
          <section className="grid two">
            <div className="panel">
              <h2>Create Task</h2>
              <input value={taskTitle} onChange={(event) => setTaskTitle(event.target.value)} />
              <textarea value={taskDetail} onChange={(event) => setTaskDetail(event.target.value)} />
              <input value={taskCommand} onChange={(event) => setTaskCommand(event.target.value)} />
              <button onClick={createTask}>
                <Send size={16} /> Create
              </button>
            </div>
            <div className="stack">
              {(snapshot?.tasks ?? []).map((task) => <TaskRow key={task.id} task={task} onRun={runTask} onDelegate={delegateTask} onRetry={retryTask} />)}
            </div>
          </section>
        ) : null}

        {active === 'Review' ? (
          <section className="grid two">
            <div className="panel">
              <h2>Changed Files</h2>
              {snapshot?.diff.files.length ? snapshot.diff.files.map((file) => <p key={file.path} className="diff-row">{file.status}: {file.path}</p>) : <p>No git changes found.</p>}
              <h2>Patch Preview</h2>
              <input value={patchTitle} onChange={(event) => setPatchTitle(event.target.value)} placeholder="Patch title" />
              <input value={patchPath} onChange={(event) => setPatchPath(event.target.value)} placeholder="README.md" />
              <input value={patchTaskId} onChange={(event) => setPatchTaskId(event.target.value)} placeholder="Optional task id" />
              <textarea value={patchBefore} onChange={(event) => setPatchBefore(event.target.value)} placeholder="Text to replace. Leave blank to write the whole file." />
              <textarea value={patchAfter} onChange={(event) => setPatchAfter(event.target.value)} placeholder="Replacement or full file content" />
              <button onClick={previewPatch}>Preview Patch</button>
              <h2>Patches</h2>
              {(snapshot?.patches ?? []).map((patch) => (
                <article key={patch.id} className="mini">
                  <strong>{patch.title}</strong>
                  <span>{patch.status}</span>
                  <p>{patch.files.map((file) => file.path).join(', ')}</p>
                  <div className="row">
                    <button className="secondary" onClick={() => applyPatch(patch.id)}>Apply</button>
                    <button className="secondary" onClick={() => rejectPatch(patch.id)}>Reject</button>
                  </div>
                </article>
              ))}
            </div>
            <pre className="panel diff">{snapshot?.diff.unifiedDiff || 'No unified diff available.'}</pre>
          </section>
        ) : null}

        {active === 'Artifacts' ? (
          <section className="grid two">
            <div className="panel">
              <h2>Artifacts</h2>
              {snapshot?.artifacts.length ? snapshot.artifacts.map((artifact) => <p key={artifact.id}>{artifact.kind}: {artifact.relativePath}</p>) : <p>No artifact folders found yet.</p>}
            </div>
            <div className="panel">
              <h2>Receipts</h2>
              {snapshot?.receipts.length ? snapshot.receipts.map((receipt) => <p key={receipt.id}>{receipt.status}: {receipt.summary}</p>) : <p>No receipts yet.</p>}
            </div>
          </section>
        ) : null}

        {active === 'Buddy' ? (
          <section className="panel">
            <h2>{snapshot?.buddy.activeFocus}</h2>
            {(snapshot?.buddy.guidance ?? []).map((item) => <p key={item}>{item}</p>)}
            <div className="grid three">
              {(snapshot?.buddy.council ?? []).map((seat) => (
                <article key={seat.seat} className="mini">
                  <strong>{seat.seat}</strong>
                  <span>{seat.status}</span>
                  <p>{seat.note}</p>
                </article>
              ))}
            </div>
          </section>
        ) : null}

        {active === 'Pairing' ? (
          <section className="panel">
            <h2>iPhone Power Mode</h2>
            <p>Host {snapshot?.pairing.hostName} is {snapshot?.pairing.status}.</p>
            <div className="pair-code">{snapshot?.pairing.pairingCode}</div>
            <p>Scopes are explicit: workspace read, workspace write, process run, review read, receipts read.</p>
            <h2>Sandbox Session</h2>
            <p>{snapshot?.sandbox.id}</p>
            <p>{snapshot?.sandbox.note}</p>
            <p>Timeout {snapshot?.sandbox.commandTimeoutMs}ms · output cap {snapshot?.sandbox.maxOutputBytes} bytes</p>
          </section>
        ) : null}
      </section>
    </main>
  );
}
