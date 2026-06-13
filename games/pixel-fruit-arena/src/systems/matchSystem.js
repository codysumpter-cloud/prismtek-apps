import { applyAttack, checkRingOut, createFighter, updateFighter } from "../combat/combatSystem.js";

export function createMatch({ stage, players, fruits, training = false }) {
  const fighters = players.map((player, index) => createFighter({
    slot: player.slot,
    character: player.character,
    fruitId: player.fruitId,
    fruit: fruits[player.fruitId],
    spawn: stage.respawns[index % stage.respawns.length]
  }));
  const events = [];
  const effects = [];
  let elapsed = 0;

  return {
    stage,
    training,
    update(dt, actions) {
      elapsed += dt;
      events.length = 0;
      for (let i = effects.length - 1; i >= 0; i -= 1) {
        effects[i].age = (effects[i].age || 0) + dt;
        effects[i].ttl -= dt;
        if (effects[i].ttl <= 0) effects.splice(i, 1);
      }
      for (const f of fighters) {
        if (f.stocks <= 0) continue;
        const input = resolveInput(f, actions, fighters);
        updateFighter(f, dt, input, stage);
        if (f.slowTime <= 0) f.slowFactor = 1;
        if (training && f.dummy) {
          if (f.hitstun > 0) f.lastHitAt = elapsed;
          if (f.damage > 0 && elapsed - (f.lastHitAt || 0) > 3) f.damage = 0;
        }
      }
      for (const action of actions.filter((a) => a.type === "attack")) {
        const f = fighters.find((fighter) => fighter.slot === action.slot);
        if (!f || f.stocks <= 0) continue;
        applyAttack(f, fighters.filter((other) => other !== f), f.fruit.abilities[action.index], events);
      }
      effects.push(...events.map((event) => ({ age: 0, duration: event.duration || event.ttl || 0.25, ...event })));
      for (const f of fighters) {
        if (f.stocks > 0 && checkRingOut(f, stage)) {
          if (training) f.stocks += 1; // infinite stocks while practicing
          const spawn = stage.respawns[f.slot % stage.respawns.length];
          f.x = spawn.x;
          f.y = spawn.y;
          f.invulnerable = 1.35;
          effects.push({ age: 0, ttl: 0.65, duration: 0.65, type: "ringout", fighter: f.id, x: spawn.x, y: spawn.y, color: f.fruit.color });
        }
      }
    },
    snapshot() {
      return { stage, fighters, effects: [...effects], events: [...events], elapsed, training };
    },
    isComplete() {
      if (training) return false;
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
    aim: own.find((a) => a.type === "aim")?.value || 0,
    jump: own.some((a) => a.type === "jump"),
    dodge: own.some((a) => a.type === "dodge"),
    awaken: own.some((a) => a.type === "awaken")
  };
  if (f.ai && !f.dummy) {
    const living = fighters.filter((other) => other !== f && other.stocks > 0);
    const target = living.sort((a, b) => Math.abs(a.x - f.x) - Math.abs(b.x - f.x))[0];
    if (target) {
      const dx = target.x - f.x;
      input.move = Math.abs(dx) > 48 ? Math.sign(dx) : 0;
      input.jump = (target.y + 24 < f.y || !f.grounded && f.y > 380) && Math.random() < 0.06;
      input.dodge = Math.abs(dx) < 48 && Math.random() < 0.01;
      input.awaken = f.awakening >= 100 && Math.random() < 0.04;
      // CPUs occasionally use directional attack variants too.
      if (Math.random() < 0.35) input.aim = target.y + 30 < f.y ? -1 : target.y > f.y + 60 ? 1 : 0;
      if (Math.abs(dx) < 120 && Math.abs(target.y - f.y) < 90 && Math.random() < 0.05) {
        actions.push({ slot: f.slot, type: "attack", index: Math.floor(Math.random() * 3) });
      }
    }
  }
  return input;
}
