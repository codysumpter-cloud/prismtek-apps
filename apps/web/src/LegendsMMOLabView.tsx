import { useMemo, useState } from 'react';
import {
  applyTurn,
  createBattleCreature,
  createPlayerProfile,
  createSaveGameSnapshot,
  findMap,
  healParty,
  indexById,
  maybeRollEncounter,
  movePosition,
  starterContentPack,
  type BattleState,
  type Direction,
  type EncounterTable,
  type PlayerProfile,
  type WorldState,
} from '@prismtek/legendsmmo';

const encounterTable: EncounterTable = {
  id: 'starter-grove-grass',
  mapId: 'starter-grove',
  stepChance: 0.28,
  entries: [
    { speciesId: 'mossprout', minLevel: 2, maxLevel: 4, weight: 70 },
    { speciesId: 'budlit', minLevel: 2, maxLevel: 3, weight: 30 },
  ],
};

const initialWorld: WorldState = { activePlayers: {}, tick: 0 };

function createInitialPlayer(): PlayerProfile {
  const budlit = starterContentPack.creatures.find((creature) => creature.id === 'budlit');
  if (!budlit) throw new Error('Missing starter Budlit.');
  const battleCreature = createBattleCreature('starter-budlit', budlit, 5, ['spark-tap', 'focus-hum']);
  return createPlayerProfile({
    id: 'local-player',
    displayName: 'Prismtek',
    position: { mapId: 'starter-grove', x: 1, y: 2, facing: 'down' },
    party: {
      activeSlot: 0,
      members: [
        {
          instanceId: battleCreature.instanceId,
          speciesId: battleCreature.species.id,
          nickname: 'Buddy',
          level: battleCreature.level,
          currentHp: battleCreature.currentHp,
          stats: battleCreature.stats,
          knownMoveIds: battleCreature.knownMoveIds,
          experience: 0,
          capturedAt: new Date().toISOString(),
        },
      ],
    },
    inventory: { currency: 100, stacks: [{ itemId: 'camp-snack', quantity: 3 }] },
  });
}

