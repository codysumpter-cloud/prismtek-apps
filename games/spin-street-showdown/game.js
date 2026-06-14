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
    stats: { speed: 0.03, mass: 0.01, damage: 0.08, grip: -0.005, charge: 0.004, hp: 0.1 }
  },
  core: {
    label: "Weight Core",
    colors: ["#7df9c7", "#6cc4ff", "#bba7ff", "#f6f1de"],
    names: ["Brick", "Anchor", "Titan", "Vault", "Quartz", "Forge", "Metro", "Atlas"],
    stats: { speed: -0.012, mass: 0.045, damage: 0.035, grip: 0.006, charge: -0.002, hp: 0.8 }
  },
  driver: {
    label: "Driver Tip",
    colors: ["#54e0ff", "#70ff8d", "#ffe66d", "#ff8df3"],
    names: ["Drift", "Needle", "Skate", "Switch", "Sprint", "Spiral", "Chrome", "Dash"],
    stats: { speed: 0.05, mass: -0.004, damage: 0.018, grip: 0.02, charge: 0.008, hp: 0.15 }
  },
  chip: {
    label: "Spirit Chip",
    colors: ["#ef476f", "#8f6bff", "#06d6a0", "#ffd166"],
    names: ["Ghost", "Nova", "Tempo", "Lucky", "Echo", "Royal", "Pulse", "Jinx"],
    stats: { speed: 0.018, mass: 0.006, damage: 0.04, grip: 0.008, charge: 0.018, hp: 0.45 }
  }
};
const slots = Object.keys(SLOT_DEFS);
const suffixes = ["I", "II", "III", "IV", "V", "EX", "DX", "GT"];
const rarities = ["Common", "Tuned", "Rare", "Elite"];
const rarityGlow = {
  Common: "#ffffff",
  Tuned: "#7df9c7",
  Rare: "#6cc4ff",
  Elite: "#ff8df3"
};
const catalogue = buildCatalogue();
const ARENA = {
  cx: 480,
  cy: 270,
  rx: 408,
  ry: 206,
  innerRx: 332,
  innerRy: 156
};
const pointer = { x: 480, y: 270, down: false };
const keys = new Set();
let state;
let keyPressed = new Set();

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
      for (const [key, value] of Object.entries(def.stats)) {
        stats[key] = Number((value * (i + 4) + drift * value * 0.9 + tier * value * 8).toFixed(3));
      }
      stats.hp = Math.round(stats.hp);
      all[slot].push({
        id: `${slot}-${i}`,
        slot,
        name: `${base} ${suffix}`,
        rarity: rarities[tier],
        color: def.colors[i % def.colors.length],
        cost: 18 + tier * 55 + i * 4,
        stats,
        desc: describeStats(stats)
      });
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
  if (stats.hp) bits.push(`${stats.hp > 0 ? "+" : ""}${stats.hp} HP`);
  return bits.slice(0, 3).join(", ");
}

function freshRun(mode = "cpu") {
  const starter = Object.fromEntries(slots.map(slot => [slot, catalogue[slot][0]]));
  const p2Starter = {
    ring: catalogue.ring[12],
    core: catalogue.core[10],
    driver: catalogue.driver[14],
    chip: catalogue.chip[11]
  };
  state = {
    running: true,
    mode,
    round: 1,
    cash: 80,
    streak: 0,
    equipped: starter,
    p2Equipped: p2Starter,
    owned: new Set(Object.values(starter).map(p => p.id)),
    shop: [],
    pickups: [],
    sparks: [],
    beasts: [],
    rivals: [],
    shake: 0,
    slowmo: 0,
    message: "Claim the street circuit.",
    player: topEntity(240, 270, "p1"),
    player2: mode === "pvp" ? topEntity(720, 270, "p2") : null
  };
  if (mode === "pvp") setupPvp();
  else spawnRound();
  rollShop();
  updateStats(true, state.player, state.equipped);
  if (state.player2) updateStats(true, state.player2, state.p2Equipped);
  ui.panel.style.display = "none";
}

function topEntity(x, y, role, rank = 1) {
  const player = role === "p1" || role === "p2";
  return {
    x, y, vx: 0, vy: 0, r: player ? 23 : 21 + rank,
    hp: 100, maxHp: 100, charge: 0, beast: 0, spin: 0, player, role, rank,
    color: role === "p2" ? "#ffcf4d" : player ? "#54e0ff" : `hsl(${25 + rank * 38}, 95%, 60%)`,
    cooldown: 0,
    moveCd: 0,
    guard: 0,
    launch: 1
  };
}

