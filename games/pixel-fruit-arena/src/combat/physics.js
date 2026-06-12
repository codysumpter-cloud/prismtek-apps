import { GAME } from '../systems/config.js';
import { rectsOverlap } from '../stages/stageRegistry.js';

export function fighterRect(player) {
  return { x: player.x - 16, y: player.y - 56, width: 32, height: 56 };
}

export function integratePlayer(player, stage, dt) {
  if (player.stocks <= 0) return;
  if (player.respawn > 0) {
    player.respawn -= dt;
    return;
  }

  player.hitstun = Math.max(0, player.hitstun - dt);
  player.cooldowns = player.cooldowns.map((value) => Math.max(0, value - dt));
  player.awakeningTime = Math.max(0, player.awakeningTime - dt);
  player.vy += GAME.gravity;
  player.x += player.vx;
  player.y += player.vy;

  let grounded = false;
  for (const platform of stage.platforms) {
    const rect = fighterRect(player);
    const wasAbove = rect.y + rect.height - player.vy <= platform.y + 8;
    if (rectsOverlap(rect, platform) && player.vy >= 0 && wasAbove) {
      player.y = platform.y;
      player.vy = 0;
      grounded = true;
      player.jumpsLeft = 2;
    }
  }
  player.grounded = grounded;
  player.vx *= grounded ? GAME.groundFriction : GAME.airFriction;

  for (const hazard of stage.hazards ?? []) {
    if (rectsOverlap(fighterRect(player), hazard)) {
      player.damage += hazard.damagePerSecond * dt;
      player.vy = Math.min(player.vy, hazard.launchY);
      player.awakening = Math.min(100, player.awakening + 2 * dt);
    }
  }

  const out = stage.ringOut;
  if (player.x < out.left || player.x > out.right || player.y < out.top || player.y > out.bottom) {
    player.stocks -= 1;
    if (player.stocks > 0) {
      const spawn = stage.spawns[(player.slot - 1) % stage.spawns.length];
      Object.assign(player, { x: spawn.x, y: spawn.y, vx: 0, vy: 0, damage: 0, respawn: 1.2, hitstun: 0, jumpsLeft: 2 });
    }
  }
}

export function applyHit(target, source, hit, dt = 1) {
  if (target.stocks <= 0 || target.respawn > 0) return;
  const direction = target.x >= source.x ? 1 : -1;
  const awakeningBoost = source.awakeningTime > 0 ? 1.25 : 1;
  const scaling = 1 + target.damage / 100;
  target.damage += hit.damage * awakeningBoost * dt;
  target.vx = direction * hit.knockback * scaling * awakeningBoost;
  target.vy = -Math.abs(hit.knockback * 0.42 * scaling * awakeningBoost);
  target.hitstun = hit.status === 'freeze' ? 0.55 : 0.22;
  target.awakening = Math.min(100, target.awakening + hit.damage * 0.55);
  source.awakening = Math.min(100, source.awakening + hit.damage * 0.35);
}
