const canvas = document.querySelector("#game");
const ctx = canvas.getContext("2d");
const logList = document.querySelector("#log");
const keys = new Set();
const pressed = new Set();
const W = canvas.width;
const H = canvas.height;

const clamp = (value, min, max) => Math.max(min, Math.min(max, value));
const distance = (a, b) => Math.hypot(a.x - b.x, a.y - b.y);
const angleTo = (a, b) => Math.atan2(b.y - a.y, b.x - a.x);

window.addEventListener("keydown", (event) => {
  if (["Space", "Tab", "ArrowUp", "ArrowDown", "ArrowLeft", "ArrowRight"].includes(event.code)) {
    event.preventDefault();
  }
  if (!keys.has(event.code)) pressed.add(event.code);
  keys.add(event.code);
});

window.addEventListener("keyup", (event) => keys.delete(event.code));

function consume(code) {
  if (!pressed.has(code)) return false;
  pressed.delete(code);
  return true;
}

function log(message) {
  const item = document.createElement("li");
  item.textContent = message;
  logList.prepend(item);
  while (logList.children.length > 12) logList.lastChild.remove();
}

const creatures = [
  { name: "Sproutbit", role: "control", color: "#82d173", maxHp: 145, power: 1, speed: 150, cooldowns: [0, 0, 0, 0] },
  { name: "Embermite", role: "burst", color: "#ff8b54", maxHp: 115, power: 1.2, speed: 180, cooldowns: [0, 0, 0, 0] },
  { name: "Tidepup", role: "support", color: "#74c7ec", maxHp: 130, power: 1, speed: 165, cooldowns: [0, 0, 0, 0] }
];

let player;
let companion;
let enemy;
let activeIndex;
let alphaMode;
let projectiles;
let zones;
let textBursts;
let score;
let paused;

function reset(nextAlphaMode = false) {
  player = {
    name: "Trainer",
    x: 210,
    y: 320,
    r: 13,
    hp: 120,
    maxHp: 120,
    color: "#f6d365",
    face: 0,
    dodgeCooldown: 0,
    invulnerable: 0
  };
  companion = { x: 260, y: 330, r: 15 };
  activeIndex = 0;
  alphaMode = nextAlphaMode;
  enemy = alphaMode
    ? { name: "Alpha Bramblehorn", x: 690, y: 320, r: 34, hp: 820, maxHp: 820, color: "#e85d75", speed: 92, ai: 0 }
    : { name: "Wild Bramblehorn", x: 690, y: 320, r: 20, hp: 220, maxHp: 220, color: "#d9a441", speed: 116, ai: 0 };
  projectiles = [];
  zones = [];
  textBursts = [];
  score = { damage: 0, captures: 0 };
  paused = false;
  log(alphaMode ? "Alpha raid sandbox started." : "Wild capture sandbox started.");
}

function activeCreature() {
  return creatures[activeIndex];
}

function burst(text, x, y, color) {
  textBursts.push({ text, x, y, color, life: 0.7 });
}

function applyDamage(target, amount, source) {
  if (target.invulnerable > 0 || target.hp <= 0) return false;
  target.hp = clamp(target.hp - amount, 0, target.maxHp);
  burst("-" + Math.round(amount), target.x, target.y - 20, "#ff9a9a");
  if (target.hp <= 0) log(target.name + " was knocked out by " + source + ".");
  return true;
}

function heal(target, amount) {
  target.hp = clamp(target.hp + amount, 0, target.maxHp);
  burst("+" + Math.round(amount), target.x, target.y - 20, "#9cffb7");
}

