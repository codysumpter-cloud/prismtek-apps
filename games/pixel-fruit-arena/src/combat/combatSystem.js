// Combat core: fighters, movement, directional hitboxes, haki, awakening, knockback.
import { gainMastery } from "../fruits/fruits.js";
import { styleFor } from "./combatStyles.js";

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
    w: 38,
    h: 58,
    stocks: 3,
    damage: 0,
    health: 100,
    maxHealth: 100,
    jumps: 2,
    grounded: false,
    hitstun: 0,
    invulnerable: 1.2,
    awakening: 0,
    awakened: 0,
    haki: 35,
    hakiActive: 0,
    hakiGuard: 0,
    hakiFlash: 0,
    slowTime: 0,
    slowFactor: 1,
    nullTime: 0,
    cooldowns: {},
    animTime: 0,
    attackFlash: 0,
    attackKind: "attack",
    state: "idle",
    spriteKey: character.sprite_key || ["pink", "owlet", "dude", "pink"][slot % 4],
    combatStyle: styleFor(character.combat_style),
    ai: Boolean(character.cpu),
    dummy: Boolean(character.dummy)
  };
}

export function updateFighter(f, dt, input, stage) {
  const style = f.combatStyle || styleFor("duelist");
  const accel = (f.awakened > 0 ? 1800 : 1450) * style.speed;
  const statusSpeed = f.slowTime > 0 ? f.slowFactor : 1;
  const maxSpeed = (f.awakened > 0 ? 330 : 275) * style.speed * statusSpeed;
  const gravity = f.awakened > 0 ? 1220 : 1380;

  f.invulnerable = Math.max(0, f.invulnerable - dt);
  f.hitstun = Math.max(0, f.hitstun - dt);
  f.awakened = Math.max(0, f.awakened - dt);
  f.hakiActive = Math.max(0, f.hakiActive - dt);
  f.hakiGuard = Math.max(0, f.hakiGuard - dt);
  f.hakiFlash = Math.max(0, f.hakiFlash - dt);
  f.slowTime = Math.max(0, f.slowTime - dt);
  f.nullTime = Math.max(0, f.nullTime - dt);
  f.attackFlash = Math.max(0, f.attackFlash - dt);
  f.animTime += dt;
  for (const key of Object.keys(f.cooldowns)) f.cooldowns[key] = Math.max(0, f.cooldowns[key] - dt);
  f.awakening = Math.min(100, f.awakening + dt * 1.8);
  f.haki = Math.min(100, f.haki + dt * (f.awakened > 0 ? 6 : 3.5));

  f.heldMove = input.move || 0;
  f.heldAim = input.aim || 0;

  if (f.hitstun <= 0) {
    if (input.move) {
      f.vx += input.move * accel * statusSpeed * dt;
      f.facing = Math.sign(input.move);
    } else {
      f.vx *= f.grounded ? 0.78 : 0.96;
    }
    f.vx = clamp(f.vx, -maxSpeed, maxSpeed);
    if (input.jump && f.jumps > 0) {
      f.vy = -540 * style.jump;
      f.jumps -= 1;
      f.grounded = false;
    }
    if (input.dodge) {
      f.vx = f.facing * 520 * style.dodge;
      f.invulnerable = Math.max(f.invulnerable, 0.22 * style.dodge);
    }
    if (input.haki && f.haki >= 22) {
      f.haki -= 22;
      f.hakiGuard = 0.55;
      f.hakiActive = Math.max(f.hakiActive, 0.28);
      f.hakiFlash = 0.28;
      f.invulnerable = Math.max(f.invulnerable, 0.08);
    }
    if (input.awaken && f.awakening >= 100) {
      f.awakening = 0;
      f.awakened = 10;
      f.haki = Math.min(100, f.haki + 35);
      f.hakiActive = Math.max(f.hakiActive, 1.2);
    }
  }

  f.health = Math.max(0, f.maxHealth - Math.min(f.damage, f.maxHealth));
  f.vy += gravity * dt;
  f.x += f.vx * dt;
  f.y += f.vy * dt;
  solvePlatforms(f, stage.platforms);
  const nextState = deriveState(f);
  if (nextState !== f.state) f.animTime = 0;
  f.state = nextState;
}

export const MOVE_VARIANTS = {
  neutral: { id: "neutral", label: "Neutral", damage: 1, knockback: 1, range: 1, cooldown: 1, dx: 0, dy: 0, launch: 0, shift: 0, angle: 0 },
  forward: { id: "forward", label: "Forward", damage: 1.16, knockback: 1.14, range: 1.16, cooldown: 1.1, dx: 34, dy: 0, launch: -20, shift: 165, angle: 0 },
  back: { id: "back", label: "Back", damage: 0.86, knockback: 0.92, range: 0.92, cooldown: 0.76, dx: -30, dy: 0, launch: -70, shift: -150, angle: 180 },
  up: { id: "up", label: "Rising", damage: 1.05, knockback: 1.03, range: 0.98, cooldown: 1.04, dx: 0, dy: -50, launch: -270, shift: 0, angle: -90 },
  down: { id: "down", label: "Low", damage: 1.08, knockback: 0.9, range: 0.98, cooldown: 1.12, dx: 0, dy: 40, launch: 210, shift: 0, angle: 90 }
};

