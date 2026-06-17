const COLORS = {
  bg: "#101018",
  panel: "#17172a",
  grid: "#252545",
  text: "#f7f7ff",
  accent: "#5ee7ff",
  hot: "#ff5e78",
  good: "#7cff9b",
  warn: "#ffd166"
};

export function createArcadeGame(config) {
  const root = document.querySelector("#game-root");
  if (!root) throw new Error("Missing #game-root");
  root.innerHTML = `
    <section class="shell">
      <header>
        <div><p class="eyebrow">Prismtek Arcade</p><h1>${config.title}</h1></div>
        <div class="score"><span id="score">0</span><small>score</small></div>
      </header>
      <canvas id="game" width="480" height="320" aria-label="${config.title} canvas"></canvas>
      <footer><span id="status">${config.instructions}</span><button id="restart">Restart</button></footer>
    </section>`;

  const canvas = root.querySelector("#game");
  const ctx = canvas.getContext("2d");
  ctx.imageSmoothingEnabled = false;
  const scoreEl = root.querySelector("#score");
  const statusEl = root.querySelector("#status");
  const restart = root.querySelector("#restart");
  const keys = new Set();
  const input = { pressed: new Set(), pointer: false };
  let state = init(config.slug);
  let last = performance.now();

  addEventListener("keydown", event => {
    keys.add(event.key.toLowerCase());
    input.pressed.add(event.key.toLowerCase());
    if ([" ", "arrowup", "arrowdown", "arrowleft", "arrowright"].includes(event.key.toLowerCase())) event.preventDefault();
  });
  addEventListener("keyup", event => keys.delete(event.key.toLowerCase()));
  canvas.addEventListener("pointerdown", () => { input.pointer = true; input.pressed.add(" "); canvas.focus(); });
  restart.addEventListener("click", () => { state = init(config.slug); });

  function frame(now) {
    const dt = Math.min(0.033, (now - last) / 1000);
    last = now;
    update(config.slug, state, dt, keys, input);
    render(config, state, ctx);
    scoreEl.textContent = Math.floor(state.score).toString();
    statusEl.textContent = state.gameOver ? `${config.title} ended — press Restart` : config.instructions;
    input.pressed.clear();
    input.pointer = false;
    requestAnimationFrame(frame);
  }
  requestAnimationFrame(frame);
}

function init(slug) {
  const common = { t: 0, score: 0, gameOver: false };
  if (slug === "flappy-pixel") return { ...common, bird: { x: 92, y: 150, vy: 0 }, pipes: makePipes(), gravity: 720 };
  if (slug === "crossy-pixel") return { ...common, player: { x: 224, y: 280 }, cars: makeCars(), lanes: 6 };
  if (slug === "pixel-snake") return { ...common, grid: 20, dir: { x: 1, y: 0 }, next: { x: 1, y: 0 }, snake: [{ x: 8, y: 8 }, { x: 7, y: 8 }, { x: 6, y: 8 }], food: { x: 15, y: 8 }, tick: 0 };
  if (slug === "neon-brick-breaker") return { ...common, paddle: { x: 200, w: 82 }, ball: { x: 240, y: 230, vx: 145, vy: -165 }, bricks: makeBricks() };
  if (slug === "pixel-stacker") return { ...common, stack: [{ x: 150, y: 290, w: 180 }], active: { x: 0, y: 270, w: 180, vx: 130 }, level: 0 };
  return common;
}

function update(slug, s, dt, keys, input) {
  if (s.gameOver) return;
  s.t += dt;
  if (slug === "flappy-pixel") updateFlappy(s, dt, input);
  if (slug === "crossy-pixel") updateCrossy(s, dt, keys, input);
  if (slug === "pixel-snake") updateSnake(s, dt, keys, input);
  if (slug === "neon-brick-breaker") updateBreakout(s, dt, keys);
  if (slug === "pixel-stacker") updateStacker(s, dt, input);
}

function render(config, s, ctx) {
  clear(ctx);
  drawGrid(ctx);
  if (config.slug === "flappy-pixel") drawFlappy(ctx, s);
  if (config.slug === "crossy-pixel") drawCrossy(ctx, s);
  if (config.slug === "pixel-snake") drawSnake(ctx, s);
  if (config.slug === "neon-brick-breaker") drawBreakout(ctx, s);
  if (config.slug === "pixel-stacker") drawStacker(ctx, s);
  if (s.gameOver) centerText(ctx, "GAME OVER", 154, COLORS.hot);
}