function equippedStats(loadout = state.equipped) {
  const base = { speed: 1.68, mass: 1, damage: 7.5, grip: 0.982, charge: 0.75, hp: 108 };
  for (const part of Object.values(loadout)) {
    for (const [key, value] of Object.entries(part.stats)) base[key] += value;
  }
  base.speed = Math.max(1.05, base.speed);
  base.mass = Math.max(0.55, base.mass);
  base.grip = Math.min(0.993, Math.max(0.948, base.grip));
  base.charge = Math.max(0.42, base.charge);
  return base;
}

function updateStats(heal, top = state.player, loadout = state.equipped) {
  const s = equippedStats(loadout);
  top.maxHp = Math.round(s.hp);
  if (heal) top.hp = top.maxHp;
  top.r = 20 + Math.min(8, s.mass * 3);
}

function spawnRound() {
  state.rivals = [];
  const count = state.round % 4 === 0 ? 2 : 1;
  for (let i = 0; i < count; i++) {
    const rival = topEntity(680 + i * 70, 220 + i * 95, "cpu", state.round);
    rival.maxHp = 72 + state.round * 18 + i * 20;
    rival.hp = rival.maxHp;
    rival.vx = -1.5 - state.round * 0.08;
    state.rivals.push(rival);
  }
  state.pickups = [
    { x: 480, y: 150, kind: "cash", ttl: 560 },
    { x: 475, y: 392, kind: "repair", ttl: 560 }
  ];
}

function setupPvp() {
  state.rivals = [state.player2];
  state.pickups = [];
  state.cash = 0;
  state.message = "Local PvP: best blade wins.";
  state.player.x = 250; state.player.y = 270;
  state.player2.x = 710; state.player2.y = 270;
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
  ui.parts.innerHTML = `
    <div class="part summary"><strong>${ownedCount}/256 parts owned</strong><small>64 original parts in each slot.</small></div>
    ${slots.map(slot => {
      const part = state.equipped[slot];
      return `<div class="part equipped" style="border-color:${part.color}">
        <strong>${SLOT_DEFS[slot].label}</strong>
        <small>${part.name} · ${part.rarity}<br>${part.desc}</small>
      </div>`;
    }).join("")}`;
  ui.shop.innerHTML = state.shop.map((p, i) => {
    const owned = state.owned.has(p.id);
    return `<div class="shop-item" style="border-color:${p.color}">
      <strong>${p.name} <span>${p.rarity}</span></strong>
      <small>${SLOT_DEFS[p.slot].label} · ${p.desc}</small>
      <button data-buy="${i}">${owned ? "Equip" : `Buy $${p.cost}`}</button>
    </div>`;
  }).join("");
}

ui.shop.addEventListener("click", e => {
  const btn = e.target.closest("button[data-buy]");
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
});

function flashMessage(text) {
  state.message = text;
  ui.mode.textContent = text;
}

function update() {
  if (!state?.running) return draw();
  const p = state.player;
  const s = equippedStats(state.equipped);
  steerPlayer(p, s, "p1");
  if (p.charge > 0.96) pulse(p.x, p.y, "#f6f1de", 18);
  if (state.mode === "pvp" && state.player2) {
    steerPlayer(state.player2, equippedStats(state.p2Equipped), "p2");
  } else {
    state.rivals.forEach((r, i) => steerRival(r, p, i));
  }
  updateBeasts();
  [p, ...state.rivals].forEach(physics);
  state.rivals.forEach(r => collide(p, r, s, equippedStats(r.role === "p2" ? state.p2Equipped : rivalLoadout(r.rank))));
  for (let i = 0; i < state.rivals.length; i++) {
    for (let j = i + 1; j < state.rivals.length; j++) collideNpc(state.rivals[i], state.rivals[j]);
  }
  if (state.mode !== "pvp") collectPickups();
  state.rivals = state.mode === "pvp" ? state.rivals : state.rivals.filter(r => r.hp > 0);
  state.pickups.forEach(pu => pu.ttl--);
  state.pickups = state.pickups.filter(pu => pu.ttl > 0);
  state.sparks = state.sparks.filter(sp => --sp.life > 0);
  state.shake *= 0.86;
  state.slowmo *= 0.9;
  if (state.mode === "pvp") {
    if (p.hp <= 0 || state.player2.hp <= 0) endRun(p.hp > state.player2.hp, p.hp > state.player2.hp ? "P1 wins the dome." : "P2 wins the dome.");
  } else {
    if (state.rivals.length === 0) winRound();
    if (p.hp <= 0) endRun(false);
  }
  draw();
  keyPressed.clear();
}

