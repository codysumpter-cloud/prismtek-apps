const canvas = document.getElementById("game");
const ctx = canvas.getContext("2d");

const ui = {
  round: document.getElementById("round"),
  mode: document.getElementById("mode"),
  cash: document.getElementById("cash"),
  hp: document.getElementById("hp"),
  charge: document.getElementById("charge"),
  panel: document.getElementById("panel"),
  start: document.getElementById("start"),
  pvp: document.getElementById("pvp"),
  parts: document.getElementById("parts"),
  shop: document.getElementById("shop")
};

const SLOT_DEFS = {
  ring: {
    label: "Attack Ring",
    colors: ["#ff4f7b", "#ff8750", "#ffd447", "#f45cff"],
    names: ["Razor", "Comet", "Vandal", "Spark", "Orbit", "Fang", "Meteor", "Flash"],
    stats: { speed: 0.025, mass: 0.012, damage: 0.095, grip: -0.004, charge: 0.004, hp: 0.14, stability: -0.002 }
  },
  core: {
    label: "Weight Core",
    colors: ["#7df9c7", "#6cc4ff", "#bba7ff", "#f6f1de"],
    names: ["Brick", "Anchor", "Titan", "Vault", "Quartz", "Forge", "Metro", "Atlas"],
    stats: { speed: -0.011, mass: 0.052, damage: 0.032, grip: 0.005, charge: -0.002, hp: 0.86, stability: 0.012 }
  },
  driver: {
    label: "Driver Tip",
    colors: ["#54e0ff", "#70ff8d", "#ffe66d", "#ff8df3"],
    names: ["Drift", "Needle", "Skate", "Switch", "Sprint", "Spiral", "Chrome", "Dash"],
    stats: { speed: 0.055, mass: -0.004, damage: 0.016, grip: 0.026, charge: 0.009, hp: 0.12, stability: 0.006 }
  },
  chip: {
    label: "Spirit Chip",
    colors: ["#ef476f", "#8f6bff", "#06d6a0", "#ffd166"],
    names: ["Ghost", "Nova", "Tempo", "Lucky", "Echo", "Royal", "Pulse", "Jinx"],
    stats: { speed: 0.016, mass: 0.006, damage: 0.044, grip: 0.007, charge: 0.019, hp: 0.48, stability: 0.005 }
  }
};

const slots = Object.keys(SLOT_DEFS);
const suffixes = ["I", "II", "III", "IV", "V", "EX", "DX", "GT"];
const rarities = ["Common", "Tuned", "Rare", "Elite"];
const rarityGlow = { Common: "#ffffff", Tuned: "#7df9c7", Rare: "#6cc4ff", Elite: "#ff8df3" };
const rarityScore = { Common: 0, Tuned: 1, Rare: 2, Elite: 3 };
const catalogue = buildCatalogue();
const ARENA = { cx: 480, cy: 270, rx: 408, ry: 206, innerRx: 332, innerRy: 156, rail: 0.93, pocket: 1.03 };
const pointer = { x: ARENA.cx, y: ARENA.cy, down: false };
const keys = new Set();
let keyPressed = new Set();
let state;
let lastTime = 0;

function buildCatalogue() {
  const all = {};
  for (const slot of slots) {
    const def = SLOT_DEFS[slot];
    all[slot] = [];
    for (let i = 0; i < 64; i++) {
      const tier = Math.floor(i / 16);
      const base = def.names[i % def.names.length];
      const suffix = suffixes[Math.floor(i / def.names.length) % suffixes.length];
      const drift = ((i * 17) % 11) - 5;
      const stats = {};
      for (const [key, value] of Object.entries(def.stats)) stats[key] = Number((value * (i + 4) + drift * value * 0.8 + tier * value * 7).toFixed(3));
      stats.hp = Math.round(stats.hp);
      all[slot].push({ id: `${slot}-${i}`, slot, name: `${base} ${suffix}`, rarity: rarities[tier], color: def.colors[i % def.colors.length], cost: 18 + tier * 55 + i * 4, stats, desc: describeStats(stats) });
    }
  }
  return all;
}

function describeStats(stats) {
  const bits = [];
  if (stats.speed) bits.push(`${stats.speed > 0 ? "+" : ""}${stats.speed.toFixed(2)} speed`);
  if (stats.mass) bits.push(`${stats.mass > 0 ? "+" : ""}${stats.mass.toFixed(2)} mass`);
  if (stats.damage) bits.push(`${stats.damage > 0 ? "+" : ""}${stats.damage.toFixed(2)} hit`);
  if (stats.grip) bits.push(`${stats.grip > 0 ? "+" : ""}${stats.grip.toFixed(2)} grip`);
  if (stats.charge) bits.push(`${stats.charge > 0 ? "+" : ""}${stats.charge.toFixed(2)} charge`);
  if (stats.stability) bits.push(`${stats.stability > 0 ? "+" : ""}${stats.stability.toFixed(2)} stability`);
  if (stats.hp) bits.push(`${stats.hp > 0 ? "+" : ""}${stats.hp} HP`);
  return bits.slice(0, 3).join(", ");
}

function freshRun(mode = "cpu") {
  const starter = Object.fromEntries(slots.map(slot => [slot, catalogue[slot][0]]));
  const p2Starter = { ring: catalogue.ring[12], core: catalogue.core[10], driver: catalogue.driver[14], chip: catalogue.chip[11] };
  state = {
    running: true, mode, round: 1, cash: 80, streak: 0,
    equipped: starter, p2Equipped: p2Starter, owned: new Set(Object.values(starter).map(p => p.id)),
    shop: [], pickups: [], sparks: [], shockwaves: [], texts: [], trails: [], skidMarks: [], spiritSurges: [], rivals: [],
    shake: 0, slowmo: 0, flash: 0, message: "Claim the street circuit.",
    player: topEntity(246, 270, "p1"), player2: mode === "pvp" ? topEntity(714, 270, "p2") : null
  };
  if (mode === "pvp") setupPvp(); else spawnRound();
  rollShop();
  updateStats(true, state.player, state.equipped);
  if (state.player2) updateStats(true, state.player2, state.p2Equipped);
  ui.panel.style.display = "none";
  flashMessage(mode === "pvp" ? "Local PvP: out-control the other top." : "CPU Circuit: tune, clash, and survive 12 rounds.");
}

