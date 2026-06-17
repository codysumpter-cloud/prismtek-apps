export const PRISMCADE_PLAYABLE_ROSTER = [
  {
    id: "buddy",
    displayName: "Buddy",
    rosterClass: "mascot",
    sourceVariantId: "buddy",
    templateFamilyId: "buddy-core",
    spriteKey: "prismcade_buddy",
    animationFidelity: "source-animation-normalized",
    defaultFighter: {
      name: "Buddy",
      fruitId: "volt",
      combatStyle: "trickster",
      appearance: {
        hairStyle: "antenna_nubs",
        clothingStyle: "buddy_shell",
        hairColor: "#72ddf7",
        skinTone: "#9ff3df",
        outfitPrimary: "#18b7a8",
        outfitSecondary: "#dffcf5",
        accessoryColor: "#ffd166"
      }
    }
  },
  {
    id: "prismtek",
    displayName: "Prismtek",
    rosterClass: "humanoid",
    sourceVariantId: "prismtek",
    templateFamilyId: "prismtek-player",
    spriteKey: "prismcade_prismtek",
    animationFidelity: "source-animation-normalized",
    defaultFighter: {
      name: "Prismtek",
      fruitId: "flame",
      combatStyle: "duelist",
      appearance: {
        hairStyle: "low_taper",
        clothingStyle: "arcade_jacket",
        hairColor: "#1b1f3b",
        skinTone: "#b97855",
        outfitPrimary: "#28536b",
        outfitSecondary: "#72ddf7",
        accessoryColor: "#ffd166"
      }
    }
  },
  {
    id: "prismtek-jones",
    displayName: "Prismtek Jones",
    rosterClass: "humanoid",
    sourceVariantId: "prismtek-jones",
    templateFamilyId: "prismtek-player",
    spriteKey: "prismcade_prismtek_jones",
    animationFidelity: "rotation-derived",
    defaultFighter: {
      name: "Prismtek Jones",
      fruitId: "gravity",
      combatStyle: "guardian",
      appearance: {
        hairStyle: "normal_hair",
        clothingStyle: "jacket",
        hairColor: "#1b1f3b",
        skinTone: "#8d563f",
        outfitPrimary: "#26344f",
        outfitSecondary: "#ef476f",
        accessoryColor: "#72ddf7"
      }
    }
  },
  {
    id: "female-blue-hoodie",
    displayName: "Female Blue Hoodie",
    rosterClass: "humanoid",
    sourceVariantId: "female-character-blue-hoodie",
    templateFamilyId: "female-blue-hoodie-player",
    spriteKey: "prismcade_female_blue_hoodie",
    animationFidelity: "rotation-derived",
    defaultFighter: {
      name: "Blue Hoodie",
      fruitId: "frost",
      combatStyle: "ranger",
      appearance: {
        hairStyle: "ponytail",
        clothingStyle: "blue_hoodie",
        hairColor: "#7f5539",
        skinTone: "#f1c6a8",
        outfitPrimary: "#28536b",
        outfitSecondary: "#72ddf7",
        accessoryColor: "#f7f7ff"
      }
    }
  },
  {
    id: "ponytail-guy",
    displayName: "Ponytail Guy",
    rosterClass: "humanoid",
    sourceVariantId: "ponytail-guy",
    templateFamilyId: "ponytail-avatar",
    spriteKey: "prismcade_ponytail_guy",
    animationFidelity: "rotation-derived",
    defaultFighter: {
      name: "Ponytail Guy",
      fruitId: "rubber",
      combatStyle: "brawler",
      appearance: {
        hairStyle: "ponytail",
        clothingStyle: "coat",
        hairColor: "#1b1f3b",
        skinTone: "#d8a17c",
        outfitPrimary: "#512d6d",
        outfitSecondary: "#f4c542",
        accessoryColor: "#06d6a0"
      }
    }
  },
  {
    id: "prismtek-pixel-god",
    displayName: "Prismtek Pixel God",
    rosterClass: "humanoid",
    sourceVariantId: "prismtek-pixel-god",
    templateFamilyId: "prismtek-player",
    spriteKey: "prismcade_prismtek_pixel_god",
    animationFidelity: "rotation-derived",
    defaultFighter: {
      name: "Pixel God",
      fruitId: "shadow",
      combatStyle: "striker",
      appearance: {
        hairStyle: "pixel_crown",
        clothingStyle: "pixel_god",
        hairColor: "#f4c542",
        skinTone: "#d8a17c",
        outfitPrimary: "#111827",
        outfitSecondary: "#ffd166",
        accessoryColor: "#72ddf7"
      }
    }
  },
  {
    id: "prismbot-pixel-god",
    displayName: "PrismBot Pixel God",
    rosterClass: "humanoid",
    sourceVariantId: "prismbot-pixel-god",
    templateFamilyId: "buddy-core",
    spriteKey: "prismcade_prismbot_pixel_god",
    animationFidelity: "rotation-derived",
    defaultFighter: {
      name: "PrismBot",
      fruitId: "volt",
      combatStyle: "guardian",
      appearance: {
        hairStyle: "robot_glow",
        clothingStyle: "prismbot_armor",
        hairColor: "#72ddf7",
        skinTone: "#adb5bd",
        outfitPrimary: "#26344f",
        outfitSecondary: "#06d6a0",
        accessoryColor: "#ffd166"
      }
    }
  }
];

export const PRISMCADE_SPRITE_KEYS = PRISMCADE_PLAYABLE_ROSTER.map((character) => character.spriteKey);

export const PRISMCADE_BODY_NAMES = Object.fromEntries(
  PRISMCADE_PLAYABLE_ROSTER.map((character) => [character.spriteKey, character.displayName])
);

export const PRISMCADE_HAIR_STYLES = [
  "normal_hair",
  "low_taper",
  "antenna_nubs",
  "pixel_crown",
  "robot_glow"
];

export const PRISMCADE_CLOTHING_STYLES = [
  "blue_hoodie",
  "arcade_jacket",
  "buddy_shell",
  "pixel_god",
  "prismbot_armor"
];

export const PRISMCADE_ROSTER_PRESETS = PRISMCADE_PLAYABLE_ROSTER.map((character) => ({
  ...character.defaultFighter.appearance
}));

export function prismcadeRosterGuest(slot = 0) {
  const character = PRISMCADE_PLAYABLE_ROSTER[slot % PRISMCADE_PLAYABLE_ROSTER.length];
  return {
    device: "cpu",
    name: character.defaultFighter.name,
    sprite_key: character.spriteKey,
    combat_style: character.defaultFighter.combatStyle,
    fruitId: character.defaultFighter.fruitId,
    appearance: { ...character.defaultFighter.appearance },
    prismcadeSource: character.id
  };
}

export function prismcadeCharacterBySpriteKey(spriteKey) {
  return PRISMCADE_PLAYABLE_ROSTER.find((character) => character.spriteKey === spriteKey) || null;
}