function steerPlayer(p, s, scheme) {
  const p2 = scheme === "p2";
  const ax = (keys.has(p2 ? "l" : "arrowright") || (!p2 && keys.has("d")) ? 1 : 0) - (keys.has(p2 ? "j" : "arrowleft") || (!p2 && keys.has("a")) ? 1 : 0);
  const ay = (keys.has(p2 ? "k" : "arrowdown") || (!p2 && keys.has("s")) ? 1 : 0) - (keys.has(p2 ? "i" : "arrowup") || (!p2 && keys.has("w")) ? 1 : 0);
  let dx = p2 ? ax : pointer.x - p.x;
  let dy = p2 ? ay : pointer.y - p.y;
  if (ax || ay) { dx = ax; dy = ay; }
  const len = Math.hypot(dx, dy) || 1;
  p.vx += (dx / len) * s.speed * 0.2 * p.launch;
  p.vy += (dy / len) * s.speed * 0.2 * p.launch;
  p.launch = Math.max(1, p.launch * 0.992);
  if ((p2 ? keys.has("u") : pointer.down || keys.has(" ")) && p.charge < 1) p.charge = Math.min(1, p.charge + 0.012 + s.charge * 0.012);
  p.moveCd = Math.max(0, p.moveCd - 1);
  p.guard = Math.max(0, p.guard - 1);
  const moveKey = p2 ? "o" : "shift";
  const beastKey = p2 ? "p" : "e";
  if (keyPressed.has(moveKey) && p.moveCd <= 0) useBladeMove(p, dx / len, dy / len, s);
  if (keyPressed.has(beastKey) && p.beast >= 100) summonBitBeast(p, p2 ? state.p2Equipped : state.equipped);
}

function steerRival(r, p, i) {
  const dx = p.x - r.x;
  const dy = p.y - r.y;
  const d = Math.hypot(dx, dy) || 1;
  const orbit = Math.sin(Date.now() / (460 - Math.min(220, state.round * 12)) + i * 2.2);
  const aggression = 0.095 + state.round * 0.012;
  r.vx += (dx / d) * aggression + Math.cos(orbit) * 0.07;
  r.vy += (dy / d) * aggression + Math.sin(orbit) * 0.07;
  if (r.cooldown-- <= 0 && d < 180) {
    r.vx += (dx / d) * (2 + state.round * 0.08);
    r.vy += (dy / d) * (2 + state.round * 0.08);
    r.cooldown = 120 - Math.min(65, state.round * 4);
  }
}

function physics(o) {
  o.x += o.vx;
  o.y += o.vy;
  const grip = o.player ? equippedStats().grip : 0.976 - Math.min(0.018, state.round * 0.001);
  o.vx *= grip;
  o.vy *= grip;
  o.spin += Math.hypot(o.vx, o.vy) * 0.055 + (o.charge || 0) * 0.04;
  applyDomePhysics(o);
}

function applyDomePhysics(o) {
  const dx = o.x - ARENA.cx;
  const dy = o.y - ARENA.cy;
  const nx = dx / ARENA.rx;
  const ny = dy / ARENA.ry;
  const dome = Math.hypot(nx, ny) || 0.001;
  const slope = Math.max(0, dome - 0.48);
  o.vx -= (dx / ARENA.rx) * slope * 0.026;
  o.vy -= (dy / ARENA.ry) * slope * 0.046;
  if (dome <= 1) return;

  const px = nx / dome;
  const py = ny / dome;
  o.x = ARENA.cx + px * ARENA.rx;
  o.y = ARENA.cy + py * ARENA.ry;
  const normalX = px / ARENA.rx;
  const normalY = py / ARENA.ry;
  const normalLen = Math.hypot(normalX, normalY) || 1;
  const ux = normalX / normalLen;
  const uy = normalY / normalLen;
  const dot = o.vx * ux + o.vy * uy;
  o.vx -= dot * ux * 1.72;
  o.vy -= dot * uy * 1.72;
  o.vx *= 0.92;
  o.vy *= 0.92;
  o.hp -= o.player ? 0.08 : 0.22;
  pulse(o.x, o.y, "#ffd34e", 8);
}