function topEntity(x, y, role, rank = 1) {
  const player = role === "p1" || role === "p2";
  return { x, y, px: x, py: y, vx: 0, vy: 0, r: player ? 23 : 21 + Math.min(8, rank), hp: 100, maxHp: 100, charge: 0, spirit: 0, spin: Math.random() * Math.PI * 2, spinRate: player ? 0.32 : 0.26 + rank * 0.015, tilt: 0, stability: 1, wobble: Math.random() * Math.PI * 2, player, role, rank, color: role === "p2" ? "#ffcf4d" : player ? "#54e0ff" : `hsl(${25 + rank * 38}, 95%, 60%)`, cooldown: 0, moveCd: 0, guard: 0, stagger: 0, invuln: 0, launch: 1 };
}

function equippedStats(loadout = state.equipped) {
  const base = { speed: 1.58, mass: 1, damage: 7.25, grip: 0.982, charge: 0.74, hp: 108, stability: 1, rim: 1, torque: 1 };
  for (const part of Object.values(loadout)) for (const [key, value] of Object.entries(part.stats)) base[key] = (base[key] ?? 0) + value;
  base.speed = clamp(base.speed, 0.95, 3.35);
  base.mass = clamp(base.mass, 0.58, 4.25);
  base.damage = clamp(base.damage, 5.8, 24);
  base.grip = clamp(base.grip, 0.944, 0.994);
  base.charge = clamp(base.charge, 0.42, 2.4);
  base.hp = clamp(base.hp, 80, 240);
  base.stability = clamp(base.stability, 0.48, 2.25);
  base.rim = 0.92 + Math.min(0.16, base.mass * 0.015);
  base.torque = 0.9 + Math.min(0.55, base.speed * 0.14 + base.charge * 0.08);
  return base;
}

function updateStats(heal, top = state.player, loadout = state.equipped) {
  const s = equippedStats(loadout);
  top.maxHp = Math.round(s.hp);
  if (heal) top.hp = top.maxHp;
  top.r = 19 + Math.min(10, s.mass * 3.2);
  top.stability = clamp(top.stability, 0.25, s.stability);
}

function spawnRound() {
  state.rivals = [];
  const count = state.round % 4 === 0 ? 2 : 1;
  for (let i = 0; i < count; i++) {
    const rival = topEntity(690 + i * 62, 226 + i * 88, "cpu", state.round);
    const stats = equippedStats(rivalLoadout(rival.rank));
    rival.maxHp = Math.round(72 + state.round * 18 + i * 20 + stats.hp * 0.28);
    rival.hp = rival.maxHp;
    rival.vx = -2.0 - state.round * 0.08;
    rival.vy = (i ? -1 : 1) * 0.8;
    rival.spinRate = 0.24 + state.round * 0.012;
    state.rivals.push(rival);
  }
  state.pickups = [{ x: 480, y: 145, kind: "cash", ttl: 560 }, { x: 476, y: 392, kind: "repair", ttl: 560 }, { x: 610, y: 270, kind: "overdrive", ttl: 420 }];
}

function setupPvp() {
  state.rivals = [state.player2];
  state.pickups = [];
  state.cash = 0;
  state.message = "Local PvP: read the dome, not just the buttons.";
  state.player.x = 250; state.player.y = 270; state.player.vx = 2.5;
  state.player2.x = 710; state.player2.y = 270; state.player2.vx = -2.5;
}

function rollShop() {
  state.shop = [];
  for (const slot of slots) {
    const start = Math.min(63, state.round * 5 + Math.floor(Math.random() * 10));
    for (let i = 0; i < 2; i++) state.shop.push(catalogue[slot][Math.min(63, start + i * 8)]);
  }
  renderBench();
}

function renderBench() {
  const ownedCount = state.owned.size;
  ui.parts.innerHTML = `<div class="part summary"><strong>${ownedCount}/256 parts owned</strong><small>Builds now affect mass, bite, grip, stability, burst charge, and Spirit Surge uptime.</small></div>${slots.map(slot => { const part = state.equipped[slot]; return `<div class="part equipped" style="border-color:${part.color}"><strong>${SLOT_DEFS[slot].label}</strong><small>${part.name} · ${part.rarity}<br>${part.desc}</small></div>`; }).join("")}`;
  ui.shop.innerHTML = state.shop.map((p, i) => { const owned = state.owned.has(p.id); return `<div class="shop-item" style="border-color:${p.color}"><strong>${p.name} <span>${p.rarity}</span></strong><small>${SLOT_DEFS[p.slot].label} · ${p.desc}</small><button data-buy="${i}">${owned ? "Equip" : `Buy $${p.cost}`}</button></div>`; }).join("");
}

ui.shop.addEventListener("click", event => {
  const btn = event.target.closest("button[data-buy]");
  if (!btn || !state?.running) return;
  const item = state.shop[Number(btn.dataset.buy)];
  if (!state.owned.has(item.id)) {
    if (state.cash < item.cost) return flashMessage("Need more cash.");
    state.cash -= item.cost;
    state.owned.add(item.id);
  }
  state.equipped[item.slot] = item;
  updateStats(false, state.player, state.equipped);
  renderBench();
  flashMessage(`${item.name} equipped.`);
  floatingText("TUNED", state.player.x, state.player.y - 42, item.color);
});

function flashMessage(text) { state.message = text; ui.mode.textContent = text; }

function gameLoop(time) {
  if (!lastTime) lastTime = time;
  const dt = Math.min(2, (time - lastTime) / (1000 / 60));
  lastTime = time;
  update(dt);
  requestAnimationFrame(gameLoop);
}

function update(dt = 1) {
  if (!state?.running) { draw(); keyPressed.clear(); return; }
  const p = state.player;
  const pStats = equippedStats(state.equipped);
  steerPlayer(p, pStats, "p1", dt);
  if (state.mode === "pvp" && state.player2) steerPlayer(state.player2, equippedStats(state.p2Equipped), "p2", dt);
  else state.rivals.forEach((r, i) => steerRival(r, p, i, dt));
  updateSpiritSurges(dt);
  const actors = [p, ...state.rivals].filter(Boolean);
  for (const actor of actors) physics(actor, actorStats(actor), dt);
  for (const rival of state.rivals) resolveTopCollision(p, rival, pStats, actorStats(rival), dt);
  for (let i = 0; i < state.rivals.length; i++) for (let j = i + 1; j < state.rivals.length; j++) resolveTopCollision(state.rivals[i], state.rivals[j], actorStats(state.rivals[i]), actorStats(state.rivals[j]), dt, true);
  if (state.mode !== "pvp") collectPickups();
  state.rivals = state.mode === "pvp" ? state.rivals : state.rivals.filter(r => r.hp > 0);
  state.pickups.forEach(pickup => pickup.ttl -= dt);
  state.pickups = state.pickups.filter(pickup => pickup.ttl > 0);
  state.sparks = state.sparks.filter(sp => (sp.life -= dt) > 0);
  state.shockwaves = state.shockwaves.filter(wave => (wave.life -= dt) > 0);
  state.texts = state.texts.filter(text => (text.life -= dt) > 0);
  state.trails = state.trails.filter(trail => (trail.life -= dt) > 0);
  state.skidMarks = state.skidMarks.filter(mark => (mark.life -= dt) > 0).slice(-80);
  state.shake *= Math.pow(0.84, dt);
  state.slowmo *= Math.pow(0.88, dt);
  state.flash *= Math.pow(0.86, dt);
  if (state.mode === "pvp") {
    if (p.hp <= 0 || state.player2.hp <= 0) endRun(p.hp > state.player2.hp, p.hp > state.player2.hp ? "P1 wins the dome." : "P2 wins the dome.");
  } else {
    if (state.rivals.length === 0) winRound();
    if (p.hp <= 0) endRun(false);
  }
  draw();
  keyPressed.clear();
}