function commandMove(slot) {
  const creature = activeCreature();
  if (creature.cooldowns[slot] > 0 || enemy.hp <= 0) return;

  const direction = angleTo(companion, enemy);

  if (slot === 0) {
    projectiles.push({
      x: companion.x,
      y: companion.y,
      vx: Math.cos(direction) * 480,
      vy: Math.sin(direction) * 480,
      r: 8,
      damage: 18 * creature.power,
      color: creature.color,
      team: "player",
      life: 0.65
    });
    creature.cooldowns[0] = 1.1;
    log(creature.name + " used Quick Strike.");
  }

  if (slot === 1) {
    zones.push({
      x: enemy.x,
      y: enemy.y,
      r: 54,
      damage: 24 * creature.power,
      color: creature.color,
      team: "player",
      windup: 0.38,
      life: 0.75,
      hit: false
    });
    creature.cooldowns[1] = 4.4;
    log(creature.name + " prepared an area attack.");
  }

  if (slot === 2) {
    player.invulnerable = 0.55;
    creature.cooldowns[2] = 5.5;
    burst("guard", player.x, player.y - 28, "#b5d8ff");
    log(creature.name + " guarded the trainer.");
  }

  if (slot === 3) {
    heal(player, 16);
    creature.cooldowns[3] = 7.5;
    log(creature.name + " used Support Pulse.");
  }
}

function enemyAttack() {
  if (enemy.hp <= 0) return;
  const target = distance(enemy, player) < distance(enemy, companion) ? player : companion;

  if (alphaMode && Math.random() < 0.45) {
    zones.push({
      x: target.x,
      y: target.y,
      r: 92,
      damage: 34,
      color: "#ff758f",
      team: "enemy",
      windup: 0.72,
      life: 1.05,
      hit: false
    });
    log(enemy.name + " telegraphed Alpha Quake.");
    return;
  }

  const direction = angleTo(enemy, target);
  projectiles.push({
    x: enemy.x,
    y: enemy.y,
    vx: Math.cos(direction) * 310,
    vy: Math.sin(direction) * 310,
    r: 10,
    damage: alphaMode ? 24 : 16,
    color: "#ffd166",
    team: "enemy",
    life: 1
  });
  log(enemy.name + " attacked.");
}

function attemptCapture() {
  if (alphaMode) {
    log("Alpha creatures use raid rewards, not direct capture.");
    return;
  }
  if (enemy.hp <= 0) {
    log("Cannot capture a knocked out creature.");
    return;
  }
  if (distance(player, enemy) > 110) {
    log("Move closer before throwing.");
    return;
  }
  const chance = clamp(0.14 + (1 - enemy.hp / enemy.maxHp) * 0.72, 0.06, 0.88);
  if (Math.random() < chance) {
    enemy.hp = 0;
    score.captures += 1;
    log("Captured " + enemy.name + "! Chance " + Math.round(chance * 100) + "%.");
  } else {
    log("Capture failed. Chance " + Math.round(chance * 100) + "%.");
  }
}