export function variantFor(attacker) {
  if ((attacker.heldAim || 0) < 0) return MOVE_VARIANTS.up;
  if ((attacker.heldAim || 0) > 0) return MOVE_VARIANTS.down;
  const move = attacker.heldMove || 0;
  if (move && Math.sign(move) === Math.sign(attacker.facing)) return MOVE_VARIANTS.forward;
  if (move) return MOVE_VARIANTS.back;
  return MOVE_VARIANTS.neutral;
}

export function awakenedAbilityFor(ability, fruit, variant = MOVE_VARIANTS.neutral) {
  const awakenedName = ability.awakenedName || `${fruit?.awakening || "Awakened"} ${ability.name}`;
  return {
    ...ability,
    baseId: ability.id,
    id: ability.id,
    name: awakenedName,
    damage: Math.round((ability.damage || 1) * 1.28 + 2),
    knockback: Math.round(Math.abs(ability.knockback || 300) * 1.18) * Math.sign(ability.knockback || 1),
    cooldown: Math.max(0.22, (ability.cooldown || 0.6) * 0.72),
    range: ability.range ? Math.round(ability.range * 1.18) : ability.range,
    speed: ability.speed ? Math.round(ability.speed * 1.16) : ability.speed,
    awakened: true,
    variantLabel: variant.label
  };
}

export function hitboxFor(attacker, ability, styleRange = 1, variant = MOVE_VARIANTS.neutral) {
  const range = (ability.range || rangeFor(ability)) * styleRange * variant.range * (ability.awakened ? 1.12 : 1);
  const omni = OMNI_KINDS.has(ability.kind);
  const tall = ability.kind === "uppercut" || ability.kind === "slam" || ability.kind === "jump";
  const height = tall ? 150 : ability.kind === "field" || ability.kind === "burst" ? 130 : 96;
  const directionalOffset = omni ? 0 : attacker.facing * ((range / 2) + variant.dx);
  const cx = attacker.x + directionalOffset;
  const cy = attacker.y + attacker.h / 2 + (ability.kind === "slam" ? 30 : tall ? -24 : 0) + variant.dy;
  const width = omni ? range * 2 : range + attacker.w * 0.5;
  return { x: cx - width / 2, y: cy - height / 2, w: width, h: height };
}

const OMNI_KINDS = new Set(["field", "burst", "pull"]);

export function applyAttack(attacker, defenders, ability, events) {
  if (!ability || attacker.cooldowns[ability.id] > 0 || attacker.hitstun > 0) return;
  if (attacker.nullTime > 0 && ability.kind !== "melee" && ability.kind !== "heavy") return;
  const style = attacker.combatStyle || styleFor("duelist");
  const variant = variantFor(attacker);
  const hakiBurst = attacker.hakiActive > 0 || attacker.haki >= 55;
  const spendsHaki = attacker.haki >= 55 && attacker.hakiActive <= 0;
  const activeAbility = attacker.awakened > 0 ? awakenedAbilityFor(ability, attacker.fruit, variant) : ability;
  if (spendsHaki) {
    attacker.haki -= 18;
    attacker.hakiActive = 0.35;
    attacker.hakiFlash = 0.25;
  }

  attacker.cooldowns[ability.id] = activeAbility.cooldown * style.cooldown * variant.cooldown * (attacker.awakened > 0 ? 0.65 : 1);
  const awakeningPower = attacker.awakened > 0 ? 1.25 : 1;
  const hakiPower = hakiBurst ? 1.14 : 1;
  const power = awakeningPower * hakiPower * style.damage * variant.damage;
  const knockbackPower = (attacker.awakened > 0 ? 1.22 : 1) * (hakiBurst ? 1.12 : 1) * style.knockback * variant.knockback;

  if (activeAbility.kind === "dash" || activeAbility.kind === "blink") attacker.vx = attacker.facing * activeAbility.speed;
  if (activeAbility.kind === "blink") attacker.x += attacker.facing * 52;
  if (activeAbility.kind === "jump" || activeAbility.kind === "uppercut") attacker.vy = -620;
  if (activeAbility.kind === "slam") attacker.vy = 720;
  if (variant.shift) attacker.vx += attacker.facing * variant.shift;
  if (variant.id === "up" && attacker.grounded) attacker.vy = Math.min(attacker.vy, -180);

  attacker.attackFlash = 0.18;
  attacker.attackKind = activeAbility.kind === "projectile" || activeAbility.kind === "beam" || activeAbility.kind === "field" ? "special" : "attack";
  attacker.state = attacker.attackKind;
  attacker.animTime = 0;

  const box = hitboxFor(attacker, activeAbility, style.range, variant);
  const ttl = ttlFor(activeAbility);
  events.push({
    ttl,
    duration: ttl,
    type: "attack",
    attacker: attacker.id,
    fruitId: attacker.fruitId,
    ability: activeAbility,
    variant: variant.id,
    variantLabel: variant.label,
    awakened: attacker.awakened > 0,
    haki: hakiBurst,
    x: attacker.x,
    y: attacker.y + 22 + variant.dy,
    facing: attacker.facing,
    color: hakiBurst ? "#f8fafc" : attacker.fruit.color,
    hitbox: box,
    angle: variant.angle,
    range: (activeAbility.range || rangeFor(activeAbility)) * style.range * variant.range
  });

  for (const target of defenders) {
    if (target.stocks <= 0 || target.invulnerable > 0) continue;
    const tx = target.x;
    const ty = target.y + target.h / 2;
    const inBox = tx + target.w / 2 > box.x && tx - target.w / 2 < box.x + box.w
      && ty + target.h / 2 > box.y && ty - target.h / 2 < box.y + box.h;
    if (!inBox) continue;
    const dx = target.x - attacker.x;
    const direction = activeAbility.knockback < 0 ? -Math.sign(dx || attacker.facing) : Math.sign(dx || attacker.facing);
    const targetStyle = target.combatStyle || styleFor("duelist");
    const guard = target.hakiGuard > 0 ? 0.55 : 1;
    const damageTaken = Math.max(1, Math.round(activeAbility.damage * power * guard));
    target.damage += damageTaken;
    target.health = Math.max(0, target.maxHealth - Math.min(target.damage, target.maxHealth));
    target.hitstun = 0.18 + target.damage / 420 + (hakiBurst ? 0.06 : 0);
    target.vx = direction * (Math.abs(activeAbility.knockback) + target.damage * 5) * knockbackPower * guard / targetStyle.weight;
    target.vy = -180 - target.damage * 2.5 + variant.launch;
    if (variant.id === "down" && target.grounded) target.vy = -60;
    applyStatus(attacker, target, activeAbility, power);
    target.awakening = Math.min(100, target.awakening + activeAbility.damage * 1.2);
    target.haki = Math.min(100, target.haki + damageTaken * 0.8);
    attacker.awakening = Math.min(100, attacker.awakening + activeAbility.damage * 1.6);
    attacker.haki = Math.min(100, attacker.haki + activeAbility.damage * 0.35);
    gainMastery(attacker.character, attacker.fruitId, attacker.awakened > 0 ? 0.55 : 0.35);
    events.push({ ttl: 0.24, duration: 0.24, type: "hit", attacker: attacker.id, fruitId: attacker.fruitId, target: target.id, x: target.x, y: target.y + 24, color: hakiBurst ? "#f8fafc" : attacker.fruit.color, ability: activeAbility, haki: hakiBurst, awakened: attacker.awakened > 0 });
  }
}