function actorStats(actor) {
  if (actor.role === "p1") return equippedStats(state.equipped);
  if (actor.role === "p2") return equippedStats(state.p2Equipped);
  return equippedStats(rivalLoadout(actor.rank));
}

function steerPlayer(top, stats, scheme, dt) {
  const p2 = scheme === "p2";
  const ax = (keys.has(p2 ? "l" : "arrowright") || (!p2 && keys.has("d")) ? 1 : 0) - (keys.has(p2 ? "j" : "arrowleft") || (!p2 && keys.has("a")) ? 1 : 0);
  const ay = (keys.has(p2 ? "k" : "arrowdown") || (!p2 && keys.has("s")) ? 1 : 0) - (keys.has(p2 ? "i" : "arrowup") || (!p2 && keys.has("w")) ? 1 : 0);
  let dx = p2 ? ax : pointer.x - top.x;
  let dy = p2 ? ay : pointer.y - top.y;
  if (ax || ay) { dx = ax; dy = ay; }
  const len = Math.hypot(dx, dy) || 1;
  const speed = Math.hypot(top.vx, top.vy);
  const traction = clamp(1.25 - speed / 24, 0.36, 1);
  const staggerScale = top.stagger > 0 ? 0.45 : 1;
  top.vx += (dx / len) * stats.speed * stats.torque * 0.24 * top.launch * traction * staggerScale * dt;
  top.vy += (dy / len) * stats.speed * stats.torque * 0.24 * top.launch * traction * staggerScale * dt;
  top.launch = Math.max(1, top.launch * Math.pow(0.992, dt));
  top.moveCd = Math.max(0, top.moveCd - dt);
  top.guard = Math.max(0, top.guard - dt);
  top.stagger = Math.max(0, top.stagger - dt);
  top.invuln = Math.max(0, top.invuln - dt);
  const chargeHeld = p2 ? keys.has("u") : pointer.down || keys.has(" ");
  if (chargeHeld && top.charge < 1) {
    top.charge = Math.min(1, top.charge + (0.012 + stats.charge * 0.012) * dt);
    top.stability = Math.max(0.25, top.stability - 0.0015 * dt);
    if (top.charge > 0.92) createSparkBurst(top.x, top.y, "#f6f1de", 1, 5);
  }
  const moveKey = p2 ? "o" : "shift";
  const surgeKey = p2 ? "p" : "e";
  if (keyPressed.has(moveKey) && top.moveCd <= 0) useBladeMove(top, dx / len, dy / len, stats);
  if (keyPressed.has(surgeKey) && top.spirit >= 100) summonSpiritSurge(top, p2 ? state.p2Equipped : state.equipped);
}

function steerRival(rival, player, index, dt) {
  const dx = player.x - rival.x;
  const dy = player.y - rival.y;
  const distance = Math.hypot(dx, dy) || 1;
  const edge = domeValue(rival.x, rival.y);
  const orbit = Math.sin(performance.now() / (420 - Math.min(230, state.round * 12)) + index * 2.2);
  const bait = distance < 130 ? -0.5 : 1;
  const aggression = 0.07 + state.round * 0.012;
  rival.vx += (dx / distance) * aggression * bait * dt + Math.cos(orbit) * 0.09 * dt;
  rival.vy += (dy / distance) * aggression * bait * dt + Math.sin(orbit) * 0.09 * dt;
  if (edge > 0.82) { rival.vx += (ARENA.cx - rival.x) * 0.0014 * dt; rival.vy += (ARENA.cy - rival.y) * 0.0019 * dt; }
  rival.cooldown -= dt;
  if (rival.cooldown <= 0) {
    if (distance < 210) { rival.charge = Math.min(1, rival.charge + 0.2 + state.round * 0.03); rival.vx += (dx / distance) * (2.2 + state.round * 0.1); rival.vy += (dy / distance) * (2.2 + state.round * 0.1); flashAiIntent(rival, "dash"); }
    else { rival.charge = Math.min(1, rival.charge + 0.16); flashAiIntent(rival, "bait"); }
    rival.cooldown = 82 - Math.min(52, state.round * 3.4);
  }
}

function flashAiIntent(actor, kind) { if (Math.random() <= 0.35) floatingText(kind === "dash" ? "RUSH" : "BAIT", actor.x, actor.y - 35, actor.color, 28); }

function physics(top, stats, dt) {
  top.px = top.x; top.py = top.y;
  const speed = Math.hypot(top.vx, top.vy);
  const wobbleForce = (1 - clamp(top.stability / Math.max(0.5, stats.stability), 0, 1)) * 0.075;
  top.wobble += (0.08 + speed * 0.005) * dt;
  if (wobbleForce > 0.01) { top.vx += Math.cos(top.wobble * 2.1) * wobbleForce * dt; top.vy += Math.sin(top.wobble * 1.7) * wobbleForce * dt; }
  top.x += top.vx * dt; top.y += top.vy * dt;
  const gripLoss = clamp(1 - speed / 68, 0.965, 1);
  const friction = Math.pow(stats.grip * gripLoss, dt);
  top.vx *= friction; top.vy *= friction;
  top.spinRate = clamp(top.spinRate + speed * 0.0025 + top.charge * 0.004 - (1 - stats.grip) * 0.006, 0.05, 0.92);
  top.spin += top.spinRate * dt + speed * 0.011 * dt;
  top.tilt = clamp(top.tilt + (speed * 0.003 - stats.stability * 0.0012) * dt, 0, 1.1);
  if (speed > 1.6) state.trails.push({ x: top.x, y: top.y, px: top.px, py: top.py, color: topColor(top), width: clamp(speed * 0.36, 2, 12), life: 18 });
  if (speed > 7 && Math.random() < 0.12 * dt) state.skidMarks.push({ x: top.x, y: top.y, vx: -top.vx * 0.25, vy: -top.vy * 0.25, life: 180 });
  applyDomePhysics(top, stats, dt);
}

