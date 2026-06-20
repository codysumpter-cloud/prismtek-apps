import React, { useEffect, useMemo, useRef, useState } from 'react';
import { createRoot } from 'react-dom/client';
import './styles.css';
import {
  BITBUD_DEFAULT_PET,
  CODEX_PET_ATLAS_PROFILE,
  createObjectUrl,
  getStateById,
  normalisePetManifest,
  readJsonFile
} from './petFormat.js';

const DEFAULT_PACKAGE_PATH = '~/.codex/pets/bitbud/';
const STORAGE_KEYS = {
  tasks: 'prismtek-buddies.tasks',
  memo: 'prismtek-buddies.memo',
  xp: 'prismtek-buddies.xp',
  ambience: 'prismtek-buddies.ambience'
};

function readStoredJson(key, fallback) {
  try {
    return JSON.parse(window.localStorage.getItem(key) || 'null') ?? fallback;
  } catch {
    return fallback;
  }
}

function useSpriteAnimation({ image, stateId, playing }) {
  const [frame, setFrame] = useState(0);
  const state = useMemo(() => getStateById(stateId), [stateId]);

  useEffect(() => setFrame(0), [stateId]);

  useEffect(() => {
    if (!playing || !image) return undefined;
    const delay = Math.max(60, Math.round(1000 / state.fps));
    const timer = window.setInterval(() => setFrame((current) => (current + 1) % state.frames), delay);
    return () => window.clearInterval(timer);
  }, [image, playing, state.fps, state.frames]);

  return { frame, setFrame, state };
}

function SpriteCanvas({ image, stateId, playing, zoom }) {
  const canvasRef = useRef(null);
  const { frame, setFrame, state } = useSpriteAnimation({ image, stateId, playing });

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    const width = CODEX_PET_ATLAS_PROFILE.cellWidth;
    const height = CODEX_PET_ATLAS_PROFILE.cellHeight;
    canvas.width = width * zoom;
    canvas.height = height * zoom;
    ctx.imageSmoothingEnabled = false;
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    if (!image) {
      drawPlaceholder(ctx, canvas.width, canvas.height, zoom);
      return;
    }

    ctx.drawImage(image, frame * width, state.row * height, width, height, 0, 0, canvas.width, canvas.height);
  }, [frame, image, state.row, zoom]);

  return (
    <div className="sprite-stage" aria-label="Animated Buddy pet preview">
      <canvas ref={canvasRef} className="sprite-canvas" />
      <div className="frame-readout">{state.label}: frame {frame + 1}/{state.frames}</div>
      <input aria-label="Frame scrubber" type="range" min="0" max={state.frames - 1} value={frame} onChange={(event) => setFrame(Number(event.target.value))} />
    </div>
  );
}

function drawPlaceholder(ctx, width, height, zoom) {
  ctx.fillStyle = '#0f172a';
  ctx.fillRect(0, 0, width, height);
  ctx.fillStyle = '#fde68a';
  ctx.fillRect(54 * zoom, 54 * zoom, 84 * zoom, 70 * zoom);
  ctx.fillStyle = '#111827';
  ctx.fillRect(72 * zoom, 78 * zoom, 8 * zoom, 16 * zoom);
  ctx.fillRect(112 * zoom, 78 * zoom, 8 * zoom, 16 * zoom);
  ctx.fillStyle = '#0f766e';
  ctx.fillRect(45 * zoom, 132 * zoom, 102 * zoom, 44 * zoom);
  ctx.fillStyle = '#14b8a6';
  ctx.fillRect(70 * zoom, 28 * zoom, 18 * zoom, 32 * zoom);
  ctx.fillRect(104 * zoom, 28 * zoom, 18 * zoom, 32 * zoom);
}

function formatTime(seconds) {
  const minutes = Math.floor(seconds / 60).toString().padStart(2, '0');
  const rest = Math.floor(seconds % 60).toString().padStart(2, '0');
  return `${minutes}:${rest}`;
}

