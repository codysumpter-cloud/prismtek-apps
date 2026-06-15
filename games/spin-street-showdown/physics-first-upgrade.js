(() => {
  const ROUND_SECONDS = 40;
  const RPM_MAX = 100;
  const LOW_RPM = 22;
  const GRAVITY_PULL = 0.18;
  const UPHILL_DRAG = 0.075;
  const DOWNHILL_BOOST = 0.115;
  const TANGENTIAL_KEEP = 0.018;

  const originalFreshRun = freshRun;
  const originalTopEntity = topEntity;
  const originalUpdate = update;
  const originalPhysics = physics;
  const originalSteerPlayer = steerPlayer;
  const originalResolveTopCollision = resolveTopCollision;
  const originalUseBladeMove = useBladeMove;
  const originalWinRound = winRound;
  const originalEndRun = endRun;
  const originalDraw = draw;

  ui.rpm = document.getElementById("rpm");
  ui.timer = document.getElementById("timer");

  topEntity = function upgradedTopEntity(...args) {
    const top = originalTopEntity(...args);
    seedRPM(top);
    return top;
  };

  freshRun = function upgradedFreshRun(mode = "cpu") {
    originalFreshRun(mode);
    seedMatchState();
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
    const chargeHeld = p2 ? keys.has("u") : pointer.down || keys.has(" ");
    if (chargeHeld) drainRPM(top, (0.08 + stats.charge * 0.02) * dt, "charge");
    applyDriverPatternControl(top, stats, p2 ? state.p2Equipped : state.equipped, scheme, dt);
    if (top.rpm < LOW_RPM) {
      top.vx *= 0.985;
      top.vy *= 0.985;
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
    drainRPM(top, seconds * (1.05 + speed * 0.07 + top.tilt * 0.32 + wobblePenalty * 1.7 + slope * 0.55), "spin");
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

    const rpmHit = 1.8 + impactSpeed * 0.34 + Math.max(0, edgePressure - 0.72) * 7;
    drainRPM(a, rpmHit * (a.guard > 0 ? 0.52 : 1), "clash");
    drainRPM(b, rpmHit * (b.guard > 0 ? 0.52 : 1), "clash");
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
    const cost = speed > 6.2 || top.charge > 0.7 ? 5 : 12;
    if (top.rpm < cost + 4) {
      floatingText("LOW RPM", top.x, top.y - 38, "#ffd34e", 30);
      top.moveCd = Math.max(top.moveCd, 18);
      return;
    }
    drainRPM(top, cost, "dash");
    originalUseBladeMove(top, dx, dy, stats);
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
      drainRPM(top, slow * 0.42, "uphill");
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
    const control = 0.035 * stats.speed * rpmScale;
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
    top.maxRpm = top.maxRpm || RPM_MAX;
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
    const pct = clamp((state.player.rpm ?? RPM_MAX) / RPM_MAX, 0, 1);
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
    ctx.fillText(`RPM ${Math.round(pct * 100)}%`, x + w / 2, y + 17);
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
