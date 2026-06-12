import { applyAttack, checkRingOut, createFighter, updateFighter } from "../combat/combatSystem.js";

export function createMatch({ stage, players, fruits }) {
  const fighters = players.map((player, index) => createFighter({
    slot: player.slot,
    character: player.character,
    fruitId: player.fruitId,
    fruit: fruits[player.fruitId],
    spawn: stage.respawns[index]
  }));
  const events = [];
  const effects = [];
  let elapsed = 0;

  return {
    update(dt, actions) {
      elapsed += dt;
      events.length = 0;
      for (let i = effects.length - 1; i >= 0; i -= 1) {
        effects[i].ttl -= dt;
        if (effects[i].ttl <= 0) effects.splice(i, 1);
      }
      for (const f of fighters) {
        if (f.stocks <= 0) continue;
        const input = resolveInput(f, actions, fighters);
        updateFighter(f, dt, input, stage);
        if (f.slowTime <= 0) f.slowFactor = 1;
      }
      for (const action of actions.filter((a) => a.type === "attack")) {
        const f = fighters[action.slot];
        if (!f || f.stocks <= 0) continue;
        applyAttack(f, fighters.filter((other) => other !== f), f.fruit.abilities[action.index], events);
      }
      effects.push(...events);
      for (const f of fighters) {
        if (f.stocks > 0 && checkRingOut(f, stage)) {
          const spawn = stage.respawns[f.slot % stage.respawns.length];
          f.x = spawn.x;
          f.y = spawn.y;
          f.invulnerable = 1.35;
          effects.push({ ttl: 0.65, type: "ringout", fighter: f.id, x: spawn.x, y: spawn.y, color: f.fruit.color });
        }
      }
    },
    snapshot() {
      return { stage, fighters, effects: [...effects], events: [...events], elapsed };
    },
    isComplete() {
      return fighters.filter((f) => f.stocks > 0).length <= 1;
    },
    winner() {
      return fighters.find((f) => f.stocks > 0) || null;
    }
  };
}

function resolveInput(f, actions, fighters) {
  const own = actions.filter((a) => a.slot === f.slot);
  const input = {
    move: own.find((a) => a.type === "move")?.value || 0,
    jump: own.some((a) => a.type === "jump"),
    dodge: own.some((a) => a.type === "dodge"),
    awaken: own.some((a) => a.type === "awaken")
  };
  if (f.ai) {
    const living = fighters.filter((other) => other !== f && other.stocks > 0);
    const target = living.sort((a, b) => Math.abs(a.x - f.x) - Math.abs(b.x - f.x))[0];
    if (target) {
      const dx = target.x - f.x;
      input.move = Math.abs(dx) > 48 ? Math.sign(dx) : 0;
      input.jump = (target.y + 24 < f.y || !f.grounded && f.y > 380) && Math.random() < 0.06;
      input.dodge = Math.abs(dx) < 48 && Math.random() < 0.01;
      input.awaken = f.awakening >= 100 && Math.random() < 0.04;
      if (Math.abs(dx) < 120 && Math.abs(target.y - f.y) < 90 && Math.random() < 0.05) {
        actions.push({ slot: f.slot, type: "attack", index: Math.floor(Math.random() * 3) });
      }
    }
  }
  return input;
}