function updateFlappy(s, dt, input) {
  if (input.pressed.has(" ")) s.bird.vy = -255;
  s.bird.vy += s.gravity * dt;
  s.bird.y += s.bird.vy * dt;
  for (const p of s.pipes) {
    p.x -= 105 * dt;
    if (p.x < -52) Object.assign(p, { x: 510, gap: 95 + Math.random() * 125, passed: false });
    if (!p.passed && p.x + 44 < s.bird.x) { p.passed = true; s.score += 10; }
    if (overlap(s.bird.x, s.bird.y, 20, 20, p.x, 0, 44, p.gap - 55) || overlap(s.bird.x, s.bird.y, 20, 20, p.x, p.gap + 55, 44, 320)) s.gameOver = true;
  }
  if (s.bird.y < 0 || s.bird.y > 305) s.gameOver = true;
}

function updateCrossy(s, dt, keys, input) {
  const step = 40;
  if (input.pressed.has("arrowup") || input.pressed.has("w")) s.player.y -= step;
  if (input.pressed.has("arrowdown") || input.pressed.has("s")) s.player.y += step;
  if (input.pressed.has("arrowleft") || input.pressed.has("a")) s.player.x -= step;
  if (input.pressed.has("arrowright") || input.pressed.has("d")) s.player.x += step;
  s.player.x = clamp(s.player.x, 10, 450);
  s.player.y = clamp(s.player.y, 0, 292);
  for (const car of s.cars) {
    car.x += car.vx * dt;
    if (car.vx > 0 && car.x > 520) car.x = -70;
    if (car.vx < 0 && car.x < -80) car.x = 520;
    if (overlap(s.player.x, s.player.y, 24, 24, car.x, car.y, car.w, 24)) s.gameOver = true;
  }
  s.score = Math.max(s.score, Math.round((300 - s.player.y) * 3));
  if (s.player.y <= 8) { s.score += 100; s.player.y = 280; }
}

function updateSnake(s, dt, keys, input) {
  if (keys.has("arrowup") || keys.has("w")) s.next = { x: 0, y: -1 };
  if (keys.has("arrowdown") || keys.has("s")) s.next = { x: 0, y: 1 };
  if (keys.has("arrowleft") || keys.has("a")) s.next = { x: -1, y: 0 };
  if (keys.has("arrowright") || keys.has("d")) s.next = { x: 1, y: 0 };
  if (s.next.x !== -s.dir.x || s.next.y !== -s.dir.y) s.dir = s.next;
  s.tick += dt;
  if (s.tick < 0.11) return;
  s.tick = 0;
  const head = { x: s.snake[0].x + s.dir.x, y: s.snake[0].y + s.dir.y };
  if (head.x < 0 || head.y < 0 || head.x >= 24 || head.y >= 16 || s.snake.some(p => p.x === head.x && p.y === head.y)) { s.gameOver = true; return; }
  s.snake.unshift(head);
  if (head.x === s.food.x && head.y === s.food.y) { s.score += 10; s.food = { x: Math.floor(Math.random() * 24), y: Math.floor(Math.random() * 16) }; }
  else s.snake.pop();
}

function updateBreakout(s, dt, keys) {
  if (keys.has("arrowleft") || keys.has("a")) s.paddle.x -= 260 * dt;
  if (keys.has("arrowright") || keys.has("d")) s.paddle.x += 260 * dt;
  s.paddle.x = clamp(s.paddle.x, 0, 480 - s.paddle.w);
  s.ball.x += s.ball.vx * dt; s.ball.y += s.ball.vy * dt;
  if (s.ball.x < 6 || s.ball.x > 474) s.ball.vx *= -1;
  if (s.ball.y < 6) s.ball.vy *= -1;
  if (overlap(s.ball.x - 5, s.ball.y - 5, 10, 10, s.paddle.x, 292, s.paddle.w, 10)) s.ball.vy = -Math.abs(s.ball.vy);
  for (const b of s.bricks) if (!b.hit && overlap(s.ball.x - 5, s.ball.y - 5, 10, 10, b.x, b.y, b.w, b.h)) { b.hit = true; s.ball.vy *= -1; s.score += 10; }
  if (s.ball.y > 330) s.gameOver = true;
  if (s.bricks.every(b => b.hit)) s.gameOver = true;
}

