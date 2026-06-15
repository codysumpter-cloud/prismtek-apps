// Spin Street Showdown Bit Beast upgrade layer.
// Adds original procedural summon animations and lightweight RPM/clash feedback.

(() => {
  const required = ["state", "ctx", "canvas", "freshRun", "draw", "summonSpiritSurge", "drawSpiritSurge"];
  for (const binding of required) {
    try {
      if (typeof globalThis.eval(binding) === "undefined") return;
    } catch {
      return;
    }
  }

  const beasts = [
    { id: "astral-lynx", name: "Astral Lynx", glyph: "LX", colors: ["#8f6bff", "#54e0ff", "#f6f1de"], shape: "lynx" },
    { id: "chrome-wyvern", name: "Chrome Wyvern", glyph: "WY", colors: ["#ff4f7b", "#ffd34e", "#f6f1de"], shape: "wyvern" },
    { id: "vault-tortoise", name: "Vault Tortoise", glyph: "VT", colors: ["#70ff8d", "#7df9c7", "#16382e"], shape: "tortoise" },
    { id: "pulse-raven", name: "Pulse Raven", glyph: "RV", colors: ["#06d6a0", "#111425", "#f6f1de"], shape: "raven" },
    { id: "comet-wolf", name: "Comet Wolf", glyph: "CW", colors: ["#6cc4ff", "#f6f1de", "#0f1e3d"], shape: "wolf" },
    { id: "neon-kirin", name: "Neon Kirin", glyph: "KR", colors: ["#ffd166", "#ff8df3", "#31194f"], shape: "kirin" }
  ];

  const originalFreshRun = freshRun;
  const originalDraw = draw;
  const originalSummonSpiritSurge = summonSpiritSurge;
  const originalDrawSpiritSurge = drawSpiritSurge;
  const originalResolveTopCollision = typeof resolveTopCollision === "function" ? resolveTopCollision : null;

  freshRun = function bitBeastFreshRun(mode = "cpu") {
    const result = originalFreshRun(mode);
    ensureBitBeastState();
    flashMessage?.("Bit Beasts are online: win the angle, then call the beast.");
    return result;
  };

  if (originalResolveTopCollision) {
    resolveTopCollision = function bitBeastCollision(a, b, aStats, bStats, dt, npcOnly = false) {
      const beforeA = a ? { hp: a.hp, vx: a.vx, vy: a.vy, charge: a.charge } : null;
      const beforeB = b ? { hp: b.hp, vx: b.vx, vy: b.vy, charge: b.charge } : null;
      const result = originalResolveTopCollision(a, b, aStats, bStats, dt, npcOnly);
      if (!a || !b || npcOnly) return result;
      const impact = Math.hypot((a.vx - b.vx), (a.vy - b.vy));
      const damaged = Math.abs((beforeA?.hp ?? a.hp) - a.hp) > 0.01 || Math.abs((beforeB?.hp ?? b.hp) - b.hp) > 0.01;
      if (damaged && impact > 3.25) {
        const winner = (beforeA?.charge ?? 0) >= (beforeB?.charge ?? 0) ? a : b;
        const loser = winner === a ? b : a;
        const beast = beastForTop(winner);
        winner.bitBeastCharge = Math.min(100, (winner.bitBeastCharge || 0) + 8 + impact);
        loser.rpm = Math.max(8, (loser.rpm || 70) - impact * 0.7);
        pushBeastEcho(winner, beast, impact > 5 ? "angle-bite" : "clash");
        floatingText?.(impact > 5 ? "ANGLE BITE" : "BEAST CLASH", (a.x + b.x) / 2, (a.y + b.y) / 2 - 42, beast.colors[0], 30);
      }
      return result;
    };
  }

  summonSpiritSurge = function bitBeastSummon(top, loadout) {
    const beast = beastForLoadout(loadout, top);
    top.bitBeastCharge = 0;
    top.rpm = Math.min(145, (top.rpm || 80) + 28);
    top.charge = Math.min(1, (top.charge || 0) + 0.45);
    pushBeastEcho(top, beast, "summon");
    flashMessage?.(`${top.role === "p2" ? "P2" : "P1"} calls ${beast.name}.`);
    return originalSummonSpiritSurge(top, loadout);
  };

  drawSpiritSurge = function bitBeastDrawSurge(surge) {
    originalDrawSpiritSurge(surge);
    const beast = surge.beast || beastForTop(surge.owner);
    const pulse = Math.sin(performance.now() / 120) * 5;
    ctx.save();
    ctx.translate(surge.x, surge.y - 8 + pulse);
    ctx.globalAlpha = Math.min(0.78, surge.ttl / 70);
    drawBeast(beast, Math.max(46, surge.r * 1.05), Math.floor(performance.now() / 100) % 4);
    ctx.restore();
  };

  draw = function bitBeastDraw() {
    ensureBitBeastState();
    originalDraw();
    drawBeastEchoes();
    drawBeastMeters();
  };

  function ensureBitBeastState() {
    if (!state) return;
    state.bitBeastEchoes ??= [];
    for (const top of [state.player, state.player2, ...(state.rivals || [])].filter(Boolean)) {
      top.bitBeastCharge ??= top.spirit || 0;
      top.rpm ??= 76;
    }
  }

  function beastForTop(top) {
    const loadout = top?.role === "p2" ? state?.p2Equipped : state?.equipped;
    return beastForLoadout(loadout, top);
  }

  function beastForLoadout(loadout, top) {
    const chipIndex = loadout?.chip && typeof partIndex === "function" ? partIndex(loadout.chip) : top?.rank || 0;
    return beasts[Math.abs(chipIndex) % beasts.length];
  }

  function pushBeastEcho(owner, beast, kind) {
    state.bitBeastEchoes.push({
      owner,
      beast,
      kind,
      x: owner.x,
      y: owner.y,
      vx: (owner.vx || 0) * 0.2,
      vy: (owner.vy || 0) * 0.2 - 0.35,
      life: kind === "summon" ? 100 : 52,
      maxLife: kind === "summon" ? 100 : 52,
      seed: Math.random() * 10
    });
  }

  function drawBeastEchoes() {
    state.bitBeastEchoes = state.bitBeastEchoes.filter((echo) => (echo.life -= 1) > 0);
    for (const echo of state.bitBeastEchoes) {
      echo.x += echo.vx;
      echo.y += echo.vy;
      echo.vx *= 0.96;
      echo.vy *= 0.96;
      const t = 1 - echo.life / echo.maxLife;
      ctx.save();
      ctx.translate(echo.x, echo.y - 68 - t * 18);
      ctx.globalAlpha = Math.max(0, 0.72 - t * 0.45);
      drawBeast(echo.beast, 54 + Math.sin(t * Math.PI) * 26, Math.floor(performance.now() / 90 + echo.seed) % 4);
      ctx.restore();
    }
  }

  function drawBeastMeters() {
    drawMeter(state.player, 58, 118, "P1 BEAST");
    if (state.mode === "pvp" && state.player2) drawMeter(state.player2, 710, 118, "P2 BEAST");
  }

  function drawMeter(top, x, y, label) {
    if (!top) return;
    const value = Math.min(1, Math.max(0, (top.bitBeastCharge || top.spirit || 0) / 100));
    ctx.save();
    ctx.fillStyle = "#140d16";
    ctx.fillRect(x, y, 170, 7);
    const gradient = ctx.createLinearGradient(x, y, x + 170, y);
    gradient.addColorStop(0, "#8f6bff");
    gradient.addColorStop(0.55, "#54e0ff");
    gradient.addColorStop(1, "#ffd34e");
    ctx.fillStyle = gradient;
    ctx.fillRect(x, y, 170 * value, 7);
    ctx.strokeStyle = "#f6f1de";
    ctx.strokeRect(x, y, 170, 7);
    ctx.fillStyle = "#f6f1de";
    ctx.font = "700 9px system-ui, sans-serif";
    ctx.fillText(`${label} ${Math.round(value * 100)}%`, x + 5, y + 18);
    ctx.restore();
  }

  function drawBeast(beast, size, frame) {
    const [primary, secondary, ink] = beast.colors;
    ctx.save();
    ctx.shadowColor = primary;
    ctx.shadowBlur = 16;
    ctx.fillStyle = `${primary}33`;
    ctx.beginPath();
    ctx.arc(0, 0, size * 0.58, 0, Math.PI * 2);
    ctx.fill();
    ctx.shadowBlur = 0;
    if (beast.shape === "lynx") drawLynx(size, primary, secondary, ink, frame);
    else if (beast.shape === "wyvern") drawWyvern(size, primary, secondary, ink, frame);
    else if (beast.shape === "tortoise") drawTortoise(size, primary, secondary, ink, frame);
    else if (beast.shape === "raven") drawRaven(size, primary, secondary, ink, frame);
    else if (beast.shape === "wolf") drawWolf(size, primary, secondary, ink, frame);
    else drawKirin(size, primary, secondary, ink, frame);
    ctx.fillStyle = ink;
    ctx.font = `900 ${Math.max(10, size * 0.18)}px system-ui, sans-serif`;
    ctx.textAlign = "center";
    ctx.textBaseline = "middle";
    ctx.fillText(beast.glyph, 0, size * 0.48);
    ctx.restore();
  }

  function drawLynx(s, p, a, ink, f) {
    poly([[-.42,-.12],[-.2,-.32-f*.02],[0,-.2],[.2,-.32-f*.02],[.42,-.12],[.22,.24],[0,.34],[-.22,.24]], s, p);
    rect(-s*.18, -s*.05, s*.1, s*.1, a); rect(s*.08, -s*.05, s*.1, s*.1, a);
    strokeArc(s*.31, s*.12, s*.25, -1.4, 1.2, ink, 4);
  }

  function drawWyvern(s, p, a, ink, f) {
    const flap = Math.sin(f * Math.PI / 2) * .12;
    poly([[-.08,-.36],[.28,-.08],[.08,.34],[-.18,.04]], s, p);
    poly([[-.08,-.08],[-.62,-.25-flap],[-.34,.2],[-.04,.06]], s, a);
    poly([[.08,-.08],[.62,-.25-flap],[.34,.2],[.04,.06]], s, a);
    rect(s*.1, -s*.18, s*.08, s*.08, ink);
  }

  function drawTortoise(s, p, a, ink, f) {
    polygon(0, 0, s*.36, 6, p, ink, f*.08);
    rect(-s*.12, -s*.46, s*.24, s*.18, a);
    rect(-s*.48, -s*.08, s*.18, s*.16, a); rect(s*.3, -s*.08, s*.18, s*.16, a);
  }

  function drawRaven(s, p, a, ink, f) {
    const flap = Math.sin(f * Math.PI / 2) * .14;
    poly([[-.1,-.08],[-.68,-.18-flap],[-.34,.16],[0,.08],[.34,.16],[.68,-.18-flap],[.1,-.08],[0,-.28]], s, a);
    rect(-s*.1, -s*.2, s*.2, s*.28, p); rect(-s*.04, -s*.32, s*.08, s*.08, ink);
  }

  function drawWolf(s, p, a, ink, f) {
    const snap = f % 2 ? .06 : 0;
    poly([[-.46,-.08],[-.18,-.36],[.3,-.28],[.5,-.02],[.22,.24+snap],[-.24,.2]], s, p);
    rect(s*.12, -s*.13, s*.1, s*.08, a); line(s*.28, s*.07, s*.5, s*.02, ink, 4);
  }

  function drawKirin(s, p, a, ink, f) {
    const pulse = Math.sin(f * Math.PI / 2) * .08;
    poly([[-.34,.18],[-.16,-.18],[.18,-.2],[.42,.02],[.2,.28]], s, p);
    poly([[0,-.22],[.08,-.62-pulse],[.16,-.2]], s, a);
    line(-s*.3, s*.2, -s*.52, s*(.38+pulse), a, 4); rect(s*.18, -s*.08, s*.08, s*.08, ink);
  }

  function rect(x, y, w, h, fill) { ctx.fillStyle = fill; ctx.fillRect(Math.round(x), Math.round(y), Math.round(w), Math.round(h)); }
  function line(x1, y1, x2, y2, stroke, width) { ctx.strokeStyle = stroke; ctx.lineWidth = width; ctx.beginPath(); ctx.moveTo(x1, y1); ctx.lineTo(x2, y2); ctx.stroke(); }
  function strokeArc(x, y, r, start, end, stroke, width) { ctx.strokeStyle = stroke; ctx.lineWidth = width; ctx.beginPath(); ctx.arc(x, y, r, start, end); ctx.stroke(); }
  function poly(points, size, fill) { ctx.fillStyle = fill; ctx.beginPath(); points.forEach(([x, y], i) => i ? ctx.lineTo(x * size, y * size) : ctx.moveTo(x * size, y * size)); ctx.closePath(); ctx.fill(); }
  function polygon(x, y, radius, sides, fill, stroke, rotation = 0) {
    ctx.save(); ctx.translate(x, y); ctx.rotate(rotation); ctx.fillStyle = fill; ctx.strokeStyle = stroke; ctx.lineWidth = 3; ctx.beginPath();
    for (let i = 0; i < sides; i++) {
      const angle = -Math.PI / 2 + (Math.PI * 2 * i) / sides;
      const px = Math.cos(angle) * radius;
      const py = Math.sin(angle) * radius;
      if (i === 0) ctx.moveTo(px, py); else ctx.lineTo(px, py);
    }
    ctx.closePath(); ctx.fill(); ctx.stroke(); ctx.restore();
  }

  ensureBitBeastState();
})();
