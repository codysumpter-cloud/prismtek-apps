import { ABILITY_VFX, CHARACTER_SPRITES, STAGE_ART, VFX_SHEETS } from "../assets/assetManifest.js";
import { runtimeConfig } from "../systems/runtimeConfig.js";

const REFERENCE_MANIFEST_PATH = ["assets", "reference", "one" + "piece-test", "runtime", "manifest.json"].join("/");

export class Renderer {
  constructor(canvas) {
    this.canvas = canvas;
    this.ctx = canvas.getContext("2d");
    this.ctx.imageSmoothingEnabled = false;
    this.images = new Map();
    this.referenceManifest = null;
    this.loadManifestImages();
    if (runtimeConfig.useReferenceTestAssets) this.loadReferenceManifest();
  }

  loadManifestImages() {
    for (const sprite of Object.values(CHARACTER_SPRITES)) for (const animation of Object.values(sprite.animations)) this.load(animation.src);
    for (const sheet of Object.values(VFX_SHEETS)) this.load(sheet.src);
    this.load(STAGE_ART.skyRuins.tileset);
  }

  async loadReferenceManifest() {
    try {
      const response = await fetch(REFERENCE_MANIFEST_PATH, { cache: "no-store" });
      if (!response.ok) {
        console.warn("Reference asset mode is enabled, but the local reference manifest was not found.");
        return;
      }
      this.referenceManifest = await response.json();
      for (const effect of Object.values(this.referenceManifest.effects || {})) this.load(effect.src);
      if (this.referenceManifest.stageTexture) this.load(this.referenceManifest.stageTexture.src);
      console.warn("Local reference attack assets enabled. Development/fan testing only; release builds exclude these files.");
    } catch (error) {
      console.warn("Failed to load local reference attack assets.", error);
    }
  }

  load(src) {
    if (this.images.has(src)) return this.images.get(src);
    const image = new Image();
    image.src = src;
    this.images.set(src, image);
    return image;
  }