function collide(a, b, s, bStats = { mass: 1, damage: 7.5 }) {
  const dx = b.x - a.x;
  const dy = b.y - a.y;
  const d = Math.hypot(dx, dy);
  const min = a.r + b.r;
  if (d >= min) return;
  const nx = dx / (d || 1);
  const ny = dy / (d || 1);
  const overlap = min - d;
  a.x -= nx * overlap * 0.48; a.y -= ny * overlap * 0.48;
  b.x += nx * overlap * 0.52; b.y += ny * overlap * 0.52;
  const speed = Math.hypot(a.vx - b.vx, a.vy - b.vy);
  const perfectBurst = a.charge > 0.82 && speed > 2.4;
  const burst = a.charge > 0.2 ? 1 + a.charge * 2.2 : 1;
  const guarded = b.guard > 0 ? 0.42 : 1;
  const hit = (speed + s.damage) * burst;
  b.hp -= hit * 0.2 * guarded;
  a.hp -= Math.max(0.06, (speed * 0.026 + (b.rank || 1) * 0.015) * (a.guard > 0 ? 0.45 : 1));
  a.beast = Math.min(100, a.beast + hit * 0.55);
  b.beast = Math.min(100, b.beast + (speed + bStats.damage) * 0.26);
  a.vx -= nx * (1.1 + s.mass) * burst;
  a.vy -= ny * (1.1 + s.mass) * burst;
  b.vx += nx * (2.0 + s.mass * 1.15) * burst;
  b.vy += ny * (2.0 + s.mass * 1.15) * burst;
  if (a.charge > 0.2) {
    a.charge = 0;
    state.slowmo = perfectBurst ? 1 : 0.4;
    flashMessage(perfectBurst ? "Perfect burst!" : "Burst hit!");
  }
  state.shake = Math.min(15, hit * 0.13);
  pulse((a.x + b.x) / 2, (a.y + b.y) / 2, perfectBurst ? "#ffffff" : "#ffd34e", perfectBurst ? 22 : 12);
}

function useBladeMove(p, dx, dy, s) {
  const speed = Math.hypot(p.vx, p.vy);
  if (speed > 5.5) {
    p.guard = 34;
    p.moveCd = 78;
    flashMessage(`${p.role === "p2" ? "P2" : "P1"} guard break stance.`);
    pulse(p.x, p.y, "#6cc4ff", 18);
    return;
  }
  p.vx += dx * (7.2 + s.speed * 2.2);
  p.vy += dy * (7.2 + s.speed * 2.2);
  p.charge = Math.min(1, p.charge + 0.24);
  p.moveCd = 92;
  flashMessage(`${p.role === "p2" ? "P2" : "P1"} strike dash!`);
  pulse(p.x, p.y, "#ffffff", 24);
}

function summonBitBeast(p, loadout) {
  const beastNames = ["Dragoon", "Dranzer", "Draciel", "Driger", "Wolborg", "Trypio"];
  const chip = partIndex(loadout.chip);
  const beast = {
    owner: p,
    x: p.x,
    y: p.y,
    r: 40,
    ttl: 120,
    color: loadout.chip.color,
    name: beastNames[chip % beastNames.length],
    angle: 0
  };
  p.beast = 0;
  p.charge = Math.min(1, p.charge + 0.35);
  state.beasts.push(beast);
  flashMessage(`${p.role === "p2" ? "P2" : "P1"} calls ${beast.name}!`);
  pulse(p.x, p.y, loadout.chip.color, 36);
}

function updateBeasts() {
  for (const beast of state.beasts) {
    beast.ttl--;
    beast.angle += 0.16;
    beast.x = beast.owner.x + Math.cos(beast.angle) * 62;
    beast.y = beast.owner.y + Math.sin(beast.angle * 1.4) * 42;
    for (const target of [state.player, ...state.rivals]) {
      if (!target || target === beast.owner || target.hp <= 0) continue;
      const dx = target.x - beast.x;
      const dy = target.y - beast.y;
      const d = Math.hypot(dx, dy) || 1;
      if (d < beast.r + target.r) {
        target.hp -= 0.5;
        target.vx += (dx / d) * 0.35;
        target.vy += (dy / d) * 0.35;
      }
    }
  }
  state.beasts = state.beasts.filter(beast => beast.ttl > 0);
}

function collideNpc(a, b) {
  const dx = b.x - a.x;
  const dy = b.y - a.y;
  const d = Math.hypot(dx, dy);
  if (d > a.r + b.r) return;
  const nx = dx / (d || 1), ny = dy / (d || 1);
  a.vx -= nx; a.vy -= ny; b.vx += nx; b.vy += ny;
  a.hp -= 0.2; b.hp -= 0.2;
}

