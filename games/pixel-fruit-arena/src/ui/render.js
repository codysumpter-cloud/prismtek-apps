export function drawStage(ctx, stage) {
  ctx.imageSmoothingEnabled = false;
  ctx.fillStyle = '#14182e';
  ctx.fillRect(0, 0, stage.size.width, stage.size.height);
  ctx.fillStyle = '#24355f';
  for (let y = 32; y < stage.size.height; y += 48) {
    for (let x = (y / 48) % 2 ? 16 : 0; x < stage.size.width; x += 64) ctx.fillRect(x, y, 8, 8);
  }
  for (const p of stage.platforms) {
    ctx.fillStyle = '#6d4a38';
    ctx.fillRect(p.x, p.y, p.width, p.height);
    ctx.fillStyle = '#b77b4a';
    ctx.fillRect(p.x, p.y, p.width, 6);
    ctx.fillStyle = '#2a2232';
    ctx.fillRect(p.x, p.y + p.height - 6, p.width, 6);
  }
  for (const h of stage.hazards ?? []) {
    ctx.fillStyle = '#a8f7ff';
    ctx.fillRect(h.x, h.y, h.width, h.height);
    ctx.fillStyle = '#ffffff';
    ctx.fillRect(h.x + 10, h.y + 8, h.width - 20, 4);
  }
}

export function drawPlayer(ctx, player, fruits) {
  if (player.stocks <= 0) return;
  const fruit = fruits.find((f) => f.id === player.fruitId) ?? fruits[0];
  const a = player.appearance;
  ctx.save();
  ctx.translate(Math.round(player.x), Math.round(player.y));
  if (player.facing < 0) ctx.scale(-1, 1);
  ctx.globalAlpha = player.respawn > 0 ? 0.45 : 1;
  if (player.awakeningTime > 0) {
    ctx.fillStyle = fruit.color;
    ctx.fillRect(-24, -62, 48, 60);
  }
  px(ctx, -10, -50, 20, 18, a.skinTone);
  px(ctx, -13, -56, 26, 9, a.hairColor);
  px(ctx, -12, -32, 24, 24, a.outfitPrimary);
  px(ctx, -17, -28, 6, 24, a.skinTone);
  px(ctx, 11, -28, 6, 24, a.skinTone);
  px(ctx, -11, -8, 8, 18, a.outfitSecondary);
  px(ctx, 3, -8, 8, 18, a.outfitSecondary);
  px(ctx, 16, -42, 8, 8, fruit.color);
  px(ctx, -5, -45, 3, 3, '#101018');
  px(ctx, 5, -45, 3, 3, '#101018');
  ctx.restore();

  ctx.fillStyle = '#ffffff';
  ctx.font = '10px monospace';
  ctx.textAlign = 'center';
  ctx.fillText(`P${player.slot}`, player.x, player.y - 66);
}

export function drawEffects(ctx, match, fruits) {
  for (const effect of match.effects) {
    const owner = match.players.find((p) => p.slot === effect.owner);
    const fruit = fruits.find((f) => f.id === owner?.fruitId) ?? fruits[0];
    ctx.fillStyle = effect.color ?? fruit.color;
    ctx.globalAlpha = 0.75;
    ctx.fillRect(effect.x - effect.width / 2, effect.y - effect.height / 2, effect.width, effect.height);
    ctx.globalAlpha = 1;
    ctx.fillStyle = '#ffffff';
    ctx.font = '10px monospace';
    ctx.textAlign = 'center';
    ctx.fillText(effect.name, effect.x, effect.y + 3);
  }
}

function px(ctx, x, y, w, h, color) {
  ctx.fillStyle = color;
  ctx.fillRect(Math.round(x), Math.round(y), Math.round(w), Math.round(h));
}
