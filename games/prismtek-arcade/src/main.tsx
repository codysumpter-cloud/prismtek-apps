import "./styles.css";
import { ACTIVE_ARCADE_GAME_ORDER, type GameId } from "./arcade/shared";

type Vec = { x: number; y: number };
type Block = { x: number; y: number; w: number; h: number; dx?: number; alive?: boolean };

type Runtime = {
  gameId: GameId;
  score: number;
  lives: number;
  time: number;
  player: Block;
  velocity: Vec;
  blocks: Block[];
  snake: Vec[];
  food: Vec;
  direction: Vec;
  nextDirection: Vec;
  ball: Block;
  paddle: Block;
  slab: Block;
  stack: Block[];
  running: boolean;
  ended: boolean;
};

const width = 420;
const height = 640;
const root = document.getElementById("root");

if (!root) {
  throw new Error("Missing #root element");
}

const app = document.createElement("main");
app.className = "arcade-app";
root.appendChild(app);

const title = document.createElement("section");
title.className = "hero";
title.innerHTML = `<p class="eyebrow">Prismtek Apps</p><h1>Prismtek Arcade</h1><p>Five arcade games migrated from the Prismtek site into a first-class games workspace.</p>`;
app.appendChild(title);

const layout = document.createElement("section");
layout.className = "arcade-layout";
app.appendChild(layout);

const menu = document.createElement("nav");
menu.className = "game-menu";
layout.appendChild(menu);

const stage = document.createElement("section");
stage.className = "stage";
layout.appendChild(stage);

const hud = document.createElement("div");
hud.className = "hud";
stage.appendChild(hud);

const canvas = document.createElement("canvas");
canvas.width = width;
canvas.height = height;
canvas.setAttribute("aria-label", "Prismtek arcade playfield");
stage.appendChild(canvas);

const help = document.createElement("p");
help.className = "help";
help.textContent = "Controls: Arrow keys or WASD to move. Space, Enter, click, or tap for the main action. P pauses. R restarts.";
stage.appendChild(help);

const context = canvas.getContext("2d");
if (!context) {
  throw new Error("Canvas 2D context is unavailable");
}

let activeGame: GameId = "flappy-pixel";
let runtime = createRuntime(activeGame);
const keys = new Set<string>();
let actionPressed = false;
let lastFrame = performance.now();
let paused = false;

for (const game of ACTIVE_ARCADE_GAME_ORDER) {
  const button = document.createElement("button");
  button.type = "button";
  button.className = "game-card";
  button.innerHTML = `<strong>${game.name}</strong><span>${game.shortPitch}</span>`;
  button.addEventListener("click", () => {
    activeGame = game.id;
    runtime = createRuntime(activeGame);
    paused = false;
    markActiveButton();
  });
  menu.appendChild(button);
}

function markActiveButton() {
  [...menu.querySelectorAll("button")].forEach((button, index) => {
    button.classList.toggle("active", ACTIVE_ARCADE_GAME_ORDER[index]?.id === activeGame);
  });
}

function createRuntime(gameId: GameId): Runtime {
  const blocks: Block[] = [];
  if (gameId === "flappy-pixel") {
    for (let index = 0; index < 4; index += 1) blocks.push(makePipe(480 + index * 170));
  }
  if (gameId === "crossy-pixel") {
    for (let row = 0; row < 7; row += 1) blocks.push({ x: (row * 73) % width, y: 120 + row * 64, w: 70, h: 24, dx: row % 2 === 0 ? 92 : -82 });
  }
  if (gameId === "neon-brick-breaker") {
    for (let y = 0; y < 5; y += 1) {
      for (let x = 0; x < 7; x += 1) blocks.push({ x: 22 + x * 54, y: 74 + y * 28, w: 44, h: 16, alive: true });
    }
  }
  return {
    gameId,
    score: 0,
    lives: 3,
    time: 0,
    player: { x: 92, y: height / 2, w: 24, h: 24 },
    velocity: { x: 0, y: 0 },
    blocks,
    snake: [{ x: 10, y: 12 }, { x: 9, y: 12 }, { x: 8, y: 12 }],
    food: { x: 17, y: 12 },
    direction: { x: 1, y: 0 },
    nextDirection: { x: 1, y: 0 },
    ball: { x: 210, y: 390, w: 14, h: 14, dx: 130, alive: true },
    paddle: { x: 165, y: 586, w: 90, h: 16 },
    slab: { x: 0, y: 590, w: 190, h: 24, dx: 140 },
    stack: [{ x: 115, y: 616, w: 190, h: 24 }],
    running: true,
    ended: false
  };
}

function makePipe(x: number): Block {
  const gap = 150;
  const top = 90 + Math.random() * 310;
  return { x, y: top, w: 58, h: gap, dx: -135 };
}

function reset() {
  runtime = createRuntime(activeGame);
  paused = false;
}

