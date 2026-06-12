export const FRUITS = {
  flame: {
    id: "flame",
    name: "Flame Fruit",
    color: "#ff6b35",
    icon: "F",
    awakening: "Inferno Mode",
    abilities: [
      { id: "fireball", name: "Fireball", kind: "projectile", damage: 11, knockback: 360, cooldown: 0.55, speed: 520 },
      { id: "flame_dash", name: "Flame Dash", kind: "dash", damage: 9, knockback: 430, cooldown: 0.9, speed: 760 },
      { id: "burning_uppercut", name: "Burning Uppercut", kind: "uppercut", damage: 15, knockback: 620, cooldown: 1.1 }
    ]
  },
  frost: {
    id: "frost",
    name: "Frost Fruit",
    color: "#8fd8ff",
    icon: "I",
    awakening: "Frozen Domain",
    abilities: [
      { id: "ice_spike", name: "Ice Spike", kind: "projectile", damage: 9, knockback: 320, cooldown: 0.5, speed: 480 },
      { id: "freeze_field", name: "Freeze Field", kind: "field", damage: 5, knockback: 180, cooldown: 1.5, slow: 0.55 },
      { id: "ice_slide", name: "Ice Slide", kind: "dash", damage: 8, knockback: 390, cooldown: 0.8, speed: 700 }
    ]
  },
  volt: {
    id: "volt",
    name: "Volt Fruit",
    color: "#ffe45e",
    icon: "V",
    awakening: "Thunderstorm",
    abilities: [
      { id: "lightning_bolt", name: "Lightning Bolt", kind: "beam", damage: 10, knockback: 350, cooldown: 0.55, speed: 900 },
      { id: "blink_dash", name: "Blink Dash", kind: "blink", damage: 6, knockback: 300, cooldown: 0.75, speed: 840 },
      { id: "chain_shock", name: "Chain Shock", kind: "chain", damage: 13, knockback: 460, cooldown: 1.2 }
    ]
  },
  shadow: {
    id: "shadow",
    name: "Shadow Fruit",
    color: "#7c5cff",
    icon: "S",
    awakening: "Abyss Form",
    abilities: [
      { id: "pull_field", name: "Pull Field", kind: "pull", damage: 4, knockback: -260, cooldown: 1.0 },
      { id: "shadow_burst", name: "Shadow Burst", kind: "burst", damage: 13, knockback: 430, cooldown: 0.95 },
      { id: "null_zone", name: "Null Zone", kind: "field", damage: 6, knockback: 150, cooldown: 1.6, slow: 0.35 }
    ]
  },
  rubber: {
    id: "rubber",
    name: "Rubber Fruit",
    color: "#ff8fab",
    icon: "R",
    awakening: "Freedom Form",
    abilities: [
      { id: "stretch_punch", name: "Stretch Punch", kind: "melee", damage: 10, knockback: 390, cooldown: 0.45, range: 88 },
      { id: "bounce_jump", name: "Bounce Jump", kind: "jump", damage: 7, knockback: 340, cooldown: 0.85 },
      { id: "giant_fist", name: "Giant Fist", kind: "heavy", damage: 17, knockback: 650, cooldown: 1.35, range: 110 }
    ]
  },
  gravity: {
    id: "gravity",
    name: "Gravity Fruit",
    color: "#9be564",
    icon: "G",
    awakening: "Singularity Mode",
    abilities: [
      { id: "pull", name: "Pull", kind: "pull", damage: 5, knockback: -330, cooldown: 0.75 },
      { id: "slam", name: "Slam", kind: "slam", damage: 16, knockback: 620, cooldown: 1.25 },
      { id: "float_strike", name: "Float Strike", kind: "uppercut", damage: 12, knockback: 500, cooldown: 0.95 }
    ]
  }
};

export function masteryFor(character, fruitId) {
  return character.fruit_mastery?.[fruitId] || 0;
}

export function gainMastery(character, fruitId, amount) {
  character.fruit_mastery[fruitId] = Math.min(100, masteryFor(character, fruitId) + amount);
}