  draw(snapshot, mode, options = {}) {
    const ctx = this.ctx;
    const stage = snapshot.stage;
    ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
    if (stage.theme === "boxing") drawBoxingBackdrop(ctx, snapshot.elapsed, stage);
    else {
      drawSky(ctx, snapshot.elapsed);
      drawRuinsBackdrop(ctx, this.images.get(STAGE_ART.skyRuins.tileset), this.referenceManifest, this.images);
    }
    for (const p of stage.platforms) stage.theme === "boxing" ? drawBoxingPlatform(ctx, p, stage) : drawPlatform(ctx, p, this.images.get(STAGE_ART.skyRuins.tileset));
    if (stage.theme === "boxing") drawRingRopes(ctx, stage);
    for (const effect of snapshot.effects || []) drawEffect(ctx, effect, this.referenceManifest, this.images);
    for (const f of snapshot.fighters) drawFighter(ctx, f, this.images);
    if (options.showHitboxes) drawHitboxes(ctx, snapshot);
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

function drawRuinsBackdrop(ctx, tileset, referenceManifest, images) {
  const referenceTexture = referenceManifest?.stageTexture ? images.get(referenceManifest.stageTexture.src) : null;
  if (isReady(referenceTexture)) {
    drawFittedStageImage(ctx, referenceTexture, {
      x: 0,
      y: 0,
      w: 960,
      h: 540,
      fit: referenceManifest.stageTexture.fit || "cover",
      alpha: referenceManifest.stageTexture.alpha ?? 0.22
    });
  }
  ctx.fillStyle = "rgba(14, 22, 35, .35)";
  ctx.fillRect(76, 365, 84, 170);
  ctx.fillRect(792, 350, 78, 190);
  ctx.fillStyle = "#61715e";
  for (let y = 370; y < 530; y += 24) {
    ctx.fillRect(82, y, 70, 10);
    ctx.fillRect(798, y + 8, 64, 10);
  }
  if (isReady(tileset)) STAGE_ART.skyRuins.fruitTiles.forEach((tile, index) => blit(ctx, tileset, tile, 338 + index * 96, 178 + (index % 2) * 24, 32, 32));
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
  for (let x = p.x; x < p.x + p.w; x += 32) blit(ctx, tileset, art.platformTile, x, p.y - 4, 32, 32);
  blit(ctx, tileset, art.platformCap, p.x - 10, p.y - 4, 32, 32);
  blit(ctx, tileset, art.platformCap, p.x + p.w - 22, p.y - 4, 32, 32);
}

function drawBoxingBackdrop(ctx, elapsed) {
  const g = ctx.createLinearGradient(0, 0, 0, 540);
  g.addColorStop(0, "#1a1026");
  g.addColorStop(0.6, "#2b1a38");
  g.addColorStop(1, "#170d20");
  ctx.fillStyle = g;
  ctx.fillRect(0, 0, 960, 540);
  for (let i = 0; i < 3; i += 1) {
    const cx = 240 + i * 240 + Math.sin(elapsed * 0.6 + i) * 4;
    ctx.fillStyle = "#0c0814";
    ctx.fillRect(cx - 3, 0, 6, 46);
    ctx.fillStyle = "#39304d";
    ctx.fillRect(cx - 18, 44, 36, 16);
    const beam = ctx.createLinearGradient(cx, 60, cx, 430);
    beam.addColorStop(0, "rgba(255, 238, 170, .20)");
    beam.addColorStop(1, "rgba(255, 238, 170, 0)");
    ctx.fillStyle = beam;
    ctx.beginPath();
    ctx.moveTo(cx - 14, 60);
    ctx.lineTo(cx + 14, 60);
    ctx.lineTo(cx + 120, 430);
    ctx.lineTo(cx - 120, 430);
    ctx.closePath();
    ctx.fill();
  }
  for (let row = 0; row < 3; row += 1) {
    const y = 240 + row * 26;
    ctx.fillStyle = `rgba(10, 6, 18, ${0.85 - row * 0.18})`;
    for (let i = 0; i < 24; i += 1) {
      const x = 8 + i * 41 + (row % 2) * 18;
      const bob = Math.sin(elapsed * 2 + i * 1.7 + row) * 2;
      ctx.beginPath();
      ctx.arc(x, y + bob, 11, Math.PI, 0);
      ctx.fill();
      ctx.fillRect(x - 11, y + bob, 22, 14);
    }
  }
  ctx.fillStyle = "#3d2a55";
  ctx.fillRect(330, 96, 300, 38);
  ctx.fillStyle = "#16243a";
  ctx.fillRect(336, 102, 288, 26);
  ctx.fillStyle = "#ffd166";
  ctx.font = "bold 16px ui-sans-serif, system-ui";
  ctx.textAlign = "center";
  ctx.fillText("PIXEL FRUIT TEST ARENA", 480, 120);
  ctx.fillStyle = "#241430";
  ctx.fillRect(0, 470, 960, 70);
}

function drawBoxingPlatform(ctx, p) {
  if (p.type === "solid") {
    ctx.fillStyle = "#7a2434";
    ctx.fillRect(p.x - 18, p.y + 8, p.w + 36, p.h + 22);
    ctx.fillStyle = "#e8e0cf";
    ctx.fillRect(p.x, p.y, p.w, 12);
    ctx.fillStyle = "#cfc4ab";
    ctx.fillRect(p.x, p.y + 12, p.w, p.h - 12);
    ctx.fillStyle = "rgba(90, 70, 60, .35)";
    for (let x = p.x + 60; x < p.x + p.w; x += 110) ctx.fillRect(x, p.y, 3, p.h);
    ctx.strokeStyle = "#a8333f";
    ctx.lineWidth = 4;
    ctx.beginPath();
    ctx.arc(p.x + p.w / 2, p.y + 6, 30, 0, Math.PI, true);
    ctx.stroke();
    return;
  }
  ctx.fillStyle = "#27405c";
  ctx.fillRect(p.x, p.y, p.w, p.h);
  ctx.fillStyle = "#5d7190";
  ctx.fillRect(p.x, p.y, p.w, 6);
  ctx.fillStyle = "#16243a";
  ctx.fillRect(p.x, p.y + p.h - 4, p.w, 4);
}

function drawRingRopes(ctx, stage) {
  const ring = stage.ring;
  if (!ring) return;
  const left = ring.postLeft;
  const right = ring.postRight;
  const floorY = ring.floor.y;
  for (const post of [left, right]) {
    ctx.fillStyle = "#31415d";
    ctx.fillRect(post.x, post.y, 16, floorY - post.y + 8);
    ctx.fillStyle = "#72ddf7";
    ctx.fillRect(post.x, post.y, 16, 10);
  }
  ["#ef476f", "#f8fafc", "#118ab2"].forEach((color, index) => {
    const y = ring.ropeYs[index];
    ctx.save();
    ctx.globalAlpha = 0.5;
    ctx.strokeStyle = color;
    ctx.lineWidth = 4;
    ctx.beginPath();
    ctx.moveTo(left.x + 8, y);
    ctx.quadraticCurveTo((left.x + right.x) / 2 + 8, y + 7, right.x + 8, y);
    ctx.stroke();
    ctx.restore();
  });
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
  if (f.hakiGuard > 0 || f.hakiActive > 0) drawHakiAura(ctx, f);
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
      drawCustomLayers(ctx, f, sprite, -dw / 2, dy);
    } else {
      ctx.drawImage(image, frame * sprite.frameWidth, 0, sprite.frameWidth, sprite.frameHeight, dx, dy, dw, dh);
      drawCustomLayers(ctx, f, sprite, dx, dy);
    }
  } else {
    drawFallbackFighter(ctx, f);
  }
  ctx.restore();
  drawNameplate(ctx, f);
}

