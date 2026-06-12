import { CHARACTER_SPRITES, STAGE_ART } from "../assets/assetManifest.js";

export class Renderer {
  constructor(canvas, stage) {
    this.canvas = canvas;
    this.ctx = canvas.getContext("2d");
    this.ctx.imageSmoothingEnabled = false;
    this.stage = stage;
    this.images = new Map();
    this.loadManifestImages();
  }

  loadManifestImages() {
    for (const sprite of Object.values(CHARACTER_SPRITES)) {
      for (const animation of Object.values(sprite.animations)) this.load(animation.src);
    }
    this.load(STAGE_ART.skyRuins.tileset);
  }

  load(src) {
    if (this.images.has(src)) return this.images.get(src);
    const image = new Image();
    image.src = src;
    this.images.set(src, image);
    return image;
  }

  draw(snapshot, mode) {
    const ctx = this.ctx;
    ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
    drawSky(ctx, snapshot.elapsed);
    drawStage(ctx, snapshot.stage, this.images.get(STAGE_ART.skyRuins.tileset));
    for (const effect of snapshot.effects || []) drawEffect(ctx, effect);
    for (const f of snapshot.fighters) drawFighter(ctx, f, this.images);
    if (mode !== "fight") drawDim(ctx, this.canvas);
  }
}

function drawSky(ctx, elapsed) {
  const g = ctx.createLinearGradient(0, 0, 0, 540);
  g.addColorStop(0, "#152238");
  g.addColorStop(0.54, "#284764");
  g.addColorStop(1, "#70835d");
  ctx.fillStyle = g;
  ctx.fillRect(0, 0, 960, 540);

  ctx.fillStyle = "rgba(255,255,255,.14)";
  for (let i = 0; i < 9; i += 1) {
    const x = (80 + i * 116 - (elapsed * 10) % 116 + 116) % 1050 - 50;
    ctx.fillRect(x, 70 + (i % 3) * 42, 44, 6);
    ctx.fillRect(x + 18, 62 + (i % 2) * 12, 28, 6);
  }

  ctx.fillStyle = "rgba(9, 15, 28, .28)";
  ctx.fillRect(0, 452, 960, 88);
}

function drawStage(ctx, stage, tileset) {
  drawRuinsBackdrop(ctx, tileset);
  for (const p of stage.platforms) drawPlatform(ctx, p, tileset);
}

function drawRuinsBackdrop(ctx, tileset) {
  ctx.fillStyle = "rgba(14, 22, 35, .35)";
  ctx.fillRect(76, 365, 84, 170);
  ctx.fillRect(792, 350, 78, 190);
  ctx.fillStyle = "#61715e";
  for (let y = 370; y < 530; y += 24) {
    ctx.fillRect(82, y, 70, 10);
    ctx.fillRect(798, y + 8, 64, 10);
  }
  if (isReady(tileset)) {
    const fruitTiles = STAGE_ART.skyRuins.fruitTiles;
    fruitTiles.forEach((tile, index) => {
      blit(ctx, tileset, tile, 338 + index * 96, 178 + (index % 2) * 24, 32, 32);
    });
  }
}

function drawPlatform(ctx, p, tileset) {
  ctx.fillStyle = "#3b4f46";
  ctx.fillRect(p.x, p.y + 10, p.w, p.h);
  ctx.fillStyle = "#91a86d";
  ctx.fillRect(p.x, p.y, p.w, 12);
  ctx.fillStyle = "#26382f";
  ctx.fillRect(p.x, p.y + p.h - 4, p.w, 4);

  if (!isReady(tileset)) return;
  const art = STAGE_ART.skyRuins;
  for (let x = p.x; x < p.x + p.w; x += 32) {
    blit(ctx, tileset, art.platformTile, x, p.y - 4, 32, 32);
  }
  blit(ctx, tileset, art.platformCap, p.x - 10, p.y - 4, 32, 32);
  blit(ctx, tileset, art.platformCap, p.x + p.w - 22, p.y - 4, 32, 32);
}