function pulse(x, y, color, count) {
  for (let i = 0; i < count; i++) {
    state.sparks.push({ x, y, vx: (Math.random() - 0.5) * 7, vy: (Math.random() - 0.5) * 7, color, life: 16 + Math.random() * 12 });
  }
}

function collectPickups() {
  const p = state.player;
  for (const pu of state.pickups) {
    if (Math.hypot(p.x - pu.x, p.y - pu.y) < p.r + 16) {
      if (pu.kind === "cash") { state.cash += 18 + state.round * 4; flashMessage("Cash pickup!"); }
      if (pu.kind === "repair") { p.hp = Math.min(p.maxHp, p.hp + 22); flashMessage("Quick repair!"); }
      pu.ttl = 0;
      pulse(pu.x, pu.y, pu.kind === "cash" ? "#ffd34e" : "#70ff8d", 16);
    }
  }
}

function winRound() {
  state.streak++;
  state.cash += 35 + state.round * 18 + state.streak * 6;
  if (state.round >= 12) return endRun(true);
  state.round++;
  updateStats(false);
  state.player.hp = Math.min(state.player.maxHp, state.player.hp + 28);
  state.player.x = 240; state.player.y = 270; state.player.vx = 0; state.player.vy = 0; state.player.charge = 0;
  spawnRound();
  rollShop();
  flashMessage("Round clear. Shop refreshed.");
}

function endRun(won, message) {
  state.running = false;
  const title = state.mode === "pvp" ? "Match Decided" : won ? "Dome Champion" : "Top Busted";
  ui.panel.innerHTML = `<h1>${title}</h1><p>${message || (won ? `You cleared 12 rounds with ${state.owned.size} parts owned.` : `You reached round ${state.round}. Win with moves, bursts, and Bit Beasts.`)}</p><div class="panel-actions"><button id="again">CPU Circuit</button><button id="again-pvp">Local PvP</button></div>`;
  ui.panel.style.display = "grid";
  document.getElementById("again").onclick = () => freshRun("cpu");
  document.getElementById("again-pvp").onclick = () => freshRun("pvp");
}

