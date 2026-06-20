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

function useSpriteAnimation({ image, stateId, playing }) {
  const [frame, setFrame] = useState(0);
  const state = useMemo(() => getStateById(stateId), [stateId]);

  useEffect(() => {
    setFrame(0);
  }, [stateId]);

  useEffect(() => {
    if (!playing || !image) {
      return undefined;
    }

    const delay = Math.max(60, Math.round(1000 / state.fps));
    const timer = window.setInterval(() => {
      setFrame((current) => (current + 1) % state.frames);
    }, delay);

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

    ctx.drawImage(
      image,
      frame * width,
      state.row * height,
      width,
      height,
      0,
      0,
      canvas.width,
      canvas.height
    );
  }, [frame, image, state.row, zoom]);

  return (
    <div className="sprite-stage" aria-label="Animated Buddy pet preview">
      <canvas ref={canvasRef} className="sprite-canvas" />
      <div className="frame-readout">
        {state.label}: frame {frame + 1}/{state.frames}
      </div>
      <input
        aria-label="Frame scrubber"
        type="range"
        min="0"
        max={state.frames - 1}
        value={frame}
        onChange={(event) => setFrame(Number(event.target.value))}
      />
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

function App() {
  const [pet, setPet] = useState(BITBUD_DEFAULT_PET);
  const [spriteUrl, setSpriteUrl] = useState(null);
  const [image, setImage] = useState(null);
  const [stateId, setStateId] = useState('idle');
  const [playing, setPlaying] = useState(true);
  const [zoom, setZoom] = useState(2);
  const [isOverlay, setIsOverlay] = useState(false);
  const [error, setError] = useState(null);

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

  return (
    <main className={isOverlay ? 'app overlay-mode' : 'app'}>
      <section className="hero panel">
        <div>
          <p className="eyebrow">Prismtek Buddies Desktop</p>
          <h1>{pet.displayName}</h1>
          <p>{pet.description}</p>
          <code>{DEFAULT_PACKAGE_PATH}</code>
        </div>
        <button type="button" onClick={() => setIsOverlay((value) => !value)}>
          {isOverlay ? 'Exit overlay mock' : 'Overlay mock'}
        </button>
      </section>

      <section className="workspace">
        <div className="room panel">
          <div className="room-wall">
            <span className="shelf" />
            <span className="poster">BUAP</span>
          </div>
          <div className="room-floor">
            <SpriteCanvas image={image} stateId={stateId} playing={playing} zoom={zoom} />
          </div>
        </div>

        <aside className="controls panel">
          <h2>Pet package</h2>
          <label>
            pet.json
            <input type="file" accept="application/json,.json" onChange={onManifestChange} />
          </label>
          <label>
            spritesheet.webp
            <input type="file" accept="image/webp,image/png,image/*" onChange={onSpritesheetChange} />
          </label>
          {error ? <p className="error">{error}</p> : null}

          <h2>States</h2>
          <div className="state-grid">
            {CODEX_PET_ATLAS_PROFILE.states.map((state) => (
              <button
                type="button"
                key={state.id}
                className={stateId === state.id ? 'active' : ''}
                onClick={() => setStateId(state.id)}
              >
                {state.label}
              </button>
            ))}
          </div>

          <div className="row-actions">
            <button type="button" onClick={() => setPlaying((value) => !value)}>
              {playing ? 'Pause' : 'Play'}
            </button>
            <label>
              Zoom
              <input
                type="range"
                min="1"
                max="4"
                value={zoom}
                onChange={(event) => setZoom(Number(event.target.value))}
              />
            </label>
          </div>

          <h2>Codex pet atlas</h2>
          <ul className="atlas-list">
            <li>Atlas: 1536x1872</li>
            <li>Cells: 192x208</li>
            <li>Grid: 8 columns x 9 rows</li>
            <li>Default: Bitbud</li>
          </ul>
        </aside>
      </section>
    </main>
  );
}

createRoot(document.getElementById('root')).render(<App />);