function domeValue(x, y) { return Math.hypot((x - ARENA.cx) / ARENA.rx, (y - ARENA.cy) / ARENA.ry); }

function applyDomePhysics(top, stats, dt) {
  const dx = top.x - ARENA.cx, dy = top.y - ARENA.cy;
  const nx = dx / ARENA.rx, ny = dy / ARENA.ry;
  const dome = Math.hypot(nx, ny) || 0.001;
  const slope = Math.max(0, dome - 0.34);
  const centerPull = 0.018 + slope * slope * 0.052;
  top.vx -= (dx / ARENA.rx) * centerPull * (1.3 - stats.grip) * dt;
  top.vy -= (dy / ARENA.ry) * centerPull * (1.8 - stats.grip) * dt;
  if (dome < ARENA.rail) return;
  const px = nx / dome, py = ny / dome;
  const normalX = px / ARENA.rx, normalY = py / ARENA.ry;
  const normalLen = Math.hypot(normalX, normalY) || 1;
  const ux = normalX / normalLen, uy = normalY / normalLen;
  const tangentX = -uy, tangentY = ux;
  const railDepth = dome - ARENA.rail;
  const towardRail = top.vx * ux + top.vy * uy;
  const tangentialSpeed = top.vx * tangentX + top.vy * tangentY;
  state.skidMarks.push({ x: top.x, y: top.y, vx: tangentX * tangentialSpeed * 0.35, vy: tangentY * tangentialSpeed * 0.35, life: 110 });
  top.vx -= ux * Math.max(0, towardRail) * (1.18 + railDepth * 1.2) * dt;
  top.vy -= uy * Math.max(0, towardRail) * (1.18 + railDepth * 1.2) * dt;
  top.vx += tangentX * tangentialSpeed * 0.012 * (stats.rim - 1) * dt;
  top.vy += tangentY * tangentialSpeed * 0.012 * (stats.rim - 1) * dt;
  top.hp -= (top.player ? 0.035 : 0.075) * (1 + railDepth * 10) * dt;
  top.stability = Math.max(0.2, top.stability - 0.006 * railDepth * dt);
  state.shake = Math.max(state.shake, Math.min(7, railDepth * 36));
  if (dome <= ARENA.pocket) { const clampDome = ARENA.rail + 0.006; top.x = ARENA.cx + px * ARENA.rx * clampDome; top.y = ARENA.cy + py * ARENA.ry * clampDome; if (Math.random() < 0.2 * dt) createSparkBurst(top.x, top.y, "#ffd34e", 3, 5); return; }
  top.x = ARENA.cx + px * ARENA.rx * ARENA.pocket; top.y = ARENA.cy + py * ARENA.ry * ARENA.pocket;
  top.vx -= ux * towardRail * 1.7; top.vy -= uy * towardRail * 1.7; top.vx *= 0.86; top.vy *= 0.86; top.hp -= 4.5;
  createImpact(top.x, top.y, "#ffd34e", 18, 12); floatingText("RAIL CRASH", top.x, top.y - 28, "#ffd34e");
}

function resolveTopCollision(a, b, aStats, bStats, dt, npcOnly = false) {
  if (!a || !b || a.hp <= 0 || b.hp <= 0) return;
  const dx = b.x - a.x, dy = b.y - a.y;
  const distance = Math.hypot(dx, dy) || 0.001;
  const min = a.r + b.r;
  if (distance >= min) return;
  const nx = dx / distance, ny = dy / distance;
  const overlap = min - distance;
  const invA = 1 / Math.max(0.35, aStats.mass), invB = 1 / Math.max(0.35, bStats.mass), invTotal = invA + invB;
  a.x -= nx * overlap * (invA / invTotal) * 0.95; a.y -= ny * overlap * (invA / invTotal) * 0.95;
  b.x += nx * overlap * (invB / invTotal) * 0.95; b.y += ny * overlap * (invB / invTotal) * 0.95;
  const rvx = b.vx - a.vx, rvy = b.vy - a.vy;
  const normalSpeed = rvx * nx + rvy * ny;
  const tangentialSpeed = rvx * -ny + rvy * nx;
  const closing = Math.max(0, -normalSpeed);
  const absoluteSpeed = Math.hypot(rvx, rvy);
  const aBurst = a.charge > 0.18 ? 1 + a.charge * 2.35 : 1;
  const bBurst = b.charge > 0.18 ? 1 + b.charge * 2.0 : 1;
  const burst = Math.max(aBurst, bBurst);
  const guardA = a.guard > 0 ? 0.48 : 1, guardB = b.guard > 0 ? 0.48 : 1;
  const bite = 1 + Math.min(0.85, Math.abs(tangentialSpeed) * 0.035);
  const impulse = ((1.62 + Math.min(0.2, aStats.grip + bStats.grip - 1.92)) * (closing + absoluteSpeed * 0.32) * burst) / invTotal;
  a.vx -= nx * impulse * invA; a.vy -= ny * impulse * invA; b.vx += nx * impulse * invB; b.vy += ny * impulse * invB;
  const chipA = Math.max(0.04, (absoluteSpeed * 0.018 + bStats.damage * 0.026) * guardA * bite);
  const chipB = Math.max(0.04, (absoluteSpeed * 0.018 + aStats.damage * 0.034) * guardB * bite * burst);
  a.hp -= chipA; b.hp -= chipB;
  a.stability = Math.max(0.15, a.stability - chipA * 0.006); b.stability = Math.max(0.15, b.stability - chipB * 0.006);
  a.stagger = Math.max(a.stagger, chipA * 0.08); b.stagger = Math.max(b.stagger, chipB * 0.08);
  const impactX = (a.x + b.x) / 2, impactY = (a.y + b.y) / 2;
  const perfectBurst = !npcOnly && (a.charge > 0.82 || b.charge > 0.82) && absoluteSpeed > 4.8;
  const color = perfectBurst ? "#ffffff" : aBurst >= bBurst ? topColor(a) : topColor(b);
  if (a.charge > 0.18 || b.charge > 0.18) { a.charge = Math.max(0, a.charge - 0.84); b.charge = Math.max(0, b.charge - 0.84); state.slowmo = perfectBurst ? 1.4 : 0.55; flashMessage(perfectBurst ? "Perfect burst!" : "Burst clash!"); floatingText(perfectBurst ? "PERFECT" : "BURST", impactX, impactY - 34, color); }
  a.spirit = Math.min(100, a.spirit + (chipB + absoluteSpeed) * 0.38);
  b.spirit = Math.min(100, b.spirit + (chipA + absoluteSpeed) * 0.32);
  state.shake = Math.min(18, Math.max(state.shake, absoluteSpeed * 0.9 + burst * 2));
  createImpact(impactX, impactY, color, perfectBurst ? 34 : 18, perfectBurst ? 24 : 14);
}

