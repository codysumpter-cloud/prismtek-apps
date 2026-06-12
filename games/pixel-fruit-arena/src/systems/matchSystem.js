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
  let elapsed = 0;

  return {
    update(dt, actions) {
      elapsed += dt;
      events.length = 0;
      for (const f of fighters) {
        if (f.stocks <= 0) continue;
        const input = resolveInput(f, actions, fighters);
        updateFighter(f, dt, input, stage);
      }
      for (const action of actions.filter((a) => a.type === "attack")) {
        const f = fighters[action.slot];
        if (!f || f.stocks <= 0) continue;
        applyAttack(f, fighters.filter((other) => other !== f), f.fruit.abilities[action.index], events);
      }
      for (const f of fighters) {
        if (f.stocks > 0 && checkRingOut(f, stage)) {
          const spawn = stage.respawns[f.slot % stage.respawns.length];
          f.x = spawn.x;
          f.y = spawn.y;
          f.invulnerable = 1.35;
          events.push({ type: "ringout", fighter: f.id });
        }
      }
    },
    snapshot() {
      return { stage, fighters, events: [...events], elapsed };
    },
    isComplete() {
      return fighters.filter((f) => f.stocks > 0).length <= 1;
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
  if (f.ai && Math.random() < 0.03) {
    const living = fighters.filter((other) => other !== f && other.stocks > 0);
    const target = living[0];
    if (target) {
      input.move = Math.sign(target.x - f.x);
      input.jump = target.y + 20 < f.y && Math.random() < 0.1;
      if (Math.abs(target.x - f.x) < 120) actions.push({ slot: f.slot, type: "attack", index: Math.floor(Math.random() * 3) });
    }
  }
  return input;
}