function drawTop(o) {
  const loadout = o.role === "p2" ? state.p2Equipped : o.player ? state.equipped : rivalLoadout(o.rank);
  const ring = loadout.ring.color;
  const core = loadout.core.color;
  const driver = loadout.driver.color;
  const chip = loadout.chip.color;
  const elite = loadout.ring.rarity === "Elite" || loadout.chip.rarity === "Elite";
  const toothCount = 8 + (partIndex(loadout.ring) % 5) * 2;
  const bladeLength = 8 + (partIndex(loadout.ring) % 4) * 3;
  const coreSides = 5 + (partIndex(loadout.core) % 4);
  const driverFins = 3 + (partIndex(loadout.driver) % 4);
  const chipMark = partIndex(loadout.chip) % 6;
  ctx.save();
  ctx.translate(o.x, o.y);
  ctx.rotate(o.spin);
  ctx.shadowColor = rarityGlow[loadout.chip.rarity] || "#ffffff";
  ctx.shadowBlur = elite ? 24 : 10;
  ctx.fillStyle = "#05050a";
  ctx.beginPath();
  ctx.arc(5, 7, o.r + 6, 0, Math.PI * 2);
  ctx.fill();

  ctx.shadowBlur = 0;
  for (let i = 0; i < toothCount; i++) {
    ctx.save();
    ctx.rotate((Math.PI * 2 * i) / toothCount);
    ctx.fillStyle = i % 2 ? darken(ring, 0.28) : ring;
    ctx.beginPath();
    ctx.moveTo(o.r - 2, -4);
    ctx.lineTo(o.r + bladeLength, 0);
    ctx.lineTo(o.r - 2, 4);
    ctx.closePath();
    ctx.fill();
    ctx.restore();
  }
  for (let i = 0; i < toothCount; i++) {
    ctx.save();
    ctx.rotate((Math.PI * 2 * (i + 0.5)) / toothCount);
    ctx.fillStyle = "#f6f1decc";
    ctx.fillRect(o.r * 0.72, -1, bladeLength * 0.65, 2);
    ctx.restore();
  }

  const rim = ctx.createRadialGradient(0, 0, o.r * 0.2, 0, 0, o.r + 2);
  rim.addColorStop(0, lighten(ring, 0.3));
  rim.addColorStop(0.58, ring);
  rim.addColorStop(1, darken(ring, 0.42));
  ctx.fillStyle = rim;
  ctx.beginPath();
  ctx.arc(0, 0, o.r + 1, 0, Math.PI * 2);
  ctx.fill();

  ctx.globalCompositeOperation = "multiply";
  ctx.fillStyle = "#0007";
  for (let i = 0; i < toothCount / 2; i++) {
    ctx.save();
    ctx.rotate((Math.PI * 2 * i) / (toothCount / 2));
    ctx.fillRect(-2, -o.r, 4, o.r * 2);
    ctx.restore();
  }
  ctx.globalCompositeOperation = "source-over";

  ctx.strokeStyle = "#f6f1de88";
  ctx.lineWidth = 2;
  ctx.beginPath();
  ctx.arc(0, 0, o.r - 5, 0, Math.PI * 2);
  ctx.stroke();

  drawPolygon(0, 0, o.r * 0.62, coreSides, core, darken(core, 0.42), o.spin * 0.2);
  ctx.strokeStyle = "#05050a";
  ctx.lineWidth = 2;
  for (let i = 0; i < coreSides; i++) {
    ctx.save();
    ctx.rotate((Math.PI * 2 * i) / coreSides);
    ctx.beginPath();
    ctx.moveTo(0, 0);
    ctx.lineTo(o.r * 0.55, 0);
    ctx.stroke();
    ctx.restore();
  }

  ctx.strokeStyle = driver;
  ctx.lineWidth = 3;
  for (let i = 0; i < driverFins; i++) {
    ctx.save();
    ctx.rotate((Math.PI * 2 * i) / driverFins + Math.PI / 8);
    ctx.beginPath();
    ctx.moveTo(4, 0);
    ctx.quadraticCurveTo(o.r * 0.33, -8, o.r * 0.55, -1);
    ctx.stroke();
    ctx.restore();
  }

  const gem = ctx.createRadialGradient(-3, -4, 1, 0, 0, o.r * 0.28);
  gem.addColorStop(0, "#ffffff");
  gem.addColorStop(0.35, chip);
  gem.addColorStop(1, darken(chip, 0.5));
  ctx.fillStyle = gem;
  ctx.beginPath();
  ctx.arc(0, 0, o.r * 0.28, 0, Math.PI * 2);
  ctx.fill();

  ctx.fillStyle = ring;
  ctx.font = `${Math.max(8, o.r * 0.34)}px Arial`;
  ctx.textAlign = "center";
  ctx.textBaseline = "middle";
  ctx.fillStyle = "#111";
  ctx.fillText(["X", "V", "Z", "N", "R", "*"][chipMark], 0, 1);

  ctx.globalAlpha = 0.8;
  ctx.strokeStyle = rarityGlow[loadout.ring.rarity] || "#fff";
  ctx.lineWidth = 1;
  ctx.beginPath();
  ctx.arc(0, 0, o.r + 4 + Math.sin(Date.now() / 90) * 1.5, 0, Math.PI * 2);
  ctx.stroke();
  ctx.globalAlpha = 1;
  ctx.restore();

  drawTrail(o, driver);
}

function drawBeast(beast) {
  ctx.save();
  ctx.translate(beast.x, beast.y);
  ctx.globalAlpha = Math.min(0.9, beast.ttl / 35);
  ctx.strokeStyle = beast.color;
  ctx.fillStyle = `${beast.color}33`;
  ctx.lineWidth = 4;
  ctx.beginPath();
  ctx.arc(0, 0, beast.r, 0, Math.PI * 2);
  ctx.fill();
  ctx.stroke();
  ctx.rotate(beast.angle);
  ctx.fillStyle = beast.color;
  ctx.beginPath();
  ctx.moveTo(0, -beast.r);
  ctx.lineTo(14, -10);
  ctx.lineTo(beast.r, 0);
  ctx.lineTo(10, 12);
  ctx.lineTo(0, beast.r);
  ctx.lineTo(-10, 12);
  ctx.lineTo(-beast.r, 0);
  ctx.lineTo(-14, -10);
  ctx.closePath();
  ctx.fill();
  ctx.fillStyle = "#ffffff";
  ctx.fillRect(-12, -8, 7, 7);
  ctx.fillRect(5, -8, 7, 7);
  ctx.restore();
}

function rivalLoadout(rank) {
  return {
    ring: catalogue.ring[Math.min(63, rank * 4)],
    core: catalogue.core[Math.min(63, rank * 3 + 5)],
    driver: catalogue.driver[Math.min(63, rank * 2 + 7)],
    chip: catalogue.chip[Math.min(63, rank * 5 + 2)]
  };
}

function partIndex(part) {
  return Number(part.id.split("-")[1]) || 0;
}