function useBladeMove(top, dx, dy, stats) {
  const speed = Math.hypot(top.vx, top.vy);
  if (speed > 6.2 || top.charge > 0.7) { top.guard = 38; top.moveCd = 62; top.stability = Math.min(stats.stability, top.stability + 0.16); top.vx *= 0.86; top.vy *= 0.86; flashMessage(`${top.role === "p2" ? "P2" : "P1"} counter guard.`); createImpact(top.x, top.y, "#6cc4ff", 14, 14); floatingText("GUARD", top.x, top.y - 38, "#6cc4ff"); return; }
  top.vx += dx * (7.4 + stats.speed * 2.6); top.vy += dy * (7.4 + stats.speed * 2.6); top.charge = Math.min(1, top.charge + 0.28); top.stability = Math.max(0.25, top.stability - 0.06); top.moveCd = 74; flashMessage(`${top.role === "p2" ? "P2" : "P1"} strike dash.`); createImpact(top.x, top.y, "#ffffff", 20, 18); floatingText("DASH", top.x, top.y - 38, "#ffffff");
}

function summonSpiritSurge(top, loadout) {
  const names = ["Astral Lynx", "Chrome Wyvern", "Vault Turtle", "Pulse Raven", "Comet Wolf", "Neon Kirin"];
  const chip = partIndex(loadout.chip);
  const surge = { owner: top, x: top.x, y: top.y, r: 42 + rarityScore[loadout.chip.rarity] * 4, ttl: 170, color: loadout.chip.color, name: names[chip % names.length], angle: 0, pulse: 0 };
  top.spirit = 0; top.charge = Math.min(1, top.charge + 0.42); top.stability = Math.min(actorStats(top).stability, top.stability + 0.25);
  state.spiritSurges.push(surge); flashMessage(`${top.role === "p2" ? "P2" : "P1"} triggers Spirit Surge: ${surge.name}.`); createImpact(top.x, top.y, loadout.chip.color, 42, 32);
}

function updateSpiritSurges(dt) {
  for (const surge of state.spiritSurges) {
    surge.ttl -= dt; surge.angle += 0.12 * dt; surge.pulse += 0.08 * dt; surge.x = surge.owner.x + Math.cos(surge.angle) * 66; surge.y = surge.owner.y + Math.sin(surge.angle * 1.35) * 43;
    for (const target of [state.player, ...state.rivals]) {
      if (!target || target === surge.owner || target.hp <= 0) continue;
      const dx = target.x - surge.x, dy = target.y - surge.y, d = Math.hypot(dx, dy) || 1;
      if (d < surge.r + target.r) { target.hp -= 0.62 * dt; target.vx += (dx / d) * 0.46 * dt; target.vy += (dy / d) * 0.46 * dt; target.stability = Math.max(0.18, target.stability - 0.008 * dt); if (Math.random() < 0.2 * dt) createSparkBurst(target.x, target.y, surge.color, 2, 6); }
    }
  }
  state.spiritSurges = state.spiritSurges.filter(surge => surge.ttl > 0);
}

function createImpact(x, y, color, count = 12, radius = 10) { state.shockwaves.push({ x, y, color, radius, max: radius * 3.2, life: 22 }); createSparkBurst(x, y, color, count, radius); }
function createSparkBurst(x, y, color, count, force) { for (let i = 0; i < count; i++) { const angle = Math.random() * Math.PI * 2; const speed = (0.6 + Math.random()) * force; state.sparks.push({ x, y, vx: Math.cos(angle) * speed, vy: Math.sin(angle) * speed, color, life: 16 + Math.random() * 18, size: 2 + Math.random() * 4 }); } }
function floatingText(text, x, y, color, life = 42) { state.texts.push({ text, x, y, vy: -0.45, color, life, maxLife: life }); }

function collectPickups() {
  const p = state.player;
  for (const pickup of state.pickups) {
    if (Math.hypot(p.x - pickup.x, p.y - pickup.y) < p.r + 17) {
      if (pickup.kind === "cash") { state.cash += 18 + state.round * 4; flashMessage("Cash pickup."); }
      if (pickup.kind === "repair") { p.hp = Math.min(p.maxHp, p.hp + 24); p.stability = Math.min(actorStats(p).stability, p.stability + 0.18); flashMessage("Quick repair."); }
      if (pickup.kind === "overdrive") { p.charge = Math.min(1, p.charge + 0.38); p.spirit = Math.min(100, p.spirit + 16); flashMessage("Overdrive pickup."); }
      pickup.ttl = 0; createImpact(pickup.x, pickup.y, pickup.kind === "cash" ? "#ffd34e" : pickup.kind === "repair" ? "#70ff8d" : "#8f6bff", 18, 13);
    }
  }
}

function winRound() { state.streak++; state.cash += 35 + state.round * 18 + state.streak * 6; if (state.round >= 12) return endRun(true); state.round++; updateStats(false); state.player.hp = Math.min(state.player.maxHp, state.player.hp + 30); Object.assign(state.player, { x: 240, y: 270, vx: 0, vy: 0, charge: 0, guard: 0, stagger: 0 }); state.player.stability = Math.min(actorStats(state.player).stability, state.player.stability + 0.35); spawnRound(); rollShop(); flashMessage("Round clear. Shop refreshed."); }

function endRun(won, message) { state.running = false; const title = state.mode === "pvp" ? "Match Decided" : won ? "Dome Champion" : "Top Busted"; ui.panel.innerHTML = `<h1>${title}</h1><p>${message || (won ? `You cleared 12 rounds with ${state.owned.size} parts owned.` : `You reached round ${state.round}. Win by reading mass, spin, rim angle, bursts, guards, and Spirit Surge timing.`)}</p><div class="panel-actions"><button id="again">CPU Circuit</button><button id="again-pvp">Local PvP</button></div>`; ui.panel.style.display = "grid"; document.getElementById("again").onclick = () => freshRun("cpu"); document.getElementById("again-pvp").onclick = () => freshRun("pvp"); }