function updateStacker(s, dt, input) {
  const a = s.active;
  a.x += a.vx * dt;
  if (a.x < 0 || a.x + a.w > 480) { a.vx *= -1; a.x = clamp(a.x, 0, 480 - a.w); }
  if (!input.pressed.has(" ")) return;
  const below = s.stack[s.stack.length - 1];
  const left = Math.max(a.x, below.x);
  const right = Math.min(a.x + a.w, below.x + below.w);
  const w = right - left;
  if (w <= 5) { s.gameOver = true; return; }
  s.stack.push({ x: left, y: below.y - 18, w });
  s.level += 1; s.score += 15 + s.level * 4;
  s.active = { x: 0, y: below.y - 36, w, vx: 130 + s.level * 12 };
  if (s.active.y < 40) s.gameOver = true;
}

function clear(ctx) { ctx.fillStyle = COLORS.bg; ctx.fillRect(0, 0, 480, 320); }
function drawGrid(ctx) { ctx.strokeStyle = COLORS.grid; ctx.lineWidth = 1; for (let x = 0; x < 480; x += 20) line(ctx, x, 0, x, 320); for (let y = 0; y < 320; y += 20) line(ctx, 0, y, 480, y); }
function drawFlappy(ctx, s) { rect(ctx, s.bird.x, s.bird.y, 20, 20, COLORS.warn); s.pipes.forEach(p => { rect(ctx, p.x, 0, 44, p.gap - 55, COLORS.good); rect(ctx, p.x, p.gap + 55, 44, 320, COLORS.good); }); }
function drawCrossy(ctx, s) { for (let y = 40; y < 280; y += 40) rect(ctx, 0, y, 480, 24, "#20203a"); s.cars.forEach(c => rect(ctx, c.x, c.y, c.w, 24, c.color)); rect(ctx, s.player.x, s.player.y, 24, 24, COLORS.accent); }
function drawSnake(ctx, s) { rect(ctx, s.food.x * s.grid, s.food.y * s.grid, 18, 18, COLORS.hot); s.snake.forEach((p, i) => rect(ctx, p.x * s.grid, p.y * s.grid, 18, 18, i ? COLORS.good : COLORS.accent)); }
function drawBreakout(ctx, s) { rect(ctx, s.paddle.x, 292, s.paddle.w, 10, COLORS.accent); rect(ctx, s.ball.x - 5, s.ball.y - 5, 10, 10, COLORS.warn); s.bricks.forEach(b => { if (!b.hit) rect(ctx, b.x, b.y, b.w, b.h, b.color); }); }
function drawStacker(ctx, s) { s.stack.forEach((b, i) => rect(ctx, b.x, b.y, b.w, 16, i ? COLORS.accent : COLORS.good)); rect(ctx, s.active.x, s.active.y, s.active.w, 16, COLORS.warn); }

function makePipes() { return [0, 1, 2].map(i => ({ x: 360 + i * 170, gap: 95 + Math.random() * 125, passed: false })); }
function makeCars() { return [0, 1, 2, 3, 4, 5].map(i => ({ x: Math.random() * 440, y: 46 + i * 40, w: 46 + i * 3, vx: (i % 2 ? -1 : 1) * (95 + i * 20), color: i % 2 ? COLORS.hot : COLORS.warn })); }
function makeBricks() { const out = []; for (let y = 0; y < 5; y++) for (let x = 0; x < 8; x++) out.push({ x: 30 + x * 52, y: 32 + y * 22, w: 42, h: 14, color: [COLORS.hot, COLORS.warn, COLORS.accent, COLORS.good][y % 4], hit: false }); return out; }
function rect(ctx, x, y, w, h, color) { ctx.fillStyle = color; ctx.fillRect(Math.round(x), Math.round(y), Math.round(w), Math.round(h)); }
function line(ctx, x1, y1, x2, y2) { ctx.beginPath(); ctx.moveTo(x1, y1); ctx.lineTo(x2, y2); ctx.stroke(); }
function centerText(ctx, text, y, color) { ctx.fillStyle = color; ctx.font = "bold 28px monospace"; ctx.textAlign = "center"; ctx.fillText(text, 240, y); }
function overlap(ax, ay, aw, ah, bx, by, bw, bh) { return ax < bx + bw && ax + aw > bx && ay < by + bh && ay + ah > by; }
function clamp(v, min, max) { return Math.max(min, Math.min(max, v)); }
