(() => {
  const ROUND_SECONDS = 40;
  const RPM_MAX = 100;
  const LOW_RPM = 22;
  const GRAVITY_PULL = 0.18;
  const UPHILL_DRAG = 0.075;
  const DOWNHILL_BOOST = 0.115;
  const TANGENTIAL_KEEP = 0.018;

  const BIT_BEASTS = [
    { name: "Astral Lynx", style: "attack", active: "Pounce Burst", passive: "Angle hits build extra Spirit and bite harder.", color: "#ef476f" },
    { name: "Chrome Wyvern", style: "defense", active: "Iron Cyclone", passive: "Guard spin reduces knockback and RPM loss.", color: "#8f6bff" },
    { name: "Vault Turtle", style: "defense", active: "Shell Lock", passive: "Rail crashes cost less HP and stability.", color: "#06d6a0" },
    { name: "Pulse Raven", style: "stamina", active: "Tempo Siphon", passive: "Orbiting the dome preserves more RPM.", color: "#ffd166" },
    { name: "Comet Wolf", style: "attack", active: "Meteor Rush", passive: "Dash impacts get higher launch and hit sparks.", color: "#ff8750" },
    { name: "Neon Kirin", style: "stamina", active: "Regen Current", passive: "Low RPM wobble recovers faster.", color: "#54e0ff" },
    { name: "Grav Bull", style: "defense", active: "Anchor Drop", passive: "Mass advantage matters more in clashes.", color: "#bba7ff" },
    { name: "Volt Jackal", style: "attack", active: "Spark Feint", passive: "Switching direction briefly boosts control.", color: "#ffe66d" }
  ];

  const originalFreshRun = freshRun;
  const originalTopEntity = topEntity;
  const originalEquippedStats = equippedStats;
  const originalUpdateStats = updateStats;
  const originalUpdate = update;
  const originalPhysics = physics;
  const originalSteerPlayer = steerPlayer;
  const originalResolveTopCollision = resolveTopCollision;
  const originalUseBladeMove = useBladeMove;
  const originalSummonSpiritSurge = summonSpiritSurge;
  const originalWinRound = winRound;
  const originalEndRun = endRun;
  const originalDraw = draw;

  installPartIdentitySystem();

  equippedStats = function upgradedEquippedStats(loadout = state.equipped) {
    const stats = originalEquippedStats(loadout);
    return applyArchetypeMultipliers(stats, loadout);
  };

  updateStats = function upgradedUpdateStats(heal, top = state.player, loadout = state.equipped) {
    originalUpdateStats(heal, top, loadout);
    const stats = equippedStats(loadout);
    top.maxRpm = Math.round(stats.rpmMax);
    top.rpm = heal ? top.maxRpm : clamp(top.rpm ?? top.maxRpm, 0, top.maxRpm);
    top.style = stats.primaryStyle;
    top.attackStyle = stats.attackStyle;
    top.defenseStyle = stats.defenseStyle;
    top.staminaStyle = stats.staminaStyle;
    top.maxHp = Math.round(stats.hp);
    top.r = 18 + Math.min(13, stats.mass * 3.45);
  };

  ui.rpm = document.getElementById("rpm");
  ui.timer = document.getElementById("timer");

  topEntity = function upgradedTopEntity(...args) {
    const top = originalTopEntity(...args);
    seedRPM(top);
    return top;
  };

  freshRun = function upgradedFreshRun(mode = "cpu") {
    originalFreshRun(mode);
    installPvpDiversityLoadouts(mode);
    seedMatchState();
    renderBench();
  };

  update = function upgradedUpdate(dt = 1) {
    originalUpdate(dt);
    if (!state?.running) return;
    const seconds = dt / 60;
    state.matchClock = Math.max(0, (state.matchClock ?? ROUND_SECONDS) - seconds);
    state.slashArcs = (state.slashArcs ?? []).filter(arc => (arc.life -= dt) > 0).slice(-48);
    if (state.matchClock <= 0) resolveTimedRound();
    updateArcadeHud();
  };

  steerPlayer = function upgradedSteerPlayer(top, stats, scheme, dt) {
    originalSteerPlayer(top, stats, scheme, dt);
    seedRPM(top);
    const p2 = scheme === "p2";
    const loadout = p2 ? state.p2Equipped : state.equipped;
    const chargeHeld = p2 ? keys.has("u") : pointer.down || keys.has(" ");
    if (chargeHeld) drainRPM(top, (0.08 + stats.charge * 0.02) * stats.rpmDrain * dt, "charge");
    applyDriverPatternControl(top, stats, loadout, scheme, dt);
    applyBitBeastPassive(top, stats, loadout, dt);
    if (top.rpm < LOW_RPM) {
      const recovery = bitBeast(loadout).name === "Neon Kirin" ? 0.993 : 0.985;
      top.vx *= recovery;
      top.vy *= recovery;
      top.tilt = Math.min(1.1, top.tilt + 0.004 * dt);
    }
  };

  physics = function upgradedPhysics(top, stats, dt) {
    originalPhysics(top, stats, dt);
    seedRPM(top);
    applyDomePitchPhysics(top, stats, dt);
    const seconds = dt / 60;
    const speed = Math.hypot(top.vx, top.vy);
    const wobblePenalty = 1 - clamp(top.stability / Math.max(0.5, stats.stability), 0, 1);
    const slope = domeKinematics(top).slope;
    drainRPM(top, seconds * (1.05 + speed * 0.07 + top.tilt * 0.32 + wobblePenalty * 1.7 + slope * 0.55) * stats.rpmDrain, "spin");
    const rpmPct = top.rpm / top.maxRpm;
    top.spinRate = clamp(top.spinRate * (0.94 + rpmPct * 0.06), 0.035, 0.92);
    if (rpmPct < 0.22 && Math.random() < 0.06 * dt) {
      floatingText("WOBBLE", top.x, top.y - 36, topColor(top), 20);
    }
  };

  resolveTopCollision = function upgradedResolveTopCollision(a, b, aStats, bStats, dt, npcOnly = false) {
    if (!a || !b || a.hp <= 0 || b.hp <= 0) return;
    const dx = b.x - a.x;
    const dy = b.y - a.y;
    const distance = Math.hypot(dx, dy) || 0.001;
    const min = a.r + b.r;
    if (distance >= min) return originalResolveTopCollision(a, b, aStats, bStats, dt, npcOnly);

    const nx = dx / distance;
    const ny = dy / distance;
    const rvx = b.vx - a.vx;
    const rvy = b.vy - a.vy;
    const normalSpeed = rvx * nx + rvy * ny;
    const tangentialSpeed = rvx * -ny + rvy * nx;
    const impactSpeed = Math.hypot(rvx, rvy);
    const angleScore = Math.abs(tangentialSpeed) / Math.max(1, impactSpeed);
    const edgePressure = Math.max(domeValue(a.x, a.y), domeValue(b.x, b.y));
    const perfectAngle = impactSpeed > 5.2 && angleScore > 0.52;
    const impactX = (a.x + b.x) / 2;
    const impactY = (a.y + b.y) / 2;
    const color = perfectAngle ? "#ffffff" : topColor(a);

    originalResolveTopCollision(a, b, aStats, bStats, dt, npcOnly);

    const beastA = bitBeast(loadoutForActor(a));
    const beastB = bitBeast(loadoutForActor(b));
    const rpmHit = 1.8 + impactSpeed * 0.34 + Math.max(0, edgePressure - 0.72) * 7;
    const aGuard = a.guard > 0 && beastA.name === "Chrome Wyvern" ? 0.36 : a.guard > 0 ? 0.52 : 1;
    const bGuard = b.guard > 0 && beastB.name === "Chrome Wyvern" ? 0.36 : b.guard > 0 ? 0.52 : 1;
    drainRPM(a, rpmHit * aGuard * aStats.rpmDrain, "clash");
    drainRPM(b, rpmHit * bGuard * bStats.rpmDrain, "clash");
    if (perfectAngle && beastA.name === "Astral Lynx") a.spirit = Math.min(100, a.spirit + 10);
    if (perfectAngle && beastB.name === "Astral Lynx") b.spirit = Math.min(100, b.spirit + 10);
    createSlashArc(impactX, impactY, Math.atan2(dy, dx), color, perfectAngle ? 34 : 22, perfectAngle ? 38 : 24);
    if (perfectAngle) {
      state.flash = Math.max(state.flash, 0.9);
      state.shake = Math.max(state.shake, 16);
      floatingText("ANGLE HIT", impactX, impactY - 42, "#ffffff", 34);
    } else if (impactSpeed > 3.2 && -normalSpeed > 0) {
      floatingText("CLASH", impactX, impactY - 35, color, 24);
    }
  };

  useBladeMove = function upgradedUseBladeMove(top, dx, dy, stats) {
    seedRPM(top);
    const speed = Math.hypot(top.vx, top.vy);
    const cost = (speed > 6.2 || top.charge > 0.7 ? 5 : 12) * stats.rpmDrain;
    if (top.rpm < cost + 4) {
      floatingText("LOW RPM", top.x, top.y - 38, "#ffd34e", 30);
      top.moveCd = Math.max(top.moveCd, 18);
      return;
    }
    drainRPM(top, cost, "dash");
    originalUseBladeMove(top, dx, dy, stats);
  };

  summonSpiritSurge = function upgradedSummonSpiritSurge(top, loadout) {
    const beast = bitBeast(loadout);
    top.spirit = 0;
    top.charge = Math.min(1, top.charge + 0.36 + (beast.style === "attack" ? 0.08 : 0));
    top.stability = Math.min(actorStats(top).stability, top.stability + (beast.style === "defense" ? 0.38 : 0.22));
    const surge = { owner: top, x: top.x, y: top.y, r: 40 + rarityScore[loadout.chip.rarity] * 5, ttl: 150 + (beast.style === "stamina" ? 36 : 0), color: beast.color || loadout.chip.color, name: beast.name, angle: 0, pulse: 0, beast };
    state.spiritSurges.push(surge);
    applyBitBeastActive(top, loadout, beast);
    flashMessage(`${top.role === "p2" ? "P2" : "P1"} Bit Beast: ${beast.name} — ${beast.active}.`);
    createImpact(top.x, top.y, surge.color, 42, 32);
  };

  winRound = function upgradedWinRound() {
    originalWinRound();
    if (!state?.running) return;
    state.matchClock = ROUND_SECONDS;
    seedRPM(state.player);
    state.player.rpm = Math.min(state.player.maxRpm, state.player.rpm + 18);
    for (const rival of state.rivals) seedRPM(rival);
    updateArcadeHud();
  };

  endRun = function upgradedEndRun(won, message) {
    originalEndRun(won, message);
    const heading = ui.panel.querySelector("h1");
    if (heading) heading.textContent = state.mode === "pvp" ? winnerLabel() : won ? "WIN" : "OUTSPUN";
  };

  draw = function upgradedDraw() {
    originalDraw();
    if (!state) return;
    drawSlashArcs();
    drawRPMMeter();
    drawRoundClock();
    drawSlopeVectorDebug();
  };

  function installPartIdentitySystem() {
    SLOT_DEFS.chip.label = "Bit Beast";
    for (const slot of slots) {
      for (const part of catalogue[slot]) {
        const index = partIndex(part);
        const weights = partStyleWeights(slot, part, index);
        part.styleWeights = weights;
        part.primaryStyle = primaryStyle(weights);
        if (slot === "chip") {
          const beast = BIT_BEASTS[index % BIT_BEASTS.length];
          part.bitBeast = { ...beast };
          const suffix = suffixes[Math.floor(index / BIT_BEASTS.length) % suffixes.length];
          part.name = `${beast.name} ${suffix}`;
          part.color = beast.color;
          part.desc = `${beast.style.toUpperCase()} Bit Beast · Active: ${beast.active} · Passive: ${beast.passive}`;
        } else {
          part.desc = `${part.primaryStyle.toUpperCase()} style · ${part.desc}`;
        }
      }
    }
  }

  function partStyleWeights(slot, part, index) {
    const cycle = index % 6;
    const attack = slot === "ring" ? 3.2 : slot === "driver" ? 1.25 : slot === "chip" ? 1.55 : 0.7;
    const defense = slot === "core" ? 3.25 : slot === "ring" ? 0.9 : slot === "chip" ? 1.25 : 0.75;
    const stamina = slot === "driver" ? 2.8 : slot === "core" ? 1.35 : slot === "chip" ? 1.8 : 0.85;
    return {
      attack: attack + (cycle === 0 || cycle === 3 ? 1.35 : 0) + rarityScore[part.rarity] * 0.42,
      defense: defense + (cycle === 1 || cycle === 4 ? 1.35 : 0) + rarityScore[part.rarity] * 0.42,
      stamina: stamina + (cycle === 2 || cycle === 5 ? 1.35 : 0) + rarityScore[part.rarity] * 0.42
    };
  }

  function applyArchetypeMultipliers(stats, loadout) {
    const profile = buildStyleProfile(loadout);
    const a = profile.attack;
    const d = profile.defense;
    const s = profile.stamina;
    stats.damage = clamp(stats.damage * (1 + a * 0.42 - d * 0.05), 4.8, 36);
    stats.speed = clamp(stats.speed * (1 + a * 0.14 + s * 0.1 - d * 0.08), 0.75, 4.2);
    stats.mass = clamp(stats.mass * (1 + d * 0.34 + a * 0.08 - s * 0.06), 0.48, 5.4);
    stats.hp = clamp(stats.hp * (1 + d * 0.46 + s * 0.12 - a * 0.08), 62, 330);
    stats.stability = clamp(stats.stability * (1 + d * 0.36 + s * 0.24 - a * 0.08), 0.34, 3.4);
    stats.charge = clamp(stats.charge * (1 + a * 0.18 + s * 0.24), 0.32, 3.4);
    stats.grip = clamp(stats.grip + d * 0.006 + s * 0.012 - a * 0.006, 0.92, 1.006);
    stats.rpmMax = clamp(RPM_MAX + s * 46 + d * 18 - a * 8, 78, 172);
    stats.rpmDrain = clamp(1 + a * 0.12 + d * 0.02 - s * 0.28, 0.58, 1.38);
    stats.attackStyle = a;
    stats.defenseStyle = d;
    stats.staminaStyle = s;
    stats.primaryStyle = primaryStyle({ attack: a, defense: d, stamina: s });
    return stats;
  }

  function buildStyleProfile(loadout) {
    const total = { attack: 0, defense: 0, stamina: 0 };
    for (const part of Object.values(loadout || {})) {
      const weights = part.styleWeights || partStyleWeights(part.slot, part, partIndex(part));
      total.attack += weights.attack;
      total.defense += weights.defense;
      total.stamina += weights.stamina;
    }
    const sum = Math.max(1, total.attack + total.defense + total.stamina);
    return { attack: total.attack / sum, defense: total.defense / sum, stamina: total.stamina / sum };
  }

  function primaryStyle(weights) {
    return Object.entries(weights).sort((a, b) => b[1] - a[1])[0][0];
  }

  function bitBeast(loadout) {
    return loadout?.chip?.bitBeast || BIT_BEASTS[0];
  }

  function loadoutForActor(actor) {
    if (!actor) return state.equipped;
    if (actor.role === "p1") return state.equipped;
    if (actor.role === "p2") return state.p2Equipped;
    return rivalLoadout(actor.rank);
  }

  function installPvpDiversityLoadouts(mode) {
    if (mode !== "pvp" || !state.player2) return;
    state.equipped = { ring: catalogue.ring[24], core: catalogue.core[8], driver: catalogue.driver[5], chip: catalogue.chip[4] };
    state.p2Equipped = { ring: catalogue.ring[9], core: catalogue.core[38], driver: catalogue.driver[17], chip: catalogue.chip[18] };
    updateStats(true, state.player, state.equipped);
    updateStats(true, state.player2, state.p2Equipped);
  }

  function applyBitBeastPassive(top, stats, loadout, dt) {
    const beast = bitBeast(loadout);
    const k = domeKinematics(top);
    if (beast.name === "Pulse Raven" && Math.abs(k.tangentialSpeed) > 3.2) top.rpm = Math.min(top.maxRpm, top.rpm + 0.018 * dt);
    if (beast.name === "Vault Turtle" && k.dome > 0.88) top.hp = Math.min(top.maxHp, top.hp + 0.006 * dt);
    if (beast.name === "Grav Bull" && Math.hypot(top.vx, top.vy) < 4.4) top.stability = Math.min(stats.stability, top.stability + 0.003 * dt);
    if (beast.name === "Volt Jackal" && top.moveCd > 0 && Math.random() < 0.015 * dt) createSparkBurst(top.x, top.y, beast.color, 1, 4);
  }

  function applyBitBeastActive(top, loadout, beast) {
    if (beast.name === "Astral Lynx") { top.vx *= 1.35; top.vy *= 1.35; top.charge = 1; }
    if (beast.name === "Chrome Wyvern") { top.guard = 95; top.stability = Math.min(actorStats(top).stability, top.stability + 0.7); }
    if (beast.name === "Vault Turtle") { top.hp = Math.min(top.maxHp, top.hp + 38); top.guard = 70; }
    if (beast.name === "Pulse Raven") { top.rpm = Math.min(top.maxRpm, top.rpm + 32); top.spirit = Math.min(40, top.spirit + 12); }
    if (beast.name === "Comet Wolf") { const k = domeKinematics(top); top.vx += k.radialX * 8 + k.tangentX * 6; top.vy += k.radialY * 8 + k.tangentY * 6; top.charge = 1; }
    if (beast.name === "Neon Kirin") { top.rpm = Math.min(top.maxRpm, top.rpm + 22); top.hp = Math.min(top.maxHp, top.hp + 18); top.stability = Math.min(actorStats(top).stability, top.stability + 0.34); }
    if (beast.name === "Grav Bull") { const k = domeKinematics(top); top.vx -= k.radialX * 9; top.vy -= k.radialY * 9; top.guard = 54; }
    if (beast.name === "Volt Jackal") { top.moveCd = 0; top.charge = Math.min(1, top.charge + 0.55); }
  }

  function applyDomePitchPhysics(top, stats, dt) {
    const k = domeKinematics(top);
    const slope = k.slope;
    if (slope <= 0.01) return;

    const uphill = Math.max(0, k.radialSpeed);
    const downhill = Math.max(0, -k.radialSpeed);
    const wall = clamp((k.dome - 0.48) / 0.52, 0, 1);
    const gravity = GRAVITY_PULL * slope * wall;

    top.vx -= k.radialX * gravity * dt;
    top.vy -= k.radialY * gravity * dt;

    if (uphill > 0) {
      const slow = Math.min(uphill * UPHILL_DRAG * slope * dt, uphill * 0.42);
      top.vx -= k.radialX * slow;
      top.vy -= k.radialY * slow;
      drainRPM(top, slow * 0.42 * stats.rpmDrain, "uphill");
      if (slope > 0.5 && uphill > 2.5 && Math.random() < 0.025 * dt) floatingText("CLIMB", top.x, top.y - 35, topColor(top), 18);
    }

    if (downhill > 0) {
      const boost = Math.min(3.8, downhill * DOWNHILL_BOOST * slope * dt + gravity * 0.9 * dt);
      top.vx -= k.radialX * boost;
      top.vy -= k.radialY * boost;
      top.stability = Math.max(0.18, top.stability - boost * 0.004);
      if (slope > 0.5 && downhill > 2.4 && Math.random() < 0.028 * dt) floatingText("DROP SPEED", top.x, top.y - 35, topColor(top), 18);
    }

    const tangentKeep = 1 + TANGENTIAL_KEEP * slope * stats.grip * dt;
    const maxTangential = 14 + stats.speed * 4 + stats.grip * 3;
    const currentTangential = clamp(k.tangentialSpeed * tangentKeep, -maxTangential, maxTangential);
    const radialAfter = top.vx * k.radialX + top.vy * k.radialY;
    top.vx = k.radialX * radialAfter + k.tangentX * currentTangential;
    top.vy = k.radialY * radialAfter + k.tangentY * currentTangential;
  }

  function applyDriverPatternControl(top, stats, loadout, scheme, dt) {
    if (!loadout?.driver) return;
    const driver = loadout.driver.name.split(" ")[0];
    const k = domeKinematics(top);
    const intent = playerIntentVector(top, scheme);
    const aimX = intent.x;
    const aimY = intent.y;
    let patternX = aimX;
    let patternY = aimY;
    let label = driver.toUpperCase();
    const t = performance.now() / 1000 + partIndex(loadout.driver) * 0.37;

    if (driver === "Drift") {
      patternX = aimX * 0.55 + k.tangentX * 0.8;
      patternY = aimY * 0.55 + k.tangentY * 0.8;
      label = "DRIFT LINE";
    } else if (driver === "Needle") {
      patternX = aimX * 0.82 - k.radialX * 0.22;
      patternY = aimY * 0.82 - k.radialY * 0.22;
      top.stability = Math.min(actorStats(top).stability, top.stability + 0.0025 * dt);
      label = "ANCHOR LINE";
    } else if (driver === "Skate") {
      const sign = k.tangentialSpeed >= 0 ? 1 : -1;
      patternX = aimX * 0.35 + k.tangentX * sign * 1.1;
      patternY = aimY * 0.35 + k.tangentY * sign * 1.1;
      label = "RAIL SKATE";
    } else if (driver === "Switch") {
      const swap = Math.sin(t * 2.4) > 0 ? 1 : -1;
      patternX = aimX * 0.62 + k.tangentX * swap * 0.62 - k.radialX * 0.16;
      patternY = aimY * 0.62 + k.tangentY * swap * 0.62 - k.radialY * 0.16;
      label = "SWITCH CUT";
    } else if (driver === "Sprint") {
      patternX = aimX * 1.25 + k.radialX * 0.26;
      patternY = aimY * 1.25 + k.radialY * 0.26;
      label = "SPRINT COMMIT";
    } else if (driver === "Spiral") {
      const swirl = Math.sin(t * 5.2);
      patternX = aimX * 0.62 + k.tangentX * swirl * 0.9 - k.radialX * 0.18;
      patternY = aimY * 0.62 + k.tangentY * swirl * 0.9 - k.radialY * 0.18;
      label = "SPIRAL HUNT";
    } else if (driver === "Chrome") {
      patternX = aimX * 0.72 - k.radialX * 0.34;
      patternY = aimY * 0.72 - k.radialY * 0.34;
      top.vx *= 0.998;
      top.vy *= 0.998;
      label = "HEAVY LINE";
    } else if (driver === "Dash") {
      patternX = aimX * 1.18 + k.tangentX * 0.28;
      patternY = aimY * 1.18 + k.tangentY * 0.28;
      label = "DASH ANGLE";
    }

    const len = Math.hypot(patternX, patternY) || 1;
    const rpmScale = clamp((top.rpm ?? RPM_MAX) / RPM_MAX, 0.25, 1);
    const control = 0.035 * stats.speed * rpmScale * (1 + stats.attackStyle * 0.18 + stats.staminaStyle * 0.12);
    top.vx += (patternX / len) * control * dt;
    top.vy += (patternY / len) * control * dt;

    if (state.matchClock && Math.ceil(state.matchClock) % 9 === 0 && Math.random() < 0.006 * dt) {
      floatingText(label, top.x, top.y - 48, loadout.driver.color, 22);
    }
  }

  function domeKinematics(top) {
    const dx = top.x - ARENA.cx;
    const dy = top.y - ARENA.cy;
    const nx = dx / ARENA.rx;
    const ny = dy / ARENA.ry;
    const dome = Math.hypot(nx, ny) || 0.001;
    const radialX = (nx / dome) / ARENA.rx;
    const radialY = (ny / dome) / ARENA.ry;
    const radialLen = Math.hypot(radialX, radialY) || 1;
    const rx = radialX / radialLen;
    const ry = radialY / radialLen;
    const tx = -ry;
    const ty = rx;
    return {
      dome,
      slope: clamp((dome - 0.25) / 0.75, 0, 1),
      radialX: rx,
      radialY: ry,
      tangentX: tx,
      tangentY: ty,
      radialSpeed: top.vx * rx + top.vy * ry,
      tangentialSpeed: top.vx * tx + top.vy * ty
    };
  }

  function playerIntentVector(top, scheme) {
    const p2 = scheme === "p2";
    const ax = (keys.has(p2 ? "l" : "arrowright") || (!p2 && keys.has("d")) ? 1 : 0) - (keys.has(p2 ? "j" : "arrowleft") || (!p2 && keys.has("a")) ? 1 : 0);
    const ay = (keys.has(p2 ? "k" : "arrowdown") || (!p2 && keys.has("s")) ? 1 : 0) - (keys.has(p2 ? "i" : "arrowup") || (!p2 && keys.has("w")) ? 1 : 0);
    let dx = p2 ? ax : pointer.x - top.x;
    let dy = p2 ? ay : pointer.y - top.y;
    if (!p2 && (ax || ay)) { dx = ax; dy = ay; }
    const len = Math.hypot(dx, dy) || 1;
    return { x: dx / len, y: dy / len };
  }

  function seedMatchState() {
    state.matchClock = ROUND_SECONDS;
    state.slashArcs = [];
    for (const actor of [state.player, state.player2, ...state.rivals].filter(Boolean)) seedRPM(actor);
    updateArcadeHud();
  }

  function seedRPM(top) {
    if (!top) return;
    const stats = actorStats(top);
    top.maxRpm = Math.round(stats.rpmMax || top.maxRpm || RPM_MAX);
    top.rpm = typeof top.rpm === "number" ? clamp(top.rpm, 0, top.maxRpm) : top.maxRpm;
  }

  function drainRPM(top, amount, reason) {
    if (!top || top.hp <= 0) return;
    seedRPM(top);
    top.rpm = clamp(top.rpm - amount, 0, top.maxRpm);
    if (top.rpm <= 0) {
      top.hp = 0;
      createImpact(top.x, top.y, topColor(top), 28, 18);
      floatingText(reason === "clash" ? "BURST OUT" : "OUTSPUN", top.x, top.y - 42, topColor(top), 44);
    }
  }

  function resolveTimedRound() {
    const p = state.player;
    if (state.mode === "pvp" && state.player2) {
      const p1Score = scoreActor(p);
      const p2Score = scoreActor(state.player2);
      return endRun(p1Score >= p2Score, p1Score >= p2Score ? "P1 wins on RPM control." : "P2 wins on RPM control.");
    }
    const rivalScore = Math.max(0, ...state.rivals.map(scoreActor));
    if (scoreActor(p) >= rivalScore) return winRound();
    endRun(false, "Timer hit zero. You lost the RPM war.");
  }

  function scoreActor(top) {
    seedRPM(top);
    return top.rpm + Math.max(0, top.hp) * 0.25 + top.stability * 6;
  }

  function winnerLabel() {
    if (!state.player2) return "WIN";
    return scoreActor(state.player) >= scoreActor(state.player2) ? "P1 WIN" : "P2 WIN";
  }

  function updateArcadeHud() {
    if (!state) return;
    if (ui.rpm) ui.rpm.textContent = `${Math.round(state.player.rpm ?? RPM_MAX)}%`;
    if (ui.timer) ui.timer.textContent = `${Math.ceil(state.matchClock ?? ROUND_SECONDS)}s`;
  }

  function createSlashArc(x, y, angle, color, radius, life) {
    state.slashArcs = state.slashArcs || [];
    state.slashArcs.push({ x, y, angle, color, radius, life, maxLife: life });
  }

  function drawSlashArcs() {
    const arcs = state.slashArcs || [];
    for (const arc of arcs) {
      const pct = arc.life / arc.maxLife;
      ctx.save();
      ctx.translate(arc.x, arc.y);
      ctx.rotate(arc.angle);
      ctx.globalAlpha = Math.max(0, pct);
      ctx.strokeStyle = arc.color;
      ctx.lineWidth = 5 * pct + 1;
      ctx.beginPath();
      ctx.arc(0, 0, arc.radius, -0.95, 0.95);
      ctx.stroke();
      ctx.strokeStyle = "#ffffff";
      ctx.lineWidth = 2;
      ctx.beginPath();
      ctx.arc(0, 0, arc.radius + 5, -0.55, 0.55);
      ctx.stroke();
      ctx.restore();
    }
  }

  function drawRPMMeter() {
    const pct = clamp((state.player.rpm ?? RPM_MAX) / state.player.maxRpm, 0, 1);
    const x = 310, y = 492, w = 340, h = 24;
    ctx.save();
    ctx.fillStyle = "#080812cc";
    ctx.fillRect(x, y, w, h);
    const grad = ctx.createLinearGradient(x, y, x + w, y);
    grad.addColorStop(0, "#ef476f");
    grad.addColorStop(0.45, "#ffd34e");
    grad.addColorStop(1, "#54e0ff");
    ctx.fillStyle = grad;
    ctx.fillRect(x + 4, y + 4, (w - 8) * pct, h - 8);
    ctx.strokeStyle = "#f6f1de";
    ctx.lineWidth = 2;
    ctx.strokeRect(x, y, w, h);
    ctx.fillStyle = "#f6f1de";
    ctx.font = "800 13px system-ui, sans-serif";
    ctx.textAlign = "center";
    ctx.fillText(`${state.player.style?.toUpperCase?.() || "HYBRID"} RPM ${Math.round(pct * 100)}%`, x + w / 2, y + 17);
    ctx.restore();
  }

  function drawRoundClock() {
    const time = Math.ceil(state.matchClock ?? ROUND_SECONDS);
    ctx.save();
    ctx.fillStyle = time <= 8 ? "#ef476f" : "#f6f1de";
    ctx.font = "900 28px system-ui, sans-serif";
    ctx.textAlign = "center";
    ctx.fillText(`${time}`, ARENA.cx, 56);
    ctx.font = "700 10px system-ui, sans-serif";
    ctx.fillText("SECONDS", ARENA.cx, 72);
    ctx.restore();
  }

  function drawSlopeVectorDebug() {
    if (!state?.player) return;
    const k = domeKinematics(state.player);
    if (k.slope < 0.5) return;
    ctx.save();
    ctx.globalAlpha = 0.28;
    ctx.strokeStyle = state.player.rpm < LOW_RPM ? "#ef476f" : "#54e0ff";
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.moveTo(state.player.x, state.player.y);
    ctx.lineTo(state.player.x - k.radialX * 42 * k.slope, state.player.y - k.radialY * 42 * k.slope);
    ctx.stroke();
    ctx.restore();
  }

  seedMatchState();
})();