function draw() {
  if (!state) return;
  ctx.save();
  const shake = state.shake * (state.slowmo > 0.08 ? 0.45 : 1);
  ctx.translate((Math.random() - 0.5) * shake, (Math.random() - 0.5) * shake);
  drawDomeArena(); drawTrails(); state.skidMarks.forEach(drawSkidMark); state.pickups.forEach(drawPickup); state.spiritSurges.forEach(drawSpiritSurge); state.rivals.forEach(drawPremiumTop); drawPremiumTop(state.player); drawParticles(); state.shockwaves.forEach(drawShockwave); drawBars(); drawFloatingText();
  if (state.flash > 0.02) { ctx.fillStyle = `rgba(255,255,255,${state.flash * 0.18})`; ctx.fillRect(0, 0, canvas.width, canvas.height); }
  ctx.restore();
  ui.round.textContent = state.mode === "pvp" ? "Local PvP" : `Round ${state.round}/12`;
  ui.cash.textContent = `$${state.cash}`;
  ui.hp.textContent = Math.max(0, Math.ceil(state.player.hp));
  ui.charge.textContent = `${Math.round(state.player.charge * 100)}%`;
}

function drawDomeArena() {
  ctx.fillStyle = "#0c0c16"; ctx.fillRect(0, 0, 960, 540);
  const outerGlow = ctx.createRadialGradient(ARENA.cx, ARENA.cy, 20, ARENA.cx, ARENA.cy, ARENA.rx * 1.2);
  outerGlow.addColorStop(0, "#606ea7"); outerGlow.addColorStop(0.42, "#323a66"); outerGlow.addColorStop(0.78, "#181d3d"); outerGlow.addColorStop(1, "#070812");
  ctx.fillStyle = outerGlow; ctx.beginPath(); ctx.ellipse(ARENA.cx, ARENA.cy, ARENA.rx + 38, ARENA.ry + 30, 0, 0, Math.PI * 2); ctx.fill();
  const floor = ctx.createRadialGradient(ARENA.cx - 90, ARENA.cy - 70, 10, ARENA.cx, ARENA.cy, ARENA.rx);
  floor.addColorStop(0, "#7381bd"); floor.addColorStop(0.35, "#4b568e"); floor.addColorStop(0.68, "#28305f"); floor.addColorStop(1, "#111425");
  ctx.fillStyle = floor; ctx.beginPath(); ctx.ellipse(ARENA.cx, ARENA.cy, ARENA.rx, ARENA.ry, 0, 0, Math.PI * 2); ctx.fill();
  ctx.save(); ctx.beginPath(); ctx.ellipse(ARENA.cx, ARENA.cy, ARENA.rx - 6, ARENA.ry - 6, 0, 0, Math.PI * 2); ctx.clip();
  for (let r = 0; r < 9; r++) { ctx.strokeStyle = r % 2 ? "#91a0f044" : "#f6f1de22"; ctx.lineWidth = r === 0 ? 3 : 2; ctx.beginPath(); ctx.ellipse(ARENA.cx, ARENA.cy, ARENA.innerRx - r * 34, ARENA.innerRy - r * 17, 0, 0, Math.PI * 2); ctx.stroke(); }
  for (let a = 0; a < Math.PI * 2; a += Math.PI / 18) { const pulse = 0.45 + Math.sin(performance.now() / 380 + a * 4) * 0.2; ctx.strokeStyle = `rgba(246,241,222,${0.08 + pulse * 0.04})`; ctx.lineWidth = 1; ctx.beginPath(); ctx.moveTo(ARENA.cx, ARENA.cy); ctx.lineTo(ARENA.cx + Math.cos(a) * ARENA.rx, ARENA.cy + Math.sin(a) * ARENA.ry); ctx.stroke(); }
  ctx.fillStyle = "#ffffff14"; ctx.beginPath(); ctx.ellipse(ARENA.cx - 110, ARENA.cy - 75, ARENA.rx * 0.44, ARENA.ry * 0.19, -0.08, 0, Math.PI * 2); ctx.fill(); ctx.restore();
  const rim = ctx.createLinearGradient(ARENA.cx, ARENA.cy - ARENA.ry, ARENA.cx, ARENA.cy + ARENA.ry);
  rim.addColorStop(0, "#fff8d4"); rim.addColorStop(0.28, "#aab7ff"); rim.addColorStop(0.62, "#4a5078"); rim.addColorStop(1, "#07070d"); ctx.strokeStyle = rim; ctx.lineWidth = 24; ctx.beginPath(); ctx.ellipse(ARENA.cx, ARENA.cy, ARENA.rx + 8, ARENA.ry + 8, 0, 0, Math.PI * 2); ctx.stroke();
  ctx.strokeStyle = "#ef476f"; ctx.lineWidth = 4; ctx.beginPath(); ctx.ellipse(ARENA.cx, ARENA.cy, ARENA.rx * ARENA.rail, ARENA.ry * ARENA.rail, 0, 0, Math.PI * 2); ctx.stroke();
  ctx.strokeStyle = "#54e0ff88"; ctx.lineWidth = 2; ctx.beginPath(); ctx.ellipse(ARENA.cx, ARENA.cy, ARENA.rx * 0.28, ARENA.ry * 0.28, 0, 0, Math.PI * 2); ctx.stroke();
}