function rangeFor(ability) {
  if (ability.kind === "projectile" || ability.kind === "beam") return 190;
  if (ability.kind === "field" || ability.kind === "burst") return 110;
  if (ability.kind === "pull" || ability.kind === "chain") return 150;
  if (ability.kind === "slam") return 96;
  if (ability.kind === "dash" || ability.kind === "blink") return 120;
  return 68;
}

function ttlFor(ability) {
  if (ability.kind === "field") return ability.awakened ? 1.05 : 0.8;
  if (ability.kind === "beam") return ability.awakened ? 0.54 : 0.42;
  if (ability.kind === "projectile") return ability.awakened ? 0.65 : 0.5;
  if (ability.kind === "slam" || ability.kind === "heavy") return 0.36;
  return 0.25;
}

function applyStatus(attacker, target, ability, power) {
  if (ability.slow) {
    target.slowTime = Math.max(target.slowTime, 1.5 * power);
    target.slowFactor = Math.min(target.slowFactor, ability.slow);
  }
  if (ability.kind === "field" && ability.id === "null_zone") {
    target.nullTime = Math.max(target.nullTime, 1.8 * power);
    target.cooldowns = Object.fromEntries(Object.entries(target.cooldowns).map(([key, value]) => [key, Math.max(value, 0.35)]));
  }
  if (ability.kind === "chain") target.hitstun += 0.08;
  if (ability.kind === "pull") {
    target.vx += Math.sign(attacker.x - target.x || attacker.facing) * 260 * power;
    target.vy -= 90 * power;
  }
  if (ability.kind === "jump") {
    attacker.vy = -700;
    attacker.jumps = Math.max(attacker.jumps, 1);
  }
}

export function checkRingOut(f, stage) {
  const out = f.x < stage.bounds.left || f.x > stage.bounds.right || f.y < stage.bounds.top || f.y > stage.bounds.bottom;
  if (!out) return false;
  f.stocks -= 1;
  f.damage = 0;
  f.health = f.maxHealth;
  f.vx = 0;
  f.vy = 0;
  f.awakening = Math.min(100, f.awakening + 20);
  f.haki = Math.min(100, f.haki + 15);
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
  if (f.attackFlash > 0) return f.attackKind;
  if (!f.grounded && f.vy < 0) return "jump";
  if (!f.grounded) return "fall";
  if (Math.abs(f.vx) > 220) return "run";
  if (Math.abs(f.vx) > 20) return "walk";
  return "idle";
}

function clamp(value, min, max) {
  return Math.max(min, Math.min(max, value));
}