function update(dt) {
  if (consume("KeyP")) paused = !paused;
  if (consume("Enter")) reset(alphaMode);
  if (consume("KeyR")) reset(!alphaMode);
  if (paused) return;

  if (consume("Tab")) {
    activeIndex = (activeIndex + 1) % creatures.length;
    log("Swapped to " + activeCreature().name + ".");
  }
  if (consume("KeyC")) attemptCapture();
  for (let slot = 0; slot < 4; slot += 1) {
    if (consume("Digit" + (slot + 1))) commandMove(slot);
  }

  let moveX = 0;
  let moveY = 0;
  if (keys.has("KeyW") || keys.has("ArrowUp")) moveY -= 1;
  if (keys.has("KeyS") || keys.has("ArrowDown")) moveY += 1;
  if (keys.has("KeyA") || keys.has("ArrowLeft")) moveX -= 1;
  if (keys.has("KeyD") || keys.has("ArrowRight")) moveX += 1;

  const magnitude = Math.hypot(moveX, moveY) || 1;
  moveX /= magnitude;
  moveY /= magnitude;
  if (moveX !== 0 || moveY !== 0) player.face = Math.atan2(moveY, moveX);

  player.dodgeCooldown = Math.max(0, player.dodgeCooldown - dt);
  player.invulnerable = Math.max(0, player.invulnerable - dt);

  if (consume("Space") && player.dodgeCooldown <= 0) {
    player.dodgeCooldown = 0.85;
    player.invulnerable = 0.24;
    player.x += Math.cos(player.face) * 42;
    player.y += Math.sin(player.face) * 42;
    burst("dodge", player.x, player.y - 26, "#fff");
  }

  player.x = clamp(player.x + moveX * 205 * dt, 34, W - 34);
  player.y = clamp(player.y + moveY * 205 * dt, 74, H - 46);

  const creature = activeCreature();
  const followX = player.x + Math.cos(player.face + 0.7) * 48;
  const followY = player.y + Math.sin(player.face + 0.7) * 48;
  const followDistance = Math.hypot(followX - companion.x, followY - companion.y) || 1;
  companion.x += ((followX - companion.x) / followDistance) * creature.speed * dt;
  companion.y += ((followY - companion.y) / followDistance) * creature.speed * dt;

  creatures.forEach((entry) => {
    entry.cooldowns = entry.cooldowns.map((cooldown) => Math.max(0, cooldown - dt));
  });

  if (enemy.hp > 0) {
    enemy.ai -= dt;
    const target = distance(enemy, player) < distance(enemy, companion) ? player : companion;
    const desiredRange = alphaMode ? 170 : 120;
    if (distance(enemy, target) > desiredRange) {
      const direction = angleTo(enemy, target);
      enemy.x += Math.cos(direction) * enemy.speed * dt;
      enemy.y += Math.sin(direction) * enemy.speed * dt;
    }
    if (enemy.ai <= 0) {
      enemyAttack();
      enemy.ai = alphaMode ? 1.3 + Math.random() : 1.8 + Math.random() * 1.2;
    }
  }

  projectiles.forEach((projectile) => {
    projectile.x += projectile.vx * dt;
    projectile.y += projectile.vy * dt;
    projectile.life -= dt;
    const target = projectile.team === "player" ? enemy : player;
    if (target.hp > 0 && distance(projectile, target) < projectile.r + target.r) {
      if (applyDamage(target, projectile.damage, "projectile") && projectile.team === "player") {
        score.damage += projectile.damage;
      }
      projectile.life = 0;
    }
  });
  projectiles = projectiles.filter((projectile) => projectile.life > 0);

  zones.forEach((zone) => {
    zone.life -= dt;
    zone.windup -= dt;
    if (zone.windup <= 0 && !zone.hit) {
      const targets = zone.team === "player" ? [enemy] : [player, { ...companion, hp: 1, maxHp: 1, name: activeCreature().name, r: 15 }];
      targets.forEach((target) => {
        if (target.hp > 0 && distance(zone, target) < zone.r + target.r) {
          if (applyDamage(target, zone.damage, "area attack") && zone.team === "player") score.damage += zone.damage;
        }
      });
      zone.hit = true;
    }
  });
  zones = zones.filter((zone) => zone.life > 0);

  textBursts.forEach((item) => {
    item.life -= dt;
    item.y -= 30 * dt;
  });
  textBursts = textBursts.filter((item) => item.life > 0);
}

function drawBar(x, y, width, height, percent, color) {
  ctx.fillStyle = "rgba(0,0,0,.5)";
  ctx.fillRect(x, y, width, height);
  ctx.fillStyle = color;
  ctx.fillRect(x, y, width * clamp(percent, 0, 1), height);
}

function drawEntity(entity, ring = false) {
  if (entity.hp <= 0) return;
  ctx.fillStyle = "rgba(0,0,0,.3)";
  ctx.beginPath();
  ctx.ellipse(entity.x, entity.y + entity.r * 0.7, entity.r * 1.15, entity.r * 0.42, 0, 0, Math.PI * 2);
  ctx.fill();
  ctx.fillStyle = entity.color;
  ctx.beginPath();
  ctx.arc(entity.x, entity.y, entity.r, 0, Math.PI * 2);
  ctx.fill();
  ctx.fillStyle = "#111";
  ctx.fillRect(entity.x + entity.r * 0.2, entity.y - entity.r * 0.25, 4, 4);
  ctx.fillRect(entity.x + entity.r * 0.2, entity.y + entity.r * 0.12, 4, 4);
  if (ring) {
    ctx.strokeStyle = "#fff";
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.arc(entity.x, entity.y, entity.r + 5, 0, Math.PI * 2);
    ctx.stroke();
  }
  drawBar(entity.x - 34, entity.y - entity.r - 20, 68, 7, entity.hp / entity.maxHp, entity.hp / entity.maxHp > 0.35 ? "#82d173" : "#ff6b6b");
}