function drawPremiumTop(top) {
  const loadout = top.role === "p2" ? state.p2Equipped : top.player ? state.equipped : rivalLoadout(top.rank);
  const ring = loadout.ring.color, core = loadout.core.color, driver = loadout.driver.color, chip = loadout.chip.color;
  const elite = loadout.ring.rarity === "Elite" || loadout.chip.rarity === "Elite";
  const toothCount = 8 + (partIndex(loadout.ring) % 5) * 2, bladeLength = 8 + (partIndex(loadout.ring) % 4) * 3, coreSides = 5 + (partIndex(loadout.core) % 4), driverFins = 3 + (partIndex(loadout.driver) % 4), chipMark = partIndex(loadout.chip) % 6;
  const wobble = (1 - clamp(top.stability / Math.max(0.5, actorStats(top).stability), 0, 1)) * Math.sin(top.wobble) * 0.18;
  const tiltScale = 1 - Math.min(0.18, top.tilt * 0.08);
  ctx.save(); ctx.translate(top.x, top.y); ctx.scale(1 + wobble, tiltScale); ctx.rotate(top.spin);
  ctx.globalAlpha = 0.28; ctx.fillStyle = "#000"; ctx.beginPath(); ctx.ellipse(7, 11, top.r + 11, top.r * 0.72 + 7, 0, 0, Math.PI * 2); ctx.fill(); ctx.globalAlpha = 1;
  const glow = rarityGlow[loadout.chip.rarity] || "#ffffff"; ctx.shadowColor = glow; ctx.shadowBlur = elite ? 26 : 12;
  for (let i = 0; i < toothCount; i++) { ctx.save(); ctx.rotate((Math.PI * 2 * i) / toothCount); ctx.fillStyle = i % 2 ? darken(ring, 0.28) : ring; ctx.beginPath(); ctx.moveTo(top.r - 3, -5); ctx.lineTo(top.r + bladeLength, 0); ctx.lineTo(top.r - 2, 5); ctx.closePath(); ctx.fill(); ctx.strokeStyle = "#05050a"; ctx.lineWidth = 1.5; ctx.stroke(); ctx.restore(); }
  ctx.shadowBlur = 0;
  const rim = ctx.createRadialGradient(-5, -6, top.r * 0.12, 0, 0, top.r + 4); rim.addColorStop(0, lighten(ring, 0.34)); rim.addColorStop(0.52, ring); rim.addColorStop(0.76, darken(ring, 0.28)); rim.addColorStop(1, "#05050a"); ctx.fillStyle = rim; ctx.beginPath(); ctx.arc(0, 0, top.r + 2, 0, Math.PI * 2); ctx.fill();
  ctx.save(); ctx.globalCompositeOperation = "multiply"; ctx.fillStyle = "#0006"; for (let i = 0; i < toothCount / 2; i++) { ctx.save(); ctx.rotate((Math.PI * 2 * i) / (toothCount / 2)); ctx.fillRect(-2, -top.r - 1, 4, top.r * 2 + 2); ctx.restore(); } ctx.restore();
  ctx.strokeStyle = "#f6f1de99"; ctx.lineWidth = 2; ctx.beginPath(); ctx.arc(0, 0, top.r - 5, 0, Math.PI * 2); ctx.stroke();
  drawPolygon(0, 0, top.r * 0.62, coreSides, core, darken(core, 0.42), top.spin * 0.2);
  ctx.strokeStyle = "#05050a"; ctx.lineWidth = 2; for (let i = 0; i < coreSides; i++) { ctx.save(); ctx.rotate((Math.PI * 2 * i) / coreSides); ctx.beginPath(); ctx.moveTo(0, 0); ctx.lineTo(top.r * 0.55, 0); ctx.stroke(); ctx.restore(); }
  ctx.strokeStyle = driver; ctx.lineWidth = 3; for (let i = 0; i < driverFins; i++) { ctx.save(); ctx.rotate((Math.PI * 2 * i) / driverFins + Math.PI / 8); ctx.beginPath(); ctx.moveTo(4, 0); ctx.quadraticCurveTo(top.r * 0.33, -8, top.r * 0.57, -1); ctx.stroke(); ctx.restore(); }
  const gem = ctx.createRadialGradient(-3, -4, 1, 0, 0, top.r * 0.3); gem.addColorStop(0, "#ffffff"); gem.addColorStop(0.34, chip); gem.addColorStop(1, darken(chip, 0.52)); ctx.fillStyle = gem; ctx.beginPath(); ctx.arc(0, 0, top.r * 0.3, 0, Math.PI * 2); ctx.fill();
  ctx.font = `${Math.max(8, top.r * 0.34)}px Arial`; ctx.textAlign = "center"; ctx.textBaseline = "middle"; ctx.fillStyle = "#111"; ctx.fillText(["X", "V", "Z", "N", "R", "*"][chipMark], 0, 1);
  if (top.guard > 0) { ctx.globalAlpha = 0.8; ctx.strokeStyle = "#6cc4ff"; ctx.lineWidth = 3; ctx.beginPath(); ctx.arc(0, 0, top.r + 11 + Math.sin(performance.now() / 70) * 2, 0, Math.PI * 2); ctx.stroke(); ctx.globalAlpha = 1; }
  if (top.charge > 0.65) { ctx.globalAlpha = top.charge * 0.65; ctx.strokeStyle = "#ffd34e"; ctx.lineWidth = 2; ctx.beginPath(); ctx.arc(0, 0, top.r + 8 + Math.sin(performance.now() / 80) * 3, 0, Math.PI * 2); ctx.stroke(); ctx.globalAlpha = 1; }
  ctx.restore();
}

function drawSpiritSurge(surge) { ctx.save(); ctx.translate(surge.x, surge.y); const alpha = Math.min(0.86, surge.ttl / 45); ctx.globalAlpha = alpha; ctx.strokeStyle = surge.color; ctx.fillStyle = `${surge.color}2c`; ctx.lineWidth = 4; ctx.beginPath(); ctx.arc(0, 0, surge.r + Math.sin(surge.pulse) * 4, 0, Math.PI * 2); ctx.fill(); ctx.stroke(); ctx.rotate(surge.angle); ctx.fillStyle = surge.color; ctx.beginPath(); ctx.moveTo(0, -surge.r); ctx.lineTo(14, -10); ctx.lineTo(surge.r, 0); ctx.lineTo(10, 12); ctx.lineTo(0, surge.r); ctx.lineTo(-10, 12); ctx.lineTo(-surge.r, 0); ctx.lineTo(-14, -10); ctx.closePath(); ctx.fill(); ctx.fillStyle = "#ffffff"; ctx.fillRect(-12, -8, 7, 7); ctx.fillRect(5, -8, 7, 7); ctx.restore(); }
function drawTrails() { for (const trail of state.trails) { ctx.save(); ctx.globalAlpha = Math.min(0.42, trail.life / 24); ctx.strokeStyle = trail.color; ctx.lineWidth = trail.width; ctx.lineCap = "round"; ctx.beginPath(); ctx.moveTo(trail.px, trail.py); ctx.lineTo(trail.x, trail.y); ctx.stroke(); ctx.restore(); } }
function drawSkidMark(mark) { ctx.save(); ctx.globalAlpha = Math.min(0.22, mark.life / 220); ctx.strokeStyle = "#05050a"; ctx.lineWidth = 2; ctx.beginPath(); ctx.moveTo(mark.x, mark.y); ctx.lineTo(mark.x + mark.vx, mark.y + mark.vy); ctx.stroke(); ctx.restore(); }
function drawParticles() { for (const sp of state.sparks) { sp.x += sp.vx; sp.y += sp.vy; sp.vx *= 0.94; sp.vy *= 0.94; ctx.save(); ctx.globalAlpha = Math.min(1, sp.life / 16); ctx.fillStyle = sp.color; ctx.fillRect(sp.x, sp.y, sp.size, sp.size); ctx.restore(); } }
function drawShockwave(wave) { const progress = 1 - wave.life / 22; ctx.save(); ctx.globalAlpha = Math.max(0, 1 - progress); ctx.strokeStyle = wave.color; ctx.lineWidth = 3; ctx.beginPath(); ctx.arc(wave.x, wave.y, wave.radius + (wave.max - wave.radius) * progress, 0, Math.PI * 2); ctx.stroke(); ctx.restore(); }
function drawFloatingText() { ctx.save(); ctx.textAlign = "center"; ctx.textBaseline = "middle"; ctx.font = "800 18px system-ui, sans-serif"; for (const text of state.texts) { text.y += text.vy; ctx.globalAlpha = Math.min(1, text.life / 18); ctx.fillStyle = "#05050a"; ctx.fillText(text.text, text.x + 2, text.y + 2); ctx.fillStyle = text.color; ctx.fillText(text.text, text.x, text.y); } ctx.restore(); }

