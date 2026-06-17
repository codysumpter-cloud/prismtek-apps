export const COMBAT_STYLES = {
  duelist: {
    id: "duelist",
    name: "Duelist",
    summary: "Balanced footwork and reliable cooldowns.",
    speed: 1,
    jump: 1,
    damage: 1,
    knockback: 1,
    range: 1,
    cooldown: 1,
    weight: 1,
    dodge: 1
  },
  brawler: {
    id: "brawler",
    name: "Brawler",
    summary: "Close-range pressure with heavier hits.",
    speed: 0.94,
    jump: 0.98,
    damage: 1.1,
    knockback: 1.08,
    range: 0.92,
    cooldown: 1.05,
    weight: 1.06,
    dodge: 0.95
  },
  striker: {
    id: "striker",
    name: "Striker",
    summary: "Fast movement, quick confirms, lighter hits.",
    speed: 1.13,
    jump: 1.05,
    damage: 0.94,
    knockback: 0.96,
    range: 1,
    cooldown: 0.92,
    weight: 0.96,
    dodge: 1.12
  },
  ranger: {
    id: "ranger",
    name: "Ranger",
    summary: "Longer specials and safer spacing.",
    speed: 0.98,
    jump: 1,
    damage: 0.97,
    knockback: 0.98,
    range: 1.24,
    cooldown: 1,
    weight: 0.98,
    dodge: 1
  },
  guardian: {
    id: "guardian",
    name: "Guardian",
    summary: "Harder to launch, slower to reposition.",
    speed: 0.9,
    jump: 0.94,
    damage: 1.02,
    knockback: 1,
    range: 1,
    cooldown: 1.04,
    weight: 1.18,
    dodge: 0.9
  },
  trickster: {
    id: "trickster",
    name: "Trickster",
    summary: "Sharper dodges and cooldowns with lower power.",
    speed: 1.07,
    jump: 1.08,
    damage: 0.9,
    knockback: 0.92,
    range: 1.05,
    cooldown: 0.88,
    weight: 0.94,
    dodge: 1.25
  }
};

export function styleFor(id) {
  return COMBAT_STYLES[id] || COMBAT_STYLES.duelist;
}