function drawPolygon(x, y, radius, sides, fill, stroke, rotation) {
  ctx.save();
  ctx.translate(x, y);
  ctx.rotate(rotation);
  ctx.fillStyle = fill;
  ctx.strokeStyle = stroke;
  ctx.lineWidth = 3;
  ctx.beginPath();
  for (let i = 0; i < sides; i++) {
    const angle = -Math.PI / 2 + (Math.PI * 2 * i) / sides;
    const px = Math.cos(angle) * radius;
    const py = Math.sin(angle) * radius;
    if (i === 0) ctx.moveTo(px, py);
    else ctx.lineTo(px, py);
  }
  ctx.closePath();
  ctx.fill();
  ctx.stroke();
  ctx.restore();
}

function drawTrail(o, color) {
  const speed = Math.hypot(o.vx, o.vy);
  if (speed < 1.2) return;
  ctx.save();
  ctx.globalAlpha = Math.min(0.45, speed / 18);
  ctx.strokeStyle = color;
  ctx.lineWidth = Math.min(12, 3 + speed * 0.5);
  ctx.beginPath();
  ctx.moveTo(o.x - o.vx * 1.5, o.y - o.vy * 1.5);
  ctx.lineTo(o.x - o.vx * 5, o.y - o.vy * 5);
  ctx.stroke();
  ctx.restore();
}

function lighten(hex, amount) {
  return shade(hex, Math.abs(amount));
}

function darken(hex, amount) {
  return shade(hex, -Math.abs(amount));
}

function shade(hex, amount) {
  const raw = hex.replace("#", "");
  const full = raw.length === 3 ? raw.split("").map(c => c + c).join("") : raw;
  const n = parseInt(full, 16);
  const r = Math.max(0, Math.min(255, (n >> 16) + amount * 255));
  const g = Math.max(0, Math.min(255, ((n >> 8) & 255) + amount * 255));
  const b = Math.max(0, Math.min(255, (n & 255) + amount * 255));
  return `rgb(${r | 0}, ${g | 0}, ${b | 0})`;
}

function draw() {
  ctx.save();
  ctx.translate((Math.random() - 0.5) * state.shake, (Math.random() - 0.5) * state.shake);
  drawDomeArena();
  drawBars();
  state.pickups.forEach(drawPickup);
  state.rivals.forEach(drawTop);
  drawTop(state.player);
  state.beasts.forEach(drawBeast);
  state.sparks.forEach(sp => {
    sp.x += sp.vx; sp.y += sp.vy; sp.vx *= 0.95; sp.vy *= 0.95;
    ctx.fillStyle = sp.color;
    ctx.fillRect(sp.x, sp.y, 4, 4);
  });
  ctx.restore();
  ui.round.textContent = `Round ${state.round}/12`;
  if (state.mode === "pvp") ui.round.textContent = "Local PvP";
  ui.cash.textContent = `$${state.cash}`;
  ui.hp.textContent = Math.max(0, Math.ceil(state.player.hp));
  ui.charge.textContent = `${Math.round(state.player.charge * 100)}%`;
}

function drawDomeArena() {
  ctx.fillStyle = "#151522";
  ctx.fillRect(0, 0, 960, 540);
  const floor = ctx.createRadialGradient(ARENA.cx, ARENA.cy, 20, ARENA.cx, ARENA.cy, ARENA.rx);
  floor.addColorStop(0, "#4f5a8c");
  floor.addColorStop(0.48, "#353d69");
  floor.addColorStop(0.82, "#22284c");
  floor.addColorStop(1, "#111425");
  ctx.fillStyle = floor;
  ctx.beginPath();
  ctx.ellipse(ARENA.cx, ARENA.cy, ARENA.rx, ARENA.ry, 0, 0, Math.PI * 2);
  ctx.fill();

  ctx.save();
  ctx.beginPath();
  ctx.ellipse(ARENA.cx, ARENA.cy, ARENA.rx - 5, ARENA.ry - 5, 0, 0, Math.PI * 2);
  ctx.clip();
  for (let r = 0; r < 7; r++) {
    ctx.strokeStyle = r % 2 ? "#7d8ad044" : "#f6f1de22";
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.ellipse(ARENA.cx, ARENA.cy, ARENA.innerRx - r * 42, ARENA.innerRy - r * 20, 0, 0, Math.PI * 2);
    ctx.stroke();
  }
  for (let a = 0; a < Math.PI * 2; a += Math.PI / 12) {
    ctx.strokeStyle = "#f6f1de18";
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(ARENA.cx, ARENA.cy);
    ctx.lineTo(ARENA.cx + Math.cos(a) * ARENA.rx, ARENA.cy + Math.sin(a) * ARENA.ry);
    ctx.stroke();
  }
  ctx.restore();

  const rim = ctx.createLinearGradient(ARENA.cx, ARENA.cy - ARENA.ry, ARENA.cx, ARENA.cy + ARENA.ry);
  rim.addColorStop(0, "#f6f1de");
  rim.addColorStop(0.38, "#8d95c8");
  rim.addColorStop(0.68, "#343852");
  rim.addColorStop(1, "#0a0b12");
  ctx.strokeStyle = rim;
  ctx.lineWidth = 20;
  ctx.beginPath();
  ctx.ellipse(ARENA.cx, ARENA.cy, ARENA.rx + 7, ARENA.ry + 7, 0, 0, Math.PI * 2);
  ctx.stroke();
  ctx.strokeStyle = "#ef476f";
  ctx.lineWidth = 4;
  ctx.beginPath();
  ctx.ellipse(ARENA.cx, ARENA.cy, ARENA.rx - 22, ARENA.ry - 18, 0, 0, Math.PI * 2);
  ctx.stroke();
  ctx.fillStyle = "#ffffff18";
  ctx.beginPath();
  ctx.ellipse(ARENA.cx - 110, ARENA.cy - 75, ARENA.rx * 0.42, ARENA.ry * 0.18, -0.08, 0, Math.PI * 2);
  ctx.fill();
}