function drawCustomLayers(ctx, f, sprite, dx, dy) {
  if (!sprite.customizable) return;
  const a = f.character.appearance || {};
  const scale = sprite.scale || 2;
  const skin = a.skinTone || "#b97855";
  const hair = a.hairColor || "#5ee7ff";
  const outfit = a.outfitPrimary || "#26344f";
  const trim = a.outfitSecondary || "#f4c542";
  const accessory = a.accessoryColor || "#ef476f";
  const clothing = a.clothingStyle || "runner";
  const hairStyle = a.hairStyle || "crest";
  px(ctx, dx, dy, scale, 11, 7, 10, 8, skin);
  px(ctx, dx, dy, scale, 8, 17, 3, 6, skin);
  px(ctx, dx, dy, scale, 22, 17, 3, 6, skin);
  px(ctx, dx, dy, scale, 9, 15, 15, 10, outfit);
  if (clothing === "jacket") { px(ctx, dx, dy, scale, 9, 15, 4, 10, trim); px(ctx, dx, dy, scale, 20, 15, 4, 10, trim); }
  if (clothing === "hoodie") { px(ctx, dx, dy, scale, 10, 14, 13, 3, trim); px(ctx, dx, dy, scale, 14, 15, 5, 10, outfit); }
  if (clothing === "armor") { px(ctx, dx, dy, scale, 8, 15, 17, 3, trim); px(ctx, dx, dy, scale, 12, 18, 9, 2, "#f8fafc"); }
  if (clothing === "robe") { px(ctx, dx, dy, scale, 8, 15, 17, 14, outfit); px(ctx, dx, dy, scale, 15, 15, 2, 14, trim); }
  if (clothing === "skirt") { px(ctx, dx, dy, scale, 8, 22, 17, 5, outfit); px(ctx, dx, dy, scale, 9, 21, 15, 2, trim); }
  if (clothing === "gi") { px(ctx, dx, dy, scale, 9, 15, 15, 10, "#e8e0cf"); px(ctx, dx, dy, scale, 10, 20, 13, 2, accessory); }
  if (clothing === "coat") { px(ctx, dx, dy, scale, 7, 15, 19, 12, outfit); px(ctx, dx, dy, scale, 15, 15, 2, 12, trim); }
  px(ctx, dx, dy, scale, 11, 25, 4, 5, trim);
  px(ctx, dx, dy, scale, 18, 25, 4, 5, trim);
  if (hairStyle === "crest") { px(ctx, dx, dy, scale, 13, 2, 7, 3, hair); px(ctx, dx, dy, scale, 15, 0, 4, 3, hair); }
  else if (hairStyle === "bob") { px(ctx, dx, dy, scale, 10, 2, 13, 5, hair); px(ctx, dx, dy, scale, 10, 7, 2, 7, hair); px(ctx, dx, dy, scale, 21, 7, 2, 7, hair); }
  else if (hairStyle === "spikes") { px(ctx, dx, dy, scale, 10, 4, 3, 3, hair); px(ctx, dx, dy, scale, 14, 1, 3, 6, hair); px(ctx, dx, dy, scale, 18, 3, 4, 4, hair); }
  else if (hairStyle === "cap") { px(ctx, dx, dy, scale, 10, 3, 13, 4, accessory); px(ctx, dx, dy, scale, 20, 6, 5, 2, accessory); }
  else if (hairStyle === "long") { px(ctx, dx, dy, scale, 10, 2, 13, 5, hair); px(ctx, dx, dy, scale, 9, 7, 3, 12, hair); px(ctx, dx, dy, scale, 21, 7, 3, 12, hair); }
  else if (hairStyle === "ponytail") { px(ctx, dx, dy, scale, 11, 2, 11, 5, hair); px(ctx, dx, dy, scale, 22, 6, 5, 8, hair); }
  else if (hairStyle === "mohawk") px(ctx, dx, dy, scale, 15, 0, 4, 8, hair);
  else if (hairStyle === "hood") { px(ctx, dx, dy, scale, 9, 2, 15, 8, outfit); px(ctx, dx, dy, scale, 12, 5, 9, 3, hair); }
}