function drawFighter(ctx, f, images) {
  if (f.stocks <= 0) return;
  const sprite = CHARACTER_SPRITES[f.spriteKey] || CHARACTER_SPRITES.pink;
  const state = pickAnimationState(f);
  const animation = sprite.animations[state] || sprite.animations.idle;
  const image = images.get(animation.src);

  ctx.save();
  if (f.invulnerable > 0 && Math.floor(performance.now() / 80) % 2 === 0) ctx.globalAlpha = 0.45;
  if (f.awakened > 0) drawAwakeningAura(ctx, f);
  if (isReady(image)) {
    const frame = frameIndex(animation, f.animTime);
    const dw = sprite.frameWidth * sprite.scale;
    const dh = sprite.frameHeight * sprite.scale;
    const dx = Math.round(f.x - dw / 2);
    const dy = Math.round(f.y + f.h - dh);
    if (f.facing < 0) {
      ctx.translate(Math.round(f.x), 0);
      ctx.scale(-1, 1);
      ctx.drawImage(image, frame * sprite.frameWidth, 0, sprite.frameWidth, sprite.frameHeight, -dw / 2, dy, dw, dh);
    } else {
      ctx.drawImage(image, frame * sprite.frameWidth, 0, sprite.frameWidth, sprite.frameHeight, dx, dy, dw, dh);
    }
  } else {
    drawFallbackFighter(ctx, f);
  }
  ctx.restore();

  drawNameplate(ctx, f);
}

function pickAnimationState(f) {
  if (f.hitstun > 0) return "hurt";
  if (f.attackFlash > 0) return f.state === "special" ? "special" : "attack";
  if (f.state === "fall") return "fall";
  return f.state || "idle";
}

function frameIndex(animation, time) {
  const raw = Math.floor(time * animation.fps);
  return animation.loop ? raw % animation.frames : Math.min(animation.frames - 1, raw);
}

function drawAwakeningAura(ctx, f) {
  ctx.strokeStyle = f.fruit.color;
  ctx.globalAlpha *= 0.92;
  ctx.lineWidth = 4;
  ctx.strokeRect(Math.round(f.x - 26), Math.round(f.y - 3), 52, 66);
  ctx.globalAlpha *= 0.8;
  ctx.fillStyle = f.fruit.color;
  ctx.fillRect(Math.round(f.x - 2), Math.round(f.y - 12), 4, 8);
}

function drawFallbackFighter(ctx, f) {
  const a = f.character.appearance;
  ctx.fillStyle = a.outfitPrimary;
  ctx.fillRect(Math.round(f.x - 15), Math.round(f.y + 23), 30, 25);
  ctx.fillStyle = a.skinTone;
  ctx.fillRect(Math.round(f.x - 12), Math.round(f.y + 6), 24, 20);
  ctx.fillStyle = a.hairColor;
  ctx.fillRect(Math.round(f.x - 8), Math.round(f.y - 2), 16, 10);
}

function drawNameplate(ctx, f) {
  ctx.font = "11px ui-sans-serif, system-ui";
  ctx.textAlign = "center";
  ctx.fillStyle = "rgba(8, 13, 24, .7)";
  const text = f.character.name || f.id;
  const width = Math.max(42, ctx.measureText(text).width + 10);
  ctx.fillRect(Math.round(f.x - width / 2), Math.round(f.y - 20), width, 15);
  ctx.fillStyle = "#f8fafc";
  ctx.fillText(text, Math.round(f.x), Math.round(f.y - 9));
}

function drawEffect(ctx, effect) {
  const alpha = Math.max(0, Math.min(1, effect.ttl / 0.25));
  ctx.save();
  ctx.globalAlpha = alpha;
  ctx.strokeStyle = effect.color || "#ffffff";
  ctx.fillStyle = effect.color || "#ffffff";
  if (effect.type === "attack") {
    const length = effect.ability.kind === "projectile" || effect.ability.kind === "beam" ? 92 : 42;
    ctx.lineWidth = 6;
    ctx.beginPath();
    ctx.moveTo(effect.x, effect.y);
    ctx.lineTo(effect.x + effect.facing * length, effect.y - 8);
    ctx.stroke();
    ctx.fillRect(effect.x + effect.facing * length - 4, effect.y - 12, 8, 8);
  }
  if (effect.type === "hit") {
    ctx.lineWidth = 4;
    ctx.beginPath();
    ctx.arc(effect.x, effect.y, 24 * alpha + 8, 0, Math.PI * 2);
    ctx.stroke();
  }
  if (effect.type === "ringout") {
    ctx.fillRect(effect.x - 18, effect.y - 18, 36, 36);
  }
  ctx.restore();
}

function drawDim(ctx, canvas) {
  ctx.fillStyle = "rgba(8, 13, 24, .55)";
  ctx.fillRect(0, 0, canvas.width, canvas.height);
}

function blit(ctx, image, tile, x, y, w, h) {
  ctx.drawImage(image, tile.x, tile.y, tile.w, tile.h, Math.round(x), Math.round(y), w, h);
}

function isReady(image) {
  return image && image.complete && image.naturalWidth > 0;
}
