(() => {
  const ROUND_SECONDS = 40;
  const RPM_MAX = 100;
  const LOW_RPM = 22;

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
    if (top.rpm < LOW_RPM) {
      top.vx *= 0.985;
      top.vy *= 0.985;
      top.tilt = Math.min(1.1, top.tilt + 0.004 * dt);
    }
  };

  physics = function upgradedPhysics(top, stats, dt) {
    originalPhysics(top, stats, dt);
    seedRPM(top);
    const seconds = dt / 60;
    const speed = Math.hypot(top.vx, top.vy);
    const wobblePenalty = 1 - clamp(top.stability / Math.max(0.5, stats.stability), 0, 1);
    drainRPM(top, seconds * (1.15 + speed * 0.09 + top.tilt * 0.35 + wobblePenalty * 1.8), "spin");
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
  };

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

  seedMatchState();
})();