function App() {
  const [pet, setPet] = useState(BITBUD_DEFAULT_PET);
  const [spriteUrl, setSpriteUrl] = useState(null);
  const [image, setImage] = useState(null);
  const [stateId, setStateId] = useState('idle');
  const [playing, setPlaying] = useState(true);
  const [zoom, setZoom] = useState(1.6);
  const [miniMode, setMiniMode] = useState(false);
  const [error, setError] = useState(null);

  const [tasks, setTasks] = useState(() => readStoredJson(STORAGE_KEYS.tasks, [
    { id: 1, text: 'Load Bitbud pet package', done: false },
    { id: 2, text: 'Run one focus session', done: false }
  ]));
  const [newTask, setNewTask] = useState('');
  const [memo, setMemo] = useState(() => window.localStorage.getItem(STORAGE_KEYS.memo) || 'Today I am building with Bitbud.');
  const [xp, setXp] = useState(() => Number(window.localStorage.getItem(STORAGE_KEYS.xp) || 0));
  const [gift, setGift] = useState('No gift yet. Finish a focus session.');
  const [ambience, setAmbience] = useState(() => readStoredJson(STORAGE_KEYS.ambience, { rain: false, keyboard: true, fireplace: false, cafe: false }));
  const [timerMode, setTimerMode] = useState('countdown');
  const [timerSeconds, setTimerSeconds] = useState(25 * 60);
  const [timerRunning, setTimerRunning] = useState(false);

  useEffect(() => window.localStorage.setItem(STORAGE_KEYS.tasks, JSON.stringify(tasks)), [tasks]);
  useEffect(() => window.localStorage.setItem(STORAGE_KEYS.memo, memo), [memo]);
  useEffect(() => window.localStorage.setItem(STORAGE_KEYS.xp, String(xp)), [xp]);
  useEffect(() => window.localStorage.setItem(STORAGE_KEYS.ambience, JSON.stringify(ambience)), [ambience]);

  useEffect(() => {
    if (!timerRunning) return undefined;
    const timer = window.setInterval(() => {
      setTimerSeconds((current) => {
        if (timerMode === 'countup') return current + 1;
        if (current <= 1) {
          window.clearInterval(timer);
          completeFocusSession();
          return 0;
        }
        return current - 1;
      });
    }, 1000);
    return () => window.clearInterval(timer);
  }, [timerMode, timerRunning]);

  useEffect(() => {
    if (!spriteUrl) {
      setImage(null);
      return undefined;
    }
    const img = new Image();
    img.onload = () => setImage(img);
    img.onerror = () => setError('Could not load spritesheet. Choose the matching spritesheet.webp from the pet package.');
    img.src = spriteUrl;
    return () => {
      img.onload = null;
      img.onerror = null;
    };
  }, [spriteUrl]);

  function completeFocusSession() {
    setTimerRunning(false);
    setStateId('jumping');
    setXp((value) => value + 25);
    setGift('Gift delivered: cozy sticker pack placeholder unlocked.');
  }

  async function onManifestChange(event) {
    const file = event.target.files?.[0];
    if (!file) return;
    try {
      const parsed = await readJsonFile(file);
      setPet(normalisePetManifest(parsed));
      setError(null);
    } catch (err) {
      setError(`Could not parse pet.json: ${err.message}`);
    }
  }

  function onSpritesheetChange(event) {
    const file = event.target.files?.[0];
    if (!file) return;
    if (spriteUrl) URL.revokeObjectURL(spriteUrl);
    setSpriteUrl(createObjectUrl(file));
    setError(null);
  }

  function addTask(event) {
    event.preventDefault();
    const text = newTask.trim();
    if (!text) return;
    setTasks((items) => [...items, { id: Date.now(), text, done: false }]);
    setNewTask('');
    setStateId('waiting');
  }

  function toggleTask(id) {
    setTasks((items) => items.map((task) => task.id === id ? { ...task, done: !task.done } : task));
    setStateId('review');
  }

  function deleteTask(id) {
    setTasks((items) => items.filter((task) => task.id !== id));
    setStateId('failed');
  }

  function startTimer() {
    setTimerRunning(true);
    setStateId(timerMode === 'countup' ? 'running' : 'review');
  }

  function resetTimer(seconds = 25 * 60) {
    setTimerRunning(false);
    setTimerSeconds(seconds);
    setStateId('idle');
  }

  const level = Math.max(1, Math.floor(xp / 100) + 1);
  const activeTask = tasks.find((task) => !task.done);

  return (
    <main className={miniMode ? 'app mini-mode' : 'app'}>
      <section className="hero panel">
        <div>
          <p className="eyebrow">Prismtek Buddies Desktop</p>
          <h1>{pet.displayName} Cozy Room</h1>
          <p>{pet.description}</p>
          <code>{DEFAULT_PACKAGE_PATH}</code>
        </div>
        <button type="button" onClick={() => setMiniMode((value) => !value)}>{miniMode ? 'Full Room' : 'Mini Mode'}</button>
      </section>

      <section className="workspace">
        <div className="room panel">
          <div className="room-wall">
            <span className="poster">BUAP</span>
            <span className="shelf">plant · mug · tiny trophy</span>
            <span className="window">lo-fi rain window</span>
          </div>
          <div className="desk-zone">
            <div className="desk">desk station · focus terminal · snack tray</div>
            <div className="xp-card">Level {level} · {xp} focus XP<br />{gift}</div>
          </div>
          <div className="room-floor">
            <SpriteCanvas image={image} stateId={stateId} playing={playing} zoom={zoom} />
            <p className="state-note">Buddy state: {getStateById(stateId).label} · Current task: {activeTask?.text || 'room is clear'}</p>
          </div>
        </div>

        <aside className="controls panel">
          <section className="widget pet-loader">
            <h2>Pet package</h2>
            <label>pet.json<input type="file" accept="application/json,.json" onChange={onManifestChange} /></label>
            <label>spritesheet.webp<input type="file" accept="image/webp,image/png,image/*" onChange={onSpritesheetChange} /></label>
            {error ? <p className="error">{error}</p> : null}
          </section>

          <section className="widget focus-widget">
            <h2>Focus timer</h2>
            <div className="timer-face">{formatTime(timerSeconds)}</div>
            <div className="button-row">
              <button type="button" onClick={startTimer}>Start</button>
              <button type="button" onClick={() => setTimerRunning(false)}>Pause</button>
              <button type="button" onClick={() => resetTimer(timerMode === 'countup' ? 0 : 25 * 60)}>Reset</button>
            </div>
            <div className="button-row">
              <button type="button" className={timerMode === 'countdown' ? 'active' : ''} onClick={() => { setTimerMode('countdown'); resetTimer(25 * 60); }}>25m focus</button>
              <button type="button" onClick={() => { setTimerMode('countdown'); resetTimer(5 * 60); }}>5m break</button>
              <button type="button" className={timerMode === 'countup' ? 'active' : ''} onClick={() => { setTimerMode('countup'); resetTimer(0); }}>Count up</button>
            </div>
          </section>

          <section className="widget task-widget">
            <h2>To-do list</h2>
            <form onSubmit={addTask} className="task-form">
              <input value={newTask} onChange={(event) => setNewTask(event.target.value)} placeholder="Add a cozy task" />
              <button type="submit">Add</button>
            </form>
            <ul className="task-list">
              {tasks.map((task) => (
                <li key={task.id} className={task.done ? 'done' : ''}>
                  <button type="button" onClick={() => toggleTask(task.id)}>{task.done ? '✓' : '○'}</button>
                  <span>{task.text}</span>
                  <button type="button" onClick={() => deleteTask(task.id)}>×</button>
                </li>
              ))}
            </ul>
          </section>

          <section className="widget memo-widget">
            <h2>Memo pad</h2>
            <textarea value={memo} onChange={(event) => setMemo(event.target.value)} />
            <button type="button" onClick={() => setMemo('')}>Clear memo</button>
          </section>

          <section className="widget ambience-widget">
            <h2>Lo-fi / ambience</h2>
            <div className="button-row">
              <button type="button" onClick={() => setStateId('waving')}>Mock play</button>
              <button type="button" onClick={() => setPlaying((value) => !value)}>{playing ? 'Pause pet' : 'Play pet'}</button>
            </div>
            {Object.keys(ambience).map((key) => (
              <label key={key} className="check-row">
                <input type="checkbox" checked={ambience[key]} onChange={() => setAmbience((value) => ({ ...value, [key]: !value[key] }))} />
                {key}
              </label>
            ))}
            <label>Custom audio placeholder<input type="file" accept="audio/*" /></label>
            <input placeholder="YouTube bookmark placeholder" />
          </section>

          <section className="widget state-widget">
            <h2>Buddy states</h2>
            <div className="state-grid">
              {CODEX_PET_ATLAS_PROFILE.states.map((state) => (
                <button type="button" key={state.id} className={stateId === state.id ? 'active' : ''} onClick={() => setStateId(state.id)}>{state.label}</button>
              ))}
            </div>
            <label>Zoom<input type="range" min="1" max="4" step="0.2" value={zoom} onChange={(event) => setZoom(Number(event.target.value))} /></label>
          </section>
        </aside>
      </section>
    </main>
  );
}

createRoot(document.getElementById('root')).render(<App />);
