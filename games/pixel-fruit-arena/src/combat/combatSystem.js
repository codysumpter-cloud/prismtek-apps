import { gainMastery } from "../fruits/fruits.js";

export function createFighter({ slot, character, fruitId, fruit, spawn }) {
  return {
    id: `p${slot + 1}`,
    slot,
    character,
    fruitId,
    fruit,
    x: spawn.x,
    y: spawn.y,
    vx: 0,
    vy: 0,
    facing: slot % 2 === 0 ? 1 : -1,
    w: 34,
    h: 52,
    stocks: 3,
    damage: 0,
    jumps: 2,
    grounded: false,
    hitstun: 0,
    invulnerable: 1.2,
    awakening: 0,
    awakened: 0,
    cooldowns: {},
    state: "idle",
    ai: slot > 1
  };
}

export function updateFighter(f, dt, input, stage) {
  const accel = f.awakened > 0 ? 1800 : 1450;
  const maxSpeed = f.awakened > 0 ? 330 : 275;
  const gravity = f.awakened > 0 ? 1220 : 1380;

  f.invulnerable = Math.max(0, f.invulnerable - dt);
  f.hitstun = Math.max(0, f.hitstun - dt);
  f.awakened = Math.max(0, f.awakened - dt);
  for (const key of Object.keys(f.cooldowns)) f.cooldowns[key] = Math.max(0, f.cooldowns[key] - dt);
  f.awakening = Math.min(100, f.awakening + dt * 1.8);

  if (f.hitstun <= 0) {
    if (input.move) {
      f.vx += input.move * accel * dt;
      f.facing = Math.sign(input.move);
    } else {
      f.vx *= f.grounded ? 0.78 : 0.96;
    }
    f.vx = clamp(f.vx, -maxSpeed, maxSpeed);
    if (input.jump && f.jumps > 0) {
      f.vy = -540;
      f.jumps -= 1;
      f.grounded = false;
    }
    if (input.dodge) {
      f.vx = f.facing * 520;
      f.invulnerable = Math.max(f.invulnerable, 0.22);
    }
    if (input.awaken && f.awakening >= 100) {
      f.awakening = 0;
      f.awakened = 10;
    }
  }

  f.vy += gravity * dt;
  f.x += f.vx * dt;
  f.y += f.vy * dt;
  solvePlatforms(f, stage.platforms);
  f.state = deriveState(f);
}

export function applyAttack(attacker, defenders, ability, events) {
  if (!ability || attacker.cooldowns[ability.id] > 0 || attacker.hitstun > 0) return;
  attacker.cooldowns[ability.id] = ability.cooldown * (attacker.awakened > 0 ? 0.65 : 1);
  const range = ability.range || (ability.kind === "projectile" || ability.kind === "beam" ? 150 : 58);
  const power = attacker.awakened > 0 ? 1.35 : 1;

  if (ability.kind === "dash" || ability.kind === "blink") attacker.vx = attacker.facing * ability.speed;
  if (ability.kind === "jump" || ability.kind === "uppercut") attacker.vy = -620;
  if (ability.kind === "slam") attacker.vy = 720;

  events.push({ type: "attack", attacker: attacker.id, ability, x: attacker.x, y: attacker.y, facing: attacker.facing, color: attacker.fruit.color });
  for (const target of defenders) {
    if (target.stocks <= 0 || target.invulnerable > 0) continue;
    const dx = target.x - attacker.x;
    const dy = target.y - attacker.y;
    if (Math.abs(dx) < range && Math.abs(dy) < 76) {
      const direction = ability.knockback < 0 ? -Math.sign(dx || attacker.facing) : Math.sign(dx || attacker.facing);
      target.damage += Math.round(ability.damage * power);
      target.hitstun = 0.18 + target.damage / 420;
      target.vx = direction * (Math.abs(ability.knockback) + target.damage * 5) * power;
      target.vy = -180 - target.damage * 2.5;
      target.awakening = Math.min(100, target.awakening + ability.damage * 1.2);
      attacker.awakening = Math.min(100, attacker.awakening + ability.damage * 1.6);
      gainMastery(attacker.character, attacker.fruitId, 0.35);
      events.push({ type: "hit", attacker: attacker.id, target: target.id, ability });
    }
  }
}

export function checkRingOut(f, stage) {
  const out = f.x < stage.bounds.left || f.x > stage.bounds.right || f.y < stage.bounds.top || f.y > stage.bounds.bottom;
  if (!out) return false;
  f.stocks -= 1;
  f.damage = 0;
  f.vx = 0;
  f.vy = 0;
  f.awakening = Math.min(100, f.awakening + 20);
  return true;
}

function solvePlatforms(f, platforms) {
  f.grounded = false;
  for (const p of platforms) {
    const wasAbove = f.y + f.h <= p.y + Math.max(10, f.vy * 0.016);
    const overlapsX = f.x + f.w / 2 > p.x && f.x - f.w / 2 < p.x + p.w;
    const lands = overlapsX && wasAbove && f.y + f.h >= p.y && f.vy >= 0;
    if (lands) {
      f.y = p.y - f.h;
      f.vy = 0;
      f.grounded = true;
      f.jumps = 2;
    }
  }
}

function deriveState(f) {
  if (f.hitstun > 0) return "hurt";
  if (f.awakened > 0) return "special";
  if (!f.grounded && f.vy < 0) return "jump";
  if (!f.grounded) return "fall";
  if (Math.abs(f.vx) > 220) return "run";
  if (Math.abs(f.vx) > 20) return "walk";
  return "idle";
}

function clamp(value, min, max) {
  return Math.max(min, Math.min(max, value));
}