function px(ctx, dx, dy, scale, x, y, w, h, color) {
  ctx.fillStyle = color;
  ctx.fillRect(Math.round(dx + x * scale), Math.round(dy + y * scale), Math.round(w * scale), Math.round(h * scale));
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

function drawHakiAura(ctx, f) {
  ctx.save();
  ctx.globalAlpha = 0.62;
  ctx.strokeStyle = "#f8fafc";
  ctx.lineWidth = 2;
  ctx.strokeRect(Math.round(f.x - 22), Math.round(f.y + 4), 44, 54);
  ctx.restore();
}

function drawFallbackFighter(ctx, f) {
  const a = f.character.appearance || {};
  ctx.fillStyle = a.outfitPrimary || "#26344f";
  ctx.fillRect(Math.round(f.x - 15), Math.round(f.y + 23), 30, 25);
  ctx.fillStyle = a.skinTone || "#b97855";
  ctx.fillRect(Math.round(f.x - 12), Math.round(f.y + 6), 24, 20);
  ctx.fillStyle = a.hairColor || "#5ee7ff";
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

function drawEffect(ctx, effect, referenceManifest, images) {
  const alpha = Math.max(0, Math.min(1, effect.ttl / 0.25));
  ctx.save();
  ctx.globalAlpha = alpha;
  ctx.strokeStyle = effect.color || "#ffffff";
  ctx.fillStyle = effect.color || "#ffffff";
  if (effect.type === "attack") {
    if (drawVfxSheet(ctx, effect, images) || drawReferenceEffect(ctx, effect, referenceManifest, images, alpha)) { ctx.restore(); return; }
    const length = effect.ability.kind === "projectile" || effect.ability.kind === "beam" ? 92 : 42;
    ctx.lineWidth = 6;
    ctx.beginPath();
    ctx.moveTo(effect.x, effect.y);
    ctx.lineTo(effect.x + effect.facing * length, effect.y - 8);
    ctx.stroke();
    ctx.fillRect(effect.x + effect.facing * length - 4, effect.y - 12, 8, 8);
  }
  if (effect.type === "hit") {
    if (drawVfxSheet(ctx, { ...effect, ability: { id: "hit" } }, images)) { ctx.restore(); return; }
    ctx.lineWidth = 4;
    ctx.beginPath();
    ctx.arc(effect.x, effect.y, 24 * alpha + 8, 0, Math.PI * 2);
    ctx.stroke();
  }
  if (effect.type === "ringout") ctx.fillRect(effect.x - 18, effect.y - 18, 36, 36);
  ctx.restore();
}

function effectAnchor(effect) {
  const kind = effect.ability?.kind;
  const age = effect.age ?? Math.max(0, (effect.duration || 0.25) - effect.ttl);
  const range = effect.range || 120;
  if (kind === "projectile") return { x: effect.x + (effect.facing || 1) * Math.min(1, age / Math.max(0.001, effect.duration || 0.5)) * range, y: effect.y - 8 };
  if (kind === "beam") return { x: effect.x + (effect.facing || 1) * range * 0.55, y: effect.y - 8 };
  return null;
}

function drawVfxSheet(ctx, effect, images) {
  const key = ABILITY_VFX[effect.ability?.id] || ABILITY_VFX[effect.ability?.kind];
  const sheet = key ? VFX_SHEETS[key] : null;
  if (!sheet) return false;
  const image = images.get(sheet.src);
  if (!isReady(image)) return false;
  const elapsed = effect.age ?? Math.max(0, (effect.duration || 0.25) - effect.ttl);
  const frame = Math.max(0, Math.min(sheet.frames - 1, Math.floor(elapsed * sheet.fps)));
  const columns = sheet.columns || Math.max(1, Math.floor(image.naturalWidth / sheet.frameWidth));
  const sx = (frame % columns) * sheet.frameWidth;
  const sy = Math.floor(frame / columns) * sheet.frameHeight;
  const width = sheet.frameWidth * sheet.scale;
  const height = sheet.frameHeight * sheet.scale;
  const anchor = effectAnchor(effect);
  const x = Math.round(anchor ? anchor.x : effect.x + (effect.facing || 1) * (sheet.offsetX ?? 40));
  const y = Math.round(anchor ? anchor.y : effect.y + (sheet.offsetY ?? -8));
  ctx.save();
  ctx.globalAlpha = Math.max(ctx.globalAlpha, 0.85);
  if ((effect.facing || 1) < 0) { ctx.translate(x, y); ctx.scale(-1, 1); ctx.drawImage(image, sx, sy, sheet.frameWidth, sheet.frameHeight, -width / 2, -height / 2, width, height); }
  else ctx.drawImage(image, sx, sy, sheet.frameWidth, sheet.frameHeight, x - width / 2, y - height / 2, width, height);
  ctx.restore();
  return true;
}

function drawReferenceEffect(ctx, effect, referenceManifest, images, alpha) {
  const effectAsset = referenceManifest?.effects?.[effect.ability?.id] || referenceManifest?.effects?.[effect.ability?.kind];
  if (!effectAsset) return false;
  const image = images.get(effectAsset.src);
  if (!isReady(image)) return false;
  const scale = effectAsset.scale || 1;
  const width = (effectAsset.width || image.naturalWidth) * scale;
  const height = (effectAsset.height || image.naturalHeight) * scale;
  const x = Math.round(effect.x + effect.facing * (effectAsset.offsetX ?? 54));
  const y = Math.round(effect.y + (effectAsset.offsetY ?? -10));
  ctx.save();
  ctx.globalAlpha = Math.min(1, alpha + 0.15);
  if (effect.facing < 0) { ctx.translate(x, y); ctx.scale(-1, 1); ctx.drawImage(image, -width / 2, -height / 2, width, height); }
  else ctx.drawImage(image, x - width / 2, y - height / 2, width, height);
  ctx.restore();
  return true;
}

function drawHitboxes(ctx, snapshot) {
  ctx.save();
  ctx.lineWidth = 2;
  for (const f of snapshot.fighters) {
    if (f.stocks <= 0) continue;
    ctx.strokeStyle = "rgba(114, 221, 247, .9)";
    ctx.strokeRect(Math.round(f.x - f.w / 2), Math.round(f.y), f.w, f.h);
  }
  for (const effect of snapshot.effects || []) {
    if (effect.type !== "attack" || !effect.hitbox) continue;
    ctx.strokeStyle = "rgba(239, 71, 111, .9)";
    ctx.fillStyle = "rgba(239, 71, 111, .15)";
    ctx.fillRect(effect.hitbox.x, effect.hitbox.y, effect.hitbox.w, effect.hitbox.h);
    ctx.strokeRect(effect.hitbox.x, effect.hitbox.y, effect.hitbox.w, effect.hitbox.h);
    if (effect.variantLabel) {
      ctx.font = "bold 11px ui-sans-serif, system-ui";
      ctx.textAlign = "center";
      ctx.fillStyle = "rgba(248, 250, 252, .95)";
      ctx.fillText(`${effect.variantLabel} ${effect.ability?.name || ""}`, effect.hitbox.x + effect.hitbox.w / 2, effect.hitbox.y - 6);
    }
  }
  ctx.restore();
}

function drawDim(ctx, canvas) {
  ctx.fillStyle = "rgba(8, 13, 24, .55)";
  ctx.fillRect(0, 0, canvas.width, canvas.height);
}

function drawFittedStageImage(ctx, image, { x = 0, y = 0, w = 960, h = 540, fit = "cover", alpha = 1 } = {}) {
  if (!isReady(image)) return;
  const iw = image.naturalWidth;
  const ih = image.naturalHeight;
  const scale = fit === "contain" ? Math.min(w / iw, h / ih) : Math.max(w / iw, h / ih);
  const dw = Math.ceil(iw * scale);
  const dh = Math.ceil(ih * scale);
  const dx = Math.round(x + (w - dw) / 2);
  const dy = Math.round(y + (h - dh) / 2);
  ctx.save();
  ctx.globalAlpha *= alpha;
  ctx.drawImage(image, 0, 0, iw, ih, dx, dy, dw, dh);
  ctx.restore();
}

function blit(ctx, image, tile, x, y, w, h) {
  ctx.drawImage(image, tile.x, tile.y, tile.w, tile.h, Math.round(x), Math.round(y), w, h);
}

function isReady(image) {
  return image && image.complete && image.naturalWidth > 0;
}
