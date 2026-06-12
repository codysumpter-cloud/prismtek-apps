import { GAME } from '../systems/config.js';
import { applyHit, fighterRect, integratePlayer } from './physics.js';
import { rectsOverlap } from '../stages/stageRegistry.js';

export function createMatch(profile, fruits, stage, localPlayers = 2) {
  const slots = Array.from({ length: GAME.maxPlayers }, (_, index) => {
    const spawn = stage.spawns[index];
    const fruit = fruits[index % fruits.length];
    const isHuman = index < localPlayers;
    return {
      slot: index + 1,
      name: isHuman && index === 0 ? profile.name : isHuman ? `Player ${index + 1}` : `CPU ${index + 1}`,
      appearance: index === 0 ? { ...profile.appearance } : cpuAppearance(index),
      fruitId: index === 0 ? profile.equipped_fruit : fruit.id,
      x: spawn.x,
      y: spawn.y,
      vx: 0,
      vy: 0,
      facing: index % 2 === 0 ? 1 : -1,
      damage: 0,
      stocks: GAME.stockCount,
      jumpsLeft: 2,
      hitstun: 0,
      respawn: 0,
      cooldowns: [0, 0, 0],
      awakening: 0,
      awakeningTime: 0,
      isCPU: !isHuman,
      grounded: false,
      status: 'Ready',
    };
  });
  return { players: slots, effects: [], stage, time: GAME.matchSeconds, results: null };
}

export function stepMatch(match, fruits, input, dt) {
  match.time = Math.max(0, match.time - dt);
  tickEffects(match, dt);
  runCpu(match, fruits, dt);
  for (const player of match.players) {
    const command = input[player.slot] ?? {};
    applyCommand(match, fruits, player, command, dt);
    integratePlayer(player, match.stage, dt);
    player.awakening = Math.min(100, player.awakening + dt * 1.5);
  }
  const alive = match.players.filter((player) => player.stocks > 0);
  if (match.time <= 0 || alive.length <= 1) match.results = [...match.players].sort(scoreSort);
}

export function applyCommand(match, fruits, player, command) {
  if (player.stocks <= 0 || player.respawn > 0 || player.hitstun > 0) return;
  const speed = player.awakeningTime > 0 ? 7.5 : 6.2;
  if (command.left) {
    player.vx = -speed;
    player.facing = -1;
  }
  if (command.right) {
    player.vx = speed;
    player.facing = 1;
  }
  if (command.jump && player.jumpsLeft > 0) {
    player.vy = player.jumpsLeft === 2 ? -15 : -13;
    player.jumpsLeft -= 1;
    player.status = 'Jump';
  }
  if (command.dodge) {
    player.vx = -player.facing * 12;
    player.hitstun = 0;
    player.status = 'Dodge';
  }
  if (command.attack) spawnHit(match, player, { name: 'Basic', type: 'reach', damage: 6, knockback: 12, cooldown: 0.18 }, 0);
  if (command.special1) useSpecial(match, fruits, player, 0);
  if (command.special2) useSpecial(match, fruits, player, 1);
  if (command.special3) useSpecial(match, fruits, player, 2);
  if (command.awaken && player.awakening >= 100) {
    player.awakening = 0;
    player.awakeningTime = 8;
    player.status = 'Awakened';
  }
}

function useSpecial(match, fruits, player, slot) {
  const fruit = fruits.find((item) => item.id === player.fruitId) ?? fruits[0];
  const ability = fruit.abilities[slot];
  if (!ability || player.cooldowns[slot] > 0) return;
  player.cooldowns[slot] = ability.cooldown;
  player.status = ability.name;
  if (ability.type === 'dash') player.vx = player.facing * 18;
  if (ability.type === 'blink') player.x += player.facing * 95;
  if (ability.type === 'jump') player.vy = -20;
  if (ability.type === 'floatHeavy') player.vy = -8;
  spawnHit(match, player, ability, slot + 1);
}