window.addEventListener("keydown", (event) => {
  keys.add(event.key.toLowerCase());
  if ([" ", "enter"].includes(event.key.toLowerCase())) actionPressed = true;
  if (event.key.toLowerCase() === "p") paused = !paused;
  if (event.key.toLowerCase() === "r") reset();
});
window.addEventListener("keyup", (event) => keys.delete(event.key.toLowerCase()));
canvas.addEventListener("pointerdown", () => {
  actionPressed = true;
  if (runtime.ended) reset();
});

function isDown(...values: string[]) {
  return values.some((value) => keys.has(value));
}

function update(delta: number) {
  if (paused || runtime.ended) return;
  runtime.time += delta;
  if (runtime.gameId === "flappy-pixel") updateFlappy(delta);
  if (runtime.gameId === "crossy-pixel") updateCrossy(delta);
  if (runtime.gameId === "pixel-snake") updateSnake(delta);
  if (runtime.gameId === "neon-brick-breaker") updateBrick(delta);
  if (runtime.gameId === "pixel-stacker") updateStacker(delta);
  actionPressed = false;
}

function updateFlappy(delta: number) {
  if (actionPressed) runtime.velocity.y = -330;
  runtime.velocity.y += 760 * delta;
  runtime.player.y += runtime.velocity.y * delta;
  for (const pipe of runtime.blocks) {
    pipe.x += (pipe.dx ?? 0) * delta;
    if (pipe.x < -80) {
      Object.assign(pipe, makePipe(width + 80));
      runtime.score += 100;
    }
    const inX = runtime.player.x + runtime.player.w > pipe.x && runtime.player.x < pipe.x + pipe.w;
    const inGap = runtime.player.y > pipe.y && runtime.player.y + runtime.player.h < pipe.y + pipe.h;
    if (inX && !inGap) runtime.ended = true;
  }
  if (runtime.player.y < 0 || runtime.player.y > height - runtime.player.h) runtime.ended = true;
}

function updateCrossy(delta: number) {
  const speed = 210;
  if (isDown("arrowleft", "a")) runtime.player.x -= speed * delta;
  if (isDown("arrowright", "d")) runtime.player.x += speed * delta;
  if (isDown("arrowup", "w")) runtime.player.y -= speed * delta;
  if (isDown("arrowdown", "s")) runtime.player.y += speed * delta;
  runtime.player.x = clamp(runtime.player.x, 0, width - runtime.player.w);
  runtime.player.y = clamp(runtime.player.y, 40, height - runtime.player.h);
  runtime.score = Math.max(runtime.score, Math.round((height - runtime.player.y) * 2));
  for (const block of runtime.blocks) {
    block.x += (block.dx ?? 0) * delta;
    if (block.x > width + 80) block.x = -80;
    if (block.x < -90) block.x = width + 80;
    if (intersects(runtime.player, block)) runtime.ended = true;
  }
  if (runtime.player.y <= 44) runtime.ended = true;
}

function updateSnake(delta: number) {
  if (isDown("arrowleft", "a") && runtime.direction.x !== 1) runtime.nextDirection = { x: -1, y: 0 };
  if (isDown("arrowright", "d") && runtime.direction.x !== -1) runtime.nextDirection = { x: 1, y: 0 };
  if (isDown("arrowup", "w") && runtime.direction.y !== 1) runtime.nextDirection = { x: 0, y: -1 };
  if (isDown("arrowdown", "s") && runtime.direction.y !== -1) runtime.nextDirection = { x: 0, y: 1 };
  if (runtime.time % 0.105 > delta) return;
  runtime.direction = runtime.nextDirection;
  const head = runtime.snake[0];
  const next = { x: head.x + runtime.direction.x, y: head.y + runtime.direction.y };
  if (next.x < 0 || next.y < 0 || next.x >= 21 || next.y >= 29 || runtime.snake.some((part) => part.x === next.x && part.y === next.y)) {
    runtime.ended = true;
    return;
  }
  runtime.snake.unshift(next);
  if (next.x === runtime.food.x && next.y === runtime.food.y) {
    runtime.score += 75;
    runtime.food = { x: Math.floor(Math.random() * 21), y: Math.floor(Math.random() * 29) };
  } else {
    runtime.snake.pop();
  }
}

function updateBrick(delta: number) {
  const paddleSpeed = 280;
  if (isDown("arrowleft", "a")) runtime.paddle.x -= paddleSpeed * delta;
  if (isDown("arrowright", "d")) runtime.paddle.x += paddleSpeed * delta;
  runtime.paddle.x = clamp(runtime.paddle.x, 0, width - runtime.paddle.w);
  runtime.ball.x += (runtime.ball.dx ?? 130) * delta;
  runtime.ball.y += runtime.velocity.y * delta || -160 * delta;
  runtime.velocity.y = runtime.velocity.y || -160;
  if (runtime.ball.x < 0 || runtime.ball.x > width - runtime.ball.w) runtime.ball.dx = -(runtime.ball.dx ?? 130);
  if (runtime.ball.y < 0) runtime.velocity.y = Math.abs(runtime.velocity.y);
  if (intersects(runtime.ball, runtime.paddle)) runtime.velocity.y = -Math.abs(runtime.velocity.y);
  for (const brick of runtime.blocks) {
    if (brick.alive && intersects(runtime.ball, brick)) {
      brick.alive = false;
      runtime.velocity.y = -runtime.velocity.y;
      runtime.score += 50;
    }
  }
  if (runtime.blocks.every((brick) => !brick.alive)) runtime.ended = true;
  if (runtime.ball.y > height) runtime.ended = true;
}