export function LegendsMMOLabView() {
  const speciesById = useMemo(() => indexById(starterContentPack.creatures), []);
  const movesById = useMemo(() => indexById(starterContentPack.moves), []);
  const map = useMemo(() => findMap(starterContentPack, 'starter-grove'), []);
  const [player, setPlayer] = useState<PlayerProfile>(() => createInitialPlayer());
  const [world, setWorld] = useState<WorldState>(initialWorld);
  const [battle, setBattle] = useState<BattleState | null>(null);
  const [log, setLog] = useState<string[]>(['LegendsMMO lab loaded. Walk the grove to roll encounters.']);

  const activeMember = player.party.members[player.party.activeSlot];

  function append(message: string) {
    setLog((messages) => [message, ...messages].slice(0, 8));
  }

  function move(direction: Direction) {
    if (battle) {
      append('Finish the battle before moving.');
      return;
    }

    const nextPosition = movePosition(player.position, direction, map);
    const moved = nextPosition.x !== player.position.x || nextPosition.y !== player.position.y;
    const nextPlayer = { ...player, position: nextPosition, updatedAt: new Date().toISOString() };
    setPlayer(nextPlayer);
    setWorld((current) => ({
      tick: current.tick + 1,
      activePlayers: { ...current.activePlayers, [nextPlayer.id]: nextPosition },
    }));

    if (!moved) {
      append('Bump. That tile is blocked.');
      return;
    }

    const encounter = maybeRollEncounter({ position: nextPosition, table: encounterTable, species: speciesById });
    if (!encounter) {
      append(`Moved ${direction}. No encounter.`);
      return;
    }

    const wild = createBattleCreature(`wild-${encounter.species.id}-${Date.now()}`, encounter.species, encounter.level, [encounter.species.learnset[0]?.moveId].filter(Boolean));
    const starterSpecies = speciesById.get(activeMember.speciesId);
    if (!starterSpecies) throw new Error(`Missing species ${activeMember.speciesId}.`);
    const buddy = {
      instanceId: activeMember.instanceId,
      species: starterSpecies,
      level: activeMember.level,
      currentHp: activeMember.currentHp,
      stats: activeMember.stats,
      knownMoveIds: activeMember.knownMoveIds,
    };

    setBattle({
      id: `battle-${Date.now()}`,
      turn: 0,
      sideA: { trainerId: player.id, active: buddy, bench: [] },
      sideB: { trainerId: 'wild', active: wild, bench: [] },
      log: [{ turn: 0, message: `A wild ${encounter.species.name} appeared!` }],
      status: 'active',
    });
    append(`A wild ${encounter.species.name} appeared!`);
  }

  function useMove(moveId: string) {
    if (!battle) return;
    const wildMove = battle.sideB.active.knownMoveIds[0];
    const nextBattle = applyTurn(
      battle,
      movesById,
      { side: 'A', moveId },
      { side: 'B', moveId: wildMove },
    );
    setBattle(nextBattle);
    append(nextBattle.log.at(-1)?.message ?? 'Turn resolved.');
    if (nextBattle.status !== 'active') {
      append(`Battle ended: ${nextBattle.status}`);
      setPlayer((current) => ({
        ...current,
        party: {
          ...current.party,
          members: current.party.members.map((member, index) =>
            index === current.party.activeSlot ? { ...member, currentHp: nextBattle.sideA.active.currentHp } : member,
          ),
        },
      }));
    }
  }

  function rest() {
    setBattle(null);
    setPlayer((current) => ({ ...current, party: healParty(current.party), updatedAt: new Date().toISOString() }));
    append('Party healed at camp.');
  }

  function save() {
    const snapshot = createSaveGameSnapshot({ contentPack: starterContentPack.manifest, player, world });
    localStorage.setItem('legendsmmo.lab.save', JSON.stringify(snapshot));
    append('Saved local LegendsMMO lab snapshot.');
  }

  const activeMoveIds = battle?.sideA.active.knownMoveIds ?? activeMember.knownMoveIds;

  return (
    <div className="space-y-6">
      <div>
        <p className="text-sm uppercase tracking-[0.3em] text-emerald-300/70">Playable Prototype</p>
        <h2 className="text-3xl font-bold">LegendsMMO Lab</h2>
        <p className="mt-2 max-w-3xl text-white/50">
          Walk around Starter Grove, trigger weighted encounters, resolve turn-based battles, heal at camp, and save a local snapshot.
        </p>
      </div>

      <div className="grid gap-6 lg:grid-cols-[1.1fr_0.9fr]">
        <section className="rounded-2xl border border-white/10 bg-[#0f0f0f] p-6">
          <div className="mb-4 flex items-center justify-between">
            <div>
              <h3 className="font-bold">{map.name}</h3>
              <p className="text-sm text-white/40">Position {player.position.x}, {player.position.y} · facing {player.position.facing}</p>
            </div>
            <button onClick={save} className="rounded-lg bg-white/10 px-3 py-2 text-sm hover:bg-white/15">Save</button>
          </div>

          <div className="inline-grid gap-1 rounded-xl bg-black/30 p-3" style={{ gridTemplateColumns: `repeat(${map.width}, minmax(0, 3rem))` }}>
            {map.layers[0].tiles.map((tile, index) => {
              const x = index % map.width;
              const y = Math.floor(index / map.width);
              const isPlayer = player.position.x === x && player.position.y === y;
              const glyph = isPlayer ? '▲' : tile === 3 ? '♣' : tile === 2 ? '░' : '·';
              return (
                <div
                  key={`${x}-${y}`}
                  className={`flex h-12 w-12 items-center justify-center rounded-lg border text-lg ${isPlayer ? 'border-emerald-300 bg-emerald-500/30 text-emerald-100' : 'border-white/5 bg-white/5 text-white/35'}`}
                >
                  {glyph}
                </div>
              );
            })}
          </div>

          <div className="mt-5 grid w-40 grid-cols-3 gap-2">
            <span />
            <button onClick={() => move('up')} className="rounded-lg bg-white/10 py-2 hover:bg-white/15">↑</button>
            <span />
            <button onClick={() => move('left')} className="rounded-lg bg-white/10 py-2 hover:bg-white/15">←</button>
            <button onClick={rest} className="rounded-lg bg-emerald-500/20 py-2 text-xs text-emerald-200 hover:bg-emerald-500/30">Rest</button>
            <button onClick={() => move('right')} className="rounded-lg bg-white/10 py-2 hover:bg-white/15">→</button>
            <span />
            <button onClick={() => move('down')} className="rounded-lg bg-white/10 py-2 hover:bg-white/15">↓</button>
          </div>
        </section>

        <section className="space-y-4">
          <div className="rounded-2xl border border-white/10 bg-[#0f0f0f] p-6">
            <h3 className="mb-3 font-bold">Party</h3>
            <p className="text-lg">{activeMember.nickname ?? activeMember.speciesId}</p>
            <p className="text-sm text-white/40">Lv. {activeMember.level} · HP {activeMember.currentHp}/{activeMember.stats.hp}</p>
            <p className="mt-2 text-sm text-white/40">Bag: {player.inventory.stacks.map((stack) => `${stack.itemId} x${stack.quantity}`).join(', ')}</p>
          </div>

          <div className="rounded-2xl border border-white/10 bg-[#0f0f0f] p-6">
            <h3 className="mb-3 font-bold">Battle</h3>
            {!battle ? (
              <p className="text-sm text-white/40">No active battle. Walk through the grove to find one.</p>
            ) : (
              <div className="space-y-4">
                <div className="rounded-xl bg-white/5 p-3">
                  <p className="text-sm text-white/40">Wild</p>
                  <p>{battle.sideB.active.species.name} · HP {battle.sideB.active.currentHp}/{battle.sideB.active.stats.hp}</p>
                </div>
                <div className="rounded-xl bg-white/5 p-3">
                  <p className="text-sm text-white/40">Buddy</p>
                  <p>{battle.sideA.active.species.name} · HP {battle.sideA.active.currentHp}/{battle.sideA.active.stats.hp}</p>
                </div>
                <div className="flex flex-wrap gap-2">
                  {activeMoveIds.map((moveId) => {
                    const move = movesById.get(moveId);
                    return <button key={moveId} onClick={() => useMove(moveId)} className="rounded-lg bg-blue-500/20 px-3 py-2 text-sm text-blue-100 hover:bg-blue-500/30">{move?.name ?? moveId}</button>;
                  })}
                  <button onClick={() => setBattle(null)} className="rounded-lg bg-white/10 px-3 py-2 text-sm hover:bg-white/15">Run</button>
                </div>
              </div>
            )}
          </div>

          <div className="rounded-2xl border border-white/10 bg-[#0f0f0f] p-6">
            <h3 className="mb-3 font-bold">Log</h3>
            <div className="space-y-2 text-sm text-white/55">
              {log.map((entry, index) => <p key={`${entry}-${index}`}>{entry}</p>)}
            </div>
          </div>
        </section>
      </div>
    </div>
  );
}