function render() {
  ctx.fillStyle = "#233121";
  ctx.fillRect(0, 0, W, H);

  ctx.strokeStyle = "rgba(255,255,255,.055)";
  for (let x = 0; x < W; x += 32) {
    ctx.beginPath();
    ctx.moveTo(x, 64);
    ctx.lineTo(x, H);
    ctx.stroke();
  }
  for (let y = 64; y < H; y += 32) {
    ctx.beginPath();
    ctx.moveTo(0, y);
    ctx.lineTo(W, y);
    ctx.stroke();
  }

  ctx.fillStyle = "#182018";
  ctx.fillRect(0, 0, W, 64);

  zones.forEach((zone) => {
    ctx.globalAlpha = zone.windup > 0 ? 0.25 : 0.45;
    ctx.fillStyle = zone.color;
    ctx.beginPath();
    ctx.arc(zone.x, zone.y, zone.r, 0, Math.PI * 2);
    ctx.fill();
    ctx.globalAlpha = 1;
  });

  projectiles.forEach((projectile) => {
    ctx.fillStyle = projectile.color;
    ctx.beginPath();
    ctx.arc(projectile.x, projectile.y, projectile.r, 0, Math.PI * 2);
    ctx.fill();
  });

  ctx.strokeStyle = "rgba(255,255,255,.14)";
  ctx.beginPath();
  ctx.moveTo(player.x, player.y);
  ctx.lineTo(companion.x, companion.y);
  ctx.stroke();

  drawEntity(player);
  drawEntity({ ...companion, ...activeCreature(), hp: activeCreature().maxHp, r: 15 }, true);
  drawEntity(enemy);

  textBursts.forEach((item) => {
    ctx.globalAlpha = clamp(item.life / 0.7, 0, 1);
    ctx.fillStyle = item.color;
    ctx.font = "800 14px system-ui";
    ctx.fillText(item.text, item.x - ctx.measureText(item.text).width / 2, item.y);
    ctx.globalAlpha = 1;
  });

  ctx.fillStyle = "#f5f7fb";
  ctx.font = "700 16px system-ui";
  ctx.fillText(alphaMode ? "Alpha Raid Sandbox" : "Wild Capture Sandbox", 18, 26);
  ctx.font = "13px system-ui";
  ctx.fillStyle = "#aab2c5";
  ctx.fillText("Active: " + activeCreature().name + " - " + activeCreature().role, 18, 48);
  ctx.fillText("Enemy: " + enemy.name + "   Damage: " + Math.round(score.damage) + "   " + (alphaMode ? "Contribution" : "Captures") + ": " + (alphaMode ? Math.round(score.damage) : score.captures), 500, 48);

  const labels = ["Quick", "Area", "Guard", "Support"];
  const maxCooldowns = [1.1, 4.4, 5.5, 7.5];
  let y = H - 118;
  labels.forEach((label, index) => {
    const cooldown = activeCreature().cooldowns[index];
    const width = 214;
    ctx.fillStyle = "rgba(0,0,0,.45)";
    ctx.fillRect(18, y, width, 22);
    ctx.fillStyle = activeCreature().color;
    ctx.fillRect(18, y, width * (1 - cooldown / maxCooldowns[index]), 22);
    ctx.fillStyle = "#111";
    ctx.font = "700 12px system-ui";
    ctx.fillText(String(index + 1), 25, y + 15);
    ctx.fillStyle = "#fff";
    ctx.fillText(label + (cooldown > 0 ? " " + cooldown.toFixed(1) : ""), 46, y + 15);
    y += 27;
  });
}

let lastTime = performance.now();
let accumulator = 0;
function loop(time) {
  accumulator += Math.min(0.05, (time - lastTime) / 1000);
  lastTime = time;
  while (accumulator >= 1 / 60) {
    update(1 / 60);
    accumulator -= 1 / 60;
  }
  render();
  requestAnimationFrame(loop);
}

reset(false);
requestAnimationFrame(loop);