function updateStacker(delta: number) {
  runtime.slab.x += (runtime.slab.dx ?? 140) * delta;
  if (runtime.slab.x < 0 || runtime.slab.x + runtime.slab.w > width) runtime.slab.dx = -(runtime.slab.dx ?? 140);
  if (!actionPressed) return;
  const last = runtime.stack[runtime.stack.length - 1];
  const left = Math.max(last.x, runtime.slab.x);
  const right = Math.min(last.x + last.w, runtime.slab.x + runtime.slab.w);
  const overlap = right - left;
  if (overlap <= 6) {
    runtime.ended = true;
    return;
  }
  runtime.stack.push({ x: left, y: last.y - 24, w: overlap, h: 24 });
  runtime.slab = { x: runtime.slab.dx && runtime.slab.dx > 0 ? 0 : width - overlap, y: last.y - 48, w: overlap, h: 24, dx: -(runtime.slab.dx ?? 140) * 1.05 };
  runtime.score += 100 + Math.round(overlap);
  if (runtime.stack.length >= 20) runtime.ended = true;
}

function draw() {
  const game = ACTIVE_ARCADE_GAME_ORDER.find((item) => item.id === activeGame)!;
  hud.innerHTML = `<div><strong>${game.name}</strong><span>${game.shortPitch}</span></div><div class="hud-score">${runtime.score}</div>`;
  context.clearRect(0, 0, width, height);
  context.fillStyle = "#09111f";
  context.fillRect(0, 0, width, height);
  context.fillStyle = game.accent;
  context.globalAlpha = 0.14;
  for (let y = 0; y < height; y += 32) context.fillRect(0, y, width, 1);
  context.globalAlpha = 1;
  if (activeGame === "flappy-pixel") drawFlappy();
  if (activeGame === "crossy-pixel") drawCrossy();
  if (activeGame === "pixel-snake") drawSnake();
  if (activeGame === "neon-brick-breaker") drawBrick();
  if (activeGame === "pixel-stacker") drawStacker();
  if (paused || runtime.ended) {
    context.fillStyle = "rgba(0, 0, 0, 0.58)";
    context.fillRect(0, 0, width, height);
    context.fillStyle = "#ffffff";
    context.font = "bold 28px monospace";
    context.textAlign = "center";
    context.fillText(runtime.ended ? "Run complete" : "Paused", width / 2, height / 2 - 12);
    context.font = "16px monospace";
    context.fillText("Press R or tap to restart", width / 2, height / 2 + 24);
  }
}

function drawFlappy() {
  context.fillStyle = "#75ffbb";
  drawBlock(runtime.player);
  for (const pipe of runtime.blocks) {
    context.fillStyle = "#1f7a60";
    context.fillRect(pipe.x, 0, pipe.w, pipe.y);
    context.fillRect(pipe.x, pipe.y + pipe.h, pipe.w, height);
  }
}

function drawCrossy() {
  context.fillStyle = "#283653";
  for (let y = 96; y < height; y += 64) context.fillRect(0, y, width, 34);
  context.fillStyle = "#ffd166";
  drawBlock(runtime.player);
  context.fillStyle = "#ff5b7a";
  runtime.blocks.forEach(drawBlock);
}

function drawSnake() {
  const cell = 20;
  context.fillStyle = "#ff7b7b";
  runtime.snake.forEach((part) => context.fillRect(part.x * cell, part.y * cell + 36, cell - 2, cell - 2));
  context.fillStyle = "#ffe66d";
  context.fillRect(runtime.food.x * cell, runtime.food.y * cell + 36, cell - 2, cell - 2);
}

function drawBrick() {
  context.fillStyle = "#7ce2ff";
  runtime.blocks.filter((block) => block.alive).forEach(drawBlock);
  context.fillStyle = "#ffffff";
  drawBlock(runtime.ball);
  context.fillStyle = "#c9a4ff";
  drawBlock(runtime.paddle);
}

function drawStacker() {
  context.fillStyle = "#c9a4ff";
  runtime.stack.forEach(drawBlock);
  context.fillStyle = "#75ffbb";
  drawBlock(runtime.slab);
}

function drawBlock(block: Block) {
  context.fillRect(block.x, block.y, block.w, block.h);
}

function intersects(a: Block, b: Block) {
  return a.x < b.x + b.w && a.x + a.w > b.x && a.y < b.y + b.h && a.y + a.h > b.y;
}

function clamp(value: number, min: number, max: number) {
  return Math.max(min, Math.min(max, value));
}

function frame(now: number) {
  const delta = Math.min(0.04, (now - lastFrame) / 1000);
  lastFrame = now;
  update(delta);
  draw();
  requestAnimationFrame(frame);
}

markActiveButton();
requestAnimationFrame(frame);