function spawnHit(match, player, ability, slot) {
  const size = hitSize(ability.type);
  const reach = ability.type === 'projectile' || ability.type === 'beam' ? 70 : 42;
  const effect = {
    id: crypto.randomUUID?.() ?? `${Date.now()}-${Math.random()}`,
    owner: player.slot,
    slot,
    type: ability.type,
    name: ability.name,
    damage: ability.damage,
    knockback: ability.knockback,
    status: ability.status,
    color: player.awakeningTime > 0 ? '#ffffff' : null,
    x: player.x + player.facing * reach,
    y: player.y - 34,
    vx: projectileSpeed(ability.type) * player.facing,
    vy: ability.type === 'uppercut' ? -4 : ability.type === 'slam' ? 5 : 0,
    width: size.width,
    height: size.height,
    ttl: ability.type === 'projectile' ? 0.65 : ability.type === 'field' || ability.type === 'pull' || ability.type === 'null' ? 0.85 : 0.22,
  };
  match.effects.push(effect);
}

function tickEffects(match, dt) {
  for (const effect of match.effects) {
    effect.ttl -= dt;
    effect.x += effect.vx;
    effect.y += effect.vy;
    const box = { x: effect.x - effect.width / 2, y: effect.y - effect.height / 2, width: effect.width, height: effect.height };
    const source = match.players.find((player) => player.slot === effect.owner);
    for (const target of match.players) {
      if (!source || target.slot === source.slot || target.stocks <= 0 || target.respawn > 0) continue;
      if (!rectsOverlap(box, fighterRect(target))) continue;
      if (effect.type === 'pull') {
        target.vx += target.x > source.x ? -4 : 4;
        target.vy -= 1;
        continue;
      }
      if (effect.type === 'null') {
        target.vx = 0;
        target.vy = 0;
        target.hitstun = Math.max(target.hitstun, 0.2);
        continue;
      }
      applyHit(target, source, effect, dt * 6);
    }
  }
  match.effects = match.effects.filter((effect) => effect.ttl > 0);
}

function runCpu(match, fruits, dt) {
  for (const cpu of match.players.filter((player) => player.isCPU && player.stocks > 0)) {
    cpu.aiClock = (cpu.aiClock ?? 0) - dt;
    if (cpu.aiClock > 0) continue;
    cpu.aiClock = 0.35;
    const target = match.players.find((player) => !player.isCPU && player.stocks > 0) ?? match.players.find((player) => player.slot !== cpu.slot && player.stocks > 0);
    if (!target) continue;
    const close = Math.abs(target.x - cpu.x) < 130;
    applyCommand(match, fruits, cpu, {
      left: target.x < cpu.x,
      right: target.x > cpu.x,
      jump: Math.random() < 0.05,
      attack: close && Math.random() < 0.35,
      special1: close && Math.random() < 0.16,
      special2: close && Math.random() < 0.09,
      special3: close && Math.random() < 0.07,
      awaken: cpu.awakening >= 100,
    });
  }
}

function hitSize(type) {
  const sizes = {
    projectile: { width: 34, height: 24 },
    beam: { width: 170, height: 18 },
    field: { width: 150, height: 55 },
    pull: { width: 170, height: 115 },
    null: { width: 130, height: 88 },
    reach: { width: 135, height: 30 },
    heavy: { width: 120, height: 85 },
    uppercut: { width: 70, height: 95 },
    slam: { width: 110, height: 120 },
    burst: { width: 110, height: 90 },
    blink: { width: 80, height: 80 },
    jump: { width: 75, height: 45 },
    floatHeavy: { width: 115, height: 75 },
    dash: { width: 92, height: 42 },
  };
  return sizes[type] ?? { width: 70, height: 42 };
}

function projectileSpeed(type) {
  return type === 'projectile' ? 13 : 0;
}

function scoreSort(a, b) {
  if (b.stocks !== a.stocks) return b.stocks - a.stocks;
  return a.damage - b.damage;
}

function cpuAppearance(index) {
  const presets = ['#68e8ff', '#ff72c7', '#7c4dff', '#ffe34d'];
  return {
    hairStyle: 'tuft',
    hairColor: presets[index % presets.length],
    skinTone: '#c68642',
    outfitPrimary: presets[(index + 1) % presets.length],
    outfitSecondary: '#202030',
    accessoryColor: '#ffffff',
  };
}