function drawBars() {
  const p = state.player;
  ctx.fillStyle = "#140d16"; ctx.fillRect(58, 58, 190, 18);
  ctx.fillStyle = "#55e6a5"; ctx.fillRect(58, 58, 190 * Math.max(0, p.hp / p.maxHp), 18);
  ctx.strokeStyle = "#f6f1de"; ctx.lineWidth = 2; ctx.strokeRect(58, 58, 190, 18);
  state.rivals.forEach((r, i) => {
    ctx.fillStyle = "#140d16"; ctx.fillRect(710, 58 + i * 24, 190, 16);
    ctx.fillStyle = r.color; ctx.fillRect(710, 58 + i * 24, 190 * Math.max(0, r.hp / r.maxHp), 16);
    ctx.strokeStyle = "#f6f1de"; ctx.strokeRect(710, 58 + i * 24, 190, 16);
  });
  ctx.fillStyle = "#ffd34e";
  ctx.fillRect(58, 82, 190 * state.player.charge, 7);
  ctx.fillStyle = "#8f6bff";
  ctx.fillRect(58, 92, 190 * (state.player.beast / 100), 6);
  if (state.mode === "pvp" && state.player2) {
    ctx.fillStyle = "#140d16"; ctx.fillRect(710, 82, 190, 18);
    ctx.fillStyle = "#55e6a5"; ctx.fillRect(710, 82, 190 * Math.max(0, state.player2.hp / state.player2.maxHp), 18);
    ctx.strokeStyle = "#f6f1de"; ctx.strokeRect(710, 82, 190, 18);
    ctx.fillStyle = "#ffd34e"; ctx.fillRect(710, 106, 190 * state.player2.charge, 7);
    ctx.fillStyle = "#8f6bff"; ctx.fillRect(710, 116, 190 * (state.player2.beast / 100), 6);
  }
}

function drawPickup(pu) {
  ctx.save();
  ctx.translate(pu.x, pu.y);
  ctx.rotate(Date.now() / 260);
  ctx.fillStyle = pu.kind === "cash" ? "#ffd34e" : "#70ff8d";
  ctx.fillRect(-10, -10, 20, 20);
  ctx.fillStyle = "#111";
  ctx.fillRect(-4, -4, 8, 8);
  ctx.restore();
}

canvas.addEventListener("pointermove", e => {
  const r = canvas.getBoundingClientRect();
  pointer.x = (e.clientX - r.left) * canvas.width / r.width;
  pointer.y = (e.clientY - r.top) * canvas.height / r.height;
});
canvas.addEventListener("pointerdown", () => pointer.down = true);
canvas.addEventListener("pointerup", () => pointer.down = false);
addEventListener("keydown", e => {
  const key = e.key === "Shift" ? "shift" : e.key.toLowerCase();
  keys.add(key);
  keyPressed.add(key);
});
addEventListener("keyup", e => keys.delete(e.key === "Shift" ? "shift" : e.key.toLowerCase()));
ui.start.onclick = () => freshRun("cpu");
ui.pvp.onclick = () => freshRun("pvp");
freshRun("cpu");
setInterval(update, 1000 / 60);