function drawBars() {
  drawHudBar(58, 58, 190, 18, state.player.hp / state.player.maxHp, "#55e6a5", "P1 HP");
  drawHudBar(58, 82, 190, 7, state.player.charge, "#ffd34e", "Burst");
  drawHudBar(58, 94, 190, 6, state.player.spirit / 100, "#8f6bff", "Spirit");
  drawHudBar(58, 106, 190, 5, state.player.stability / actorStats(state.player).stability, "#54e0ff", "Stability");
  state.rivals.forEach((r, i) => drawHudBar(710, 58 + i * 24, 190, 16, r.hp / r.maxHp, r.color, r.role === "p2" ? "P2 HP" : "Rival"));
  if (state.mode === "pvp" && state.player2) { drawHudBar(710, 82, 190, 7, state.player2.charge, "#ffd34e", "P2 Burst"); drawHudBar(710, 94, 190, 6, state.player2.spirit / 100, "#8f6bff", "P2 Spirit"); drawHudBar(710, 106, 190, 5, state.player2.stability / actorStats(state.player2).stability, "#54e0ff", "P2 Stability"); }
}
function drawHudBar(x, y, w, h, pct, color, label) { ctx.fillStyle = "#140d16"; ctx.fillRect(x, y, w, h); ctx.fillStyle = color; ctx.fillRect(x, y, w * clamp(pct, 0, 1), h); ctx.strokeStyle = "#f6f1de"; ctx.lineWidth = 1.5; ctx.strokeRect(x, y, w, h); if (h >= 12) { ctx.fillStyle = "#f6f1de"; ctx.font = "700 10px system-ui, sans-serif"; ctx.fillText(label, x + 6, y + h - 4); } }
function drawPickup(pickup) { ctx.save(); ctx.translate(pickup.x, pickup.y); ctx.rotate(performance.now() / 260); const color = pickup.kind === "cash" ? "#ffd34e" : pickup.kind === "repair" ? "#70ff8d" : "#8f6bff"; ctx.shadowColor = color; ctx.shadowBlur = 16; ctx.fillStyle = color; ctx.fillRect(-10, -10, 20, 20); ctx.shadowBlur = 0; ctx.fillStyle = "#111"; ctx.fillRect(-4, -4, 8, 8); ctx.restore(); }
function rivalLoadout(rank) { return { ring: catalogue.ring[Math.min(63, rank * 4)], core: catalogue.core[Math.min(63, rank * 3 + 5)], driver: catalogue.driver[Math.min(63, rank * 2 + 7)], chip: catalogue.chip[Math.min(63, rank * 5 + 2)] }; }
function partIndex(part) { return Number(part.id.split("-")[1]) || 0; }
function topColor(top) { if (top.role === "p1") return state.equipped.ring.color; if (top.role === "p2") return state.p2Equipped.ring.color; return top.color; }
function drawPolygon(x, y, radius, sides, fill, stroke, rotation = 0) { ctx.save(); ctx.translate(x, y); ctx.rotate(rotation); ctx.fillStyle = fill; ctx.strokeStyle = stroke; ctx.lineWidth = 3; ctx.beginPath(); for (let i = 0; i < sides; i++) { const angle = -Math.PI / 2 + (Math.PI * 2 * i) / sides; const px = Math.cos(angle) * radius, py = Math.sin(angle) * radius; if (i === 0) ctx.moveTo(px, py); else ctx.lineTo(px, py); } ctx.closePath(); ctx.fill(); ctx.stroke(); ctx.restore(); }
function lighten(hex, amount) { return shade(hex, Math.abs(amount)); }
function darken(hex, amount) { return shade(hex, -Math.abs(amount)); }
function shade(hex, amount) { const raw = hex.replace("#", ""); const full = raw.length === 3 ? raw.split("").map(c => c + c).join("") : raw; const n = parseInt(full, 16); const r = clamp((n >> 16) + amount * 255, 0, 255); const g = clamp(((n >> 8) & 255) + amount * 255, 0, 255); const b = clamp((n & 255) + amount * 255, 0, 255); return `rgb(${r | 0}, ${g | 0}, ${b | 0})`; }
function clamp(value, min, max) { return Math.max(min, Math.min(max, value)); }

canvas.addEventListener("pointermove", event => { const rect = canvas.getBoundingClientRect(); pointer.x = (event.clientX - rect.left) * canvas.width / rect.width; pointer.y = (event.clientY - rect.top) * canvas.height / rect.height; });
canvas.addEventListener("pointerdown", event => { pointer.down = true; canvas.setPointerCapture?.(event.pointerId); });
canvas.addEventListener("pointerup", event => { pointer.down = false; canvas.releasePointerCapture?.(event.pointerId); });
canvas.addEventListener("pointercancel", () => { pointer.down = false; });
addEventListener("keydown", event => { const key = event.key === "Shift" ? "shift" : event.key.toLowerCase(); if ([" ", "arrowup", "arrowdown", "arrowleft", "arrowright"].includes(key)) event.preventDefault(); keys.add(key); keyPressed.add(key); });
addEventListener("keyup", event => { keys.delete(event.key === "Shift" ? "shift" : event.key.toLowerCase()); });
ui.start.onclick = () => freshRun("cpu");
ui.pvp.onclick = () => freshRun("pvp");
freshRun("cpu");
requestAnimationFrame(gameLoop);
