export class Renderer {
  constructor(canvas, stage) {
    this.canvas = canvas;
    this.ctx = canvas.getContext("2d");
    this.ctx.imageSmoothingEnabled = false;
    this.stage = stage;
  }

  draw(snapshot, mode) {
    const ctx = this.ctx;
    ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
    drawSky(ctx);
    drawStage(ctx, snapshot.stage);
    for (const f of snapshot.fighters) drawFighter(ctx, f);
    if (mode !== "fight") drawDim(ctx, this.canvas);
  }
}

function drawSky(ctx) {
  const g = ctx.createLinearGradient(0, 0, 0, 540);
  g.addColorStop(0, "#152238");
  g.addColorStop(0.55, "#26415f");
  g.addColorStop(1, "#6b7d5f");
  ctx.fillStyle = g;
  ctx.fillRect(0, 0, 960, 540);
  ctx.fillStyle = "rgba(255,255,255,.12)";
  for (let i = 0; i < 9; i++) ctx.fillRect(80 + i * 110, 80 + (i % 3) * 38, 44, 6);
}

function drawStage(ctx, stage) {
  ctx.fillStyle = "#536a58";
  for (const p of stage.platforms) {
    ctx.fillRect(p.x, p.y, p.w, p.h);
    ctx.fillStyle = "#8ca66d";
    ctx.fillRect(p.x, p.y, p.w, 6);
    ctx.fillStyle = "#536a58";
    for (let x = p.x + 8; x < p.x + p.w; x += 32) ctx.fillRect(x, p.y + 8, 16, 6);
  }
}

function drawFighter(ctx, f) {
  if (f.stocks <= 0) return;
  const a = f.character.appearance;
  ctx.save();
  ctx.translate(Math.round(f.x), Math.round(f.y));
  if (f.invulnerable > 0 && Math.floor(performance.now() / 80) % 2 === 0) ctx.globalAlpha = 0.45;
  if (f.awakened > 0) {
    ctx.strokeStyle = f.fruit.color;
    ctx.lineWidth = 4;
    ctx.strokeRect(-25, -7, 50, 64);
  }
  ctx.fillStyle = a.outfitPrimary;
  ctx.fillRect(-15, 23, 30, 25);
  ctx.fillStyle = a.outfitSecondary;
  ctx.fillRect(-12, 27, 24, 5);
  ctx.fillStyle = a.skinTone;
  ctx.fillRect(-12, 6, 24, 20);
  ctx.fillStyle = a.hairColor;
  if (a.hairStyle === "crest") ctx.fillRect(-8, -2, 16, 10);
  if (a.hairStyle === "spikes") for (let i = -12; i <= 8; i += 8) ctx.fillRect(i, 0, 6, 8);
  if (a.hairStyle === "bob") ctx.fillRect(-14, 0, 28, 12);
  if (a.hairStyle === "cap") ctx.fillRect(-15, 0, 30, 8);
  ctx.fillStyle = a.accessoryColor;
  ctx.fillRect(f.facing > 0 ? 9 : -15, 16, 6, 5);
  ctx.fillStyle = "#111827";
  ctx.fillRect(f.facing > 0 ? 5 : -8, 13, 4, 4);
  ctx.fillStyle = a.outfitPrimary;
  ctx.fillRect(-18, 48, 12, 10);
  ctx.fillRect(6, 48, 12, 10);
  ctx.fillStyle = f.fruit.color;
  ctx.fillRect(f.facing > 0 ? 15 : -23, 28, 8, 12);
  ctx.restore();
}

function drawDim(ctx, canvas) {
  ctx.fillStyle = "rgba(8, 13, 24, .55)";
  ctx.fillRect(0, 0, canvas.width, canvas.height);
}
